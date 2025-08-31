-- ~/.config/nvim/lua/config/clipboard.lua

-- ============================================================================
-- CLIPBOARD (Wayland)
-- ============================================================================

vim.opt.clipboard = "unnamedplus"

-- Explicitly set clipboard provider for Wayland
vim.g.clipboard = {
  name = 'wl-clipboard',
  copy = {
    ['+'] = 'wl-copy',
    ['*'] = 'wl-copy',
  },
  paste = {
    ['+'] = 'wl-paste',
    ['*'] = 'wl-paste',
  },
  cache_enabled = 0,
}
