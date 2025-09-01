
-- YAML/YML syntax check script

-- Function to parse YAML and find errors
local function parse_yaml_with_errors(content)
  local lines = vim.split(content, '\n', {plain = true})
  local line_num = 1
  local errors = {}
  
  -- Track indentation levels
  local indent_stack = {0}
  
  -- Check if line is a comment or empty
  local function is_comment_or_empty(line)
    return line:match('^%s*#') or line:match('^%s*$')
  end
  
  -- Get indentation level of a line
  local function get_indent(line)
    local spaces = line:match('^( *)')
    return #spaces
  end
  
  -- Check if line is a document separator
  local function is_document_separator(line)
    return line:match('^%-%-%-') or line:match('^%.%.%.')
  end
  
  -- Check for tab characters (YAML doesn't allow tabs for indentation)
  local function check_for_tabs(line, line_num)
    if line:match('\t') then
      local col = line:find('\t')
      return false, string.format("Tab character found at line %d, column %d (use spaces for indentation)", line_num, col)
    end
    return true
  end
  
  -- Main parsing loop
  for _, line in ipairs(lines) do
    -- Check for tabs
    local success, err = check_for_tabs(line, line_num)
    if not success then
      table.insert(errors, err)
    end
    
    -- Skip empty lines, comments, and document separators
    if not is_comment_or_empty(line) and not is_document_separator(line) then
      local indent = get_indent(line)
      local content = line:sub(indent + 1)
      
      -- Check indentation consistency
      if #indent_stack > 0 then
        local last_indent = indent_stack[#indent_stack]
        if indent > last_indent then
          table.insert(indent_stack, indent)
        elseif indent < last_indent then
          -- Dedenting - should match a previous level
          while #indent_stack > 1 and indent_stack[#indent_stack] > indent do
            table.remove(indent_stack)
          end
          if indent_stack[#indent_stack] ~= indent then
            table.insert(errors, string.format("Inconsistent indentation at line %d (doesn't match any previous level)", line_num))
          end
        end
      end
      
      -- Basic structure checks
      if content ~= '' then
        -- Check for colons without proper structure
        if content:match('^:') then
          table.insert(errors, string.format("Line %d starts with colon", line_num))
        end
        
        -- Check for multiple colons (common error)
        local _, colon_count = content:gsub(':', ':')
        if colon_count > 1 and not content:match('^["\']') then
          -- Check if it's not a quoted string
          local in_quotes = false
          local quote_char = nil
          for i = 1, #content do
            local char = content:sub(i, i)
            if not in_quotes and (char == '"' or char == "'") then
              in_quotes = true
              quote_char = char
            elseif in_quotes and char == quote_char then
              in_quotes = false
            elseif not in_quotes and char == ':' then
              if content:sub(i-1, i-1) ~= '\\' then
                local after = content:sub(i+1, i+2)
                if after ~= '//' and not after:match('^%s*$') and not after:match('^%s+') then
                  table.insert(errors, string.format("Missing space after colon at line %d", line_num))
                  break
                end
              end
            end
          end
        end
        
        -- Check for unclosed quotes
        local single_quotes = 0
        local double_quotes = 0
        local escaped = false
        for i = 1, #content do
          local char = content:sub(i, i)
          if not escaped then
            if char == "'" then single_quotes = single_quotes + 1
            elseif char == '"' then double_quotes = double_quotes + 1
            elseif char == '\\' then escaped = true
            end
          else
            escaped = false
          end
        end
        if single_quotes % 2 ~= 0 then
          table.insert(errors, string.format("Unclosed single quote at line %d", line_num))
        end
        if double_quotes % 2 ~= 0 then
          table.insert(errors, string.format("Unclosed double quote at line %d", line_num))
        end
        
        -- Check for invalid list marker
        if content:match('^%-%s*$') then
          table.insert(errors, string.format("Empty list item at line %d", line_num))
        elseif content:match('^%-[^%s]') then
          table.insert(errors, string.format("Missing space after list marker '-' at line %d", line_num))
        end
      end
    end
    
    line_num = line_num + 1
  end
  
  if #errors > 0 then
    return false, errors[1]  -- Return first error
  end
  
  return true
end

-- Function to run YAML syntax check
local function yaml_check_syntax()
  local current_file = vim.fn.expand('%:p')
  local filetype = vim.bo.filetype
  
  if vim.fn.empty(current_file) == 1 or not (filetype == 'yaml' or filetype == 'yml') then
    return
  end
  
  -- Read file content
  local content = table.concat(vim.fn.readfile(current_file), '\n')
  
  if content == '' then
    vim.notify("YAML syntax OK", vim.log.levels.INFO, {timeout = 500})
    return
  end
  
  local success, error_msg = parse_yaml_with_errors(content)
  
  if success then
    vim.notify("YAML syntax OK", vim.log.levels.INFO, {timeout = 500})
  else
    vim.notify(error_msg, vim.log.levels.ERROR)
  end
end

-- Set up autocmd to run on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.yaml", "*.yml"},
  callback = function()
    yaml_check_syntax()
  end,
  group = vim.api.nvim_create_augroup("YamlSyntaxCheck", { clear = true })
})

-- Export the function (in case you want to call it manually)
return {
  check_syntax = yaml_check_syntax
}
