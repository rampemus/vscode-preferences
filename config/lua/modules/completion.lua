local M = {}
local util = require("modules.util")

function M.setup()
  local gh = util.gh

  -- [[ Autopairs, autodetect indent ]]
  vim.pack.add({ gh("windwp/nvim-autopairs") })
  require("nvim-autopairs").setup()
  vim.pack.add({ gh("tpope/vim-sleuth") })

  -- [[ Snippet Engine ]]
  -- NOTE: You can also specify plugin using a version range for its git tag.
  --  See `:help vim.version.range()` for more info
  vim.pack.add({
    { src = gh("L3MON4D3/LuaSnip"), version = vim.version.range("2.*") },
  })
  require("luasnip").setup({})
  local luasnip = require("luasnip")
  require("luasnip.loaders.from_vscode").lazy_load({
    paths = "~/.config/nvim/snippets",
  })
  luasnip.config.setup()

  -- [[ Autocomplete Engine ]]
  vim.pack.add({
    { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
  })
  require("blink.cmp").setup({
    enabled = function()
      return vim.bo.filetype ~= "fyler_finder"
        and vim.bo.buftype ~= "nofile"
        and vim.bo.buftype ~= "prompt"
        and vim.b.completion ~= false
    end,
    keymap = {
      preset = "default",
      ["<CR>"] = { "select_and_accept", "fallback" },
    },

    appearance = {
      nerd_font_variant = "mono",
    },

    completion = {
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
      menu = {
        auto_show = true,
      },
      list = {
        selection = {
          auto_insert = false,
        },
      },
      ghost_text = { enabled = false },
    },

    sources = {
      default = {
        "lsp",
        "path",
        "buffer",
        "snippets",
      },
      providers = {
        snippets = {
          min_keyword_length = 4,
        },
      },
    },

    snippets = { preset = "luasnip" },
    fuzzy = { implementation = "lua" },
    signature = { enabled = true },
  })
end

return M
