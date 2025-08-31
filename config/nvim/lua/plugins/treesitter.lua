-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
    lazy = false,
    priority = 100,
    config = function()
      -- Add filetype detection FIRST
      vim.filetype.add({
        extension = {
          stan = "stan"
        },
      })

      -- Configure the custom Stan parser
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.stan = {
        install_info = {
          url = "https://github.com/WardBrian/tree-sitter-stan",
          files = {"src/parser.c"}, 
          branch = "main",
        },
        filetype = "stan",
      }

      -- Set up treesitter
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "stan",
          "r", "rnoweb", 
          "python", 
          "lua", 
          "vim", "vimdoc", 
          "latex", "bibtex",
          "markdown", "html",
          "yaml", "toml", "xml", "json", 
          "csv", "tsv",
          "bash", "elvish", "fish", "powershell", 
          "ruby", 
          "rust",
          "julia",
          "sql",
          "ssh_config"
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true , 
				   disable = { "python" } -- Default usually more reliable
		},
        auto_install = true,
      })

      -- Register the stan parser
      vim.treesitter.language.register("stan", "stan")
    end,
  },
}


