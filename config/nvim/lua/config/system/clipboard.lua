-- ~/.config/nvim/lua/config/clipboard.lua

-- ============================================================================
-- CLIPBOARD (Wayland)
-- ============================================================================


if vim.fn.has('win-32') == 1 then
	vim.g.clipboard = 'unnamedplus'

elseif vim.env.WAYLAND_DISPLAY then
	-- Explicitly set clipboard provider for Wayland
	vim.opt.clipboard = "unnamedplus"
	vim.g.clipboard = {

		name = 'wl-clipboard',
		copy = {['+'] = 'wl-copy',
				['*'] = 'wl-copy'},
		paste = {['+'] = 'wl-paste',
				 ['*'] = 'wl-paste'},
		cache_enabled = 0}
else
	vim.opt.clipboard = "unnamedplus"
end

