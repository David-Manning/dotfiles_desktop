-- ~/.config/nvim/lua/config/commands/shebang.lua

-- Shebang inserter
-- Provides the `:Shebang` command, which inserts a shebang line appropriate to
-- the buffer's filetype at the top of the file, followed by a blank line, so
-- that the script body starts on line 3. Works on both new (empty) buffers
-- and existing files. Nothing is applied automatically.

-- Shebang per filetype. Keyed by Neovim filetype, not file extension.
local shebangs = {
  r = "#!/usr/bin/Rscript --vanilla",
  python = "#!/usr/bin/env python",
  sh = "#!/usr/bin/env bash",
  bash = "#!/usr/bin/env bash",
  zsh = "#!/usr/bin/env zsh",
  fish = "#!/usr/bin/env fish",
  julia = "#!/usr/bin/env julia",
  lua = "#!/usr/bin/env lua",
  perl = "#!/usr/bin/env perl",
  ruby = "#!/usr/bin/env ruby",
  javascript = "#!/usr/bin/env node",
}

-- Look up the shebang for a filetype, or nil if there is none
local function shebang_for(filetype)
  return shebangs[filetype]
end

-- Insert the shebang into the current buffer
local function shebang_insert()
  local filetype = vim.bo.filetype
  local shebang = shebang_for(filetype)

  if shebang == nil then
    if filetype == "" then
      vim.notify("Shebang: buffer has no filetype set", vim.log.levels.WARN)
    else
      vim.notify("Shebang: no shebang defined for filetype '" .. filetype .. "'", vim.log.levels.WARN)
    end
    return
  end

  local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""

  -- Do not add a second shebang if the file already has one
  if first_line:sub(1, 2) == "#!" then
    vim.notify("Shebang: file already has a shebang", vim.log.levels.INFO)
    return
  end

  local line_count = vim.api.nvim_buf_line_count(0)
  local is_empty = line_count == 1 and first_line == ""

  if is_empty then
    -- New file: shebang, blank line, then an empty line 3 for the script body
    vim.api.nvim_buf_set_lines(0, 0, 1, false, { shebang, "", "" })
  else
    -- Existing file: push the current content down so it begins on line 3
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { shebang, "" })
  end

  -- Leave the cursor at the start of the script body
  vim.api.nvim_win_set_cursor(0, { 3, 0 })
end

vim.api.nvim_create_user_command("Shebang", shebang_insert, {
  nargs = 0,
  desc = "Insert a filetype-appropriate shebang at the top of the file",
})

-- User commands must start with a capital letter, so provide `:shebang`
-- as an abbreviation that expands to `:Shebang` at the start of the command line
vim.cmd([[cnoreabbrev <expr> shebang (getcmdtype() == ':' && getcmdpos() == 8) ? 'Shebang' : 'shebang']])

return {
  insert = shebang_insert,
  shebang_for = shebang_for,
  shebangs = shebangs,
}
