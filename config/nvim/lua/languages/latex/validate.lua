
-- LaTeX syntax check script

-- Function to clean up and recognise common LaTeX errors
local function clean_error_message(msg)
  -- Remove common suffixes first
  msg = msg:gsub("%. See the LaTeX.*", "")
  msg = msg:gsub(" See the LaTeX.*", "")
  msg = msg:gsub("%.+$", "")
  
  -- Map common truncated/known errors to clean messages
  local error_patterns = {
    -- Math environment errors
    ["[Bb]ad math environ"] = "bad math environment delimiter",
    ["[Mm]ath environment"] = "bad math environment delimiter",
    
    -- Undefined control sequence
    ["[Uu]ndefined control sequence"] = "undefined control sequence",
    
    -- Missing $ inserted
    ["[Mm]issing %$ inserted"] = "missing $ inserted",
    ["[Mm]issing %$"] = "missing $ inserted",
    
    -- Missing \begin or \end
    ["[Mm]issing \\begin"] = "missing \\begin{document}",
    ["[Nn]o \\begin.*document"] = "missing \\begin{document}",
    ["\\end.*document.*ended"] = "\\end{document} ended by",
    
    -- Environment errors
    ["[Ee]nvironment .* undefined"] = function(m) 
      local env = m:match("nvironment (.-) undefined")
      return env and ("environment '" .. env .. "' undefined") or "environment undefined"
    end,
    
    -- Package errors
    ["[Ff]ile .* not found"] = function(m)
      local file = m:match("ile [`'](.-)[''] not found")
      return file and ("file/package '" .. file .. "' not found") or "file/package not found"
    end,
    
    -- Missing } or ]
    ["[Mm]issing %} inserted"] = "missing } inserted",
    ["[Mm]issing %]"] = "missing ] inserted",
    
    -- Too many }'s
    ["[Tt]oo many %}'s"] = "too many }'s",
    
    -- Display math errors
    ["[Dd]isplay math should end with %$%$"] = "display math should end with $$",
    
    -- Missing number
    ["[Mm]issing number"] = "missing number, treated as zero",
    
    -- Illegal unit
    ["[Ii]llegal unit"] = "illegal unit of measure",
    
    -- Runaway argument
    ["[Rr]unaway argument"] = "runaway argument",
    
    -- Extra alignment tab
    ["[Ee]xtra alignment tab"] = "extra alignment tab has been changed to \\cr",
    
    -- Misplaced alignment tab
    ["[Mm]isplaced alignment tab"] = "misplaced alignment tab character &",
  }
  
  -- Try to match against known patterns
  for pattern, replacement in pairs(error_patterns) do
    if msg:match(pattern) then
      if type(replacement) == "function" then
        return replacement(msg)
      else
        return replacement
      end
    end
  end
  
  -- If no pattern matched, clean up common issues
  msg = msg:gsub("environ ment", "environment")
  msg = msg:gsub("docu ment", "document")
  
  -- Make lowercase and clean
  msg = msg:sub(1,1):lower() .. msg:sub(2)
  
  return msg
end

-- Function to run LaTeX syntax check
local function latex_check_syntax()
  local current_file = vim.fn.expand('%:p')
  if vim.fn.empty(current_file) == 1 or (vim.bo.filetype ~= 'tex' and vim.bo.filetype ~= 'latex') then
    return
  end
  
  -- Get the directory of the current file (for handling includes/inputs)
  local file_dir = vim.fn.fnamemodify(current_file, ':h')
  
  -- Use pdflatex in nonstopmode and draftmode for fast checking
  local cmd = {
    'pdflatex',
    '-interaction=nonstopmode',
    '-draftmode',
    '-file-line-error',
    '-halt-on-error',
    '-output-directory=' .. file_dir,
    current_file
  }
  
  -- Alternative: use lualatex if preferred
  -- local cmd = {
  --   'lualatex',
  --   '-interaction=nonstopmode',
  --   '-draftmode',
  --   '-file-line-error',
  --   '-halt-on-error',
  --   '-output-directory=' .. file_dir,
  --   current_file
  -- }
  
  local output_lines = {}
  local error_found = false
  local error_details = {}
  local current_error = nil
  
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output_lines, line)
            
            -- Check for file:line:error format
            local file, line_num, error_msg = line:match("([^:]+):(%d+): (.+)")
            if file and line_num and error_msg then
              error_found = true
              
              -- Clean up the error message - extract just the core error
              local clean_msg = error_msg:match("^LaTeX Error: (.+)") or error_msg
              
              current_error = {
                file = file,
                line = line_num,
                message = clean_msg,
                problem_line = nil
              }
              table.insert(error_details, current_error)
            end
            
            -- Capture lines starting with ! (alternative error format)
            if line:match("^! (.+)") then
              error_found = true
              local err_msg = line:match("^! (.+)")
              
              if not current_error then
                current_error = {
                  file = current_file,
                  line = "?",
                  message = err_msg,
                  problem_line = nil
                }
                table.insert(error_details, current_error)
              end
            end
            
            -- Capture the line number and problematic content from l.XXX format
            local line_indicator, line_content = line:match("^l%.(%d+)%s*(.*)")
            if line_indicator then
              if current_error then
                if current_error.line == "?" then
                  current_error.line = line_indicator
                end
                -- Capture the problematic LaTeX command if present
                if line_content and line_content ~= "" then
                  -- Clean it up - just get the command, not everything
                  local cmd_match = line_content:match("(\\%S+)") or line_content:match("^(%S+)")
                  if cmd_match then
                    current_error.problem_line = cmd_match
                  end
                end
              end
            end
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      -- Also capture stderr for some LaTeX distributions
      if data then
        for _, line in ipairs(data) do
          if line ~= "" and not line:match("^This is") and not line:match("^entering extended mode") then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      vim.schedule(function()
        if exit_code == 0 then
          -- LaTeX compiled successfully
          vim.notify("LaTeX syntax OK", vim.log.levels.INFO, {timeout = 500})
        else
          -- Format error message
          if #error_details > 0 then
            -- Get the first error (usually the most relevant)
            local first_error = error_details[1]
            local error_msg = ""
            
            -- Format the main error message with line number
            if first_error.line ~= "?" then
              error_msg = string.format("LaTeX error at line %s", first_error.line)
            else
              error_msg = "LaTeX error"
            end
            
            -- Add the error description
            if first_error.message then
              local clean_msg = clean_error_message(first_error.message)
              error_msg = error_msg .. "\n" .. clean_msg
            end
            
            -- Add the problematic command if we captured it
            if first_error.problem_line then
              error_msg = error_msg .. "\nProblem: " .. first_error.problem_line
            end
            
            vim.notify(error_msg, vim.log.levels.ERROR)
          else
            -- Simple fallback
            local error_msg = "LaTeX compilation error"
            
            for _, line in ipairs(output_lines) do
              if line:match("^! ") then
                local err = line:gsub("^! ", "")
                error_msg = error_msg .. "\n" .. err
                break
              end
            end
            
            vim.notify(error_msg, vim.log.levels.ERROR)
          end
        end
      end)
    end
  })
end

-- Optional: Function to check with chktex (LaTeX linter)
local function latex_lint()
  local current_file = vim.fn.expand('%:p')
  if vim.fn.empty(current_file) == 1 or (vim.bo.filetype ~= 'tex' and vim.bo.filetype ~= 'latex') then
    return
  end
  
  -- Run chktex for additional warnings
  local cmd = {'chktex', '-q', '-v0', current_file}
  
  local warnings = {}
  
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          -- chktex output format: file.tex:line:column:warning_number:warning_message
          local line_num, col_num, warn_msg = line:match(":(%d+):(%d+):%d+:(.+)")
          if line_num and warn_msg then
            table.insert(warnings, {
              line = line_num,
              column = col_num,
              message = warn_msg
            })
          end
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      vim.schedule(function()
        if #warnings > 0 then
          local warn_msg = string.format("LaTeX: %d warning(s) found", #warnings)
          if warnings[1] then
            warn_msg = warn_msg .. string.format("\nLine %s: %s", warnings[1].line, warnings[1].message)
          end
          vim.notify(warn_msg, vim.log.levels.WARN)
        end
      end)
    end
  })
end

-- Set up autocmd to run on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.tex", "*.latex"},
  callback = function()
    latex_check_syntax()
    -- Optionally also run the linter (comment out if not wanted)
    -- vim.defer_fn(latex_lint, 100)
  end,
  group = vim.api.nvim_create_augroup("LaTeXSyntaxCheck", { clear = true })
})

-- Export the functions
return {
  check_syntax = latex_check_syntax,
  lint = latex_lint
}
