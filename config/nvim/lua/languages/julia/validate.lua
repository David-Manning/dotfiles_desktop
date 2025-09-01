
-- Julia syntax check script

-- Function to run Julia syntax check
local function julia_check_syntax()
  local current_file = vim.fn.expand('%:p')
  if vim.fn.empty(current_file) == 1 or vim.bo.filetype ~= 'julia' then
    return
  end
  
  -- Julia script that parses the file to check syntax
  local julia_script = string.format([[
    try
        # Read and parse the file
        content = read("%s", String)
        
        # Try to parse as Julia code
        Meta.parse(string("begin\n", content, "\nend"))
        
        println("SYNTAX_OK")
        exit(0)
    catch e
        if isa(e, Meta.ParseError)
            # Convert error to string and extract the clean message
            error_str = string(e)
            
            # Extract line and column from "Error @ filename:line:col" pattern
            m = match(r"Error @ \S+:(\d+):(\d+)", error_str)
            if m !== nothing
                line_num = m.captures[1]
                col_num = m.captures[2]
                
                # Extract the error message after the └── characters
                lines = split(error_str, '\n')
                error_msg = ""
                for line in lines
                    msg_match = match(r"[└─]+\s*(.+)", line)
                    if msg_match !== nothing
                        error_msg = msg_match.captures[1]
                        break
                    end
                end
                
                # Clean up the message - remove everything after the quote
                if occursin("\"", error_msg)
                    error_msg = split(error_msg, "\"")[1]
                end
                
                if error_msg == ""
                    error_msg = "Syntax error"
                end
                
                println("Line $line_num, column $col_num: $error_msg")
            else
                # Simple fallback
                println("Syntax error in Julia code")
            end
            exit(1)
        else
            # Other errors
            println("Error reading file")
            exit(1)
        end
    end
  ]], current_file:gsub("\\", "\\\\"):gsub('"', '\\"'))
  
  -- Build command
  local cmd = {'julia', '-e', julia_script}
  
  local output_lines = {}
  local has_output = false
  
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            -- Only capture the first clean line
            if not has_output and not line:match("Base%.") and not line:match("JuliaSyntax%.") then
              table.insert(output_lines, line)
              has_output = true
            elseif line == "SYNTAX_OK" then
              output_lines = {"SYNTAX_OK"}
              has_output = true
            end
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      -- Ignore stderr to avoid the verbose output
    end,
    on_exit = function(_, exit_code, _)
      vim.schedule(function()
        if exit_code == 0 and #output_lines > 0 and output_lines[1] == "SYNTAX_OK" then
          -- Syntax is fine
          vim.notify("Julia syntax OK", vim.log.levels.INFO, {timeout = 500})
        else
          -- Display error message
          if #output_lines > 0 then
            local error_msg = output_lines[1]
            vim.notify(error_msg, vim.log.levels.ERROR)
          else
            vim.notify("Julia syntax error", vim.log.levels.ERROR)
          end
        end
      end)
    end
  })
end

-- Set up autocmd to run on save for Julia files
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.jl"},
  callback = function()
    julia_check_syntax()
  end,
  group = vim.api.nvim_create_augroup("JuliaSyntaxCheck", { clear = true })
})

-- Optional: Create a command to manually trigger the check
vim.api.nvim_create_user_command('JuliaCheckSyntax', julia_check_syntax, {})

-- Export the function (in case you want to call it from elsewhere)
return {
  check_syntax = julia_check_syntax
}
