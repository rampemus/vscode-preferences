---@diagnostic disable: missing-fields
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd("source ~/.config/nvim/common.vim")
vim.cmd("source ~/.config/nvim/util.vim")
if vim.g.started_by_firenvim then
  vim.cmd("source ~/.config/nvim/firenvim.vim")
else
  vim.cmd("source ~/.config/nvim/startup.vim")
end

-- Modules load in dependency order: options -> keymaps -> pack -> plugins
require("modules.options").setup()
require("modules.keymaps").setup()
require("modules.pack").setup()
require("modules.ui").setup()
require("modules.telescope").setup()
require("modules.lsp").setup()
require("modules.formatting").setup()
require("modules.completion").setup()
require("modules.treesitter").setup()
require("modules.fyler").setup()
require("modules.toggleterm").setup()
require("modules.bufferline").setup()
require("modules.lualine").setup()
require("modules.visuals").setup()
require("modules.firenvim").setup()
require("modules.copilot").setup()

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
