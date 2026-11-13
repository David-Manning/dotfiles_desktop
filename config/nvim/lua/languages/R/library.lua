
-- R library loader
-- Inserts `suppressPackageStartupMessages(library(<package>))` so that
-- libraries load without printing startup messages to the terminal.

-- Build the R call for a single package
local function r_library_call(package)
  return string.format("suppressPackageStartupMessages(library(%s))", package)
end

-- Insert one line per package at the cursor
local function r_library_insert(packages)
  if #packages == 0 then
    return
  end

  local lines = {}
  for _, package in ipairs(packages) do
    table.insert(lines, r_library_call(package))
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local current_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

  if current_line:match("^%s*$") then
    -- Current line is blank, so replace it
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, lines)
    vim.api.nvim_win_set_cursor(0, { row + #lines - 1, 0 })
  else
    -- Otherwise insert below the current line
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    vim.api.nvim_win_set_cursor(0, { row + #lines, 0 })
  end
end

-- Command entry point
-- Usage: :RLibrary tidyverse data.table
-- With no arguments, prompts for the package name(s)
local function r_library(opts)
  local packages = opts.fargs

  if #packages == 0 then
    vim.ui.input({ prompt = "R package(s): " }, function(input)
      if input == nil or input:match("^%s*$") then
        return
      end
      r_library_insert(vim.split(input, "%s+", { trimempty = true }))
    end)
    return
  end

  r_library_insert(packages)
end

vim.api.nvim_create_user_command("RLibrary", r_library, {
  nargs = "*",
  desc = "Insert suppressPackageStartupMessages(library(...)) for each package given",
})

-- User commands must start with a capital letter, so provide `:r_library`
-- as an abbreviation that expands to `:RLibrary` at the start of the command line
vim.cmd([[cnoreabbrev <expr> r_library (getcmdtype() == ':' && getcmdpos() == 10) ? 'RLibrary' : 'r_library']])

return {
  library = r_library_insert,
  library_call = r_library_call,
}
