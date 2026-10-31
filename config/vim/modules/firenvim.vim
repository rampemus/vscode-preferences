set laststatus=0
set spell

tnoremap <D-v> <C-w>"+
nnoremap <D-v> "+p
vnoremap <D-v> "+p
inoremap <D-v> <C-R><C-O>+
cnoremap <D-v> <C-R><C-O>+
inoremap <D-z> <Esc>ua
inoremap <silent> <D-s> <Esc>:w<CR>a
nnoremap <silent> <D-s> :w<CR>

" Cmd + Backspace/arrow
inoremap <D-BS> <C-R>=CmdBackspace()<CR>
inoremap <D-Left> <Esc>I
inoremap <D-Right> <Esc>A

function CmdBackspace()
	let l:col = col('.')
	if l:col == col('$')
		return "\<Esc>Vc"
	else
		return "\<Right>\<Esc>d^i"
	endif
endfunction

" Alt + Backspace/arrow
inoremap <M-BS> <C-w>
inoremap <M-Left> <C-Left>
inoremap <M-Right> <C-Right>
inoremap <M-Up> <C-Up>
inoremap <M-Down> <C-Down>

autocmd TextChanged * ++nested silent write

" Instead of nvim tree, escape editor
nmap - :wqa!<CR>

set guifont=Menlo:h24
set report=10
autocmd BufEnter *.txt set filetype=markdown

lua << EOF
vim.g.firenvim_config = {
	localSettings = {
		['.*'] = {
			filename = '{hostname%16}_{pathname%16}_{timestamp%16}.{extension}'
		},
	},
	globalSettings = {
		ignoreKeys = {
			all = {
				'<D-h>',
				'<D-j>',
				'<D-k>',
				'<D-l>',
				'<D-1>',
				'<D-2>',
				'<D-3>',
				'<D-4>',
				'<D-5>',
				'<D-6>',
				'<D-7>',
				'<D-8>',
				'<D-9>',
				'<D-0>',
				'<D-+>',
				'<D-->',
			},
		}
	}
}
EOF

