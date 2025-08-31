
-- JSON/JSONC syntax check script

-- Function to parse JSON and find errors
local function parse_json_with_errors(content, is_jsonc)
  local pos = 1
  local len = #content
  
  -- Skip whitespace
  local function skip_whitespace()
    while pos <= len do
      local char = content:sub(pos, pos)
      if char:match('%s') then
        pos = pos + 1
      else
        break
      end
    end
  end
  
  -- Skip single-line comment (only for JSONC)
  local function skip_line_comment()
    if pos + 1 <= len and content:sub(pos, pos + 1) == '//' then
      if not is_jsonc then
        return false, "Comments are not allowed in JSON"
      end
      pos = pos + 2
      while pos <= len and content:sub(pos, pos) ~= '\n' do
        pos = pos + 1
      end
      return true
    end
    return false
  end
  
  -- Skip block comment (only for JSONC)
  local function skip_block_comment()
    if pos + 1 <= len and content:sub(pos, pos + 1) == '/*' then
      if not is_jsonc then
        return false, "Comments are not allowed in JSON"
      end
      pos = pos + 2
      while pos + 1 <= len do
        if content:sub(pos, pos + 1) == '*/' then
          pos = pos + 2
          return true
        end
        pos = pos + 1
      end
      -- Unterminated block comment
      return false, "Unterminated block comment"
    end
    return false
  end
  
  -- Enhanced skip whitespace and comments
  local function skip_whitespace_and_comments()
    while pos <= len do
      -- Skip whitespace
      if content:sub(pos, pos):match('%s') then
        pos = pos + 1
      -- Try to skip comments
      elseif pos + 1 <= len and content:sub(pos, pos + 1) == '//' then
        local skipped, err = skip_line_comment()
        if err then
          return nil, err
        elseif not skipped then
          break
        end
      elseif pos + 1 <= len and content:sub(pos, pos + 1) == '/*' then
        local skipped, err = skip_block_comment()
        if err then
          return nil, err
        elseif not skipped then
          break
        end
      else
        break
      end
    end
    return true
  end
  
  -- Get line and column from position
  local function get_line_col(p)
    local line = 1
    local col = 1
    for i = 1, p - 1 do
      if content:sub(i, i) == '\n' then
        line = line + 1
        col = 1
      else
        col = col + 1
      end
    end
    return line, col
  end
  
  -- Parse string
  local function parse_string()
    if content:sub(pos, pos) ~= '"' then
      return nil, "Expected string"
    end
    pos = pos + 1
    
    while pos <= len do
      local char = content:sub(pos, pos)
      if char == '"' then
        pos = pos + 1
        return true
      elseif char == '\\' then
        pos = pos + 2 -- Skip escaped character
        if pos > len then
          return nil, "Unterminated string escape"
        end
      else
        pos = pos + 1
      end
    end
    
    return nil, "Unterminated string"
  end
  
  -- Parse number
  local function parse_number()
    local start_pos = pos
    
    -- Optional minus
    if content:sub(pos, pos) == '-' then
      pos = pos + 1
    end
    
    -- Must have at least one digit
    if pos > len or not content:sub(pos, pos):match('%d') then
      return nil, "Invalid number"
    end
    
    -- Integer part
    if content:sub(pos, pos) == '0' then
      pos = pos + 1
    else
      while pos <= len and content:sub(pos, pos):match('%d') do
        pos = pos + 1
      end
    end
    
    -- Fractional part
    if pos <= len and content:sub(pos, pos) == '.' then
      pos = pos + 1
      if pos > len or not content:sub(pos, pos):match('%d') then
        return nil, "Invalid number: missing digits after decimal"
      end
      while pos <= len and content:sub(pos, pos):match('%d') do
        pos = pos + 1
      end
    end
    
    -- Exponent part
    if pos <= len and content:sub(pos, pos):match('[eE]') then
      pos = pos + 1
      if pos <= len and content:sub(pos, pos):match('[%+%-]') then
        pos = pos + 1
      end
      if pos > len or not content:sub(pos, pos):match('%d') then
        return nil, "Invalid number: missing digits in exponent"
      end
      while pos <= len and content:sub(pos, pos):match('%d') do
        pos = pos + 1
      end
    end
    
    return true
  end
  
  local parse_value -- Forward declaration
  
  -- Parse array
  local function parse_array()
    if content:sub(pos, pos) ~= '[' then
      return nil, "Expected array"
    end
    pos = pos + 1
    
    local success, err = skip_whitespace_and_comments()
    if not success then
      return nil, err
    end
    
    -- Empty array
    if pos <= len and content:sub(pos, pos) == ']' then
      pos = pos + 1
      return true
    end
    
    -- Parse values
    while pos <= len do
      success, err = parse_value()
      if not success then
        return nil, err
      end
      
      success, err = skip_whitespace_and_comments()
      if not success then
        return nil, err
      end
      
      if pos > len then
        return nil, "Unterminated array"
      end
      
      local char = content:sub(pos, pos)
      if char == ']' then
        pos = pos + 1
        return true
      elseif char == ',' then
        pos = pos + 1
        success, err = skip_whitespace_and_comments()
        if not success then
          return nil, err
        end
        -- Check for trailing comma
        if pos <= len and content:sub(pos, pos) == ']' then
          -- Allow trailing comma only in JSONC
          if not is_jsonc then
            return nil, "Trailing commas are not allowed in JSON"
          end
          pos = pos + 1
          return true
        end
      else
        return nil, "Expected ',' or ']' in array"
      end
    end
    
    return nil, "Unterminated array"
  end
  
  -- Parse object
  local function parse_object()
    if content:sub(pos, pos) ~= '{' then
      return nil, "Expected object"
    end
    pos = pos + 1
    
    local success, err = skip_whitespace_and_comments()
    if not success then
      return nil, err
    end
    
    -- Empty object
    if pos <= len and content:sub(pos, pos) == '}' then
      pos = pos + 1
      return true
    end
    
    -- Parse key-value pairs
    while pos <= len do
      -- Parse key (must be string)
      success, err = parse_string()
      if not success then
        return nil, "Expected string key: " .. (err or "")
      end
      
      success, err = skip_whitespace_and_comments()
      if not success then
        return nil, err
      end
      
      if pos > len or content:sub(pos, pos) ~= ':' then
        return nil, "Expected ':' after object key"
      end
      pos = pos + 1
      
      success, err = skip_whitespace_and_comments()
      if not success then
        return nil, err
      end
      
      -- Parse value
      success, err = parse_value()
      if not success then
        return nil, err
      end
      
      success, err = skip_whitespace_and_comments()
      if not success then
        return nil, err
      end
      
      if pos > len then
        return nil, "Unterminated object"
      end
      
      local char = content:sub(pos, pos)
      if char == '}' then
        pos = pos + 1
        return true
      elseif char == ',' then
        pos = pos + 1
        success, err = skip_whitespace_and_comments()
        if not success then
          return nil, err
        end
        -- Check for trailing comma
        if pos <= len and content:sub(pos, pos) == '}' then
          -- Allow trailing comma only in JSONC
          if not is_jsonc then
            return nil, "Trailing commas are not allowed in JSON"
          end
          pos = pos + 1
          return true
        end
      else
        return nil, "Expected ',' or '}' in object"
      end
    end
    
    return nil, "Unterminated object"
  end
  
  -- Parse value
  parse_value = function()
    local success, err = skip_whitespace_and_comments()
    if not success then
      return nil, err
    end
    
    if pos > len then
      return nil, "Unexpected end of input"
    end
    
    local char = content:sub(pos, pos)
    
    if char == '"' then
      return parse_string()
    elseif char:match('[%d%-]') then
      return parse_number()
    elseif char == '[' then
      return parse_array()
    elseif char == '{' then
      return parse_object()
    elseif content:sub(pos, pos + 3) == 'true' then
      pos = pos + 4
      return true
    elseif content:sub(pos, pos + 4) == 'false' then
      pos = pos + 5
      return true
    elseif content:sub(pos, pos + 3) == 'null' then
      pos = pos + 4
      return true
    else
      return nil, "Unexpected character: '" .. char .. "'"
    end
  end
  
  -- Parse the JSON
  local success, err = parse_value()
  if not success then
    local line, col = get_line_col(pos)
    return nil, string.format("JSON syntax error at line %d, column %d: %s", line, col, err)
  end
  
  -- Check for trailing content
  success, err = skip_whitespace_and_comments()
  if not success then
    return nil, err
  end
  
  if pos <= len then
    local line, col = get_line_col(pos)
    return nil, string.format("Unexpected content after JSON at line %d, column %d", line, col)
  end
  
  return true
end

-- Function to run JSON syntax check
local function json_check_syntax()
  local current_file = vim.fn.expand('%:p')
  local filetype = vim.bo.filetype
  
  if vim.fn.empty(current_file) == 1 or not (filetype == 'json' or filetype == 'jsonc') then
    return
  end
  
  -- Determine if it's JSONC
  local is_jsonc = filetype == 'jsonc'
  
  -- Read file content
  local content = table.concat(vim.fn.readfile(current_file), '\n')
  
  if content == '' then
    vim.notify("JSON syntax OK", vim.log.levels.INFO, {timeout = 500})
    return
  end
  
  local success, error_msg = parse_json_with_errors(content, is_jsonc)
  
  if success then
    vim.notify("JSON syntax OK", vim.log.levels.INFO, {timeout = 500})
  else
    vim.notify(error_msg, vim.log.levels.ERROR)
  end
end

-- Set up autocmd to run on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.json", "*.jsonc"},
  callback = function()
    json_check_syntax()
  end,
  group = vim.api.nvim_create_augroup("JsonSyntaxCheck", { clear = true })
})

-- Export the function (in case you want to call it manually)
return {
  check_syntax = json_check_syntax
}
