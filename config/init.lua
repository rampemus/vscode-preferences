---@diagnostic disable: missing-fields
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd("source ~/.config/nvim/vim/modules/common.vim")
vim.cmd("source ~/.config/nvim/vim/modules/util.vim")
if vim.g.started_by_firenvim then
  vim.cmd("source ~/.config/nvim/vim/modules/firenvim.vim")
else
  vim.cmd("source ~/.config/nvim/vim/modules/startup.vim")
end

local modules = {
  "config/lua/modules/options.lua",
  "config/lua/modules/keymaps.lua",
  "config/lua/modules/pack.lua",
  "config/lua/modules/ui.lua",
  "config/lua/modules/telescope.lua",
  "config/lua/modules/lsp.lua",
  "config/lua/modules/formatting.lua",
  "config/lua/modules/completion.lua",
  "config/lua/modules/treesitter.lua",
  "config/lua/modules/fyler.lua",
  "config/lua/modules/toggleterm.lua",
  "config/lua/modules/bufferline.lua",
  "config/lua/modules/lualine.lua",
  "config/lua/modules/visuals.lua",
  "config/lua/modules/firenvim.lua",
  "config/lua/modules/copilot.lua",
}
-- Modules that are skipped entirely when started by firenvim
local skip_in_firenvim = {
  ["config/lua/modules/telescope.lua"] = true,
  ["config/lua/modules/fyler.lua"] = true,
  ["config/lua/modules/toggleterm.lua"] = true,
  ["config/lua/modules/bufferline.lua"] = true,
}
for _, path in ipairs(modules) do
  if not (vim.g.started_by_firenvim and skip_in_firenvim[path]) then
    local module_path = path:match("lua/(.+)%.lua$")
    local module_name = module_path:gsub("/", ".")
    require(module_name)
  end
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
