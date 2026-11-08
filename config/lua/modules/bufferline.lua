local util = require("modules.util")
local gh = util.gh

vim.pack.add({ gh("akinsho/bufferline.nvim") })

local active = { fg = "#abb2bf", bg = "#16181c" }
local inactive = { fg = "#5c6370", bg = "#16181c" }
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  callback = function()
    if vim.bo.filetype == "fyler_finder" then
      vim.api.nvim_set_hl(0, "BufferStatusFyler", active)
    else
      vim.api.nvim_set_hl(0, "BufferStatusFyler", inactive)
    end
    if vim.bo.filetype == "claude-code" then
      vim.api.nvim_set_hl(0, "BufferStatusClaude", active)
    else
      vim.api.nvim_set_hl(0, "BufferStatusClaude", inactive)
    end
  end,
})

local max_name_length = 40
require("bufferline").setup({
  options = {
    max_name_length,
    name_formatter = function(buf)
      local name = buf.name ---@diagnostic disable-line: undefined-field
      local max = math.min(max_name_length, math.floor(vim.o.columns * 0.1))

      if name:len() > max then
        return vim.fn.strcharpart(name, 0, max) .. "…"
      end

      return name
    end,
    diagnostics = "nvim_lsp",
    separator_style = "slant",
    custom_filter = function(buf_number)
      if vim.bo[buf_number].filetype ~= "claude-code" then
        return true
      end
      return false
    end,
    offsets = {
      {
        filetype = "fyler_finder",
        text = function()
          local nvimtree = 1
          local terminals = #require("toggleterm.terminal").get_all(true)

          local bufferList = vim.fn.getbufinfo({ buflisted = 1 })
          local claude_code = vim.tbl_filter(function(buf)
            return vim.bo[buf.bufnr].filetype == "claude-code"
          end, bufferList)
          local buffers = #bufferList - #claude_code

          local modified = buffers - terminals - nvimtree
          return buffers
            .. " Buffers"
            .. (modified > 0 and (" (" .. modified .. " modified)") or "")
            .. (terminals > 0 and (" (" .. terminals) .. " Terminals)" or "")
        end,
        text_align = "center",
        highlight = "BufferStatusFyler",
      },
      {
        filetype = "claude-code",
        text = vim.fn.executable("claude") == 1 and "Claude Code" or "Copilot CLI",
        text_align = "center",
        highlight = "BufferStatusClaude",
      },
    },
    always_show_bufferline = false,
    diagnostics_indicator = function(_, level)
      return level:match("error") and "" or ""
    end,
  },
})

-- vim-bufkill: close buffer without closing the window
vim.pack.add({ gh("qpkorr/vim-bufkill") })

-- stickybuf.nvim: pin buffers to windows (disabled in firenvim)
vim.pack.add({ gh("stevearc/stickybuf.nvim") })

-- Pinned terminal windows: open foreign buffers in an unpinned window, or
-- split next to the terminal (instead of stickybuf's default right split).
local function pinned_terminal(split_cmd, after)
  return {
    allow_type = "filetype",
    handle_foreign_buffer = function(foreign)
      local sticky = require("stickybuf")
      local term_win = vim.api.nvim_get_current_win()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(win).relative == "" and not sticky.is_pinned(win) then
          vim.api.nvim_set_current_win(win)
          vim.cmd.buffer(foreign)
          return
        end
      end
      vim.cmd(split_cmd .. " " .. foreign)
      if after then
        after(term_win)
      end
    end,
  }
end

require("stickybuf").setup({
  get_auto_pin = function(bufnr)
    local windows = vim.fn.getwininfo()
    if #windows == 1 then
      return false
    end
    local ft = vim.bo[bufnr].filetype
    if ft == "claude-code" then
      return pinned_terminal("leftabove vertical sbuffer")
    end
    if ft == "toggleterm" then
      return pinned_terminal("leftabove sbuffer", function(term_win)
        local size = require("toggleterm.config").get("size")
        if type(size) == "function" then
          size = size({ direction = "horizontal" })
        end
        vim.api.nvim_win_set_height(term_win, size)
      end)
    end
    if vim.fn.UtilFiletype(bufnr) == 1 then
      return "filetype"
    end
    return false
  end,
})
