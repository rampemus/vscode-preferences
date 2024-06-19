set hls
set showmatch
set incsearch
set mouse=a
set ignorecase
set fillchars+=diff:\ 
language en_US

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
nnoremap <C-u> <C-u>zt
nnoremap <C-d> <C-d>zt

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
" Default to follow the line number
nnoremap gf gF
nnoremap gF gf

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
		" Vim only settings
		:highlight CursorLine cterm=NONE ctermbg=DarkBlue
		set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
		set guicursor+=a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
		set guicursor+=sm:block-blinkwait175-blinkoff150-blinkon175
		if has('nvim')
			set signcolumn=yes
			set colorcolumn=81
			autocmd BufEnter,WinEnter * if &filetype == 'toggleterm' | set colorcolumn=0 | endif
		endif
	endif

	function! SmartBufferDelete()
		let s:explorer_window = 0

		if &diff
			execute 'q'
		endif

		for win in range(1, winnr('$'))
			if getbufvar(winbufnr(win), '&filetype') == 'NvimTree'
				let s:explorer_window = 1
				break
			endif
		endfor

		if &filetype == 'NvimTree'
		\ || &filetype == 'blame'
		\ || winnr('$') > 1 + s:explorer_window
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

" Remove highlights automatically
nnoremap <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
nnoremap <silent> <Esc> <Esc>:nohlsearch<CR>
augroup SearchHighlight
	au!
	au CursorMoved * call HlSearch()
	au InsertEnter * call StopHL()
augroup end

" SearchHighlight autogroup
function! HlSearch()
	let s:pos = match(getline('.'), @/, col('.') - 1) + 1
	if s:pos != col('.')
		call StopHL()
	endif
endfunction

function! StopHL()
	if !v:hlsearch || mode() isnot 'n'
		return
	else
		sil call feedkeys("\<Plug>(StopHL)", 'm')
	endif
endfunction

