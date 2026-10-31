local util = require("modules.util")
local gh = util.gh

vim.pack.add({ gh("lukas-reineke/indent-blankline.nvim") })
require("ibl").setup({
  indent = {
    tab_char = { "▌" },
  },
  scope = {
    show_start = false,
    highlight = { "Comment" },
    show_end = false,
  },
  whitespace = {
    remove_blankline_trail = false,
  },
})

vim.pack.add({ gh("NvChad/nvim-colorizer.lua") })
require("colorizer").setup({
  filetypes = { "*" },
  user_default_options = {
    RGB = true,
    RRGGBB = true,
    names = true,
    RRGGBBAA = true,
    AARRGGBB = true,
    rgb_fn = true,
    hsl_fn = true,
    css = true,
    css_fn = true,
    mode = "background",
    sass = { enable = false, parsers = { "css" } },
    virtualtext = "?",
  },
})

if not vim.g.started_by_firenvim then
  vim.pack.add({ gh("lukas-reineke/virt-column.nvim") })
  require("virt-column").setup({
    -- use thick ibl char
    char = "▎",
    highlight = "IblIndent",
    buftype = { "terminal" },
    exclude = {
      filetypes = {
        "claude-code",
        "help",
        "terminal",
        "nofile",
        "prompt",
        "TelescopePrompt",
        "fyler_finder",
      },
    },
  })
end

if not vim.g.started_by_firenvim then
  vim.pack.add({ gh("kevinhwang91/nvim-hlslens") })
  vim.pack.add({ gh("petertriho/nvim-scrollbar") })

  require("scrollbar.handlers.search").setup({
    override_lens = function() end,
  })
  require("hlslens").enable()

  local options = { noremap = true, silent = true }
  local normal = function(arg, count)
    if count then
      return function()
        vim.cmd("normal! " .. vim.v.count1 .. arg)
        require("hlslens").start()
      end
    end
    return function()
      vim.cmd("normal! " .. arg)
      require("hlslens").start()
    end
  end
  vim.keymap.set("n", "*", normal("*"), options)
  vim.keymap.set("n", "#", normal("#"), options)
  vim.keymap.set("n", "g*", normal("g*"), options)
  vim.keymap.set("n", "g#", normal("g#"), options)
  vim.keymap.set("n", "n", normal("n", true), options)
  vim.keymap.set("n", "N", normal("N", true), options)

  require("scrollbar").setup({
    excluded_buftypes = {
      "terminal",
      "nofile",
    },
    disabled = vim.g.started_by_firenvim,
    handle = {
      highlight = "Cursor",
      blend = 90,
    },
    handlers = {
      cursor = false,
      gitsigns = true,
    },
    marks = {
      GitDelete = {
        text = "┆",
      },
      Search = {
        color = "#5c6370",
      },
    },
  })
end

vim.pack.add({ gh("mcauley-penney/visual-whitespace.nvim") })
require("visual-whitespace").setup({
  highlight = { fg = "#181a1f", bg = "#404255" },
  space_char = " ",
  excluded = {
    buftypes = { "terminal" },
  },
})

if not vim.g.started_by_firenvim then
  vim.pack.add({ gh("3rd/image.nvim") })
  require("image").setup()
end
