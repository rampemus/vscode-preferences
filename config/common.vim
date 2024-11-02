set hls
set showmatch
set incsearch
set mouse=a
set ignorecase
set fillchars+=diff:\ 
language en_US

" Yank rest of line
nnoremap Y y$

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

" Undo breaks in insert mode and cmd+z to undo
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap : :<c-g>u
inoremap ; ;<c-g>u
inoremap + +<c-g>u
inoremap - -<c-g>u
inoremap = =<c-g>u
inoremap / /<c-g>u
inoremap <space> <space><c-g>u
inoremap  <Esc>ua

" navigate help file tags
autocmd BufNewFile,BufRead *.txt nnoremap <cr> <c-]>

" line destruction (reverse J)
nnoremap K $?[^=:\)\]\>\&\|\?]\s<CR><Plug>(StopHL)lxi<CR><Esc>k:noh<CR>

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
	let g:copilot_filetypes = {
		\'*': v:true,
		\'sh': v:false,
	        \'DressingInput': v:false,
	\}
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
		if has('nvim')
			set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
			set guicursor+=a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
			set guicursor+=sm:block-blinkwait175-blinkoff150-blinkon175

			set signcolumn=yes
			set colorcolumn=81

			autocmd BufEnter,WinEnter * if &filetype == 'toggleterm' | set colorcolumn=0 | endif
		else
			:highlight CursorLine cterm=NONE ctermbg=DarkBlue

			let &t_SI = "\<Esc>]50;CursorShape=1\x7"
			let &t_SR = "\<Esc>]50;CursorShape=2\x7"
			let &t_EI = "\<Esc>]50;CursorShape=0\x7"

			set ttimeout
			set ttimeoutlen=1
			set ttyfast
		endif
	endif

	function! SmartBufferDelete()
		if &diff || !has('nvim')
			" Trigger quit only on the left window
			silent lua require('barbecue.ui').toggle(true)
			wincmd h
			if &diff
				quit
				return
			endif
			wincmd l
			quit
			return
		endif

		if UtilFiletype()
			if &filetype == 'blame'
				silent BlameToggle
			else 
				quit
				return
			endif
		else
			let s:current_buffer = bufnr('%')
			silent BufferLineGoToBuffer -1
			let s:last_buffer = bufnr('%')
			execute 'buffer ' . s:current_buffer

			if s:last_buffer == s:current_buffer
				silent BufferLineCyclePrev
			else
				silent BufferLineCycleNext
			endif

			execute 'bdelete ' . s:current_buffer
		endif

		if SplitMode()
			quit
			return
		endif

		" Remove remaining empty buffer
		if &buftype == 'nofile'
			quit
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
nnoremap <silent> i <Plug>(StopHL)i
nnoremap <silent> a <Plug>(StopHL)a
autocmd CursorMoved * call HlSearch()

" SearchHighlight autogroup
function! HlSearch()
	if &buftype == 'nofile' || &buftype == 'prompt'
		return
	endif
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

