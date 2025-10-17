set hls
set showmatch
set incsearch
set mouse=a
set ignorecase
set fillchars+=diff:\ 
set spelloptions+=camel
language en_US.UTF-8

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
function Scroll(direction)
	let offset = a:direction == 'up' ? 2 + &scrolloff : -&scrolloff
	if line('.') < line('$') - winheight(0) + offset
		if (a:direction == 'up')
			return "\<C-u>zt"
		endif
		return "\<C-d>zt"
	else
		return "G" . (winheight(0) - &scrolloff - 1) . "gk"
	endif
endfunction
nnoremap <expr> <C-d> Scroll('down')
nnoremap <expr> <C-u> Scroll('up')

" Except in vue find script tag start
autocmd BufRead *.vue nnoremap <buffer> gm gg/<script><cr>

autocmd BufNewFile,BufRead .env* set filetype=env
augroup env_syntax
	autocmd!
	autocmd BufNewFile,BufRead .env* syntax match envVar /^[A-Za-z0-9_]\+\ze=/
	autocmd BufNewFile,BufRead .env* syntax match envValue /=\zs.\+$/
	autocmd BufNewFile,BufRead .env* highlight envValue guifg='#98c379'
	autocmd BufNewFile,BufRead .env* highlight envVar guifg='#e5c07b'

	autocmd BufNewFile,BufRead .env* syntax match envComment /#.*/ containedin=envValue
	autocmd BufNewFile,BufRead .env* highlight envComment guifg='#a14646' gui=italic
augroup END
autocmd BufNewFile,BufRead .env* setlocal commentstring=#\ %s

" In jsx find the default import definition
if !exists('g:vscode')
	autocmd BufRead *.tsx,*.jsx nnoremap <buffer> gm G?export default<CR>$h:silent! Telescope lsp_definitions<cr>

	" Configure Copilot based on .vscode/settings.json
	let current_file = expand('%:p')
	let current_dir = current_file == '' ? getcwd() : fnamemodify(current_file, ':h')
	let copilotVsCodeEnabled =  "/.vscode/settings.json | " 
	  \. "jq '.[\"github.copilot.editor.enableAutoCompletions\"]'"
	let copilot = system("cat " . current_dir . copilotVsCodeEnabled)[0:4]

	" Enable/disable copilot based on VSCode setting
	let g:copilot_filetypes = copilot == 'false' ? {
		\'*': v:false,
		\'markdown': v:true,
		\'yaml': v:true,
	\} : {
		\'*': v:true,
		\'env': v:false,
	        \'DressingInput': v:false,
	\}
	command! CopilotEnabled :let g:copilot_filetypes = {'*': v:true} | Copilot enable
	command! CopilotDisable :Copilot disable

	" gr to replace all word occurrences under cursor
	nnoremap gr :%s/\<<C-r><C-w>\>//g<left><left>
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
	map <silent> <buffer> a d
	map <silent> <buffer> r R
	map <silent> <buffer> dd D
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

			let &t_EI = "\033[2 q" " NORMAL  █
			let &t_SI = "\033[5 q" " INSERT  |

			set ttimeout
			set ttimeoutlen=1
			set ttyfast
		endif
	endif

	" leave insert mode quickly
	if !has('gui_running')
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

