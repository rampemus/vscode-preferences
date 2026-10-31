local M = {}
local util = require("modules.util")

function M.setup()
  local center = util.center
  local gh = util.gh

  if not vim.g.started_by_firenvim then
    vim.pack.add({ gh("akinsho/bufferline.nvim") })

    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      callback = function()
        if vim.bo.filetype == "fyler_finder" then
          vim.api.nvim_set_hl(
            0,
            "BufferStatusFyler",
            { fg = "#abb2bf", bg = "#16181c" }
          )
        else
          vim.api.nvim_set_hl(
            0,
            "BufferStatusFyler",
            { fg = "#5c6370", bg = "#16181c" }
          )
        end
        if vim.bo.filetype == "claude-code" then
          vim.api.nvim_set_hl(
            0,
            "BufferStatusClaude",
            { fg = "#abb2bf", bg = "#16181c" }
          )
        else
          vim.api.nvim_set_hl(
            0,
            "BufferStatusClaude",
            { fg = "#5c6370", bg = "#16181c" }
          )
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
                .. (
                  terminals > 0 and (" (" .. terminals) .. " Terminals)" or ""
                )
            end,
            text_align = "center",
            highlight = "BufferStatusFyler",
          },
          {
            filetype = "claude-code",
            text = vim.fn.executable("claude") == 1 and "Claude Code"
              or "Copilot CLI",
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
    require("stickybuf").setup({
      get_auto_pin = function(bufnr)
        local windows = vim.fn.getwininfo()
        if #windows == 1 then
          return false
        end
        if vim.fn.UtilFiletype(bufnr) == 1 then
          return "filetype"
        end
        return false
      end,
    })
  end
end

return M
