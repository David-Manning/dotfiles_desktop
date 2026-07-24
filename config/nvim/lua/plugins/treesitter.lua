-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        dependencies = {
            -- Add the Stan grammar repository as a dependency.
            -- lazy.nvim will clone this to your data directory, making the 
            -- queries (highlights.scm, etc.) available on the runtimepath automatically.
            { "WardBrian/tree-sitter-stan" },
        },
        config = function()
            -- 1. Filetype detection
            vim.filetype.add({
                extension = {
                    stan = "stan"
                },
            })

            -- 2. Define parser installation info
            -- We point to the local directory where lazy.nvim clones the dependency.
            -- This ensures we compile the parser from the downloaded source.
            local parser_path = vim.fn.stdpath("data") .. "/lazy/tree-sitter-stan"

            require("nvim-treesitter.parsers").stan = {
                install_info = {
                    url = parser_path,
                    files = { "src/parser.c", "src/scanner.c" },
                    branch = "main",
                },
            }

            -- 3. Register the language
            vim.treesitter.language.register("stan", "stan")

            -- 4. Setup nvim-treesitter
            require("nvim-treesitter").setup({
                ensure_installed = {
                    "stan",
                    "r",
                    "python",
                    "lua",
                    "vim", "vimdoc",
                    "latex", "bibtex",
                    "markdown", "html",
                    "yaml", "toml", "xml", "json",
                    "csv", "tsv",
                    "bash", "fish",
                    "ruby",
                    "rust",
                    "julia",
                    "sql",
                    "ssh_config"
                },
            })

            -- 5. Enable highlighting
            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "stan",
                    "r",
                    "python",
                    "lua",
                    "vim", "vimdoc",
                    "latex", "bibtex",
                    "markdown", "html",
                    "yaml", "toml", "xml", "json",
                    "csv", "tsv",
                    "bash", "fish",
                    "ruby",
                    "rust",
                    "julia",
                    "sql",
                    "ssh_config"
                },
                callback = function()
                    vim.treesitter.start()
                end,
            })
        end,
    },
}

