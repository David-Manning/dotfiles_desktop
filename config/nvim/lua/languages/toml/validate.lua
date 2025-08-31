
-- TOML syntax check script

-- Function to parse TOML and find errors
local function parse_toml_with_errors(content)
  local lines = vim.split(content, '\n', {plain = true})
  local line_num = 1
  local current_table = nil
  local defined_tables = {}
  local defined_keys = {}
  local is_array_table = false
  
  -- Track multiline strings
  local in_multiline_string = false
  local multiline_delimiter = nil
  
  -- Check if line is a comment or empty
  local function is_comment_or_empty(line)
    return line:match('^%s*#') or line:match('^%s*$')
  end
  
  -- Remove inline comments (but not # inside strings)
  local function remove_inline_comment(line)
    local in_string = false
    local string_char = nil
    local escaped = false
    
    for i = 1, #line do
      local char = line:sub(i, i)
      
      if not in_string then
        if char == '#' then
          -- Found comment start outside of string
          return line:sub(1, i - 1)
        elseif char == '"' or char == "'" then
          in_string = true
          string_char = char
        end
      else
        if not escaped and char == string_char then
          in_string = false
          string_char = nil
        end
        escaped = (char == '\\' and not escaped)
      end
    end
    
    return line
  end
  
  -- Trim whitespace
  local function trim(str)
    return str:match('^%s*(.-)%s*$')
  end
  
  -- Check for valid TOML key
  local function validate_key(key)
    -- Bare keys: A-Za-z0-9_-
    if key:match('^[A-Za-z0-9_%-]+$') then
      return true
    end
    -- Quoted keys
    if (key:match('^".*"$') or key:match("^'.*'$")) then
      return true
    end
    -- Dotted keys
    if key:match('^[A-Za-z0-9_%-%.]+$') then
      -- Check each part
      for part in key:gmatch('[^.]+') do
        if not part:match('^[A-Za-z0-9_%-]+$') then
          return false
        end
      end
      return true
    end
    return false
  end
  
  -- Parse string value (single line strings only)
  local function parse_string(value, line_num)
    local trimmed = trim(value)
    
    -- Basic string with double quotes
    if trimmed:match('^".*"$') then
      -- Check for unescaped quotes inside
      local inner = trimmed:sub(2, -2)
      local escaped = false
      for i = 1, #inner do
        local char = inner:sub(i, i)
        if not escaped and char == '"' then
          return nil, string.format("Unescaped double quote in string at line %d", line_num)
        end
        escaped = (char == '\\' and not escaped)
      end
      return trimmed
    end
    
    -- Literal string with single quotes
    if trimmed:match("^'.*'$") then
      -- No escaping in literal strings, but check for single quotes inside
      local inner = trimmed:sub(2, -2)
      if inner:find("'") then
        return nil, string.format("Single quote not allowed in literal string at line %d", line_num)
      end
      return trimmed
    end
    
    return nil
  end
  
  -- Parse value
  local function parse_value(value, line_num)
    local trimmed = trim(value)
    
    -- Empty value
    if trimmed == '' then
      return nil, string.format("Missing value at line %d", line_num)
    end
    
    -- Boolean
    if trimmed == 'true' or trimmed == 'false' then
      return trimmed
    end
    
    -- Single-line strings
    if trimmed:match('^"[^"]*"$') or trimmed:match("^'[^']*'$") then
      return parse_string(value, line_num)
    end
    
    -- Array
    if trimmed:match('^%[') then
      if not trimmed:match('%]$') then
        return nil, string.format("Unclosed array at line %d", line_num)
      end
      -- Check for basic bracket matching
      local bracket_count = 0
      local in_string = false
      local string_char = nil
      for i = 1, #trimmed do
        local char = trimmed:sub(i, i)
        if not in_string then
          if char == '"' or char == "'" then
            in_string = true
            string_char = char
          elseif char == '[' then
            bracket_count = bracket_count + 1
          elseif char == ']' then
            bracket_count = bracket_count - 1
            if bracket_count < 0 then
              return nil, string.format("Mismatched brackets in array at line %d", line_num)
            end
          end
        elseif char == string_char and trimmed:sub(i-1, i-1) ~= '\\' then
          in_string = false
        end
      end
      if bracket_count ~= 0 then
        return nil, string.format("Mismatched brackets in array at line %d", line_num)
      end
      return trimmed
    end
    
    -- Inline table
    if trimmed:match('^{') then
      if not trimmed:match('}$') then
        return nil, string.format("Unclosed inline table at line %d", line_num)
      end
      -- Check for basic brace matching
      local brace_count = 0
      local in_string = false
      local string_char = nil
      for i = 1, #trimmed do
        local char = trimmed:sub(i, i)
        if not in_string then
          if char == '"' or char == "'" then
            in_string = true
            string_char = char
          elseif char == '{' then
            brace_count = brace_count + 1
          elseif char == '}' then
            brace_count = brace_count - 1
            if brace_count < 0 then
              return nil, string.format("Mismatched braces in inline table at line %d", line_num)
            end
          end
        elseif char == string_char and trimmed:sub(i-1, i-1) ~= '\\' then
          in_string = false
        end
      end
      if brace_count ~= 0 then
        return nil, string.format("Mismatched braces in inline table at line %d", line_num)
      end
      return trimmed
    end
    
    -- Date/Time (basic check)
    if trimmed:match('^%d%d%d%d%-%d%d%-%d%d') then
      return trimmed
    end
    
    -- Number (integer or float)
    -- Support decimal, hex, octal, binary, infinity, nan
    if trimmed:match('^[+-]?%d[%d_]*$') or                    -- Integer
       trimmed:match('^[+-]?%d[%d_]*%.%d[%d_]*$') or         -- Float
       trimmed:match('^[+-]?%d[%d_]*[eE][+-]?%d[%d_]*$') or  -- Scientific
       trimmed:match('^[+-]?%d[%d_]*%.%d[%d_]*[eE][+-]?%d[%d_]*$') or -- Float scientific
       trimmed:match('^0x[%da-fA-F][%da-fA-F_]*$') or        -- Hex
       trimmed:match('^0o[0-7][0-7_]*$') or                  -- Octal
       trimmed:match('^0b[01][01_]*$') or                    -- Binary
       trimmed:match('^[+-]?inf$') or                        -- Infinity
       trimmed:match('^[+-]?nan$') then                      -- NaN
      -- Check for invalid underscores
      if trimmed:match('__') then
        return nil, string.format("Double underscore in number at line %d", line_num)
      end
      if trimmed:match('^_') or trimmed:match('_$') then
        return nil, string.format("Leading or trailing underscore in number at line %d", line_num)
      end
      if trimmed:match('%._') or trimmed:match('_%.') then
        return nil, string.format("Underscore adjacent to decimal point at line %d", line_num)
      end
      return trimmed
    end
    
    -- Check for multiline string start (we'll handle these separately)
    if trimmed:match('^"""') or trimmed:match("^'''") then
      -- This starts a multiline string, it's valid
      return trimmed
    end
    
    -- If none of the above, it's likely an unquoted string (which is invalid for values)
    return nil, string.format("Invalid value '%s' at line %d (strings must be quoted)", trimmed, line_num)
  end
  
  -- Array table counter
  local array_table_counts = {}
  
  -- Main parsing loop
  for _, line in ipairs(lines) do
    -- Handle multiline strings
    if in_multiline_string then
      -- Check if this line ends the multiline string
      if line:find(multiline_delimiter, 1, true) then
        in_multiline_string = false
        multiline_delimiter = nil
      end
      line_num = line_num + 1
      goto continue
    end
    
    -- Remove inline comments first (unless in multiline string)
    line = remove_inline_comment(line)
    
    if not is_comment_or_empty(line) then
      local trimmed_line = trim(line)
      
      -- Check for table header
      if trimmed_line:match('^%[%[') then
        -- Array of tables
        if not trimmed_line:match('%]%]$') then
          return false, string.format("Unclosed array of tables at line %d", line_num)
        end
        local table_name = trimmed_line:match('^%[%[(.-)%]%]$')
        if not table_name or trim(table_name) == '' then
          return false, string.format("Empty array of tables name at line %d", line_num)
        end
        -- Validate table name
        if not validate_key(trim(table_name)) then
          return false, string.format("Invalid array of tables name at line %d", line_num)
        end
        
        -- For array of tables, each occurrence creates a new element
        -- So we track them separately with a counter
        local clean_name = trim(table_name)
        array_table_counts[clean_name] = (array_table_counts[clean_name] or 0) + 1
        current_table = '[[' .. clean_name .. '#' .. array_table_counts[clean_name] .. ']]'
        defined_keys[current_table] = {}
        is_array_table = true
        
      elseif trimmed_line:match('^%[') then
        -- Regular table
        if not trimmed_line:match('%]$') then
          return false, string.format("Unclosed table header at line %d", line_num)
        end
        local table_name = trimmed_line:match('^%[(.-)%]$')
        if not table_name or trim(table_name) == '' then
          return false, string.format("Empty table name at line %d", line_num)
        end
        -- Validate table name
        if not validate_key(trim(table_name)) then
          return false, string.format("Invalid table name at line %d", line_num)
        end
        -- Check for duplicate table
        local table_key = '[' .. trim(table_name) .. ']'
        if defined_tables[table_key] then
          return false, string.format("Duplicate table '%s' at line %d", table_name, line_num)
        end
        defined_tables[table_key] = true
        current_table = table_key
        defined_keys[current_table] = {}
        is_array_table = false
        
      else
        -- Key-value pair
        local key, value = trimmed_line:match('^([^=]+)=(.*)$')
        
        if not key then
          return false, string.format("Invalid syntax at line %d (expected key = value)", line_num)
        end
        
        key = trim(key)
        
        -- Validate key
        if not validate_key(key) then
          return false, string.format("Invalid key '%s' at line %d", key, line_num)
        end
        
        -- Check for duplicate key in current table/section
        local section = current_table or 'root'
        if not defined_keys[section] then
          defined_keys[section] = {}
        end
        if defined_keys[section][key] then
          return false, string.format("Duplicate key '%s' at line %d", key, line_num)
        end
        defined_keys[section][key] = true
        
        -- Check if value starts a multiline string
        local value_trimmed = trim(value)
        if value_trimmed:match('^"""') then
          in_multiline_string = true
          multiline_delimiter = '"""'
          -- Check if it closes on the same line
          if value_trimmed:sub(4):find('"""', 1, true) then
            in_multiline_string = false
            multiline_delimiter = nil
          end
        elseif value_trimmed:match("^'''") then
          in_multiline_string = true
          multiline_delimiter = "'''"
          -- Check if it closes on the same line
          if value_trimmed:sub(4):find("'''", 1, true) then
            in_multiline_string = false
            multiline_delimiter = nil
          end
        else
          -- Validate normal value
          local parsed_value, err = parse_value(value, line_num)
          if not parsed_value then
            return false, err
          end
        end
      end
    end
    
    ::continue::
    line_num = line_num + 1
  end
  
  -- Check if we're still in a multiline string at the end
  if in_multiline_string then
    return false, string.format("Unclosed multiline string at end of file")
  end
  
  return true
end

-- Function to run TOML syntax check
local function toml_check_syntax()
  local current_file = vim.fn.expand('%:p')
  local filetype = vim.bo.filetype
  
  if vim.fn.empty(current_file) == 1 or filetype ~= 'toml' then
    return
  end
  
  -- Read file content
  local content = table.concat(vim.fn.readfile(current_file), '\n')
  
  if content == '' then
    vim.notify("TOML syntax OK", vim.log.levels.INFO, {timeout = 500})
    return
  end
  
  local success, error_msg = parse_toml_with_errors(content)
  
  if success then
    vim.notify("TOML syntax OK", vim.log.levels.INFO, {timeout = 500})
  else
    vim.notify(error_msg, vim.log.levels.ERROR)
  end
end

-- Set up autocmd to run on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.toml",
  callback = function()
    toml_check_syntax()
  end,
  group = vim.api.nvim_create_augroup("TomlSyntaxCheck", { clear = true })
})

-- Export the function (in case you want to call it manually)
return {
  check_syntax = toml_check_syntax
}
