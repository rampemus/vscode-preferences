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

local spinners = { '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏', '⠋' }
local function nmap(l, r, desc)
  vim.keymap.set('n', l, r, { silent = true, desc = desc })
end
local function vmap(l, r, desc)
  vim.keymap.set('v', l, r, { silent = true, desc = desc })
end

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
          close = {},
          stack_push = {},
          stack_pop = {},
          basic = true,
          extra = true,
        }
      })
      vim.api.nvim_create_autocmd('User', {
        pattern = 'BlameViewOpened',
        callback = function(event)
          local blame_type = event.data
          if blame_type == 'window' then
            require('barbecue.ui').toggle(false)
          end
        end,
      })
      vim.api.nvim_create_autocmd('User', {
        pattern = 'BlameViewClosed',
        callback = function(event)
          local blame_type = event.data
          if blame_type == 'window' then
            require('barbecue.ui').toggle(true)
          end
        end,
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

      -- Navigate yanks with <C-p> and <C-n>
      nmap(
        '<C-p>',
        '<Plug>yankstack_substitute_older_paste',
        'Substitute older paste'
      )
      nmap(
        '<C-n>',
        '<Plug>yankstack_substitute_newer_paste',
        'Substitute newer paste'
      )

      nmap('Y', 'y$', 'Yank to end of line')
    end,
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    enabled = not vim.g.started_by_firenvim,
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      'prettier/vim-prettier',

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function()
          local telescope = require('telescope.builtin')
          local lsp = vim.lsp.buf

          nmap('gr', lsp.rename, '[G]oto [R]ename')

          nmap('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
          nmap('gad', telescope.lsp_references, '[G]oto References')
          nmap('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
          nmap('<leader>D', telescope.lsp_type_definitions, 'Type [D]efinition')
          nmap('gs', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')
          nmap('gas', telescope.lsp_dynamic_workspace_symbols, '[A]ll workspace [S]ymbols')

          -- See `:help K` for why this keymap
          nmap('ghh', lsp.hover, '[G]oto [H]over Documentation')

          -- Lesser used LSP functionality
          nmap('gD', lsp.declaration, '[G]oto [D]eclaration')
          nmap('<leader>wa', lsp.add_workspace_folder, '[W]orkspace [A]dd Folder')
          nmap('<leader>wr', lsp.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          nmap('<leader>wl', function()
            print(vim.inspect(lsp.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config({
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
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      })

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
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

        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              runtime = {
                version = 'LuaJIT',
              },
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup({
        ensure_installed = ensure_installed
      })

      require('mason-lspconfig').setup({
        -- explicitly set to an empty stable
        -- (Kickstart populates installs via mason-tool-installer)
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend(
              'force',
              {},
              capabilities,
              server.capabilities or {}
            )
            require('lspconfig')[server_name].setup(server)
          end,
        },
      })
    end,
  },

  {
    -- Autocompletion
    'saghen/blink.cmp',
    config = function()
      require('blink.cmp').setup({
        enabled = function()
          return not vim.g.started_by_firenvim
            and not vim.tbl_contains({}, vim.bo.filetype)
            and vim.bo.filetype ~= 'fyler'
            and vim.bo.buftype ~= 'nofile'
            and vim.bo.buftype ~= 'prompt'
            and vim.b.completion ~= false
        end,
        fuzzy = { implementation = 'lua' },
        keymap = {
          preset = 'default',
          ['<CR>'] = { 'select_and_accept', 'fallback' },
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
        completion = {
          documentation = { auto_show = true },
          menu = {
            auto_show = true,
          },
          list = {
            selection = {
              auto_insert = false,
            }
          },
          ghost_text = { enabled = false },
        }
      })
    end,
    dependencies = {
      'L3MON4D3/LuaSnip',
    },
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    opts = {},
    event = 'VeryLazy',
    enabled = not vim.g.started_by_firenvim,
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

        -- Actions
        -- visual mode
        vmap('ghs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'stage git hunk')
        vmap('ghu', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'reset git hunk')
        -- normal mode
        nmap('ghs', gs.stage_hunk, 'git stage hunk')
        nmap('ghS', gs.stage_buffer, 'git stage buffer')
        nmap('ghu', gs.reset_hunk, 'git reset hunk')
        nmap('ghU', gs.reset_buffer_index, 'git reset buffer index')
        nmap('ghn', gs.next_hunk, 'next git hunk')
        nmap('ghp', gs.prev_hunk, 'prev git hunk')
        nmap('ghb', function() gs.blame_line({ full = false }) end, 'git blame line')

        local function openDiffView()
          require('bufferline').move_to(-1)
          local changed = vim.fn.systemlist('git diff --name-only')
          local staged = vim.fn.systemlist('git diff --cached --name-only')
          local offset = #changed == 0 and #staged == 0 and 1 or 0
          require('barbecue.ui').toggle(false)
          gs.diffthis('HEAD~' .. vim.v.count + offset)
          vim.defer_fn(function()
            require('bufferline').move_to(-1)
          end, 200)
        end
        nmap('<leader>gD', openDiffView, 'git diff against first/nth commit')

        -- Toggles
        nmap('<leader>gb', gs.toggle_current_line_blame, 'toggle git blame line')
        nmap('<leader>gd', gs.toggle_deleted, 'toggle git show deleted')

        -- Text object
        vim.keymap.set(
          { 'o', 'x' },
          'ih',
          ':<C-U>Gitsigns select_hunk<CR>',
          { desc = 'select git hunk', buffer = bufnr }
        )
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
      vim.cmd.colorscheme('onedark')
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    enabled = not vim.g.started_by_firenvim,
    config = function()
      local function lsp_progress()
        -- Lua lsp has some illegal characters in the status
        local status = vim.lsp.status():gsub('%%', '%%%%')
        if status ~= '' then
          vim.g.lsp_progress_status = status
          vim.g.lsp_progress_spinner = (vim.g.lsp_progress_spinner or 0) % #spinners + 1
          return spinners[vim.g.lsp_progress_spinner or 1] .. ' ' .. status
        end
        if vim.g.lsp_progress_spinner > 1 then
          vim.g.lsp_progress_spinner = (vim.g.lsp_progress_spinner or 0) % #spinners + 1
          return spinners[vim.g.lsp_progress_spinner or 1] .. ' ' .. vim.g.lsp_progress_status
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
            vim.g.copilot_spinner = 0 -- stop the spinner
          end
          return spinners[vim.g.copilot_spinner % #spinners + 1]
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
            statusline = 50,
          },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff' },
          lualine_c = { 'diagnostics', lsp_progress, qf },
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
      extensions = {
        filetype = {
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
      exclude = { filetypes = { 'fyler' } },
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
    opts = {
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
        sass = { enable = false, parsers = { 'css' }, },
        virtualtext = '?',
      },
    },
  },
  {
    'lukas-reineke/virt-column.nvim',
    enabled = not vim.g.started_by_firenvim,
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
    dependencies = {
      'kevinhwang91/nvim-hlslens',
    },
    event = 'VeryLazy',
    config = function()
      require('scrollbar.handlers.search').setup({
        override_lens = function() end,
      })

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
          }
        }
      })
    end,
  },
  {
    'mcauley-penney/visual-whitespace.nvim',
    event = 'VeryLazy',
    opts = {
      highlight = { link = 'Visual' },
      space_char = ' ',
      excluded = {
        buftypes = { 'terminal' },
        filetypes = { 'fyler' }
      }
    }
  },

  {
    'akinsho/nvim-toggleterm.lua',
    event = 'VeryLazy',
    enabled = not vim.g.started_by_firenvim,
    config = function()
      require('toggleterm').setup({
        open_mapping = [[<C-w><C-t>]],
        auto_scroll = false,
      })
      vim.api.nvim_create_autocmd('TermEnter', {
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

  -- Highlight, edit, and navigate code
  {
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
    'utilyre/barbecue.nvim', -- TODO: Switch to mbwilding/barbeque.nvim
    event = 'VeryLazy',
    name = 'barbecue',
    version = '*',
    dependencies = {
      'SmiteshP/nvim-navic',
      'nvim-tree/nvim-web-devicons', -- optional dependency
    },
    enabled = not vim.g.started_by_firenvim,
    opts = {
      exclude_filetypes = { 'fyler', 'toggleterm', '' },
      theme = {
        normal = { bg = '#282c34' },
      }
    },
  },

  {
    'stevearc/dressing.nvim',
    enabled = not vim.g.started_by_firenvim,
    opts = {
      input = {
        mappings = {
          i = {
            ['<Esc>'] = 'Close',
          },
        },
      },
    },
  },

  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    enabled = not vim.g.started_by_firenvim,
    config = function()
      vim.api.nvim_set_hl(0, 'BufferStatus', {
        fg = '#5c6370',
        bg = '#16181c',
      })
      require('bufferline').setup({
        options = {
          max_name_length = 40,
          diagnostics = 'nvim_lsp',
          separator_style = 'slant',
          offsets = {
            {
              filetype = 'fyler',
              text = function()
                local nvimtree = 1
                local terminals = #require('toggleterm.terminal').get_all(true)
                local buffers = #vim.fn.getbufinfo({ buflisted = 1 })
                local modifiedRaw = #vim.fn.getbufinfo({ bufmodified = 1 })
                local modified = modifiedRaw - terminals - nvimtree
                return 'Buffers ' .. buffers
                  .. (modified > 0 and (' (modified ' .. modified .. ')') or '')
                  .. (terminals > 0 and (' (zsh ' .. terminals) .. ')' or '')
              end,
              text_align = 'left',
              highlight = 'BufferStatus',
            }
          },
          always_show_bufferline = false,
          diagnostics_indicator = function(_, level)
            return level:match('error') and '' or ''
          end,
        },
      })

      -- Always open buffer to the last position
      vim.api.nvim_create_autocmd('BufAdd', {
        callback = function()
          vim.defer_fn(function()
            if #vim.fn.getbufinfo({ buflisted = 1 }) > 1 then
              require('bufferline').move_to(-1)
            end
          end, 100)
        end,
        pattern = '*',
      })
    end
  },
  {
    'qpkorr/vim-bufkill',
    event = 'VeryLazy',
  },
  {
    'stevearc/stickybuf.nvim',
    event = 'VeryLazy',
    enabled = not vim.g.started_by_firenvim,
    opts = {
      get_auto_pin = function(bufnr)
        local windows = vim.fn.getwininfo()

        if (#windows == 1) then
          return false -- Unpin to allow escape the full screen fyler
        end

        return vim.bo[bufnr].filetype == 'toggleterm'
          or vim.bo[bufnr].filetype == 'fyler'
          or vim.bo[bufnr].filetype == 'quickfix'
          or vim.bo[bufnr].filetype == 'blame'
          or vim.bo[bufnr].filetype == 'git'
      end
    },
  },

  -- {{ Fyler for file/folder operations }}
  {
    'A7Lavinraj/fyler.nvim',
    enabled = not vim.g.started_by_firenvim,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      local center = function(columns) return math.floor((columns - 88) / 2) end
      require('fyler').setup({
        integrations = {
          icon = 'nvim_web_devicons',
        },
        views = {
          finder = {
            close_on_select = false,
            confirm_simple = true,
            default_explorer = true,
            mappings = {
              ---@diagnostic disable-next-line: assign-type-mismatch
              ['q'] = 'noop', ['<C-t>'] = 'noop', ['.'] = 'noop', ['#'] = 'noop', ['^'] = 'noop',
              ['<S-CR>'] = 'GotoNode',
              ['-'] = 'CollapseNode',
              ['<BS>'] = 'GotoParent',
            },
            git_status = {
              enabled = false,
            },
            indentscope = {
              group = 'IblIndent',
              marker = '▎',
            },
            win = {
              win_opts = {
                cursorline = true,
                number = false,
                relativenumber = false,
              },
              kind = 'split_left_most',
              kinds = {
                split_left_most = {
                  width = center(vim.o.columns),
                },
              },
            },
          },
        },
      })

      local resizeFyler = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_get_option_value('filetype', {
            buf = vim.api.nvim_win_get_buf(win)
          }) == 'fyler' then
            vim.api.nvim_win_set_width(win, center(vim.o.columns))
          end
          vim.cmd('wincmd =')
        end
      end

      vim.api.nvim_create_autocmd('VimResized', {
        callback = resizeFyler,
      })
    end
  },

}, {
  change_detection = { notify = false },
  rocks = {
    enabled = false,
  },
  -- makes nvim_ui_attach 1ms faster
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'netrwPlugin',
        'rplugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})

-- [[ Setting options ]]

-- Make line numbers default
vim.wo.number = not vim.g.started_by_firenvim

-- Enable mouse mode
vim.o.mouse = 'a'
nmap('<2-LeftMouse>', ':silent! !open <cfile><CR>', 'Open URL under cursor')

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
nmap('gb', ':BlameToggle<CR>', 'Toggle [B]lame')

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

if (not vim.g.started_by_firenvim) then
  nmap('-', require('fyler').focus, 'Open Fyler View')
end

-- Remap for dealing with word wrap
local jk = { expr = true, silent = true }
vim.keymap.set({'n', 'v'}, 'k', "v:count == 0 ? 'gk' : 'k'", jk)
vim.keymap.set({'n', 'v'}, 'j', "v:count == 0 ? 'gj' : 'j'", jk)

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

-- Disable auto commenting on new lines
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('Empty new line', {}),
  callback = function()
    vim.opt_local.formatoptions:remove({ 'o' })
  end,
})

-- Firenvim support ends here
if vim.g.started_by_firenvim then return end

-- [[ Configure Telescope ]]
local function gitStatus()
  if vim.bo.filetype == 'fyler' then
    vim.cmd('BNext')
  end
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
  require('stickybuf').is_pinned
    and ':BufferLineGoToBuffer 1<CR><CR>:cnext<CR><CR>'
    or ':cnext<CR><CR>',
  { silent = true, desc = 'Next quicklist item' }
)
vim.keymap.set(
  'n',
  '<C-k>',
  require('stickybuf').is_pinned
    and ':BufferLineGoToBuffer 1<CR><CR>:cprev<CR><CR>'
    or ':cprev<CR><CR>',
  { silent = true, desc = 'Prev quicklist item' }
)
-- Navigate quickfix history with <C-h> and <C-l>
nmap('<C-h>', ':cnewer<CR><CR>', 'Newer quicklist')
nmap('<C-l>', ':colder<CR><CR>', 'Older quicklist')

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
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
      -- Add line number support
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
            if vim.fn.line('.') == 1 then
              vim.cmd('silent! normal! `"')
            end
          end,
        })
        return true
      end,
    },
  }
})

require('telescope').load_extension('ui-select')

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- cmd shortcuts (ghostty config does not allow '=' in text commands)
vim.api.nvim_create_user_command('TelescopeGrep', function()
  if vim.bo.filetype == 'fyler' then
    vim.cmd('BNext')
  end
  require('telescope.builtin').live_grep({
    additional_args = { '--fixed-strings' }
  })
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
vim.api.nvim_create_user_command('TelescopeFindFiles', function()
  if vim.bo.filetype == 'fyler' then
    vim.cmd('BNext')
  end
  vim.cmd([[
    Telescope find_files --sort=modified\n
  ]])
end, {})
vim.api.nvim_create_user_command('PrettierOrFormat', function()
  vim.cmd([[
    silent! Prettier
  ]])
  if vim.v.shell_error ~= 0 then
    vim.lsp.buf.format()
  end
end, {})

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
  local git_root = vim.fn.systemlist(
    'git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel'
  )[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  if vim.bo.filetype == 'fyler' then
    vim.cmd('BNext')
  end
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = { git_root },
    })
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
nmap('<leader>o', require('telescope.builtin').oldfiles, '[o] Find recently opened files')
nmap('<leader><space>', require('telescope.builtin').builtin, '[ ] Find existing buffers')
nmap('<leader>ö', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(
    require('telescope.themes').get_dropdown({
      winblend = 10,
      previewer = false,
    })
  )
end, '[ö] Fuzzily search in current buffer')

nmap('<leader>sr', require('telescope.builtin').resume, '[S]earch [R]esume')

-- [[ Configure Treesitter ]]
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup({
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
      'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript',
      'typescript', 'vimdoc', 'vim', 'bash', 'prisma',
    },

    sync_install = true,
    modules = {},
    ignore_install = {},

    -- Autoinstall languages that are not installed. Defaults to false
    -- (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
    },
  })
end, 0)

local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load({
  paths = '~/.config/nvim/snippets',
})
luasnip.config.setup()

-- vim: ts=2 sts=2 sw=2 et
