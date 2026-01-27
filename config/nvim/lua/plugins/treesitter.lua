-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            -- Filetype detection for Stan
            vim.filetype.add({
                extension = {
                    stan = "stan"
                },
            })

            -- Register custom Stan parser BEFORE setup, via autocmd
            vim.api.nvim_create_autocmd("User", {
                pattern = "TSUpdate",
                callback = function()
                    require("nvim-treesitter.parsers").stan = {
                        install_info = {
                            url = "https://github.com/WardBrian/tree-sitter-stan",
                            files = { "src/parser.c" },
                            branch = "main",
                        },
                    }
                end,
            })

            -- Trigger the autocmd manually for first load
            require("nvim-treesitter.parsers").stan = {
                install_info = {
                    url = "https://github.com/WardBrian/tree-sitter-stan",
                    files = { "src/parser.c" },
                    branch = "main",
                },
            }

            -- Register parser with filetype
            vim.treesitter.language.register("stan", "stan")

            -- New setup call (minimal - just install_dir if needed)
            require("nvim-treesitter").setup({})

            -- Install parsers
            require("nvim-treesitter").install({
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
            })

            -- Enable highlighting via FileType autocmd
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
