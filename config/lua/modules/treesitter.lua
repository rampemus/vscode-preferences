local util = require("modules.util")
local gh = util.gh

-- [[ Configure Treesitter ]]
-- NOTE: You can also specify a branch or a specific commit
vim.pack.add({
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
})

-- textobjects for af/if (function) and ac/ic (class).
-- NOTE: The plugin's Lua init is incompatible with the new
-- nvim-treesitter API, so we add it to runtimepath directly
-- instead of using packadd (which sources plugin/*.vim).
vim.pack.add({ gh("nvim-treesitter/nvim-treesitter-textobjects") })
local textobj_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/nvim-treesitter-textobjects"
if vim.fn.isdirectory(textobj_path) == 1 then
  vim.opt.runtimepath:append(textobj_path)
  -- af/if = function outer/inner, ac/ic = class outer/inner
  local ts_select = require("nvim-treesitter-textobjects.select")
  for lhs, query in pairs({
    af = "@function.outer",
    ["if"] = "@function.inner",
    ac = "@class.outer",
    ic = "@class.inner",
  }) do
    vim.keymap.set({ "x", "o" }, lhs, function()
      ts_select.select_textobject(query, "textobjects")
    end, { desc = "Textobject: " .. query })
  end
end

-- Ensure basic parsers are installed
local parsers = {
  "bash",
  "c",
  "diff",
  "html",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "query",
  "vim",
  "vimdoc",
}
require("nvim-treesitter").install(parsers)

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  -- Check if a parser exists and load it
  if not vim.treesitter.language.add(language) then
    return
  end
  -- Enable syntax highlighting and other treesitter features
  vim.treesitter.start(buf, language)

  -- Enable treesitter based folds
  local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

  -- Enable treesitter based indentation
  if has_indent_query then
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

local available_parsers = require("nvim-treesitter").get_available()
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local buf, filetype = args.buf, args.match

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then
      return
    end

    local installed_parsers = require("nvim-treesitter").get_installed("parsers")

    if vim.tbl_contains(installed_parsers, language) then
      -- Enable the parser if it is already installed
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      -- If a parser is available in `nvim-treesitter`
      -- auto-install it and enable it after the installation is done
      require("nvim-treesitter").install(language):await(function()
        treesitter_try_attach(buf, language)
      end)
    else
      -- Try to enable treesitter features in case the parser exists
      -- not available from `nvim-treesitter`
      treesitter_try_attach(buf, language)
    end
  end,
})
