-- ~/.config/nvim/lua/config/terminal_integration.lua

-- ============================================================================
-- TERMINAL INTEGRATION
-- ============================================================================

-- Set terminal title to show nvim and current file
vim.opt.title = true
vim.opt.titlestring = "nvim [%F]"           -- "nvim [/full/path/file.ext]"

-- Alternative formats
-- vim.opt.titlestring = "nvim: %t"  -- Shows "nvim: filename.ext"
-- vim.opt.titlestring = "%t - nvim"           -- "filename.ext - nvim"
-- vim.opt.titlestring = "nvim [%F]"           -- "nvim [/full/path/file.ext]"
