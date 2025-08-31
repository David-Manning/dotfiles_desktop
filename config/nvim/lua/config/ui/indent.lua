
-- Language-specific indentation settings
local M = {}

M.setup = function()
    -- Python-specific settings (PEP8 alignment)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
            -- Python benefits from these specific settings
            vim.opt_local.indentexpr = "GetPythonIndent()"
            vim.opt_local.autoindent = true
            vim.opt_local.smartindent = false  -- Can interfere with Python
            vim.opt_local.cindent = false      -- Not needed for Python
            
            -- Ensure tabs are used consistently
            vim.opt_local.tabstop = 4
            vim.opt_local.shiftwidth = 4
            vim.opt_local.softtabstop = 4
            vim.opt_local.expandtab = false
        end
    })

    -- For languages where treesitter indent works well
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {"lua", "javascript", "typescript", "rust", "julia"},
        callback = function()
            -- Use treesitter's indentation
            vim.opt_local.indentexpr = "nvim_treesitter#indent()"
        end
    })

    -- C-like languages
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {"c", "cpp", "java", "javascript", "typescript"},
        callback = function()
            vim.opt_local.cindent = true
            vim.opt_local.cinoptions = "(0,W4,m1,j1,J1"
        end
    })
end

return M
