lua <<EOF

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
require('ultimate-autopair').setup({
	cr = {
		enable = false,
	},
})
require('nvim-treesitter.configs').setup({
	autotag = {
		enable = true,
	},
})

if vim.g.started_by_firenvim then require('lualine').hide() end

-- Blame heat map colors from onedark light theme
require('heat').setup({
	colors = {
		[1] = { value = 0.00, color = '#101012' },
		[2] = { value = 0.25, color = '#3067e1' },
		[3] = { value = 0.50, color = '#a626a4' },
		[4] = { value = 0.75, color = '#e45649' },
		[5] = { value = 1.00, color = '#fedf9a' },
	},
})

require('colorizer').setup()

vim.opt.termguicolors = true
require('bufferline').setup({
	options = {
		max_name_length = 40,
		diagnostics = "coc",
		custom_filter = function(buf_number, _)
			if vim.bo[buf_number].filetype ~= "" then
				return true
			end
		end,
		offsets = {
			{
				filetype = "coc-explorer",
				text = "󱏒 Explorer",
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
