local M = {}

function M.setup()
  -- Enable faster startup by caching compiled Lua modules
  vim.loader.enable()

  vim.o.number = not vim.g.started_by_firenvim

  vim.o.cmdheight = 0

  -- Enable mouse mode, can be useful for resizing splits for example!
  vim.o.mouse = "a"

  -- Don't show the mode, since it's already in the status line
  vim.o.showmode = false

  -- Sync clipboard between OS and Neovim.
  --  Schedule the setting after `UiEnter` because it can increase startup-time.
  vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
  end)

  -- Enable break indent
  vim.o.breakindent = true

  -- Enable undo/redo changes even after closing and reopening a file
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or one or more capital letters
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Keep signcolumn on by default
  vim.o.signcolumn = vim.g.started_by_firenvim and "no" or "yes"

  -- Decrease update time
  vim.o.updatetime = 250

  -- Decrease mapped sequence wait time
  vim.o.timeoutlen = 300

  -- Configure how new splits should be opened
  vim.o.splitright = true
  vim.o.splitbelow = true

  -- Sets how neovim will display certain whitespace characters in the editor.
  --  See `:help 'list'`
  --  and `:help 'listchars'`
  vim.o.list = true
  vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

  -- Preview substitutions live, as you type!
  vim.o.inccommand = "split"

  -- Show which line your cursor is on
  vim.o.cursorline = true

  -- Minimal number of screen lines to keep above and below the cursor.
  vim.o.scrolloff = 6

  -- if performing an operation that would fail due to unsaved changes
  -- in the buffer (like `:q`), instead raise a dialog asking if you wish
  -- to save the current file(s) See `:help 'confirm'`
  vim.o.confirm = true
end

return M
