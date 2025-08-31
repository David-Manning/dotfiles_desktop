-- ~/.config/nvim/lua/config/line_numbers.lua

-- ============================================================================
-- LINE NUMBERS
-- ============================================================================

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true -- current line highlighting
vim.opt.signcolumn = "no" -- Disable sign column

-- Subtle cursor line background
vim.api.nvim_set_hl(0, 'CursorLine', { 
  bg = '#2d2d2d'     -- Subtle background highlight
})
