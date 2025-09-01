
-- XML syntax check script

-- Function to parse XML and find errors
local function parse_xml_with_errors(content)
  local pos = 1
  local len = #content
  local line_num = 1
  local col_num = 1
  
  -- Track position with line and column
  local function advance(n)
    n = n or 1
    for i = 1, n do
      if pos <= len then
        if content:sub(pos, pos) == '\n' then
          line_num = line_num + 1
          col_num = 1
        else
          col_num = col_num + 1
        end
        pos = pos + 1
      end
    end
  end
  
  -- Peek at current character without advancing
  local function peek(offset)
    offset = offset or 0
    local p = pos + offset
    if p <= len then
      return content:sub(p, p)
    end
    return nil
  end
  
  -- Check if we're at a specific string
  local function match_string(str)
    local end_pos = pos + #str - 1
    if end_pos <= len then
      return content:sub(pos, end_pos) == str
    end
    return false
  end
  
  -- Skip whitespace
  local function skip_whitespace()
    while pos <= len and content:sub(pos, pos):match('%s') do
      advance()
    end
  end
  
  -- Parse XML name (element or attribute name)
  local function parse_name()
    local start_pos = pos
    local start_line = line_num
    local start_col = col_num
    
    -- Name must start with letter or underscore
    if not peek():match('[%a_]') then
      return nil, string.format("Invalid name start character at line %d, column %d", start_line, start_col)
    end
    
    -- Continue with letters, digits, hyphens, underscores, dots
    while pos <= len and peek():match('[%w_%.%-]') do
      advance()
    end
    
    return content:sub(start_pos, pos - 1)
  end
  
  -- Parse attribute value
  local function parse_attribute_value()
    local quote = peek()
    if quote ~= '"' and quote ~= "'" then
      return nil, string.format("Attribute value must be quoted at line %d, column %d", line_num, col_num)
    end
    
    advance() -- Skip opening quote
    local start_pos = pos
    
    while pos <= len and peek() ~= quote do
      if peek() == '<' then
        return nil, string.format("Illegal '<' in attribute value at line %d, column %d", line_num, col_num)
      end
      advance()
    end
    
    if pos > len then
      return nil, string.format("Unterminated attribute value at line %d, column %d", line_num, col_num)
    end
    
    local value = content:sub(start_pos, pos - 1)
    advance() -- Skip closing quote
    
    return value
  end
  
  -- Parse attributes
  local function parse_attributes()
    local attrs = {}
    
    while pos <= len do
      skip_whitespace()
      
      -- Check for end of tag
      if peek() == '>' or (peek() == '/' and peek(1) == '>') then
        break
      end
      
      -- Parse attribute name
      local name, err = parse_name()
      if not name then
        return nil, err
      end
      
      -- Check for duplicate attribute
      if attrs[name] then
        return nil, string.format("Duplicate attribute '%s' at line %d, column %d", name, line_num, col_num)
      end
      
      skip_whitespace()
      
      -- Expect '='
      if peek() ~= '=' then
        return nil, string.format("Expected '=' after attribute name at line %d, column %d", line_num, col_num)
      end
      advance()
      
      skip_whitespace()
      
      -- Parse attribute value
      local value, err = parse_attribute_value()
      if not value then
        return nil, err
      end
      
      attrs[name] = value
    end
    
    return attrs
  end
  
  -- Parse comment
  local function parse_comment()
    if not match_string('<!--') then
      return false
    end
    
    advance(4) -- Skip '<!--'
    
    while pos <= len do
      if match_string('-->') then
        advance(3)
        return true
      end
      advance()
    end
    
    return nil, string.format("Unterminated comment at line %d", line_num)
  end
  
  -- Parse CDATA section
  local function parse_cdata()
    if not match_string('<![CDATA[') then
      return false
    end
    
    advance(9) -- Skip '<![CDATA['
    
    while pos <= len do
      if match_string(']]>') then
        advance(3)
        return true
      end
      advance()
    end
    
    return nil, string.format("Unterminated CDATA section at line %d", line_num)
  end
  
  -- Parse text content
  local function parse_text()
    local start_pos = pos
    
    while pos <= len and peek() ~= '<' do
      if peek() == '&' then
        -- Check for valid entity reference
        local entity_start = pos
        advance()
        
        if peek() == '#' then
          -- Numeric entity
          advance()
          if peek() == 'x' then
            -- Hex entity
            advance()
            if not peek():match('[%da-fA-F]') then
              return nil, string.format("Invalid hexadecimal entity at line %d, column %d", line_num, col_num)
            end
            while peek() and peek():match('[%da-fA-F]') do
              advance()
            end
          else
            -- Decimal entity
            if not peek():match('%d') then
              return nil, string.format("Invalid numeric entity at line %d, column %d", line_num, col_num)
            end
            while peek() and peek():match('%d') do
              advance()
            end
          end
        else
          -- Named entity
          if not peek():match('[%a]') then
            return nil, string.format("Invalid entity reference at line %d, column %d", line_num, col_num)
          end
          while peek() and peek():match('[%w]') do
            advance()
          end
        end
        
        if peek() ~= ';' then
          return nil, string.format("Unterminated entity reference at line %d, column %d", line_num, col_num)
        end
        advance()
      else
        advance()
      end
    end
    
    return content:sub(start_pos, pos - 1)
  end
  
  -- Stack to track open elements
  local element_stack = {}
  
  -- Main parsing loop
  local function parse_element()
    skip_whitespace()
    
    if pos > len then
      if #element_stack > 0 then
        return nil, string.format("Unclosed element '<%s>' at end of file", element_stack[#element_stack])
      end
      return true
    end
    
    if peek() ~= '<' then
      -- Parse text content
      local text, err = parse_text()
      if not text then
        return nil, err
      end
      return parse_element() -- Continue parsing
    end
    
    advance() -- Skip '<'
    
    -- Check for comment
    if match_string('!--') then
      pos = pos - 1 -- Back up to '<'
      local success, err = parse_comment()
      if not success then
        return nil, err
      end
      return parse_element() -- Continue parsing
    end
    
    -- Check for CDATA
    if match_string('![CDATA[') then
      pos = pos - 1 -- Back up to '<'
      local success, err = parse_cdata()
      if not success then
        return nil, err
      end
      return parse_element() -- Continue parsing
    end
    
    -- Check for XML declaration or processing instruction
    if peek() == '?' then
      advance()
      -- Skip until '?>'
      while pos <= len do
        if match_string('?>') then
          advance(2)
          break
        end
        advance()
      end
      return parse_element() -- Continue parsing
    end
    
    -- Check for DOCTYPE
    if match_string('!DOCTYPE') then
      -- Simple DOCTYPE parsing - skip until '>'
      local bracket_count = 0
      while pos <= len do
        if peek() == '[' then
          bracket_count = bracket_count + 1
        elseif peek() == ']' then
          bracket_count = bracket_count - 1
        elseif peek() == '>' and bracket_count == 0 then
          advance()
          break
        end
        advance()
      end
      return parse_element() -- Continue parsing
    end
    
    -- Check for closing tag
    if peek() == '/' then
      advance()
      
      local tag_name, err = parse_name()
      if not tag_name then
        return nil, string.format("Invalid closing tag at line %d, column %d", line_num, col_num)
      end
      
      skip_whitespace()
      
      if peek() ~= '>' then
        return nil, string.format("Expected '>' in closing tag at line %d, column %d", line_num, col_num)
      end
      advance()
      
      -- Check if this closes the most recent open element
      if #element_stack == 0 then
        return nil, string.format("Unexpected closing tag '</%s>' at line %d", tag_name, line_num)
      end
      
      local expected = element_stack[#element_stack]
      if tag_name ~= expected then
        return nil, string.format("Mismatched closing tag '</%s>' (expected '</%s>') at line %d", tag_name, expected, line_num)
      end
      
      table.remove(element_stack)
      return parse_element() -- Continue parsing
    end
    
    -- Parse opening tag
    local tag_name, err = parse_name()
    if not tag_name then
      return nil, string.format("Invalid element name at line %d, column %d", line_num, col_num)
    end
    
    -- Parse attributes
    local attrs, err = parse_attributes()
    if not attrs then
      return nil, err
    end
    
    skip_whitespace()
    
    -- Check for self-closing tag
    if peek() == '/' then
      advance()
      if peek() ~= '>' then
        return nil, string.format("Expected '>' after '/' in self-closing tag at line %d, column %d", line_num, col_num)
      end
      advance()
      return parse_element() -- Continue parsing
    end
    
    -- Regular opening tag
    if peek() ~= '>' then
      return nil, string.format("Expected '>' at line %d, column %d", line_num, col_num)
    end
    advance()
    
    -- Add to stack
    table.insert(element_stack, tag_name)
    
    return parse_element() -- Continue parsing
  end
  
  -- Start parsing
  local success, err = parse_element()
  
  if not success then
    return false, err
  end
  
  if #element_stack > 0 then
    return false, string.format("Unclosed element '<%s>'", element_stack[#element_stack])
  end
  
  return true
end

-- Function to run XML syntax check
local function xml_check_syntax()
  local current_file = vim.fn.expand('%:p')
  local filetype = vim.bo.filetype
  
  if vim.fn.empty(current_file) == 1 or filetype ~= 'xml' then
    return
  end
  
  -- Read file content
  local content = table.concat(vim.fn.readfile(current_file), '\n')
  
  if content == '' then
    vim.notify("XML syntax OK", vim.log.levels.INFO, {timeout = 500})
    return
  end
  
  local success, error_msg = parse_xml_with_errors(content)
  
  if success then
    vim.notify("XML syntax OK", vim.log.levels.INFO, {timeout = 500})
  else
    vim.notify(error_msg, vim.log.levels.ERROR)
  end
end

-- Set up autocmd to run on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.xml",
  callback = function()
    xml_check_syntax()
  end,
  group = vim.api.nvim_create_augroup("XmlSyntaxCheck", { clear = true })
})

-- Export the function (in case you want to call it manually)
return {
  check_syntax = xml_check_syntax
}
