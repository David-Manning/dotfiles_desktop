-- RStan syntax check script

-- Function to run RStan syntax check
local function rstan_check_syntax()
  local current_file = vim.fn.expand('%:p')
  if vim.fn.empty(current_file) == 1 or vim.bo.filetype ~= 'stan' then
    return
  end
  
  
  -- R script that captures stanc errors properly
  local r_script = string.format([[
    suppressPackageStartupMessages(library(rstan))
    
    # Redirect stderr to stdout to capture error details
    sink(stderr(), type = "message")
    
    tryCatch({
      result <- stanc('%s')
      cat("SYNTAX_OK\n")
    }, error = function(e) {
      # The actual detailed error is in the message
      full_msg <- conditionMessage(e)
      
      # Split by newlines and output each line
      lines <- strsplit(full_msg, "\n")%s
      
      # Skip the first line that just says "0"
      for (i in seq_along(lines)) {
        line <- lines[i]
        # Skip the "0" line but keep everything else
        if (i == 1 && trimws(line) == "0") {
          next
        }
        if (nchar(trimws(line)) > 0) {
          cat(line, "\n")
        }
      }
      quit(status = 1)
    })
  ]], current_file:gsub("'", "\\'"), "[[1]]")  -- Pass [[1]] as a separate format argument
  -- Build command
  local cmd = {'Rscript', '--slave', '-e', r_script}
  
  local output_lines = {}
  local capturing_error = false
  
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            if line == "SYNTAX_OK" then
              -- Syntax is fine, ignore
            else
              table.insert(output_lines, line)
              -- Start capturing after we see an error indicator
              if line:match("Syntax error") or line:match("Semantic error") or line:match("parsing error") then
                capturing_error = true
              end
            end
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      -- Capture stderr as well since R might output there
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
          -- Clear the checking message - syntax is fine
          vim.notify("Stan syntax OK", vim.log.levels.INFO, {timeout = 500})
        else
          -- Format error message
          if #output_lines > 0 then
            -- Find the main error line (Syntax error or Semantic error)
            local main_error = ""
            local line_info = ""
            
            for _, line in ipairs(output_lines) do
              if line:match("Syntax error") or line:match("Semantic error") then
                -- Extract the error type and location
                local error_type = line:match("^(%w+ error)")
                local line_num = line:match("line (%d+)")
                local col_num = line:match("column (%d+)")
                
                if error_type and line_num then
                  main_error = string.format("%s at line %s", error_type, line_num)
                  if col_num then
                    main_error = main_error .. ", column " .. col_num
                  end
                end
                break
              end
            end
            
            -- Find the explanation (last line usually)
            local explanation = ""
            for i = #output_lines, 1, -1 do
              local line = output_lines[i]
              if line ~= "" and not line:match("^%-%-%-") and not line:match("^%s*%^") and not line:match("^%s*%d+:") then
                explanation = line
                break
              end
            end
            
            -- Combine the message
            local error_msg = main_error
            if explanation ~= "" and explanation ~= main_error then
              error_msg = error_msg .. "\n" .. explanation
            end
            
            if error_msg == "" then
              -- Fallback to showing all output if we couldn't parse it
              error_msg = table.concat(output_lines, "\n")
            end
            
            vim.notify(error_msg, vim.log.levels.ERROR)
          else
            vim.notify("Stan syntax error (check file for details)", vim.log.levels.ERROR)
          end
        end
      end)
    end
  })
end

-- Set up autocmd to run on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.stan",
  callback = function()
    rstan_check_syntax()
  end,
  group = vim.api.nvim_create_augroup("StanSyntaxCheck", { clear = true })
})

-- Export the function (in case you want to call it manually)
return {
  check_syntax = rstan_check_syntax
}
