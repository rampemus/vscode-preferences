lua <<EOF

local previewers = require("telescope.previewers")
local actions = require("telescope.actions")

local new_maker = function(filepath, bufnr, opts)
	opts = opts or {}

	filepath = vim.fn.expand(filepath)
	vim.loop.fs_stat(filepath, function(_, stat)
		if not stat then return end
		if stat.size > 1000000 then
			return
		else
			previewers.buffer_previewer_maker(filepath, bufnr, opts)
		end
	end)
end
require('telescope').setup({
	defaults = {
		mappings = {
			i = {
				["<esc>"] = actions.close
			},
		},
		buffer_previewer_maker = new_maker,
		sorting_strategy = 'ascending',
		layout_config = {
			prompt_position = 'top',
		},
	}
})
require('telescope').load_extension('coc')

require('lualine').setup({
	options = {
		icons_enabled = true,
		theme = 'onedark',
		component_separators = { left = ' ', right = ' '},
		section_separators = { left = ' ', right = ' '},
		always_divide_middle = true,
		globalstatus = true,
	},
	sections = {
		lualine_a = {'mode'},
		lualine_b = {'branch', 'diff', 'diagnostics'},
		lualine_c = {},
		lualine_x = {'location', 'encoding', 'fileformat'},
		lualine_y = {'filetype', 'copilot'},
		lualine_z = {}
	},
	winbar = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_winbar = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {}
	},
})
require('netrw').setup({
	icons = {
		symlink = '', -- Symlink icon (directory and file)
		directory = '', -- Directory icon
		file = '',        -- File icon
	},
	use_devicons = true, -- Uses nvim-web-devicons if true,
	                   -- otherwise use the file icon specified above
	mappings = {},       -- Custom key mappings
})
require('nvim-autopairs').setup({
	map_cr = false,
})
require('nvim-treesitter.configs').setup({
	autotag = {
		enable = true,
	}
})

-- Scrollbar according to https://github.com/petertriho/nvim-scrollbar/issues/42
local severity_map = { Error = 1, Warning = 2, Information = 3, Hint = 4 }

local lsp_handler = require('scrollbar.handlers.diagnostic').lsp_handler

local uri_diagnostics = {}
local function handler(error, diagnosticList)
	if error ~= vim.NIL then
		return
	end
	if type(diagnosticList) ~= 'table' then
		diagnosticList = {}
	end

	for uri in pairs(uri_diagnostics) do
		uri_diagnostics[uri] = {}
	end

	for _, diagnostic in ipairs(diagnosticList) do
		local uri = diagnostic.location.uri
		local diagnostics = uri_diagnostics[uri] or {}
		table.insert(diagnostics, {
			range = diagnostic.location.range,
			severity = severity_map[diagnostic.severity],
		})
		uri_diagnostics[uri] = diagnostics
	end

	for uri, diagnostics in pairs(uri_diagnostics) do
		lsp_handler(nil, { uri = uri, diagnostics = diagnostics })
		if vim.tbl_count(diagnostics) == 0 then
			uri_diagnostics[uri] = nil
		end
	end
end

vim.api.nvim_create_autocmd('User', {
	callback = function()
		vim.fn.CocActionAsync('diagnosticList', handler)
	end,
	pattern = 'CocDiagnosticChange',
})

if not vim.g.started_by_firenvim then
	require('scrollbar').setup({
		excluded_buftypes = {
			'terminal',
			'nofile',
		},
		handle = {
			highlight = 'Cursor',
			blend = 90,
		},
		handlers = {
			cursor = false,
		},
	})
end

if vim.g.started_by_firenvim then require('lualine').hide() end

require('toggleterm').setup({
	open_mapping = [[<C-w><C-t>]],
})

-- Blame heat map colors from onedark light theme
require('heat').setup({
	colors = {
		[1] = { value = 0.00, color = '#101012' },
		[2] = { value = 0.25, color = '#3067e1' },
		[3] = { value = 0.50, color = '#a626a4' },
		[4] = { value = 0.75, color = '#e45649' },
		[5] = { value = 1.00, color = '#fedf9a' },
	}
})

vim.opt.termguicolors = true
require('bufferline').setup({
	options = {
		diagnostics = "coc",
		custom_filter = function(buf_number, buf_numbers)
			if vim.bo[buf_number].filetype ~= "" then
				return true
			end
		end,
		offsets = {
			{
			    filetype = "coc-explorer",
			    text = "Coc Explorer",
			    text_align = "left",
			}
		},
		hover = {
			enabled = true,
			delay = 200,
			reveal = {'close'}
		},
		separator_style = "slant",
	},
})
if vim.g.started_by_firenvim then vim.opt.showtabline = 0 end

EOF
