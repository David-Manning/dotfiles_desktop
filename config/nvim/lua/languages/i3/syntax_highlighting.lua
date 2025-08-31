
-- i3 window manager syntax highlighting configuration
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- i3 syntax highlighting
autocmd({'BufNewFile','BufRead'}, {
  group = augroup('i3config_ft_detection', { clear = true }),
  pattern = {'*/i3/config','*/i3/config.d/*', '*/sway/config', '*/sway/config.d/*'},
  command = 'set filetype=i3config',
})
