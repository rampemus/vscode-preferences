set laststatus=0
set spell

tmap <D-v> <C-w>"+
nnoremap <D-v> "+p
vnoremap <D-v> "+p
inoremap <D-v> <C-R><C-O>+
cnoremap <D-v> <C-R><C-O>+

au TextChanged * ++nested silent write
au TextChangedI * ++nested silent write
" Instead of nvim tree, escape editor
command! NvimTreeFocus wqa

set guifont=Menlo:h20
set report=10
au BufEnter *.txt set filetype=markdown

lua << EOF
vim.g.firenvim_config = {
	globalSettings = {
		ignoreKeys = {
			all = {
				'<D-h>',
				'<D-j>',
				'<D-k>',
				'<D-l>',
				'<D-s>',
			},
		}
	}
}
EOF

