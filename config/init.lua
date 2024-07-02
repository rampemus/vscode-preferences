vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.cmd('source ~/.config/nvim/common.vim')
vim.cmd('source ~/.config/nvim/util.vim')
if vim.g.started_by_firenvim then
  vim.cmd('source ~/.config/nvim/firenvim.vim')
else
  vim.cmd('source ~/.config/nvim/startup.vim')
end

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Git related plugins
  {
    'FabijanZulj/blame.nvim',
    enabled = not vim.g.started_by_firenvim,
    event = 'VeryLazy',
    config = function()
      require('blame').setup({
        date_format = '%d.%m.%Y %H:%M',
        mappings = {
          commit_info = 'ghh',
          show_commit = 'o',
          close = { },
        }
      })
    end,
  },
  'tpope/vim-rhubarb',

  'dahu/vim-fanfingtastic',
  'tpope/vim-surround',
  'tpope/vim-repeat',
  {
    'maxbrunsfeld/vim-yankstack',
    event = 'VeryLazy',
    config = function()
      vim.g.yankstack_map_keys = 0
      local function nmap(l, r, opts)
        vim.keymap.set('n', l, r, opts)
      end

      -- Navigate yanks with <C-p> and <C-n>
      nmap(
        '<C-p>',
        '<Plug>yankstack_substitute_older_paste',
        { silent = true, desc = 'Substitute older paste' }
      )
      nmap(
        '<C-n>',
        '<Plug>yankstack_substitute_newer_paste',
        { silent = true, desc = 'Substitute newer paste' }
      )
    end,
  },
  -- 'tpope/vim-vinegar',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    enabled = not vim.g.started_by_firenvim,
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'prettier/vim-prettier',

      -- Useful status updates for LSP
      { 'arkav/lualine-lsp-progress', opts = {
        options = {
          display_components = { 'lsp_client_name', {'percentage', 'message' } },
        },
      }},

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'VeryLazy',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    opts = {},
    event = 'VeryLazy',
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    enabled = not vim.g.started_by_firenvim,
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '▁' },
        topdelete = { text = '▔' },
        changedelete = { text = '▎' },
      },
      signs_staged = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '▁' },
        topdelete = { text = '▔' },
        changedelete = { text = '▎' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', 'ghs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'stage git hunk' })
        map('v', 'ghu', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', 'ghs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', 'ghS', gs.stage_buffer, { desc = 'git stage buffer' })
        map('n', 'ghu', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', 'ghU', gs.reset_buffer_index, { desc = 'git reset buffer index' })
        map('n', 'ghp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', 'ghn', gs.next_hunk, { desc = 'next git hunk' })
        map('n', 'ghp', gs.prev_hunk, { desc = 'prev git hunk' })
        map('n', 'ghb', function()
          gs.blame_line({ full = false })
        end, { desc = 'git blame line' })
        map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>gD', function()
          local changed = vim.fn.systemlist('git diff --name-only')
          local staged = vim.fn.systemlist('git diff --cached --name-only')
          local offset = #changed == 0 and #staged == 0 and 1 or 0
          gs.diffthis('HEAD~' .. vim.v.count + offset)
        end, { desc = 'git diff against first/nth commit' })

        -- Toggles
        map('n', '<leader>gb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>gd', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      require('onedark').setup({
        highlights = {
          -- Guides
          ['NvimTreeIndentMarker'] = { fg = '#383a42' },
          ['CursorLine'] = { bg = '#2e323c' },
          ['IblIndent'] = { fg = '#34373e' },
          -- Red comments
          ['@comment'] = { fg = '#a14646', fmt = 'italic' },
          ['@lsp.type.comment'] = { fg = '#a14646', fmt = 'italic' },
          ['zshComment'] = { fg = '#a14646', fmt = 'italic' },
          ['cssComment'] = { fg = '#a14646', fmt = 'italic' },
          ['xmlComment'] = { fg = '#a14646', fmt = 'italic' },
          ['xmlCommentPart'] = { fg = '#a14646', fmt = 'italic' },
          ['htmlComment'] = { fg = '#a14646', fmt = 'italic' },
          ['yamlComment'] = { fg = '#a14646', fmt = 'italic' },
          -- Highlight search hls
          ['Search'] = { bg = '#404255', fg = 'none' },
          ['IncSearch'] = { bg = '#404255', fg = 'none' },
          ['CurSearch'] = { bg = '#404255', fg = 'none' },
          ['Substitute'] = { bg = '#404255', fg = 'none' },
        },
      })
      vim.cmd.colorscheme('onedark')
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    enabled = not vim.g.started_by_firenvim,
    config = function()
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
          local spinners = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
          vim.g.copilot_spinner = (vim.g.copilot_spinner or 0) % #spinners + 1
          return spinners[vim.g.copilot_spinner or 1]
        end
        return vim.call('copilot#Enabled') == 1 and '' or ''
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
            statusline = 500,
          },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff' },
          lualine_c = { 'diagnostics', 'lsp_progress', qf },
          lualine_x = { 'location', 'encoding', 'fileformat' },
          lualine_y = { 'filetype', copilot },
          lualine_z = { record },
        },
      })
    end,
  },

  {
    'altermo/ultimate-autopair.nvim',
    event = 'VeryLazy',
    opts = {
      cr = {
        -- enable = false,
      },
      bs = {
        enable = false,
      },
      space = {
        enable = false,
      },
      extensions={
        filetype={
          nft = {
            'TelescopePrompt',
            'vim'
          }
        },
      },
    },
  },

  -- Visualize code indentation colors and guides
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'VeryLazy',
    main = 'ibl',
    opts = {
      scope = {
        show_start = false,
        show_end = false,
      },
      whitespace = {
        remove_blankline_trail = false,
      },
    },
  },
  {
    'NvChad/nvim-colorizer.lua',
    event = 'VeryLazy',
    config = function()
      require('colorizer').setup({
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
          sass = { enable = false, parsers = { "css" }, },
          virtualtext = "?",
        },
      })
    end,
  },
  {
    'lukas-reineke/virt-column.nvim',
    event = 'VeryLazy',
    opts = {
      -- use thick ibl char
      char = '▎',
      highlight = 'IblIndent',
      buftype = { 'terminal' },
    }
  },
  {
    'petertriho/nvim-scrollbar',
    enabled = not vim.g.started_by_firenvim,
    event = 'VeryLazy',
    opts = {
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
      }
    },
  },
  {
    'mcauley-penney/visual-whitespace.nvim',
    event = 'VeryLazy',
    config = false,
    opts = {
      highlight = { link = 'Visual' },
      space_char = ' ',
    }
  },

  {
    'akinsho/nvim-toggleterm.lua',
    event = 'VeryLazy',
    enabled = not vim.g.started_by_firenvim,
    config = function()
      require('toggleterm').setup({
        open_mapping = [[<C-w><C-t>]],
      })
      vim.api.nvim_create_autocmd('TermEnter', {
        callback = function()
          vim.cmd([[
            tnoremap <silent><Esc> <C-\><C-n>

            " Split terminal on write command
            tnoremap <silent>write <C-\><C-n>:execute b:toggle_number + 1 . 'ToggleTerm'

            " Navigate terminals in insert mode
            tnoremap <silent>BNext <C-\><C-n>:BNext
            tnoremap <silent>BPrev <C-\><C-n>:BPrev
          ]])
        end,
        pattern = 'term://*toggleterm#*',
      })
    end,
  },

  {
    'glacambre/firenvim',
    lazy = not vim.g.started_by_firenvim,
    build = function()
      vim.fn['firenvim#install'](0)
    end,
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    enabled = not vim.g.started_by_firenvim,
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
      'nvim-telescope/telescope-ui-select.nvim',
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- Copilot setup
  {
    'github/copilot.vim',
    event = 'VeryLazy',
  },

  {
    'utilyre/barbecue.nvim',
    event = 'VeryLazy',
    name = 'barbecue',
    version = '*',
    dependencies = {
      'SmiteshP/nvim-navic',
      'nvim-tree/nvim-web-devicons', -- optional dependency
    },
    enabled = not vim.g.started_by_firenvim,
    opts = {
      exclude_filetypes = { 'NvimTree', 'toggleterm', '' },
    },
  },

  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    enabled = not vim.g.started_by_firenvim,
    opts = {
      options = {
        max_name_length = 40,
        diagnostics = 'nvim_lsp',
        separator_style = 'slant',
        offsets = {
          {
            filetype = 'NvimTree',
            text = '󱏒 Explorer',
            text_align = 'left',
            highlight = 'Directory',
          }
        },
        always_show_bufferline = false,
        diagnostics_indicator = function(_, level)
           return level:match('error') and '' or ''
        end,
      },
    },
  },
  {
    'qpkorr/vim-bufkill',
    event = 'VeryLazy',
  },
  {
    "stevearc/stickybuf.nvim",
    event = "VeryLazy",
    enabled = not vim.g.started_by_firenvim,
    opts = {
      get_auto_pin = function(bufnr)
        return vim.bo[bufnr].filetype == 'NvimTree'
          or vim.bo[bufnr].filetype == 'help'
          or vim.bo[bufnr].filetype == 'toggleterm'
          or vim.bo[bufnr].buftype == 'quickfix'
      end
    },
  },

  {
    'nvim-tree/nvim-tree.lua',
    enabled = not vim.g.started_by_firenvim,
    config = function()
      require('nvim-tree').setup({
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')

          local function opts(desc)
            return {
              desc = 'nvim-tree: ' .. desc,
              buffer = bufnr,
              noremap = true,
              silent = true,
              nowait = true
            }
          end

          local function toggleHiddenAndIngored()
            api.tree.toggle_hidden_filter()
            api.tree.toggle_gitignore_filter()
          end

          local function deleteVisual()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local cline, ccol = cursor[1], cursor[2]
            local vline = vim.fn.line('v')
            local lines = math.abs(cline - vline) + 1
            local location = cline < vline and cline or vline
            vim.api.nvim_win_set_cursor(0, { location, ccol })
            for _ = 1, lines do
              vim.api.nvim_input('<esc>')
              api.fs.remove()
              api.tree.reload()
            end
            vim.api.nvim_win_set_cursor(0, { location, ccol })
          end

          api.config.mappings.default_on_attach(bufnr)
          vim.keymap.set('n', '-', api.node.navigate.parent_close, opts('Close Directory'))
          vim.keymap.set('n', '<BS>', api.tree.change_root_to_parent, opts('Up'))
          vim.keymap.set('n', '<CR>', api.tree.change_root_to_node, opts('CD'))
          vim.keymap.set('n', '.', toggleHiddenAndIngored, opts('Toggle Hidden/Ingored'))
          vim.keymap.set('n', 'l', ':NvimTreeResize +5<CR>', opts('Make wider'))
          vim.keymap.set('n', 'h', ':NvimTreeResize -5<CR>', opts('Make narrow'))
          vim.keymap.set('n', 'd', '<NOP>', opts('noop'))
          vim.keymap.set('n', 'dd', api.fs.remove, opts('Delete'))
          vim.keymap.set('n', 'yy', api.fs.copy.node, opts('Copy Name'))
          vim.keymap.set('v', 'dd', deleteVisual, opts('Delete Visual'))
        end,
        disable_netrw = true,
        hijack_netrw = true,
        view = {
          width = 30,
          side = 'left',
        },
        update_focused_file = {
          enable = true,
        },
        renderer = {
          indent_markers = {
            enable = true,
          },
        },
        filters = {
          dotfiles = true,
          git_ignored = true,
        },
        ui = {
          confirm = {
            remove = false,
          },
        }
      })
    end,
    dependencies = {
      'antosha417/nvim-lsp-file-operations',
      config = function()
        require('lsp-file-operations').setup()
      end,
    }
  },
  'nvim-tree/nvim-web-devicons'

}, {})

-- [[ Setting options ]]

-- Make line numbers default
vim.wo.number = not vim.g.started_by_firenvim

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on if not firenvim
vim.wo.signcolumn = vim.g.started_by_firenvim and 'no' or 'yes'
vim.o.cmdheight = 0

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]
vim.keymap.set('n', 'gb', ':BlameToggle<CR>:Barbecue toggle<CR>', { desc = 'Toggle [B]lame' })

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Use nvim-tree
vim.cmd('nnoremap <silent> - :NvimTreeFocus<CR>')

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('v', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('v', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
if vim.g.started_by_firenvim then
  vim.keymap.set('n', 'gE', '[s', { desc = '[G]o to previous spell [E]rror' })
  vim.keymap.set('n', 'ge', ']s', { desc = '[G]o to next spell [E]rror' })
else
  vim.keymap.set('n', 'gE', vim.diagnostic.goto_prev, { desc = '[G]o to previous diagnostic [E]rror' })
  vim.keymap.set('n', 'ge', vim.diagnostic.goto_next, { desc = '[G]o to next diagnostic [E]rror' })
end
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Firenvim support ends here
if vim.g.started_by_firenvim then return end

-- [[ Configure Telescope ]]
local function gitStatus()
  -- git diff and git diff --cached
  local changed = vim.fn.systemlist('git diff --name-only')
  local staged = vim.fn.systemlist('git diff --cached --name-only')
  if (#changed == 0 and #staged == 0) then
    require('telescope.builtin').git_commits()
  else
    require('telescope.builtin').git_status()
  end
end
vim.api.nvim_create_user_command('GitStatus', gitStatus, {})

local function filenameFirst(_, path)
  local tail = vim.fs.basename(path)
  local parent = vim.fs.dirname(path)
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

-- Navigate quickfix with <C-j> and <C-k>
vim.keymap.set(
  'n',
  '<C-j>',
  ':cnext<CR><CR>',
  { silent = true, desc = 'Next quicklist item' }
)
vim.keymap.set(
  'n',
  '<C-k>',
  ':cprev<CR><CR>',
  { silent = true, desc = 'Next quicklist item' }
)
-- Navigate quickfix history with <C-h> and <C-l>
vim.keymap.set(
  'n',
  '<C-h>',
  ':cnewer<CR><CR>',
  { silent = true, desc = 'Newer quicklist' }
)
vim.keymap.set(
  'n',
  '<C-l>',
  ':colder<CR><CR>',
  { silent = true, desc = 'Older quicklist' }
)

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        -- ['<C-u>'] = false,
        -- ['<C-d>'] = false,
        ['<esc>'] = require('telescope.actions').close,
        ['<C-p>'] = require('telescope.actions').cycle_history_prev,
        ['<C-n>'] = require('telescope.actions').cycle_history_next,
      },
    },
    sorting_strategy = 'ascending',
    layout_config = {
      prompt_position = 'top',
    },
    path_display = filenameFirst,
  },
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_cursor(),
    },
  },
})

require('telescope').load_extension('ui-select')

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>o', require('telescope.builtin').oldfiles, { desc = '[o] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').builtin, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>ö', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep({
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  })
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- [[ Configure Treesitter ]]
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup({
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  })
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('gr', vim.lsp.buf.rename, '[G]oto [R]ename')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gad', require('telescope.builtin').lsp_references, '[G]oto References')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('gs', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('gas', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[A]ll workspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('ghh', vim.lsp.buf.hover, '[G]oto [H]over Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
  nmap('<leader>f', vim.lsp.buf.format, '[F]ormat')
end

-- document existing key chains
require('which-key').register({
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
})
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').register({
  ['<leader>'] = { name = 'VISUAL <leader>' },
  ['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  tsserver = {
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

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = {
        globals = {
          'vim',
          'require'
        },
      },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')

mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
  function(server_name)
    require('lspconfig')[server_name].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    })
  end,
})

-- [[ Configure nvim-cmp ]]
local cmp = require('cmp')
local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load({
  paths = '~/.config/nvim/snippets',
})
luasnip.config.setup()

cmp.setup({
  enabled = not vim.g.started_by_firenvim,
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
})

-- vim: ts=2 sts=2 sw=2 et
