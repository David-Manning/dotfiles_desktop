-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy  = false,
        build = ":TSUpdate",
        config = function()
            -- 1. Filetype detection
            vim.filetype.add({
                extension = { stan = "stan" },
            })

            -- 2. Stan parser registration
            --    The new nvim-treesitter fires User TSUpdate before processing
            --    parsers, so custom entries must be registered there. Calling
            --    register_stan() immediately as well means :TSInstall works in
            --    the current session without having to run :TSUpdate first.
            local function register_stan()
                require("nvim-treesitter.parsers").stan = {
                    install_info = {
                        url     = "https://github.com/WardBrian/tree-sitter-stan",
                        queries = "queries/stan",
                        -- No revision field → HEAD; :TSUpdate always pulls latest.
                    },
                }
            end

            vim.api.nvim_create_autocmd("User", {
                pattern  = "TSUpdate",
                callback = register_stan,
            })
            register_stan()

            -- 3. Language registration
            vim.treesitter.language.register("stan", "stan")

            -- 4. Setup
            --    ensure_installed is removed in the rewrite.
            require("nvim-treesitter").setup({})

            -- 5. Parser installation
            --    install() is async and a no-op for already-installed parsers,
            --    so this handles a fresh machine without manual :TSInstall calls.
            local parsers = {
                "stan",
                "r", "python", "lua",
                "vim", "vimdoc",
                "latex", "bibtex",
                "markdown", "html",
                "yaml", "toml", "xml", "json",
                "csv", "tsv",
                "bash", "fish",
                "ruby", "rust", "julia",
                "sql", "ssh_config",
            }
            require("nvim-treesitter").install(parsers)

            -- 6. Enable highlighting
            vim.api.nvim_create_autocmd("FileType", {
                pattern  = parsers,
                callback = function()
                    vim.treesitter.start()
                end,
            })
        end,
    },
}
