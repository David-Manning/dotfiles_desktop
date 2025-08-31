
return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require('lspconfig')
      
      -- R language server
      lspconfig.r_language_server.setup({})
    end
  }
}
