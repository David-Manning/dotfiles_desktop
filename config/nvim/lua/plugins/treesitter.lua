-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        dependencies = {
            { "WardBrian/tree-sitter-stan" },
        },
        config = function()
            -- 1. Filetype detection
            vim.filetype.add({
                extension = {
                    stan = "stan",
                },
            })

            -- 2. Register custom parser via the documented method
            vim.api.nvim_create_autocmd("User", {
                pattern = "TSUpdate",
                callback = function()
                    require("nvim-treesitter.parsers").stan = {
                        install_info = {
                            path = vim.fn.stdpath("data") .. "/lazy/tree-sitter-stan",
                            location = "grammars/stan",
                            generate = false,
                            generate_from_json = false,
                        },
                    }
                end,
            })

            -- 3. Also register it immediately for the current session
            require("nvim-treesitter.parsers").stan = {
                install_info = {
                    path = vim.fn.stdpath("data") .. "/lazy/tree-sitter-stan",
                    location = "grammars/stan",
                    generate = false,
                    generate_from_json = false,
                },
            }

            -- 4. Register the language mapping
            vim.treesitter.language.register("stan", "stan")

            -- 5. Setup nvim-treesitter
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
                    "ssh_config",
                },
            })

            -- 6. Enable highlighting
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
                    "ssh_config",
                },
                callback = function()
                    vim.treesitter.start()
                end,
            })
        end,
    },
}

