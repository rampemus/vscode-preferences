local M = {}

local function nmap(l, r, desc, buffer)
  vim.keymap.set("n", l, r, { silent = true, desc = desc, buffer = buffer })
end
local function tmap(l, r, desc, buffer)
  vim.keymap.set("t", l, r, { silent = true, desc = desc, buffer = buffer })
end
local function vmap(l, r, desc)
  vim.keymap.set("v", l, r, { silent = true, desc = desc })
end
local center = function(columns)
  local colorcolumn = vim.api.nvim_get_option_value("colorcolumn", {})
  return math.max(math.floor((columns - colorcolumn - 7) / 2), 0)
end
local function gh(repo)
  return "https://github.com/" .. repo
end

-- Terminal editing: map normal-mode keys to insert-mode edits
local function map_terminal_edit(buf, fallback)
  local left_at
  vim.api.nvim_create_autocmd("ModeChanged", {
    buffer = buf,
    callback = function(args)
      if args.match == "t:nt" then
        vim.schedule(function()
          left_at = vim.api.nvim_win_get_cursor(0)
        end)
      end
    end,
  })
  local function insert_at(offset, delete, text, opts)
    opts = opts or {}
    local target = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_create_autocmd("TermEnter", {
      buffer = buf,
      once = true,
      callback = vim.schedule_wrap(function()
        local chan = vim.bo[buf].channel
        local cur = vim.api.nvim_win_get_cursor(0)
        if type(offset) == "string" then
          vim.api.nvim_chan_send(chan, offset)
          return
        end
        if delete and target[1] ~= cur[1] then
          vim.cmd("stopinsert")
          return
        end
        if target[1] ~= cur[1] then
          if fallback then
            vim.api.nvim_chan_send(chan, fallback)
          end
          return
        end
        local line = vim.api.nvim_buf_get_lines(buf, cur[1] - 1, cur[1], false)[1]
          or ""
        local function chars(col)
          return vim.fn.strchars(line:sub(1, col)) + math.max(0, col - #line)
        end
        local delta = chars(target[2]) + offset - chars(cur[2])
        -- Normal mode clamps a shell cursor right after the last char onto
        -- that char, so `i` there must still step left like in Vim.
        local n = vim.fn.strchars(line)
        local clamped = chars(cur[2]) == n and chars(target[2]) == n - 1
        if
          not delete
          and not clamped
          and left_at
          and target[1] == left_at[1]
          and target[2] == left_at[2]
        then
          delta = 0
        end
        if delta ~= 0 then
          local key = delta < 0 and "\27[D" or "\27[C"
          vim.api.nvim_chan_send(chan, key:rep(math.abs(delta)))
        end
        if delete then
          text = text or ""
          vim.api.nvim_chan_send(chan, ("\127"):rep(delete) .. text)
          if opts.insert then
            return
          end
          -- Leaving terminal mode snaps to the shell cursor, which may lag
          -- behind the TUI redraw. Land after the new text like `~` and `x`.
          vim.api.nvim_create_autocmd("ModeChanged", {
            buffer = buf,
            -- 'pattern' is not allowed with 'buffer', so match modes here.
            callback = function(args)
              -- ModeChanged sets `match` to "old_mode:new_mode".
              if args.match ~= "t:nt" then
                return
              end
              vim.schedule(function()
                local line_text = vim.api.nvim_buf_get_lines(
                  buf,
                  target[1] - 1,
                  target[1],
                  false
                )[1] or ""
                local col = math.min(
                  opts.land or target[2] + #text,
                  math.max(#line_text - 1, 0)
                )
                pcall(vim.api.nvim_win_set_cursor, 0, { target[1], col })
              end)
              return true
            end,
          })
          vim.defer_fn(function()
            vim.cmd("stopinsert")
          end, 50)
        end
      end),
    })
    vim.cmd("startinsert")
  end
  nmap("i", function()
    insert_at(0)
  end, "Insert at cursor", buf)
  nmap("a", function()
    insert_at(1)
  end, "Append after cursor", buf)
  nmap("I", function()
    insert_at("\1")
  end, "Insert at command line start", buf)
  nmap("A", function()
    insert_at("\5")
  end, "Append at command line end", buf)
  -- Run `keys` on a scratch copy of the cursor line, so Vim itself decides
  -- what changes (and fills registers), then replay the difference.
  -- Turn `line` into `new`, starting the diff at or before char `start`.
  local function replay(line, col, new, start, opts)
    local old_n, new_n = vim.fn.strchars(line), vim.fn.strchars(new)
    local p = 0
    local max_p = math.min(old_n, new_n, start)
    while
      p < max_p
      and vim.fn.strgetchar(line, p) == vim.fn.strgetchar(new, p)
    do
      p = p + 1
    end
    local s = 0
    while
      s < old_n - p
      and s < new_n - p
      and vim.fn.strgetchar(line, old_n - 1 - s)
        == vim.fn.strgetchar(new, new_n - 1 - s)
    do
      s = s + 1
    end
    local deleted = old_n - p - s
    insert_at(
      p + deleted - vim.fn.strchars(line:sub(1, col)),
      deleted,
      vim.fn.strcharpart(new, p, new_n - p - s),
      opts
    )
  end
  -- Edits made by `edit_line`, so `u` and <C-r> can replay them backwards.
  -- Text typed in terminal mode is not tracked: `u` then falls back to the
  -- TUI's own undo (ctrl+_ in both claude-code and zsh).
  local undo, redo = {}, {}
  local scratch
  local function edit_line(keys, insert)
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if not (scratch and vim.api.nvim_buf_is_valid(scratch)) then
      scratch = vim.api.nvim_create_buf(false, true)
    end
    vim.api.nvim_buf_set_lines(scratch, 0, -1, false, { line })
    local new, land, start
    vim.api.nvim_buf_call(scratch, function()
      vim.api.nvim_win_set_cursor(0, { 1, col })
      vim.cmd("noautocmd normal! " .. keys)
      new = vim.api.nvim_buf_get_lines(scratch, 0, 1, false)[1]
      land = vim.api.nvim_win_get_cursor(0)[2]
      start = vim.api.nvim_buf_get_mark(scratch, "[")[2]
    end)
    if new == line then
      return
    end
    -- `'[` pins where the change starts when the diff alone is ambiguous
    -- (e.g. `dw` on the first "ab " of "ab ab ").
    start = vim.fn.strchars(line:sub(1, start))
    table.insert(undo, { before = line, after = new, col = col, start = start })
    redo = {}
    replay(line, col, new, start, { insert = insert, land = land })
  end
  nmap("u", function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local entry = undo[#undo]
    if not entry or entry.after ~= line then
      undo, redo = {}, {}
      vim.api.nvim_chan_send(vim.bo[buf].channel, ("\31"):rep(vim.v.count1))
      return
    end
    table.insert(redo, table.remove(undo))
    replay(line, col, entry.before, entry.start, { land = entry.col })
  end, "Terminal undo", buf)
  nmap("<C-r>", function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local entry = redo[#redo]
    if not entry or entry.before ~= line then
      return
    end
    table.insert(undo, table.remove(redo))
    replay(line, col, entry.after, entry.start, { land = entry.col })
  end, "Terminal redo", buf)
  for _, keys in ipairs({ "~", "x", "dw", "diw", "daw", "D", "p" }) do
    nmap(keys, function()
      edit_line(vim.v.count1 .. keys)
    end, "Terminal " .. keys, buf)
  end
  for _, keys in ipairs({ "cw", "ciw", "caw", "C" }) do
    nmap(keys, function()
      edit_line(vim.v.count1 .. keys, true)
    end, "Terminal " .. keys, buf)
  end
  nmap("r", function()
    local char = vim.fn.getcharstr()
    if char ~= "\27" then
      edit_line(vim.v.count1 .. "r" .. char)
    end
  end, "Terminal r", buf)
end
local SPINNER_FRAMES =
  { "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏", "⠋" }
-- Center any window whose buffer has the given filetype (used to keep
-- side splits like fyler_finder / claude-code sized on VimResized).
local function center_windows_with_buffer(filetype)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf_type = vim.api.nvim_get_option_value("filetype", {
      buf = vim.api.nvim_win_get_buf(win),
    })
    if buf_type == filetype then
      vim.api.nvim_win_set_width(win, center(vim.o.columns))
    end
  end
end

M.nmap = nmap
M.tmap = tmap
M.vmap = vmap
M.center = center
M.gh = gh
M.map_terminal_edit = map_terminal_edit
M.SPINNER_FRAMES = SPINNER_FRAMES
M.center_windows_with_buffer = center_windows_with_buffer

return M
