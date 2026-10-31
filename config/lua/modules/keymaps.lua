local M = {}
local util = require("modules.util")

function M.setup()
  local nmap = util.nmap

  -- [[ Basic Keymaps ]]
  --  See `:help vim.keymap.set()`

  -- Clear highlights on search when pressing <Esc> in normal mode
  vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

  -- Disable <Space> default behavior in normal/visual
  vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

  -- Remap for dealing with word wrap
  local jk = { expr = true, silent = true }
  vim.keymap.set({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", jk)
  vim.keymap.set({ "n", "v" }, "j", "v:count == 0 ? 'gj' : 'j'", jk)

  -- gf (swapped with gF in common.vim) also understands `file:L145` and
  -- `file#L145`, plus approximate `file:~L145`. Native gF handles
  -- `file:145`, but not the "L" prefix.
  nmap("gf", function()
    local word = vim.fn.expand("<cWORD>")
    local file, lnum = string.match(word, "([%w%._%-/~]+)[:#]~?L(%d+)")
    local found = file and vim.fn.findfile(file) --[[@as string?]]
    if found and found ~= "" then
      vim.cmd.edit(vim.fn.fnameescape(found))
      local last = vim.api.nvim_buf_line_count(0)
      vim.api.nvim_win_set_cursor(0, { math.min(tonumber(lnum) or 1, last), 0 })
    else
      vim.cmd("normal! gF")
    end
  end, "Go to file under cursor at line")

  -- Open URL under cursor on double-click
  nmap("<2-LeftMouse>", ":silent! !open <cfile><CR>", "Open URL under cursor")

  -- Toggle git blame
  nmap("gb", ":BlameToggle<CR>", "Toggle [B]lame")

  -- Diagnostic keymaps
  nmap("gE", function()
    return vim.o.spell and vim.fn.feedkeys("[s")
      or vim.diagnostic.jump({ count = -1, float = true })
  end, "[G]o to previous [E]rror")
  nmap("ge", function()
    return vim.o.spell and vim.fn.feedkeys("]s")
      or vim.diagnostic.jump({ count = 1, float = true })
  end, "[G]o to next [E]rror")
  nmap("<leader>e", vim.diagnostic.open_float, "Open float diagnostic message")
  nmap("<leader>q", vim.diagnostic.setloclist, "Open diagnostics list")

  local function next_change(fallback, prev)
    return function()
      if require("diffview.lib").get_current_view() ~= nil then
        if prev then
          require("diffview.actions").select_prev_entry()
        else
          require("diffview.actions").select_next_entry()
        end
        if vim.fn.line(".") == 1 then
          require("gitsigns").nav_hunk("first")
        end
      else
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes(fallback, true, false, true),
          "n",
          true
        )
      end
    end
  end
  nmap("<C-j>", next_change(":cnext<CR><CR>"), "Next quicklist item")
  nmap("<C-k>", next_change(":cprev<CR><CR>", true), "Prev quicklist item")
  -- Navigate quickfix history with <C-h> and <C-l>
  nmap("<C-h>", ":cnewer<CR><CR>", "Newer quicklist")
  nmap("<C-l>", ":colder<CR><CR>", "Older quicklist")

  -- Open/focus fyler
  nmap("-", function()
    if vim.g.started_by_firenvim then
      vim.cmd("wqa!")
      return
    end
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if
        vim.api.nvim_get_option_value("filetype", {
          buf = vim.api.nvim_win_get_buf(win),
        }) == "fyler_finder"
      then
        vim.api.nvim_set_current_win(win)
        vim.cmd("norm! 0")
        return
      end
    end
    require("fyler").open({ kind = "split_left_most" })
  end, "Open Fyler View")

  -- [[ Basic Autocommands ]]
  --  See `:help lua-guide-autocommands`
  vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup(
      "kickstart-highlight-yank",
      { clear = true }
    ),
    callback = function()
      vim.hl.on_yank()
    end,
  })

  -- Disable auto commenting on new lines
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("no-auto-comment", {}),
    callback = function()
      vim.opt_local.formatoptions:remove({ "o" })
    end,
  })
end

return M
