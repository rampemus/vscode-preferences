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

" https://www.jakeworth.com/my-annotated-vimrc/
vnoremap <silent> gs :sort<cr>

" Reloading init.vim
nnoremap gv :source $MYVIMRC<cr>

autocmd BufNewFile,BufRead *.tsx,*.jsx,*.vue set filetype=typescript.tsx.html


if exists('g:vscode')
	xmap gc  <Plug>VSCodeCommentary
	nmap gc  <Plug>VSCodeCommentary
	omap gc  <Plug>VSCodeCommentary
	nmap gcc <Plug>VSCodeCommentaryLine

	function! s:refactorInVisualMode()
    let mode = mode()
		if mode ==# 'V'
			let startLine = line('v')
			let endLine = line('.')
			call VSCodeNotifyRange('editor.action.refactor', startLine, endLine, 1)
		else
			let startPos = getpos('v')
			let endPos = getpos('.')
			call VSCodeNotifyRangePos(
      \   'editor.action.refactor',
      \   startPos[1], endPos[1], startPos[2], endPos[2] + 1, 1
      \)
		endif
	endfunction

	vnoremap gr <Cmd>call <SID>refactorInVisualMode()<CR>
	nnoremap <silent> gr <Cmd>call VSCodeNotify('editor.action.rename')<CR>

  nnoremap <silent> gf <Cmd>call VSCodeNotify('editor.action.revealDefinition')<CR>
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
	" Pump action like behavior
	set completeopt=menu,noinsert
	inoremap <C-Space> <C-n>

	let g:lightline = {
		\ 'colorscheme': 'onedark',
		\ }

	" grep navigation
  nnoremap <C-f> :execute "vimgrep  **" <Bar> cw<left>
    \<left><left><left><left><left><left><left><left>
  nnoremap gd :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
  nnoremap <C-j> :cnext<CR>
  nnoremap <C-k> :cprevious<CR>
  nnoremap <C-o> :ccl<CR>
  nnoremap <silent> <Esc> :ccl<CR>

	" use terminal mode
	nnoremap <C-w>t :terminal<CR>
	nnoremap <C-w><C-t> <C-w>n:terminal<CR>
	tnoremap <Esc> <C-\><C-n>
	tmap <C-w> <Esc><C-w>
	au TermOpen * setlocal listchars= nonumber norelativenumber
	au BufEnter,BufWinEnter,WinEnter term://* startinsert
	au BufLeave term://* stopinsert

	" Vertical splits split right Splits split below
	set splitright
	set splitbelow

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
		set wildignore=*.bak,.DS_Store
		set wildignore+=*/tmp/*,*.so,*.swp,*.zip
		set wildignore+=*/node_modules/*,*/package\-lock.json
		set wildignore+=*.so,*.swp,*.zip,*.pyc
    set wildignore+=*.db,*.sqlite,.DS_Store,*/.git,*.bak
	endfunction

	" Go rename - vim style
	nnoremap gr :%s/<c-r><c-w>//gc<left><left><left>
  nnoremap <C-p> :find<Space>
endif
