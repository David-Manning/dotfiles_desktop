-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load core configuration (non-plugin related)
require("config.core.options")
require("config.core.keymaps")
require("config.core.autocmds")
require("config.system.clipboard")
require("config.system.filetypes")
require("config.system.terminal_integration")
require("config.ui.line_numbers")
require("config.ui.tabs")
require("config.ui.indent").setup()

-- Load language-specific configurations
require("languages.json.validate")
require("languages.yaml.validate")
require("languages.xml.validate")
require("languages.toml.validate")
require("languages.stan.check_blank_line_at_end")
require("languages.stan.validate")
require("languages.python.validate")
require("languages.latex.validate")
require("languages.i3.syntax_highlighting")
require("languages.R.validate")

-- Set up lazy.nvim with plugins
require("lazy").setup("plugins")
