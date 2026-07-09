---@diagnostic disable: missing-fields
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.cmd('source ~/.config/nvim/common.vim')
vim.cmd('source ~/.config/nvim/util.vim')
if vim.g.started_by_firenvim then
  vim.cmd('source ~/.config/nvim/firenvim.vim')
else
  vim.cmd('source ~/.config/nvim/startup.vim')
end

local function nmap(l, r, desc)
  vim.keymap.set('n', l, r, { silent = true, desc = desc })
end
local function vmap(l, r, desc)
  vim.keymap.set('v', l, r, { silent = true, desc = desc })
end
local center = function(columns)
  return math.max(math.floor((columns - 88) / 2), 0)
end
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options, basic keymaps, basic autocmds
-- ============================================================
do
  -- Enable faster startup by caching compiled Lua modules
  vim.loader.enable()

  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Set to true if you have a Nerd Font installed and selected in the terminal
  vim.g.have_nerd_font = false

  -- [[ Setting options ]]
  --  See `:help vim.o`
  -- NOTE: You can change these options as you wish!
  --  For more options, you can see `:help option-list`

  -- Make line numbers default
  vim.o.number = true
  -- You can also add relative line numbers, to help with jumping.
  --  Experiment for yourself to see if you like it!
  -- vim.o.relativenumber = true

  vim.o.cmdheight = 0

  -- Enable mouse mode, can be useful for resizing splits for example!
  vim.o.mouse = 'a'

  -- Don't show the mode, since it's already in the status line
  vim.o.showmode = false

  -- Sync clipboard between OS and Neovim.
  --  Schedule the setting after `UiEnter` because it can increase startup-time.
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  -- Enable break indent
  vim.o.breakindent = true

  -- Enable undo/redo changes even after closing and reopening a file
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Keep signcolumn on by default
  vim.o.signcolumn = 'yes'

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
  --
  --  Notice listchars is set using `vim.opt` instead of `vim.o`.
  --  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
  --   See `:help lua-options`
  --   and `:help lua-guide-options`
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  -- Preview substitutions live, as you type!
  vim.o.inccommand = 'split'

  -- Show which line your cursor is on
  vim.o.cursorline = true

  -- Minimal number of screen lines to keep above and below the cursor.
  vim.o.scrolloff = 6

  -- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
  -- instead raise a dialog asking if you wish to save the current file(s)
  -- See `:help 'confirm'`
  vim.o.confirm = true
end

-- ============================================================
-- SECTION 2: KEYMAPS
-- basic keymaps
-- ============================================================
do
  -- [[ Basic Keymaps ]]
  --  See `:help vim.keymap.set()`

  -- Clear highlights on search when pressing <Esc> in normal mode
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- Diagnostic Config
  --  See `:help vim.diagnostic.Opts`
  vim.diagnostic.config {
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = '󰅚 ',
        [vim.diagnostic.severity.WARN] = '󰀪 ',
        [vim.diagnostic.severity.INFO] = '󰋽 ',
        [vim.diagnostic.severity.HINT] = '󰌶 ',
      },
    } or {},
    virtual_text = {
      source = 'if_many',
      spacing = 2,
      format = function(diagnostic) return diagnostic.message end,
    },
  }

  -- Disable <Space> default behavior in normal/visual
  vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

  -- Remap for dealing with word wrap
  local jk = { expr = true, silent = true }
  vim.keymap.set({ 'n', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'", jk)
  vim.keymap.set({ 'n', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'", jk)

  -- Open URL under cursor on double-click
  nmap('<2-LeftMouse>', ':silent! !open <cfile><CR>', 'Open URL under cursor')

  -- Toggle git blame
  nmap('gb', ':BlameToggle<CR>', 'Toggle [B]lame')

  -- Diagnostic keymaps
  nmap('gE', function()
    return vim.o.spell and vim.fn.feedkeys('[s') or
      vim.diagnostic.jump({ count = -1, float = true })
  end, '[G]o to previous [E]rror')
  nmap('ge', function()
    return vim.o.spell and vim.fn.feedkeys(']s') or
      vim.diagnostic.jump({ count = 1, float = true })
  end, '[G]o to next [E]rror')
  nmap('<leader>e', vim.diagnostic.open_float, 'Open float diagnostic message')
  nmap('<leader>q', vim.diagnostic.setloclist, 'Open diagnostics list')

  -- TODO: Clean up function duplicates
  local function next_change(fallback)
    return function()
      if require("diffview.lib").get_current_view() ~= nil then
        require("diffview.actions").select_next_entry()
        if vim.fn.line('.') == 1 then
          require('gitsigns').nav_hunk('first')
        end
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(fallback, true, false, true), 'n', true)
      end
    end
  end
  local function prev_change(fallback)
    return function()
      if require("diffview.lib").get_current_view() ~= nil then
        require("diffview.actions").select_prev_entry()
        if vim.fn.line('.') == 1 then
          require('gitsigns').nav_hunk('first')
        end
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(fallback, true, false, true), 'n', true)
      end
    end
  end
  nmap('<C-j>', next_change(':cnext<CR><CR>'), 'Next quicklist item')
  nmap('<C-k>', prev_change(':cprev<CR><CR>'), 'Prev quicklist item')
  -- Navigate quickfix history with <C-h> and <C-l>
  nmap('<C-h>', ':cnewer<CR><CR>', 'Newer quicklist')
  nmap('<C-l>', ':colder<CR><CR>', 'Older quicklist')

  -- Open/focus fyler
  nmap('-', function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_get_option_value('filetype', {
        buf = vim.api.nvim_win_get_buf(win)
      }) == 'fyler_finder' then
        vim.api.nvim_set_current_win(win)
        vim.cmd('norm! 0')
        return
      end
    end
    require('fyler').open({ kind = 'split_left_most' })
  end, 'Open Fyler View')

  -- [[ Basic Autocommands ]]
  --  See `:help lua-guide-autocommands`

  -- Highlight when yanking (copying) text
  --  Try it with `yap` in normal mode
  --  See `:help vim.hl.on_yank()`
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })

  -- Disable auto commenting on new lines
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('no-auto-comment', {}),
    callback = function()
      vim.opt_local.formatoptions:remove({ 'o' })
    end,
  })
end

-- ============================================================
-- SECTION 3: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
do
  -- [[ Intro to `vim.pack` ]]
  -- `vim.pack` is a new plugin manager built into Neovim

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- This autocommand runs after a plugin is installed or updated and
  --  runs the appropriate build command for that plugin if necessary.
  --
  -- See `:help vim.pack-events`
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end

      if name == 'nvim-treesitter-textobjects' then
        -- Add queries to runtimepath without packadd (plugin init is incompatible with new nvim-treesitter)
        if vim.fn.isdirectory(ev.data.path) == 1 then
          vim.opt.runtimepath:append(ev.data.path)
        end
        return
      end

      if name == 'firenvim' then
        vim.fn['firenvim#install'](0)
        return
      end
    end,
  })
end

-- ============================================================
-- SECTION 4: UI / CORE UX PLUGINS
-- gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
  -- [[ Installing and Configuring Plugins ]]

  -- vim-fanfingtastic: extend f/t motions across lines
  vim.pack.add { gh 'dahu/vim-fanfingtastic' }

  -- vim-yankstack: yank history with cycle paste
  vim.g.yankstack_map_keys = 0
  vim.pack.add { gh 'maxbrunsfeld/vim-yankstack' }
  vim.fn['yankstack#setup']()
  nmap('<C-p>', '<Plug>yankstack_substitute_older_paste', 'Substitute older paste')
  nmap('<C-n>', '<Plug>yankstack_substitute_newer_paste', 'Substitute newer paste')
  vim.keymap.set('n', 'Y', 'y$', { silent = true, remap = true, desc = 'Yank to end of line' })

  -- Here is a more advanced configuration example that passes options to `gitsigns.nvim`
  --
  -- See `:help gitsigns` to understand what each configuration key does.
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
  require('gitsigns').setup {
    signs = {
      add = { text = '▎' }, ---@diagnostic disable-line: missing-fields
      change = { text = '▎' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '▁' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '▔' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '▎' }, ---@diagnostic disable-line: missing-fields
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      -- visual mode
      vmap('ghs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage git hunk')
      vmap('ghu', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset git hunk')
      -- normal mode
      nmap('ghs', gs.stage_hunk, 'git stage hunk')
      nmap('ghS', gs.stage_buffer, 'git stage buffer')
      nmap('ghu', gs.reset_hunk, 'git reset hunk')
      nmap('ghU', gs.reset_buffer_index, 'git reset buffer index')
      nmap('ghn', gs.next_hunk, 'next git hunk')
      nmap('ghp', gs.prev_hunk, 'prev git hunk')
      nmap('ghb', function() gs.blame_line({ full = false }) end, 'git blame line')
      nmap('<leader>gd', function()
        require('bufferline').move_to(-1)
        local changed = vim.fn.systemlist('git diff --name-only')
        local staged = vim.fn.systemlist('git diff --cached --name-only')
        local offset = #changed == 0 and #staged == 0 and 1 or 0
        gs.diffthis('HEAD~' .. vim.v.count + offset)
        vim.defer_fn(function()
          require('bufferline').move_to(-1)
        end, 200)
      end, 'git diff current file against first/nth commit')
      nmap('<leader>gb', gs.toggle_current_line_blame, 'Toggle git blame line')

      vim.keymap.set(
        { 'o', 'x' },
        'ih',
        ':<C-U>Gitsigns select_hunk<CR>',
        { desc = 'Select git hunk', buffer = bufnr }
      )
    end,
  }

  -- diffview.nvim: split diff view for all changed files
  vim.pack.add { gh 'sindrets/diffview.nvim' }
  local actions = require("diffview.actions")
  require("diffview").setup({
    keymaps = {
      view = {
        { "n", "-", actions.focus_files, { desc = "Bring focus to the file panel" } },
        -- override tab to move indent to right as >>
        { "n", "<tab>", function() vim.cmd("normal! >>") end, { desc = "Indent right" } },
        { "n", "<s-tab>", function() vim.cmd("normal! <<") end, { desc = "Indent left" } },
      },
      file_panel = {
        { "n", "<tab>", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
        { "n", "<cr>", function()
          actions.select_entry()
          vim.api.nvim_set_current_win(vim.fn.win_getid(vim.fn.winnr('$')))
          if vim.fn.line('.') == 1 then
            require('gitsigns').nav_hunk('first')
          end
        end, { desc = "Open the diff for the selected entry" },
        },
      },
    },
  })
  nmap('<leader>gad', function()
    vim.cmd(vim.v.count and 'DiffviewOpen HEAD~' .. vim.v.count or 'DiffviewOpen')
  end, 'git diff against first/nth commit')

  -- blame.nvim: git blame overlay (disabled in firenvim)
  if not vim.g.started_by_firenvim then
    vim.pack.add { gh 'FabijanZulj/blame.nvim' }
    require('blame').setup({
      date_format = '%d.%m.%Y %H:%M',
      mappings = {
        commit_info = 'ghh',
        show_commit = 'o',
        close = {},
        stack_push = {},
        stack_pop = {},
        basic = true,
        extra = true,
      },
    })
    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlameViewOpened',
      callback = function(event)
        if event.data == 'window' then
          require('barbecue.ui').toggle(false)
        end
      end,
    })
    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlameViewClosed',
      callback = function(event)
        if event.data == 'window' then
          require('barbecue.ui').toggle(true)
        end
      end,
    })
  end

  -- Useful plugin to show you pending keybinds.
  vim.pack.add { gh 'folke/which-key.nvim' }
  require('which-key').setup {
    -- Delay between pressing a key and opening which-key (milliseconds)
    delay = 400,
    icons = { mappings = vim.g.have_nerd_font },
    -- Document existing key chains
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
    },
  }

  -- [[ Colorscheme ]]
  -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command under that to load whatever the name of that colorscheme is.
  --
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  vim.pack.add { gh 'navarasu/onedark.nvim' }
  require('onedark').setup({
    highlights = {
      -- Guides
      ['FylerIndentMarker'] = { fg = '#383a42' },
      ['CursorLine'] = { bg = '#2e323c' },
      ['IblIndent'] = { fg = '#34373e' },
      -- Red comments
      ['@comment'] = { fg = '#a14646', fmt = 'italic' },
      ['@lsp.type.comment'] = { fg = '#a14646', fmt = 'italic' },
      ['confComment'] = { fg = '#a14646', fmt = 'italic' },
      ['cssComment'] = { fg = '#a14646', fmt = 'italic' },
      ['dockerfileComment'] = { fg = '#a14646', fmt = 'italic' },
      ['htmlComment'] = { fg = '#a14646', fmt = 'italic' },
      ['jsonComment'] = { fg = '#a14646', fmt = 'italic' },
      ['sqlComment'] = { fg = '#a14646', fmt = 'italic' },
      ['shComment'] = { fg = '#a14646', fmt = 'italic' },
      ['xmlComment'] = { fg = '#a14646', fmt = 'italic' },
      ['xmlCommentPart'] = { fg = '#a14646', fmt = 'italic' },
      ['yamlComment'] = { fg = '#a14646', fmt = 'italic' },
      ['zshComment'] = { fg = '#a14646', fmt = 'italic' },
      -- Highlight search hls
      ['Search'] = { bg = '#404255', fg = 'none' },
      ['IncSearch'] = { bg = '#404255', fg = 'none' },
      ['CurSearch'] = { bg = '#404255', fg = 'none' },
      ['Substitute'] = { bg = '#404255', fg = 'none' },
    },
  })

  -- Load the colorscheme here.
  -- Like many other themes, this one has different styles, and you could load
  -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
  vim.cmd.colorscheme 'onedark'

  -- Highlight todo, notes, etc in comments
  vim.pack.add { gh 'folke/todo-comments.nvim' }
  require('todo-comments').setup { signs = false }

  -- [[ mini.nvim ]]
  --  A collection of various small independent plugins/modules
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  -- If a nerd font is available, load the icons module for pretty icons in various plugins.
  if vim.g.have_nerd_font then
    require('mini.icons').setup()
    -- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
    MiniIcons.mock_nvim_web_devicons()
  end

  -- Add/delete/replace surroundings (brackets, quotes, etc.)
  vim.pack.add { gh 'tpope/vim-surround' }

  -- barbecue.nvim: winbar breadcrumbs (disabled in firenvim)
  if not vim.g.started_by_firenvim then
    vim.pack.add {
      gh 'utilyre/barbecue.nvim',
      gh 'SmiteshP/nvim-navic',
    }
    require('barbecue').setup({
      exclude_filetypes = { 'fyler', 'fyler_finder', 'toggleterm', '' },
      theme = {
        normal = { bg = '#282c34' },
      },
    })
  end

  -- dressing.nvim: improved vim.ui.input/select (disabled in firenvim)
  if not vim.g.started_by_firenvim then
    vim.pack.add { gh 'stevearc/dressing.nvim' }
    require('dressing').setup({
      input = {
        mappings = {
          i = {
            ['<Esc>'] = 'Close',
          },
        },
      },
    })
  end
end

-- ============================================================
-- SECTION 5: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
do
  ---@type (string|vim.pack.Spec)[]
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
  }
  if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end
  vim.pack.add(telescope_plugins)

  local function filenameFirst(_, path)
    local tail = vim.fs.basename(path)
    local parent = vim.fs.dirname(path)
    if parent == '.' then return tail end
    local project_root = vim.fn.getcwd()
    local user_root = vim.fn.expand('~')
    parent = parent:gsub('^' .. vim.pesc(project_root), '.')
    parent = parent:gsub('^' .. vim.pesc(user_root), '~')
    if parent == '.' then return tail end
    return string.format('%s\t\t%s', tail, parent)
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'TelescopeResults',
    callback = function(ctx)
      vim.api.nvim_buf_call(ctx.buf, function()
        vim.fn.matchadd('TelescopeParent', '\t\t.*$')
        vim.api.nvim_set_hl(0, 'TelescopeParent', { link = 'Comment' })
      end)
    end,
  })

  require('telescope').setup {
    defaults = {
      file_ignore_patterns = { '.git/' },
      mappings = {
        i = {
          ['<esc>'] = require('telescope.actions').close,
          ['<C-p>'] = require('telescope.actions').cycle_history_prev,
          ['<C-n>'] = require('telescope.actions').cycle_history_next,
        },
      },
      sorting_strategy = 'ascending',
      layout_config = { prompt_position = 'top' },
      path_display = filenameFirst,
    },
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_cursor() },
    },
    pickers = {
      git_status = {
        attach_mappings = function()
          require('telescope.actions').select_default:enhance({
            post = function()
              local current_file = vim.fn.expand('%')
              local diff = vim.fn.system('git diff -- ' .. current_file)
              local firstLineChanged = string.match(diff, '@@ %-(%d+)')
              if firstLineChanged then
                vim.cmd('normal! ' .. firstLineChanged .. 'G3jzt')
              end
            end,
          })
          return true
        end,
      },
      find_files = {
        on_input_filter_cb = function(prompt)
          local find_colon = string.find(prompt, ':') or string.find(prompt, '%(')
          if find_colon then
            local ret = string.sub(prompt, 1, find_colon - 1)
            local lnum = tonumber(string.sub(prompt, find_colon + 1))
            vim.g.telescope_find_files_line = lnum
            return { prompt = ret }
          else
            vim.g.telescope_find_files_line = nil
          end
        end,
        attach_mappings = function()
          require('telescope.actions').select_default:enhance({
            post = function()
              if vim.g.telescope_find_files_line then
                vim.api.nvim_win_set_cursor(0, { vim.g.telescope_find_files_line, 0 })
                vim.g.telescope_find_files_line = nil
              end
            end,
          })
          return true
        end,
      },
      oldfiles = {
        attach_mappings = function()
          require('telescope.actions').select_default:enhance({
            post = function()
              vim.cmd('silent! normal! `.')
              if vim.fn.line('.') == 1 then vim.cmd('silent! normal! `"') end
            end,
          })
          return true
        end,
      },
    },
  }

  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  -- Telescope LSP keymaps on attach
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
      vim.keymap.set('n', 'gad', builtin.lsp_references, { buffer = buf, desc = '[G]oto References' })
      vim.keymap.set('n', 'gI', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
      vim.keymap.set('n', '<leader>D', builtin.lsp_type_definitions, { buffer = buf, desc = 'Type [D]efinition' })
      vim.keymap.set('n', 'gs', builtin.lsp_document_symbols, { buffer = buf, desc = '[D]ocument [S]ymbols' })
      vim.keymap.set('n', 'gas', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = '[A]ll workspace [S]ymbols' })
    end,
  })

  -- Telescope keymaps
  local builtin = require 'telescope.builtin'
  nmap('<leader>o', builtin.oldfiles, '[o] Find recently opened files')
  nmap('<leader><space>', builtin.builtin, '[ ] Find existing buffers')
  nmap('<leader>ö', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
      winblend = 10,
      previewer = false,
    }))
  end, '[ö] Fuzzily search in current buffer')
  nmap('<leader>sr', builtin.resume, '[S]earch [R]esume')

  -- User commands
  local function gitStatus()
    if vim.bo.filetype == 'fyler_finder' then vim.cmd('BufferLineCycleNext') end
    local changed = vim.fn.systemlist('git diff --name-only')
    local staged = vim.fn.systemlist('git diff --cached --name-only')
    if #changed == 0 and #staged == 0 then
      builtin.git_commits()
    else
      builtin.git_status()
    end
  end
  vim.api.nvim_create_user_command('GitStatus', gitStatus, {})

  vim.api.nvim_create_user_command('TelescopeGrep', function()
    if vim.bo.filetype == 'fyler_finder' then vim.cmd('BufferLineCycleNext') end
    builtin.live_grep({ additional_args = { '--fixed-strings', '--hidden' } })
  end, {})

  vim.api.nvim_create_user_command('TelescopeFindFiles', function()
    if vim.bo.filetype == 'fyler_finder' then vim.cmd('BufferLineCycleNext') end
    builtin.find_files({ sort_mtime = true, hidden = true })
  end, {})

  vim.api.nvim_create_user_command('CodeActionFixAll', function()
    vim.lsp.buf.code_action({
      filter = function(action)
        return string.find(action.command.title, 'Fix all auto') ~= nil
      end,
      apply = true,
    })
  end, {})

  vim.api.nvim_create_user_command('CodeActionOpen', function()
    vim.lsp.buf.code_action({ layout = 'cursor' })
  end, {})

  local function find_git_root()
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir = current_file == '' and vim.fn.getcwd() or vim.fn.fnamemodify(current_file, ':h')
    local git_root = vim.fn.systemlist(
      'git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel'
    )[1]
    if vim.v.shell_error ~= 0 then
      print 'Not a git repository. Searching on current working directory'
      return vim.fn.getcwd()
    end
    return git_root
  end

  vim.api.nvim_create_user_command('LiveGrepGitRoot', function()
    if vim.bo.filetype == 'fyler_finder' then vim.cmd('BufferLineCycleNext') end
    local git_root = find_git_root()
    if git_root then builtin.live_grep({ search_dirs = { git_root } }) end
  end, {})
end

-- ============================================================
-- SECTION 6: LSP
-- LSP keymaps, server configuration, Mason tools installations
-- ============================================================
do
  -- [[ LSP Configuration ]]
  -- Brief aside: **What is LSP?**
  --
  -- LSP is an initialism you've probably heard, but might not understand what it is.
  --
  -- LSP stands for Language Server Protocol. It's a protocol that helps editors
  -- and language tooling communicate in a standardized fashion.
  --
  -- In general, you have a "server" which is some tool built to understand a particular
  -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
  -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
  -- processes that communicate with some "client" - in this case, Neovim!
  --
  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --
  -- Thus, Language Servers are external tools that must be installed separately from
  -- Neovim. This is where `mason` and related plugins come into play.
  --
  -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
  -- and elegantly composed help section, `:help lsp-vs-treesitter`

  --  This function gets run when an LSP attaches to a particular buffer.
  --    That is to say, every time a new file is opened that is associated with
  --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
  --    function will be executed to configure the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      local lsp = vim.lsp.buf

      nmap('gr', lsp.rename, '[G]oto [R]ename')
      nmap('ghh', lsp.hover, '[G]oto [H]over Documentation')
      nmap('gD', lsp.declaration, '[G]oto [D]eclaration')
      nmap('<leader>wa', lsp.add_workspace_folder, '[W]orkspace [A]dd Folder')
      nmap('<leader>wr', lsp.remove_workspace_folder, '[W]orkspace [R]emove Folder')
      nmap('<leader>wl', function()
        print(vim.inspect(lsp.list_workspace_folders()))
      end, '[W]orkspace [L]ist Folders')

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server you are using supports them
      --
      -- This may be unwanted, since they displace some of your code
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        nmap('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --  See `:help lsp-config` for information about keys and how to configure
  ---@type table<string, vim.lsp.Config>
  local servers = {
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    --    https://github.com/pmizio/typescript-tools.nvim
    --
    tsgo = {
      filetypes = {
        'typescript', 'typescriptreact', 'typescript.tsx',
      },
    },
    eslint = {
      filetypes = {
        'javascript', 'javascriptreact', 'javascript.jsx',
        'typescript', 'typescriptreact', 'typescript.tsx',
      },
      format = { enable = true },
    },
    html = { filetypes = { 'html', 'twig', 'hbs' } },
    jsonls = { filetypes = { 'json', 'jsonc' } },
    vimls = { filetypes = { 'vim' } },

    stylua = {}, -- Used to format Lua code

    -- Special Lua Config, as recommended by neovim help docs
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        client.config.settings.Lua = vim.tbl_deep_extend(
          'force',
          (client.config.settings.Lua or {}) --[[@as table]],
          {
            runtime = {
              version = 'LuaJIT',
              path = { 'lua/?.lua', 'lua/?/init.lua' },
            },
            workspace = {
              checkThirdParty = false,
              -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
              --  See https://github.com/neovim/nvim-lspconfig/issues/3189
              library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                '${3rd}/luv/library',
                '${3rd}/busted/library',
              }),
            },
          }
        )
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false }, -- Disable formatting (formatting is done by stylua)
        },
      },
    },
  }

  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  }

  -- Automatically install LSPs and related tools to stdpath for Neovim
  require('mason').setup {}

  -- Ensure the servers and tools above are installed
  --
  -- To check the current status of installed tools and/or manually install
  -- other tools, you can run
  --    :Mason
  --
  -- You can press `g?` for help in this menu.
  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    -- You can add other tools here that you want Mason to install
  })

  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- ============================================================
-- SECTION 7: FORMATTING
-- vim-prettier with LSP format fallback
-- ============================================================
do
  -- [[ Formatting ]]
  -- Use vim-prettier with LSP format as fallback instead of conform.nvim
  vim.pack.add { gh 'prettier/vim-prettier' }

  vim.api.nvim_create_user_command('PrettierOrFormat', function()
    vim.cmd('silent! Prettier')
    if vim.v.shell_error ~= 0 then
      vim.lsp.buf.format()
    end
  end, {})

  nmap('<leader>f', ':PrettierOrFormat<CR>', '[F]ormat buffer')
end

-- ============================================================
-- SECTION 8: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup
-- ============================================================
do
  -- [[ Autopairs, autodetect indent ]]
  vim.pack.add { gh 'windwp/nvim-autopairs' }
  require('nvim-autopairs').setup()
  vim.pack.add { gh 'tpope/vim-sleuth' }

  -- [[ Snippet Engine ]]
  -- NOTE: You can also specify plugin using a version range for its git tag.
  --  See `:help vim.version.range()` for more info
  vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
  require('luasnip').setup {}
  local luasnip = require('luasnip')
  require('luasnip.loaders.from_vscode').lazy_load({
    paths = '~/.config/nvim/snippets',
  })
  luasnip.config.setup()

  -- `friendly-snippets` contains a variety of premade snippets.
  --    See the README about individual language/framework/plugin snippets:
  --    https://github.com/rafamadriz/friendly-snippets
  --
  -- vim.pack.add { gh 'rafamadriz/friendly-snippets' }
  -- require('luasnip.loaders.from_vscode').lazy_load()

  -- [[ Autocomplete Engine ]]
  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
  require('blink.cmp').setup {
    enabled = function()
      return vim.bo.filetype ~= 'fyler_finder'
        and vim.bo.buftype ~= 'nofile'
        and vim.bo.buftype ~= 'prompt'
        and vim.b.completion ~= false
    end,
    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- For an understanding of why the 'default' preset is recommended,
      -- you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See `:help blink-cmp-config-keymap` for defining your own keymap
      preset = 'default',

      -- Complete copilot with tab and select with enter
      ['<CR>'] = { 'select_and_accept', 'fallback' },

      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },

    completion = {
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
      menu = {
        auto_show = true,
      },
      list = {
        selection = {
          auto_insert = false,
        }
      },
      ghost_text = { enabled = false },
    },

    sources = {
      default = {
        'lsp', 'path', 'buffer', 'snippets'
      },
      providers = {
        snippets = {
          min_keyword_length = 4,
        }
      }
    },

    snippets = { preset = 'luasnip' },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See `:help blink-cmp-config-fuzzy` for more information
    fuzzy = { implementation = 'lua' },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  }
end

-- ============================================================
-- SECTION 9: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
  -- [[ Configure Treesitter ]]
  --  Used to highlight, edit, and navigate code
  --
  --  See `:help nvim-treesitter-intro`

  -- NOTE: You can also specify a branch or a specific commit
  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  -- Provides textobjects queries and select module for af/if (function) and ac/ic (class).
  -- NOTE: The plugin's Lua init is incompatible with the new nvim-treesitter API, so we
  -- add it to runtimepath directly instead of using packadd (which sources plugin/*.vim).
  vim.pack.add { gh 'nvim-treesitter/nvim-treesitter-textobjects' }
  local textobj_path = vim.fn.stdpath('data') .. '/site/pack/core/opt/nvim-treesitter-textobjects'
  if vim.fn.isdirectory(textobj_path) == 1 then
    vim.opt.runtimepath:append(textobj_path)
    -- af/if = function outer/inner, ac/ic = class outer/inner
    local ts_select = require('nvim-treesitter-textobjects.select')
    for lhs, query in pairs({
      af = '@function.outer', ['if'] = '@function.inner',
      ac = '@class.outer',    ic    = '@class.inner',
    }) do
      vim.keymap.set({ 'x', 'o' }, lhs, function()
        ts_select.select_textobject(query, 'textobjects')
      end, { desc = 'Textobject: ' .. query })
    end
  end

  -- Ensure basic parsers are installed
  local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
  require('nvim-treesitter').install(parsers)

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- Check if a parser exists and load it
    if not vim.treesitter.language.add(language) then return end
    -- Enable syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)

    -- Enable treesitter based folds
    -- For more info on folds see `:help folds`
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- vim.wo.foldmethod = 'expr'

    -- Check if treesitter indentation is available for this language, and if so enable it
    -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

    -- Enable treesitter based indentation
    if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = require('nvim-treesitter').get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

      if vim.tbl_contains(installed_parsers, language) then
        -- Enable the parser if it is already installed
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
        require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
        treesitter_try_attach(buf, language)
      end
    end,
  })
end

-- ============================================================
-- SECTION 10: FYLER
-- File explorer using fyler.nvim
-- ============================================================
do
  vim.pack.add {
    gh 'A7Lavinraj/fyler.nvim',
    gh 'nvim-tree/nvim-web-devicons',
  }

  require('fyler').setup({
    integrations = {
      icon = 'nvim_web_devicons',
      window_picker = function()
        local windows = vim.fn.getwininfo()
        for _, win in ipairs(windows) do
          local buf = win.bufnr
          local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
          if filetype ~= 'toggleterm'
            and filetype ~= 'fyler_finder'
            and filetype ~= 'copilot-cli'
            and filetype ~= 'quickfix'
            and filetype ~= 'blame'
            and filetype ~= 'git' then
            return win.winid
          end
        end
        return nil
      end,
    },
    kind = 'split_left_most',
    kind_presets = {
      split_left_most = {
        width = center(vim.o.columns),
        win_opts = {
          cursorline = true,
          number = false,
          relativenumber = false,
        },
      },
    },
    auto_confirm_simple_mutation = true,
    use_as_default_explorer = true,
    follow_current_file = true,
    extensions = {
      watcher = { enabled = true },
    },
    mappings = {
      n = {
        ['q'] = { disabled = true },
        ['<C-T>'] = { disabled = true },
        ['g.'] = { disabled = true },
        ['.'] = { action = 'toggle_ui', args = { 'hidden_items' } },
        ['<S-CR>'] = { action = 'select', args = { pick = true } },
        ['-'] = { action = 'shrink', args = { parent = true } },
        ['<BS>'] = { action = 'visit', args = { parent = true } },
        ['<D-c>'] = {
          action = function(instance)
            local libpath = require('fyler.lib.path')
            local state = require('fyler.state')

            -- Fyler prefixes each finder line with a numeric id (e.g. "00023 init.lua")
            -- that maps back to the fs entry in fyler.state's store, so grab the raw
            -- line under the cursor to extract that id.
            local buf_line = vim.api.nvim_buf_call(
              instance.buf_id,
              function()
                return vim.api.nvim_get_current_line()
              end
            )
            local id = buf_line:match('(%d+)')
            if not id then return end

            -- Look up the actual file/dir entry (with its absolute path) for this id.
            local node_data = state.store[tonumber(id, 10)]
            if not node_data then return end

            -- Convert to a path relative to the finder's root, then copy it to the
            -- system clipboard register so it can be pasted elsewhere (e.g. config/init.lua).
            local relative_path = libpath.to_rel(instance.opts.root_path, node_data.path)
            vim.fn.setreg('+', relative_path)
            vim.g.clipboard_status = relative_path
          end
        },
      },
    },
  })

  local resizeFyler = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf_type = vim.api.nvim_get_option_value('filetype', {
        buf = vim.api.nvim_win_get_buf(win),
      })
      if buf_type == 'fyler_finder' then
        vim.api.nvim_win_set_width(win, center(vim.o.columns))
      end
      vim.cmd('wincmd =')
    end
  end

  vim.api.nvim_create_autocmd('VimResized', {
    callback = resizeFyler,
  })
end

-- ============================================================
-- SECTION 11: TOGGLETERM
-- Terminal integration
-- ============================================================
do
  vim.pack.add { gh 'akinsho/nvim-toggleterm.lua' }

  require('toggleterm').setup({
    open_mapping = [[<C-w><C-t>]],
    auto_scroll = false,
    start_in_insert = false,
  })

  vim.api.nvim_create_autocmd('TermEnter', {
    pattern = 'term://*toggleterm#*',
    callback = function()
      vim.cmd([[
        setlocal nonu nornu signcolumn=no

        tnoremap <buffer><silent><Esc> <C-\><C-n>
        nnoremap <buffer><silent>git igit

        " Split terminal on write command
        nnoremap <buffer><silent>:write <C-\><C-n>:execute b:toggle_number + 1 . 'ToggleTerm'

        " Checkout to branch under cursor
        nnoremap <buffer><silent> gc :execute b:toggle_number . "TermExec cmd='git checkout <c-r>=expand("<cWORD>")<cr>' go_back=0"<CR>
      ]])
    end,
  })
end

-- ============================================================
-- SECTION 12: BUFFERLINE
-- Tab-style buffer display with diagnostics
-- ============================================================
do
  vim.pack.add { gh 'akinsho/bufferline.nvim' }

  vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    callback = function()
      if vim.bo.filetype == 'fyler_finder' then
        vim.api.nvim_set_hl(0, 'BufferStatusFyler', { fg = '#abb2bf', bg = '#16181c' })
      else
        vim.api.nvim_set_hl(0, 'BufferStatusFyler', { fg = '#5c6370', bg = '#16181c' })
      end
      if vim.bo.filetype == 'copilot-cli' then
        vim.api.nvim_set_hl(0, 'BufferStatusCopilot', { fg = '#abb2bf', bg = '#16181c' })
      else
        vim.api.nvim_set_hl(0, 'BufferStatusCopilot', { fg = '#5c6370', bg = '#16181c' })
      end
    end,
  })

  require('bufferline').setup({
    options = {
      max_name_length = 40,
      diagnostics = 'nvim_lsp',
      separator_style = 'slant',
      custom_filter = function(buf_number, buf_numbers)
        if vim.bo[buf_number].filetype ~= 'copilot-cli' then
          return true
        end
      end,
      offsets = {
        {
          filetype = 'fyler_finder',
          text = function()
            local nvimtree = 1
            local terminals = #require('toggleterm.terminal').get_all(true)

            local bufferList = vim.fn.getbufinfo({ buflisted = 1 })
            local copilot_cli = 0
            for _, buf in ipairs(bufferList) do
              if vim.bo[buf.bufnr].filetype == 'copilot-cli' then
                copilot_cli = 1
                break
              end
            end
            local buffers = #bufferList - copilot_cli

            local modifiedRaw = #vim.fn.getbufinfo({ bufmodified = 1 })
            local modified = modifiedRaw - terminals - nvimtree
            return buffers .. ' Buffers'
              .. (modified > 0 and (' (' .. modified .. ' modified)') or '')
              .. (terminals > 0 and (' (' .. terminals) .. ' Terminals)' or '')
          end,
          text_align = 'center',
          highlight = 'BufferStatusFyler',
        },
        {
          filetype = 'copilot-cli',
          text = 'Copilot CLI',
          text_align = 'center',
          highlight = 'BufferStatusCopilot',
        }
      },
      always_show_bufferline = false,
      diagnostics_indicator = function(_, level)
        return level:match('error') and '' or ''
      end,
    },
  })

  -- Always open new buffers at the last position
  vim.api.nvim_create_autocmd('BufAdd', {
    pattern = '*',
    callback = function()
      vim.defer_fn(function()
        if #vim.fn.getbufinfo({ buflisted = 1 }) > 1 then
          require('bufferline').move_to(-1)
        end
      end, 100)
    end,
  })

  -- vim-bufkill: close buffer without closing the window
  vim.pack.add { gh 'qpkorr/vim-bufkill' }

  -- stickybuf.nvim: pin buffers to windows (disabled in firenvim)
  if not vim.g.started_by_firenvim then
    vim.pack.add { gh 'stevearc/stickybuf.nvim' }
    require('stickybuf').setup({
      get_auto_pin = function(bufnr)
        local windows = vim.fn.getwininfo()
        if #windows == 1 then
          return false
        end
        return vim.bo[bufnr].filetype == 'toggleterm'
          or vim.bo[bufnr].filetype == 'fyler_finder'
          or vim.bo[bufnr].filetype == 'copilot-cli'
          or vim.bo[bufnr].filetype == 'quickfix'
          or vim.bo[bufnr].filetype == 'blame'
          or vim.bo[bufnr].filetype == 'git'
      end,
    })
  end
end

-- ============================================================
-- SECTION 13: LUALINE
-- Status line with LSP progress, copilot, quickfix, clipboard
-- ============================================================
do
  vim.pack.add { gh 'nvim-lualine/lualine.nvim' }

  if not vim.g.started_by_firenvim then
    local spinners = { '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏', '⠋' }

    local function split(str, char)
      local comma_index = string.find(str, char)
      if comma_index then
        return string.sub(str, 1, comma_index - 1)
      else
        return str
      end
    end

    local function lsp_progress()
      local status = vim.lsp.status():gsub('%%', '%%%%')
      if status ~= '' then
        vim.g.lsp_progress_status = status
        vim.g.lsp_progress_spinner = (vim.g.lsp_progress_spinner or 0) % #spinners + 1
        return spinners[vim.g.lsp_progress_spinner or 1] .. ' ' .. split(vim.g.lsp_progress_status, ',')
      end
      if vim.g.lsp_progress_spinner > 1 then
        vim.g.lsp_progress_spinner = (vim.g.lsp_progress_spinner or 0) % #spinners + 1
        return spinners[vim.g.lsp_progress_spinner or 1] .. ' ' .. split(vim.g.lsp_progress_status, ',')
      end
      return ''
    end

    local function qf()
      local qf_list = vim.fn.getqflist()
      local qf_name = vim.fn.get(vim.fn.getqflist({ title = 1 }), 'title')
      qf_name = qf_name:gsub(' %(%)', '')
      if #qf_list > 0 then
        local qf_index = vim.fn.get(vim.fn.getqflist({ idx = 0 }), 'idx', 0)
        return qf_name .. ' ' .. qf_index .. '/' .. #qf_list
      end
      return ''
    end

    local function record()
      return vim.fn.reg_recording()
    end

    local function copilot()
      if vim.g._copilot_timer then
        vim.g.copilot_spinner = (vim.g.copilot_spinner or 0) % #spinners + 1
        return spinners[vim.g.copilot_spinner or 1]
      end
      if vim.g.copilot_spinner > 1 then
        vim.g.copilot_spinner = (vim.g.copilot_spinner or 0) + 1
        if vim.b._copilot.suggestions or vim.g.copilot_spinner > 400 then
          vim.g.copilot_spinner = 0
        end
        return spinners[vim.g.copilot_spinner % #spinners + 1]
      end
      return vim.call('copilot#Enabled') == 1 and '' or ''
    end

    local function clipboard()
      local message = vim.g.clipboard_status
      if message ~= '' then
        vim.defer_fn(function()
          if vim.g.clipboard_status == message then
            vim.g.clipboard_status = ''
          end
        end, 2000)
        return '  ' .. vim.g.clipboard_status
      end
      return ''
    end

    require('lualine').setup({
      options = {
        icons_enabled = true,
        theme = 'onedark',
        component_separators = { left = ' ', right = ' ' },
        section_separators = { left = ' ', right = ' ' },
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 100,
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { 'diagnostics', lsp_progress, qf, clipboard },
        lualine_x = { 'location', 'encoding', 'fileformat' },
        lualine_y = { 'filetype', copilot },
        lualine_z = { record },
      },
    })
  end
end

-- ============================================================
-- SECTION 14: VISUALIZE CODE INDENTATION COLORS AND GUIDES
-- indent-blankline, colorizer, virt-column, scrollbar, visual-whitespace
-- ============================================================
do
  vim.pack.add { gh 'lukas-reineke/indent-blankline.nvim' }
  require('ibl').setup({
    exclude = { filetypes = { 'fyler' } },
    indent = {
      tab_char = { '▌' },
    },
    scope = {
      show_start = false,
      highlight = { 'Comment' },
      show_end = false,
    },
    whitespace = {
      remove_blankline_trail = false,
    },
  })

  vim.pack.add { gh 'NvChad/nvim-colorizer.lua' }
  require('colorizer').setup({
    filetypes = { '*' },
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
      mode = 'background',
      sass = { enable = false, parsers = { 'css' } },
      virtualtext = '?',
    },
  })

  if not vim.g.started_by_firenvim then
    vim.pack.add { gh 'lukas-reineke/virt-column.nvim' }
    require('virt-column').setup({
      -- use thick ibl char
      char = '▎',
      highlight = 'IblIndent',
      buftype = { 'terminal' },
      exclude = {
        filetypes = { 'fyler' },
      },
    })
  end

  if not vim.g.started_by_firenvim then
    vim.pack.add { gh 'kevinhwang91/nvim-hlslens' }
    vim.pack.add { gh 'petertriho/nvim-scrollbar' }

    require('scrollbar.handlers.search').setup({
      override_lens = function() end,
    })
    require('hlslens').enable()

    local options = { noremap = true, silent = true }
    local normal = function(arg, count)
      if count then
        return function()
          vim.cmd('normal! ' .. vim.v.count1 .. arg)
          require('hlslens').start()
        end
      end
      return function()
        vim.cmd('normal! ' .. arg)
        require('hlslens').start()
      end
    end
    vim.keymap.set('n', '*', normal('*'), options)
    vim.keymap.set('n', '#', normal('#'), options)
    vim.keymap.set('n', 'g*', normal('g*'), options)
    vim.keymap.set('n', 'g#', normal('g#'), options)
    vim.keymap.set('n', 'n', normal('n', true), options)
    vim.keymap.set('n', 'N', normal('N', true), options)

    require('scrollbar').setup({
      excluded_buftypes = {
        'terminal',
        'nofile',
      },
      disabled = vim.g.started_by_firenvim,
      handle = {
        highlight = 'Cursor',
        blend = 90,
      },
      handlers = {
        cursor = false,
        gitsigns = true,
      },
      marks = {
        GitDelete = {
          text = '┆',
        },
        Search = {
          color = '#5c6370',
        },
      },
    })
  end

  vim.pack.add { gh 'mcauley-penney/visual-whitespace.nvim' }
  require('visual-whitespace').setup({
    highlight = { fg = '#181a1f', bg = '#404255' },
    space_char = ' ',
    excluded = {
      buftypes = { 'terminal' },
      filetypes = { 'fyler' },
    },
  })
end

-- ============================================================
-- SECTION 15.1: FIRENVIM
-- Embed Neovim in browser text fields
-- ============================================================
do
  -- glacambre/firenvim: loads normally when started by firenvim,
  -- otherwise just installed in the background for browser extension use.
  vim.pack.add { gh 'glacambre/firenvim' }
end

-- ============================================================
-- SECTION 15.2: COPILOT
-- Copilot terminal (disabled in firenvim), with inline suggestions
-- ============================================================
do
  vim.pack.add { gh 'github/copilot.vim' }
  if not vim.g.started_by_firenvim then
    local copilot_bufnr = nil
    local copilot_winid = nil

    local function open_copilot_term()
      vim.cmd('vertical botright ' .. center(vim.o.columns) .. 'split')
      if copilot_bufnr and vim.api.nvim_buf_is_valid(copilot_bufnr) then
        vim.api.nvim_win_set_buf(0, copilot_bufnr)
      else
        vim.cmd('enew')
        vim.fn.jobstart('copilot', { term = true })
        copilot_bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_set_option_value('filetype', 'copilot-cli', { buf = copilot_bufnr })

        vim.keymap.set(
          't',
          '<Esc>',
          [[<C-\><C-n>]],
          { buffer = copilot_bufnr }
        )

        -- copilot-cli's TUI scrolls via mouse wheel (SGR mouse reporting),
        -- not Ctrl-d/Ctrl-u, so emulate wheel events from Normal mode.
        local function send_wheel(direction, lines)
          local button = direction == 'up' and 64 or 65
          return function()
            local width = vim.api.nvim_win_get_width(0)
            local height = vim.api.nvim_win_get_height(0)
            local col, row = math.floor(width / 2), math.floor(height / 2)
            local event = string.format('\27[<%d;%d;%dM', button, col, row)
            vim.api.nvim_chan_send(vim.bo.channel, event:rep(lines))
          end
        end

        vim.keymap.set('n', '<C-u>', send_wheel('up', 4), { buffer = copilot_bufnr, desc = 'Scroll copilot terminal up' })
        vim.keymap.set('n', '<C-d>', send_wheel('down', 4), { buffer = copilot_bufnr, desc = 'Scroll copilot terminal down' })
      end
      copilot_winid = vim.api.nvim_get_current_win()
      vim.cmd('startinsert')
    end

    vim.keymap.set({ 'n' }, 'cc', function()
      if copilot_winid and vim.api.nvim_win_is_valid(copilot_winid) then
        vim.api.nvim_win_close(copilot_winid, false)
        copilot_winid = nil
      else
        open_copilot_term()
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true),
          'n',
          true
        )
      end
    end, { desc = 'Toggle Copilot terminal' })

    local resizeCopilotCLI = function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf_type = vim.api.nvim_get_option_value('filetype', {
          buf = vim.api.nvim_win_get_buf(win),
        })
        if buf_type == 'copilot-cli' then
          vim.api.nvim_win_set_width(win, center(vim.o.columns))
        end
      end
    end

    vim.api.nvim_create_autocmd('VimResized', {
      callback = resizeCopilotCLI,
    })
  end
end

-- ============================================================
-- SECTION 15.3: NX
-- Nx monorepo integration via Telescope
-- ============================================================
do
  vim.pack.add { gh 'Equilibris/nx.nvim' }
  require('nx').setup({
    nx_cmd_root = 'npx nx',
    telescope = {
      layout_strategy = 'vertical',
      layout_config = {
        width = 0.9,
        height = 0.9,
        prompt_position = 'top',
      },
    },
  })
  nmap('cn', '<cmd>Telescope nx actions<CR>', 'nx actions')
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
