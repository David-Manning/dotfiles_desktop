
-- R syntax check script

-- Function to run R parse check
local function r_check_syntax()
  local current_file = vim.fn.expand('%:p')
  if vim.fn.empty(current_file) == 1 or vim.bo.filetype ~= 'r' then
    return
  end
  
  -- R script that captures parse errors properly
  local r_script = string.format([[
    # Redirect stderr to stdout to capture error details
    sink(stderr(), type = "message")
    
    tryCatch({
      # Use parse to check syntax
      parse(file = '%s')
      cat("SYNTAX_OK\n")
    }, error = function(e) {
      # Extract the error message
      full_msg <- conditionMessage(e)
      
      # Parse errors typically have format: "Error in parse(...) : <file>:<line>:<col>: <message>"
      # Try to extract line and column information
      if (grepl("^.*:([0-9]+):([0-9]+):", full_msg)) {
        # Extract line and column numbers
        matches <- regmatches(full_msg, regexec(":([0-9]+):([0-9]+):", full_msg))%s
        if (length(matches) >= 3) {
          line_num <- matches[2]
          col_num <- matches[3]
          # Get the actual error message (after the location info)
          error_msg <- sub("^.*:[0-9]+:[0-9]+: ", "", full_msg)
          cat(sprintf("Syntax error at line %%s, column %%s\n", line_num, col_num))
          cat(error_msg, "\n")
        } else {
          # Fallback if pattern doesn't match
          cat(full_msg, "\n")
        }
      } else {
        # Handle other parse error formats
        cat(full_msg, "\n")
      }
      quit(status = 1)
    })
  ]], current_file:gsub("'", "\\'"), "[[1]]")  -- Pass [[1]] as a separate format argument
  
  -- Build command
  local cmd = {'Rscript', '--slave', '-e', r_script}
  
  local output_lines = {}
  
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            if line == "SYNTAX_OK" then
              -- Syntax is fine, could optionally notify
              vim.schedule(function()
                -- Silent success, or use this for feedback:
                vim.notify("R syntax OK", vim.log.levels.INFO, {timeout = 500})
              end)
            else
              table.insert(output_lines, line)
            end
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      -- Capture stderr as well
      if data then
        for _, line in ipairs(data) do
          if line ~= "" and not line:match("^Loading") then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      vim.schedule(function()
        if exit_code == 0 then
          -- Clear any previous error messages - syntax is fine
          -- Optionally show success message
          -- vim.notify("R syntax OK", vim.log.levels.INFO, {timeout = 500})
        else
          -- Format and display error message
          if #output_lines > 0 then
            local error_msg = table.concat(output_lines, "\n")
            vim.notify(error_msg, vim.log.levels.ERROR)
            
            -- Optional: Jump to error location if we can parse it
            for _, line in ipairs(output_lines) do
              local line_num = line:match("line (%d+)")
              local col_num = line:match("column (%d+)")
              if line_num then
                -- Move cursor to error location
                vim.api.nvim_win_set_cursor(0, {tonumber(line_num), col_num and tonumber(col_num) - 1 or 0})
                break
              end
            end
          else
            vim.notify("R syntax error (check file for details)", vim.log.levels.ERROR)
          end
        end
      end)
    end
  })
end

-- Set up autocmd to run on save for R files
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.R", "*.r"},
  callback = function()
    r_check_syntax()
  end,
  group = vim.api.nvim_create_augroup("RSyntaxCheck", { clear = true })
})

-- Optional: Create a command to manually trigger the check
vim.api.nvim_create_user_command('RCheckSyntax', r_check_syntax, {})

-- Export the function (in case you want to call it from elsewhere)
return {
  check_syntax = r_check_syntax
}
