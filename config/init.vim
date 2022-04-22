set nohls
set showmatch
set incsearch
set mouse=a
set ignorecase

" Tab navigation
nnoremap H gT
nnoremap L gt
nnoremap <C-w><C-k> <C-w><C-i>
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" f case insensitive
let g:fanfingtastic_ignorecase = 1

" Nordic keyboard troubles
nnoremap + $
vnoremap + $
nnoremap ö /
vnoremap ö /
nnoremap Ö ?
vnoremap Ö ?

" line destruction (reverse J)
nnoremap K $?[^=:\)\]\>\&\|\?]\s<CR>lxi<CR><Esc>k:noh<CR>

set autoindent
set clipboard+=unnamed
nnoremap <tab> >>
nnoremap <S-Tab> <<
vnoremap <Tab> >><Esc>gv
vnoremap <S-Tab> <<<Esc>gv

" https://www.jakeworth.com/my-annotated-vimrc/
vnoremap <silent> gs :sort<cr>

" Reloading init.vim
nnoremap gv :source $MYVIMRC<cr>

" Go middle of file
nnoremap gm :call cursor(line('$')/2, 0)<cr>

" Reddit user u/Maskdask: Repeat on next search result
nnoremap g. /\V<C-r>"<CR>cgn<C-a><Esc>

map *   <Plug>(asterisk-*)
map #   <Plug>(asterisk-#)
map g*  <Plug>(asterisk-g*)
map g#  <Plug>(asterisk-g#)
map z*  <Plug>(asterisk-z*)
map gz* <Plug>(asterisk-gz*)
map z#  <Plug>(asterisk-z#)
map gz# <Plug>(asterisk-gz#)
let g:asterisk#keeppos = 1

autocmd BufNewFile,BufRead *.tsx,*.jsx,*.vue set filetype=typescript.tsx.html
autocmd BufNewFile,BufRead *.html.twig set filetype=html
autocmd BufNewFile,BufRead *.blade.php set filetype=html

call plug#begin('~/.config/nvim-plugins')
Plug 'airblade/vim-gitgutter'
Plug 'dahu/vim-fanfingtastic'
Plug 'peitalin/vim-jsx-typescript'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-vinegar'
Plug 'Townk/vim-autoclose'
Plug 'haya14busa/vim-asterisk'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

set encoding=UTF-8

if exists('g:vscode')
	silent! CocDisable
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
				\'editor.action.refactor',
				\startPos[1], endPos[1], startPos[2], endPos[2] + 1, 1
			\)
		endif
	endfunction

	vnoremap gr <Cmd>call <SID>refactorInVisualMode()<CR>
	nmap <silent> gr <Cmd>call VSCodeNotify('editor.action.rename')<CR>
	nmap <silent> gad <Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>

	nmap <silent> gf <Cmd>call VSCodeNotify('editor.action.revealDefinition')<CR>
	nmap <silent> ghn <Cmd>call VSCodeNotify('workbench.action.editor.nextChange')<CR>
	nmap <silent> ghN <Cmd>call VSCodeNotify('workbench.action.editor.previousChange')<CR>
	vmap <silent> ghn <Cmd>call VSCodeNotify('workbench.action.editor.nextChange')<CR>
	vmap <silent> ghN <Cmd>call VSCodeNotify('workbench.action.editor.previousChange')<CR>
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

	" Remove highlights automatically
	noremap <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
	noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]

	fu! HlSearch()
		let s:pos = match(getline('.'), @/, col('.') - 1) + 1
		if s:pos != col('.')
			call StopHL()
		endif
	endfu

	fu! StopHL()
		if !v:hlsearch || mode() isnot 'n'
			return
		else
			sil call feedkeys("\<Plug>(StopHL)", 'm')
		endif
	endfu

	augroup SearchHighlight
	au!
		au CursorMoved * call HlSearch()
		au InsertEnter * call StopHL()
	augroup end
	" highlights automatically end

	function! s:GitGutterNextHunkCycle()
	  let line = line('.')
	  silent! GitGutterNextHunk
	  if line('.') == line
		1
		GitGutterNextHunk
	  endif
	endfunction

	" Go to changed line (according to git diff)
	nmap ghn <Cmd>call <SID>GitGutterNextHunkCycle()<CR>
	nmap ghN <Plug>(GitGutterPrevHunk)

	autocmd BufWritePost * GitGutter
	let g:gitgutter_async = 1

	" turn relative line numbers on
	set number relativenumber
	set path+=**
	set wildignore+=**/node_modules/**
	set wildignore+=**/vendor/**

	" Indenting settings
	filetype plugin indent on
	" show existing tab with 2 spaces width
	set tabstop=4
	" when indenting with '>', use 2 spaces width
	set shiftwidth=4
	" On pressing tab, insert 2 spaces
	" set expandtab
	" Pump action like behavior
	set completeopt=menu,noinsert
	" inoremap <C-Space> <C-n>
	inoremap <silent><expr> <c-space> coc#refresh()

	let g:lightline = {
		\ 'colorscheme': 'onedark',
		\ }

	" grep navigation overwritten by coc
	nnoremap <C-f> :execute "vimgrep  **" <Bar> cw<left>
		\<left><left><left><left><left><left><left><left>
	nnoremap gd :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
	nnoremap <C-j> :cnext<CR>
	nnoremap <C-k> :cprevious<CR>
	nnoremap <C-o> :ccl<CR>
	nnoremap <silent> <Esc> :ccl<CR>

	" change ctrl-k so that it closes all nvim windows like <c-w>o
	nnoremap <c-k> <c-w>o

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
	let g:netrw_liststyle=3
	autocmd filetype netrw call NetrwMapping()
	function! NetrwMapping()
		map <buffer> a %
		map <buffer> A d
		map <buffer> r R
		map <buffer> d D
		map <buffer> o <CR>
		map <buffer> ? :help netrw-quickmap<CR>
		set wildignore=*.bak,.DS_Store
		set wildignore+=*/tmp/*,*.so,*.swp,*.zip
		set wildignore+=*/node_modules/*,*/vendor/*,*/package\-lock.json
		set wildignore+=*.so,*.swp,*.zip,*.pyc
		set wildignore+=*.db,*.sqlite,.DS_Store,*/.git,*.bak
	endfunction

	let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-tsserver']
	let g:python_host_prog = '/usr/bin/python'
	let g:python3_host_prog = '/usr/bin/python3'

	inoremap <silent><expr> <TAB>
	\ pumvisible() ? coc#_select_confirm() :
	\ coc#expandableOrJumpable() ?
	\ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
	\ <SID>check_back_space() ? "\<TAB>" :
	\ coc#refresh()
	let g:coc_snippet_next = '<down>'
	let g:coc_snippet_prev = '<up>'

	" Backspace logic
	inoremap <a-BS> <Esc>dbxa
	function! s:check_back_space() abort
		let col = col('.') - 1
		return !col || getline('.')[col - 1]  =~# '\s'
	endfunction

	nmap <silent> gd <Plug>(coc-definition)
	nmap <silent> gad <Plug>(coc-references-used)
	nmap <silent> gy <Plug>(coc-type-definition)
	nmap <silent> gi <Plug>(coc-implementation)
	nmap <silent> gr <Plug>(coc-rename)
	nmap <C-f> :execute "CocSearch -M 80  ." <left>
	 \<left><left><left>

	" Go rename - vim style
	" nnoremap gr :%s/<c-r><c-w>//gc<left><left><left>
	nnoremap <C-p> :find<Space>
endif
