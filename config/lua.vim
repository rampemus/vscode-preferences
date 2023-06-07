lua <<EOF

local previewers = require("telescope.previewers")
local actions = require("telescope.actions")

local new_maker = function(filepath, bufnr, opts)
	opts = opts or {}

	filepath = vim.fn.expand(filepath)
	vim.loop.fs_stat(filepath, function(_, stat)
		if not stat then return end
		if stat.size > 100000 then
			return
		else
			previewers.buffer_previewer_maker(filepath, bufnr, opts)
		end
	end)
end
require("telescope").setup{
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
}
require('telescope').load_extension('coc')

require('lualine').setup()
require('lualine').setup {
	options = {
		icons_enabled = true,
		theme = 'onedark',
		component_separators = { left = '', right = ''},
		section_separators = { left = '', right = ''},
		disabled_filetypes = {},
		always_divide_middle = true,
		globalstatus = false,
	},
	sections = {
		lualine_a = {'mode'},
		lualine_b = {'branch', 'diff', 'diagnostics'},
		lualine_c = {'filename'},
		lualine_x = {'encoding', 'fileformat'},
		lualine_y = {'filetype', 'copilot', 'progress'},
		lualine_z = {'location'}
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {'filename'},
		lualine_x = {'location'},
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	extensions = {}
}
require'netrw'.setup{
  icons = {
    symlink = '', -- Symlink icon (directory and file)
    directory = '', -- Directory icon
    file = '', -- File icon
  },
  use_devicons = true, -- Uses nvim-web-devicons if true,
	                     -- otherwise use the file icon specified above
  mappings = {}, -- Custom key mappings
}
require("nvim-autopairs").setup {
  map_cr = false,
}
require'nvim-treesitter.configs'.setup {
  autotag = {
    enable = true,
  }
}

if vim.g.started_by_firenvim then require('lualine').hide() end

require("toggleterm").setup{}

EOF
