-- ~/.config/nvim/lua/config/core/autocmds.lua

-- Do not automatically continue comments on a new line.
-- Filetype plugins reset 'formatoptions' after the global options load,
-- so this must run on the FileType event rather than in options.lua.
--   r : insert comment leader after <Enter> in insert mode
--   o : insert comment leader after 'o' or 'O' in normal mode
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("no_auto_comment", { clear = true }),
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "r", "o" })
    end,
})
