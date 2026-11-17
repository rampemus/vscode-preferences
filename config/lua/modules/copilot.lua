local util = require("modules.util")
local nmap = util.nmap
local center = util.center
local map_terminal_edit = util.map_terminal_edit
local map_write = util.map_write
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
  group = vim.api.nvim_create_augroup("copilot-inline-completion", { clear = true }),
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

if vim.g.started_by_firenvim then
  return
end

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
  local parts = vim.split(vim.fn.fnamemodify(dir, ":~"), "/", { trimempty = true })
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

-- Split-below claude buffer per source claude buffer
local below_bufs = {}

-- Claude buffer exists and its job still runs (jobwait -1)
local function claude_alive(buf)
  return buf and vim.api.nvim_buf_is_valid(buf) and vim.fn.jobwait({ vim.bo[buf].channel }, 0)[1] == -1
end

-- Start claude in current window; first one is main session, rest are extra splits
local function start_claude_term()
  local is_main = not (claude_bufnr and vim.api.nvim_buf_is_valid(claude_bufnr))
  vim.cmd("enew")
  local cmd = vim.fn.executable("claude") == 1 and ("claude --session-id=" .. new_uuid())
    or ("copilot --session-id=" .. new_uuid())
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      if is_main then
        vim.g.claude_running = false
        _G.ClaudeSetGenerating(false)
      end
    end,
  })
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_option_value("filetype", "claude-code", { buf = buf })

  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = buf })
  map_terminal_edit(buf)
  -- Reuse this terminal's split-below buffer; create it only once
  map_write(buf, function()
    local below_buf = below_bufs[buf]
    if claude_alive(below_buf) then
      local win = vim.fn.bufwinid(below_buf)
      if win ~= -1 then
        vim.api.nvim_set_current_win(win)
      else
        vim.cmd("belowright split")
        vim.api.nvim_win_set_buf(0, below_buf)
      end
    else
      vim.cmd("belowright split")
      below_bufs[buf] = start_claude_term()
    end
    vim.cmd("startinsert")
  end, "Claude terminal below on :write")

  -- claude-code binds ctrl+home/ctrl+end to scroll:top/scroll:bottom.
  local function send_key(keys)
    return function()
      vim.api.nvim_chan_send(vim.bo.channel, keys)
    end
  end
  nmap("gg", send_key("\27[1;5H"), "Scroll claude terminal to top", buf)
  nmap("G", send_key("\27[1;5F"), "Scroll claude terminal to bottom", buf)

  -- claude-code's TUI scrolls via mouse wheel (SGR mouse reporting),
  -- not Ctrl-d/Ctrl-u, so emulate wheel events from Normal mode.
  local function send_wheel(direction, lines)
    local button = direction == "up" and 64 or 65
    return function()
      local win_width = vim.api.nvim_win_get_width(0)
      local win_height = vim.api.nvim_win_get_height(0)
      local col, row = math.floor(win_width / 2), math.floor(win_height / 2)
      local event = string.format("\27[<%d;%d;%dM", button, col, row)
      vim.api.nvim_chan_send(vim.bo.channel, event:rep(lines))
    end
  end

  vim.keymap.set("n", "<C-u>", send_wheel("up", 4), { buffer = buf, desc = "Scroll claude terminal up" })
  vim.keymap.set("n", "<C-d>", send_wheel("down", 4), { buffer = buf, desc = "Scroll claude terminal down" })

  -- Auto-yes timer only drives main session
  if is_main then
    vim.g.claude_running = true
    claude_bufnr = buf
    vim.keymap.set({ "n" }, "<C-y>", function()
      set_claude_yes(not vim.g.claude_yes)
    end, {
      buffer = buf,
      desc = "Toggle auto <CR> for Claude terminal",
    })
  end
  return buf
end

local function open_claude_term()
  local other_wins = 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    if ft ~= "claude-code" and ft ~= "toggleterm" then
      other_wins = other_wins + 1
    end
  end
  local width = other_wins == 1 and math.floor(vim.o.columns / 2) or center(vim.o.columns)
  vim.cmd("vertical botright " .. width .. "split")

  if claude_bufnr and vim.api.nvim_buf_is_valid(claude_bufnr) then
    vim.api.nvim_win_set_buf(0, claude_bufnr)
  else
    start_claude_term()
  end
  claude_winid = vim.api.nvim_get_current_win()
  vim.cmd("startinsert")
end

local feedtermcode = function(keys, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), mode, true)
end

-- Toggle main claude terminal together with its split-below terminal
vim.keymap.set({ "n" }, "cc", function()
  local below_buf = claude_bufnr and below_bufs[claude_bufnr]
  local below_win = below_buf and vim.fn.bufwinid(below_buf) or -1
  if claude_winid and vim.api.nvim_win_is_valid(claude_winid) then
    if below_win ~= -1 then
      vim.api.nvim_win_close(below_win, false)
    end
    vim.api.nvim_win_close(claude_winid, false)
    claude_winid = nil
  else
    -- Close stray below window so it reopens under main
    if below_win ~= -1 then
      vim.api.nvim_win_close(below_win, false)
    end
    open_claude_term()
    if claude_alive(below_buf) then
      vim.cmd("belowright split")
      vim.api.nvim_win_set_buf(0, below_buf)
      vim.api.nvim_set_current_win(claude_winid)
    end
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
