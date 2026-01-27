-- Python syntax check script

local function get_python_executable()
    if vim.fn.has('win32') == 1 then
        return 'python'
    else
        return 'python3'
    end
end

-- Function to run Python syntax check
local function python_check_syntax()
    local current_file = vim.fn.expand('%:p')
    if vim.fn.empty(current_file) == 1 or vim.bo.filetype ~= 'python' then
        return
    end
    
    -- Write the Python script to a temp file (avoids shell quoting issues on Windows)
    local tmp_script = os.tmpname()
    local f = io.open(tmp_script, 'w')
    if not f then
        vim.notify("Failed to create temp file", vim.log.levels.ERROR)
        return
    end
    
    f:write(string.format([[
import sys

try:
    with open(r"%s", "r", encoding="utf-8") as f:
        source = f.read()
    
    compile(source, r"%s", "exec")
    print("SYNTAX_OK")
    
except SyntaxError as e:
    if e.lineno and e.offset:
        print(f"Syntax error at line {e.lineno}, column {e.offset}")
    elif e.lineno:
        print(f"Syntax error at line {e.lineno}")
    else:
        print("Syntax error")
    
    if e.msg:
        print(e.msg)
    
    sys.exit(1)
    
except Exception as e:
    print(f"Error reading file: {e}")
    sys.exit(1)
]], current_file, current_file))
    f:close()
    
    local cmd = {get_python_executable(), tmp_script}
    
    local output_lines = {}
    
    vim.fn.jobstart(cmd, {
        on_stdout = function(_, data, _)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(output_lines, line)
                    end
                end
            end
        end,
        on_stderr = function(_, data, _)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(output_lines, line)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code, _)
            os.remove(tmp_script)
            vim.schedule(function()
                if exit_code == 0 and #output_lines > 0 and output_lines[1] == "SYNTAX_OK" then
                    vim.notify("Python syntax OK", vim.log.levels.INFO, {timeout = 500})
                else
                    if #output_lines > 0 then
                        local error_msg = ""
                        
                        for _, line in ipairs(output_lines) do
                            if line:match("Syntax error") then
                                error_msg = line
                                break
                            end
                        end
                        
                        for i, line in ipairs(output_lines) do
                            if line:match("Syntax error") and i < #output_lines then
                                local next_line = output_lines[i + 1]
                                if next_line and next_line ~= "" then
                                    if error_msg ~= "" then
                                        error_msg = error_msg .. "\n" .. next_line
                                    else
                                        error_msg = next_line
                                    end
                                end
                                break
                            end
                        end
                        
                        if error_msg == "" then
                            for _, line in ipairs(output_lines) do
                                if line ~= "" and line ~= "SYNTAX_OK" then
                                    error_msg = line
                                    break
                                end
                            end
                        end
                        
                        if error_msg ~= "" then
                            vim.notify(error_msg, vim.log.levels.ERROR)
                        else
                            vim.notify("Python syntax error (check file for details)", vim.log.levels.ERROR)
                        end
                    else
                        vim.notify("Python syntax error", vim.log.levels.ERROR)
                    end
                end
            end)
        end
    })
end

-- Set up autocmd to run on save
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.py",
    callback = function()
        python_check_syntax()
    end,
    group = vim.api.nvim_create_augroup("PythonSyntaxCheck", { clear = true })
})

-- Export the function (in case you want to call it manually)
return {
    check_syntax = python_check_syntax
}
