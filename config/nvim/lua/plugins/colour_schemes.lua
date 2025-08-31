-- ~/.config/nvim/lua/plugins/colourscheme.lua

return {
  {
    "kaiuri/nvim-juliana",
    lazy = false, -- Load immediately since it's our main colourscheme
    priority = 1000, -- Load before other plugins
    config = function()
      -- Set up Juliana extensions before loading
      vim.g.juliana_extensions = {
        treesitter = true,
        semantic_tokens = false,
        fzf = true,
        fugitive = true,
        coc = true,
      }
      
      -- Load the colourscheme
      vim.cmd('colorscheme juliana')
    end,
  },
}
