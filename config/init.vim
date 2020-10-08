nmap ö /
vmap ö /
nmap Ö ?
vmap Ö ?
set showmatch
set nohlsearch
set incsearch
set mouse=a
set ignorecase

" Save files
nmap S :w<CR>
nmap Q :q<CR>

" Tab navigation
nmap H gT
nmap L gt
nmap <C-w><C-k> <C-w><C-i> 
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-h> <C-w>h
nmap <C-l> <C-w>l

" f case insensitive
let g:fanfingtastic_ignorecase = 1

" 0 start of line
nnoremap Å ~
vnoremap Å ~
" end of line
nmap + $
vmap + $
" Change upper <-> lower case
nnoremap å ^
vnoremap å ^

" line destruction (reverse J)
nnoremap K $?[^=:\)\]\>\&\|\?]\s<CR>lxi<CR><Esc>k:noh<CR>

set autoindent
set clipboard+=unnamed
nnoremap <tab> >>
nnoremap <S-Tab> <<
vnoremap <Tab> >>
vnoremap <S-Tab> <<

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx.html

if exists('g:vscode')
	xmap gc  <Plug>VSCodeCommentary
	nmap gc  <Plug>VSCodeCommentary
	omap gc  <Plug>VSCodeCommentary
	nmap gcc <Plug>VSCodeCommentaryLine
else
	let &t_SI.="\e[5 q" "SI = INSERT mode
	nnoremap Ä <c-o>
	nnoremap ä <c-i>
	set scrolloff=6
	set autoindent
	colorscheme onedark
	set cursorline
	map <ScrollWheelUp> <C-Y>
	map <ScrollWheelDown> <C-E>

	" turn relative line numbers on
	set number relativenumber
	set path+=**                                                                    
	set wildignore+=**/node_modules/**
	set wildignore+=**/vendor/**

	" Indenting settings
	filetype plugin indent on
	" show existing tab with 2 spaces width
	set tabstop=2
	" when indenting with '>', use 2 spaces width
	set shiftwidth=2
	" On pressing tab, insert 2 spaces
	set expandtab

	let g:lightline = {
		\ 'colorscheme': 'onedark',
		\ }

	" grep navigation
	nmap <Right> :cnext<CR>
	nmap <Left> :cprevious<CR>

	" quick way to append to end of the line
	inoremap <S-Esc> <Esc>

	" netrw_settings
	let g:netrw_banner = 0
	let g:netrw_altv = 1
	autocmd filetype netrw call NetrwMapping()
	function! NetrwMapping()
		map <buffer> a %
		map <buffer> A d
		map <buffer> r R
		map <buffer> d D
		map <buffer> o <CR>
		map <buffer> s v
	endfunction
endif
