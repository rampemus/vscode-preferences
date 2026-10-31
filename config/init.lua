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

local modules = {
  "modules.options",
  "modules.keymaps",
  "modules.pack",
  "modules.ui",
  "modules.telescope",
  "modules.lsp",
  "modules.formatting",
  "modules.completion",
  "modules.treesitter",
  "modules.fyler",
  "modules.toggleterm",
  "modules.bufferline",
  "modules.lualine",
  "modules.visuals",
  "modules.firenvim",
  "modules.copilot",
}
-- Modules that are skipped entirely when started by firenvim
local skip_in_firenvim = {
  ["modules.telescope"] = true,
  ["modules.fyler"] = true,
  ["modules.toggleterm"] = true,
  ["modules.bufferline"] = true,
}
for _, name in ipairs(modules) do
  if not (vim.g.started_by_firenvim and skip_in_firenvim[name]) then
    require(name).setup()
  end
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
