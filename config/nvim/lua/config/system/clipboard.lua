-- ~/.config/nvim/lua/config/clipboard.lua

-- ============================================================================
-- CLIPBOARD (Wayland)
-- ============================================================================

vim.opt.clipboard = "unnamedplus"

if vim.fn.has('win-32') == 1 then
	vim.g.clipboard = 'unnamedplus'

elseif vim.env.WAYLAND_DISPLAY then
	-- Explicitly set clipboard provider for Wayland
	vim.g.clipboard = {
		name = 'wl-clipboard',
		copy = {['+'] = 'wl-copy',
				['*'] = 'wl-copy'},
		paste = {['+'] = 'wl-paste',
				 ['*'] = 'wl-paste'},
		cache_enabled = 0}
end

