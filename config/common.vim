set nohls
set showmatch
set incsearch
set mouse=a
set ignorecase
set fillchars+=diff:\

" Cmd insert mode movement
inoremap <a-BS> <Esc>dbxa
" cmd-bs cmd-left cmd-right
inoremap <char-0x15> <Esc>d^I
inoremap <C-A> <Esc>I
inoremap <C-E> <Esc>A
" alt-bs
inoremap <char-0x1b><char-0x08> <C-w>
" bind escape b to <C-Left>
inoremap <A-Left> asdf
" bind escape b, f to move cursor word right/left
inoremap <char-0x1b>b <C-Left>
inoremap <char-0x1b>f <Esc>ea
nnoremap <char-0x1b>f e

" Select command line autocomplete with arrows
cnoremap <Down> <C-N>
cnoremap <Up> <C-P>
cnoremap <C-a> <Home>

" Tab navigation
nnoremap H gT
nnoremap L gt
nnoremap <C-w><C-k> <C-w><C-i>

" Nordic keyboard troubles
nnoremap + $
vnoremap + $
nnoremap ö /
vnoremap ö /
nnoremap Ö ?
vnoremap Ö ?
nnoremap Ä <c-o>
nnoremap ä <c-i>

" navigate help file tags
autocmd BufNewFile,BufRead *.txt nnoremap <cr> <c-]>

" line destruction (reverse J)
nnoremap K $?[^=:\)\]\>\&\|\?]\s<CR>lxi<CR><Esc>k:noh<CR>

set autoindent
set clipboard+=unnamed
set nobackup
set nowritebackup
nnoremap <tab> >>
nnoremap <S-Tab> <<
vnoremap <Tab> >><Esc>gv
vnoremap <S-Tab> <<<Esc>gv

" https://www.jakeworth.com/my-annotated-vimrc/
vnoremap <silent> gs :sort<cr>

" Go middle of file
nnoremap gm :call cursor(line('$')/2, 0)<cr>
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz

" Except in vue find script tag start
autocmd BufRead *.vue nnoremap <buffer> gm gg/<script><cr>

" In jsx find the default import definition
if !exists('g:vscode')
	autocmd BufRead *.tsx,*.jsx nnoremap <buffer> gm G?export default<CR>$h:silent! Telescope lsp_definitions<cr>
else
	autocmd BufRead *.tsx,*.jsx nnoremap <buffer> gm G?export default<CR>$h:sleep 50m<cr>:call VSCodeNotify('editor.action.revealDefinition')<cr>
endif

" Reddit user u/Maskdask: Repeat on next search result
nnoremap g. /\V<C-r>"<CR>cgn<C-a><Esc>

" netrw_settings
autocmd FileType netrw setlocal colorcolumn=
let g:netrw_keepdir = 1
let g:netrw_banner = 0
let g:netrw_altv = 1
let g:netrw_liststyle = 0
let g:netrw_preview = 1
autocmd filetype netrw call NetrwMapping()
function! NetrwMapping()
	map <silent> <buffer> a %
	map <silent> <buffer> A d
	map <silent> <buffer> r R
	map <silent> <buffer> d D
	map <silent> <buffer> <space> p
	map <silent> <buffer> o <CR>
	map <silent> <buffer> ? :help netrw-quickmap<CR>
endfunction

set wildignore=*.bak,.DS_Store
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
set wildignore+=*/node_modules/*,*/vendor/*,*/package\-lock.json
set wildignore+=node_modules/*,vendor/*,package\-lock.json
set wildignore+=*.so,*.swp,*.zip,*.pyc
set wildignore+=*.db,*.sqlite,.DS_Store,*/.git,*.bak

if !exists('g:vscode')
	set scrolloff=6
	set autoindent
	set laststatus=2

	set cursorline
	if !exists('g:started_by_firenvim')
		set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
		set guicursor+=a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
		set guicursor+=sm:block-blinkwait175-blinkoff150-blinkon175
		if has('nvim')
			set signcolumn=yes
			set colorcolumn=80
			autocmd BufEnter,WinEnter * if &filetype == 'toggleterm' | set colorcolumn=0 | endif
		endif
	endif

	hi ColorColumn ctermbg=lightgrey guibg=lightgrey
	hi link xmlEndTag xmlTag

	command! -nargs=0 HighlightGroup :echo map(
				\ synstack(line('.'),
				\ col('.')),
				\ 'synIDattr(v:val, "name")'
				\)

	function! SmartBufferDelete()
		let s:explorer_window = 0

		for win in range(1, winnr('$'))
			if getbufvar(winbufnr(win), '&filetype') == 'NvimTree'
				let s:explorer_window = 1
				break
			endif
		endfor

		if &filetype == 'NvimTree' || winnr('$') > 1 + s:explorer_window
			execute 'q'
		else
			execute 'BD'
		endif

		" Remove remaining empty buffer
		if &filetype == ''
			execute 'q'
		endif
	endfunction
	command! -nargs=0 SmartBD :call SmartBufferDelete()

	" leave insert mode quickly
	if ! has('gui_running')
		set ttimeoutlen=10
		augroup FastEscape
			autocmd!
			au InsertEnter * set timeoutlen=0
			au InsertLeave * set timeoutlen=400
		augroup END
	endif
endif

autocmd BufNewFile,BufRead *.html.twig set filetype=html
autocmd BufNewFile,BufRead *.blade.php set filetype=html

set encoding=UTF-8

" f case insensitive
let g:fanfingtastic_ignorecase = 1
let g:indent_blankline_show_trailing_blankline_indent = v:false
