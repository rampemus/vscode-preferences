local M = {}
local util = require("modules.util")

function M.setup()
  local nmap = util.nmap
  local center = util.center
  local map_terminal_edit = util.map_terminal_edit
  local SPINNER_FRAMES = util.SPINNER_FRAMES
  local center_windows_with_buffer = util.center_windows_with_buffer

  -- Inline suggestions via the official Copilot language server, exposed
  -- through Neovim's native LSP client (nvim-lspconfig ships its config as
  -- lsp/copilot.lua).  See :h lsp-copilot and :h lsp-inline_completion.
  -- Requires `copilot-language-server` on $PATH:
  --   npm install --global @github/copilot-language-server
  local copilot_disabled_filetypes = { env = true, DressingInput = true }

  vim.lsp.enable("copilot")

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup(
      "copilot-inline-completion",
      { clear = true }
    ),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if not client or client.name ~= "copilot" then
        return
      end
      if copilot_disabled_filetypes[vim.bo[event.buf].filetype] then
        return
      end
      vim.lsp.inline_completion.enable(true, { bufnr = event.buf })
    end,
  })

  -- Accept the suggestion with Tab, falling back to a literal Tab otherwise.
  vim.keymap.set("i", "<Tab>", function()
    if not vim.lsp.inline_completion.get() then
      return "<Tab>"
    end
  end, { expr = true, desc = "Accept Copilot inline completion" })

  if not vim.g.started_by_firenvim then
    local claude_bufnr = nil
    local claude_winid = nil

    vim.g.claude_running = false
    vim.g.claude_generating = false
    vim.g.claude_yes = false
    local function ghostty_tab_title()
      local dir = vim.fn.getcwd()
      local check = dir
      while check ~= "/" do
        if vim.fn.isdirectory(check .. "/.git") == 1 then
          return vim.fn.fnamemodify(check, ":t")
        end
        check = vim.fn.fnamemodify(check, ":h")
      end
      local parts =
        vim.split(vim.fn.fnamemodify(dir, ":~"), "/", { trimempty = true })
      if #parts > 4 then
        parts = vim.list_slice(parts, #parts - 3)
      end
      return table.concat(parts, "/")
    end

    local spinner_frame = 1
    local dot_timer = nil

    local function set_ghostty_tab_marker(active)
      local title = ghostty_tab_title()
      if active then
        title = title .. " " .. SPINNER_FRAMES[spinner_frame]
      end
      io.stdout:write("\27]0;" .. title .. "\7")
      io.stdout:flush()
    end

    -- Deployed copy in ~/.config/nvim defines the same global.
    ---@diagnostic disable-next-line: duplicate-set-field
    _G.ClaudeSetGenerating = function(active)
      active = active and true or false
      vim.g.claude_generating = active
      set_ghostty_tab_marker(active)
      vim.cmd("redrawstatus")

      if dot_timer then
        dot_timer:stop()
        dot_timer:close()
        dot_timer = nil
      end
      if active then
        dot_timer = vim.uv.new_timer()
        if dot_timer then
          dot_timer:start(
            200,
            200,
            vim.schedule_wrap(function()
              spinner_frame = (spinner_frame % #SPINNER_FRAMES) + 1
              set_ghostty_tab_marker(true)
            end)
          )
        end
      end
    end

    local function new_uuid()
      local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
      return (
        template:gsub("[xy]", function(c)
          local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
          return string.format("%x", v)
        end)
      )
    end

    -- Auto-send <CR> to Claude Code terminal - a.k.a. no questions asked
    local claude_yes_timer = nil
    local function set_claude_yes(enabled)
      vim.g.claude_yes = enabled
      if claude_yes_timer then
        claude_yes_timer:stop()
        claude_yes_timer:close()
        claude_yes_timer = nil
      end
      if enabled then
        claude_yes_timer = vim.uv.new_timer()
        if claude_yes_timer then
          claude_yes_timer:start(
            1000,
            1000,
            vim.schedule_wrap(function()
              if claude_bufnr and vim.api.nvim_buf_is_valid(claude_bufnr) then
                vim.api.nvim_chan_send(vim.bo[claude_bufnr].channel, "\r")
              end
            end)
          )
        end
      end
    end
    vim.api.nvim_create_autocmd({ "InsertEnter", "TermEnter" }, {
      callback = function()
        if vim.bo.filetype == "claude-code" then
          set_claude_yes(false)
        end
      end,
      desc = "Disable claude auto-yes on insert mode",
    })

    local function open_claude_term()
      vim.cmd("vertical botright " .. center(vim.o.columns) .. "split")
      if claude_bufnr and vim.api.nvim_buf_is_valid(claude_bufnr) then
        vim.api.nvim_win_set_buf(0, claude_bufnr)
      else
        vim.cmd("enew")
        local cmd = vim.fn.executable("claude") == 1
            and ("claude --session-id=" .. new_uuid())
          or ("copilot --session-id=" .. new_uuid())
        vim.fn.jobstart(cmd, {
          term = true,
          on_exit = function()
            vim.g.claude_running = false
            _G.ClaudeSetGenerating(false)
          end,
        })
        vim.g.claude_running = true
        claude_bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_set_option_value(
          "filetype",
          "claude-code",
          { buf = claude_bufnr }
        )

        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = claude_bufnr })
        map_terminal_edit(claude_bufnr)

        -- claude-code binds ctrl+home/ctrl+end to scroll:top/scroll:bottom.
        local function send_key(keys)
          return function()
            vim.api.nvim_chan_send(vim.bo.channel, keys)
          end
        end
        nmap(
          "gg",
          send_key("\27[1;5H"),
          "Scroll claude terminal to top",
          claude_bufnr
        )
        nmap(
          "G",
          send_key("\27[1;5F"),
          "Scroll claude terminal to bottom",
          claude_bufnr
        )

        -- claude-code's TUI scrolls via mouse wheel (SGR mouse reporting),
        -- not Ctrl-d/Ctrl-u, so emulate wheel events from Normal mode.
        local function send_wheel(direction, lines)
          local button = direction == "up" and 64 or 65
          return function()
            local width = vim.api.nvim_win_get_width(0)
            local height = vim.api.nvim_win_get_height(0)
            local col, row = math.floor(width / 2), math.floor(height / 2)
            local event = string.format("\27[<%d;%d;%dM", button, col, row)
            vim.api.nvim_chan_send(vim.bo.channel, event:rep(lines))
          end
        end

        vim.keymap.set(
          "n",
          "<C-u>",
          send_wheel("up", 4),
          { buffer = claude_bufnr, desc = "Scroll claude terminal up" }
        )
        vim.keymap.set(
          "n",
          "<C-d>",
          send_wheel("down", 4),
          { buffer = claude_bufnr, desc = "Scroll claude terminal down" }
        )

        vim.keymap.set({ "n" }, "<C-y>", function()
          set_claude_yes(not vim.g.claude_yes)
        end, {
          buffer = claude_bufnr,
          desc = "Toggle auto <CR> for Claude terminal",
        })
      end
      claude_winid = vim.api.nvim_get_current_win()
      vim.cmd("startinsert")
    end

    local feedtermcode = function(keys, mode)
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(keys, true, false, true),
        mode,
        true
      )
    end

    vim.keymap.set({ "n" }, "cc", function()
      if claude_winid and vim.api.nvim_win_is_valid(claude_winid) then
        vim.api.nvim_win_close(claude_winid, false)
        claude_winid = nil
      else
        open_claude_term()
        feedtermcode("<C-\\><C-n>", "n")
      end
    end, { desc = "Toggle Claude terminal" })

    vim.keymap.set({ "n" }, "cr", function()
      if claude_winid and vim.api.nvim_win_is_valid(claude_winid) then
        vim.api.nvim_win_close(claude_winid, false)
        claude_winid = nil
      end
      open_claude_term()
      vim.api.nvim_feedkeys("/resume", "i", true)
      vim.defer_fn(function()
        feedtermcode("<CR>", "i")
      end, 0)
    end, { desc = "Resume Claude terminal session" })

    vim.keymap.set({ "n", "v" }, "cf", function()
      vim.fn.CopyFilePath(vim.fn.visualmode() == "V" and 1 or 0)
      if claude_winid and vim.api.nvim_win_is_valid(claude_winid) then
        vim.api.nvim_win_close(claude_winid, false)
        claude_winid = nil
      end
      open_claude_term()
      vim.api.nvim_feedkeys(" @" .. vim.fn.getreg("+") .. " ", "i", true)
    end, { desc = "Paste file under cursor into Claude terminal" })

    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        center_windows_with_buffer("claude-code")
      end,
    })
  end
end

return M
