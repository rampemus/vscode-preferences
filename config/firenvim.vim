set laststatus=0

tmap <D-v> <C-w>"+
nnoremap <D-v> "+p
vnoremap <D-v> "+p
inoremap <D-v> <C-R><C-O>+
cnoremap <D-v> <C-R><C-O>+

au TextChanged * ++nested write
au TextChangedI * ++nested write
nnoremap - <Esc>:q!<CR>

set guifont=Menlo:h10
set report=10
au BufEnter *.txt set filetype=markdown