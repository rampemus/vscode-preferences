set nohls
set showmatch
set incsearch
set mouse=a
set ignorecase

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
" And in react find the last return
autocmd BufRead *.tsx,*.jsx nnoremap <buffer> gm G?return<cr>

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
	set wildignore=*.bak,.DS_Store
	set wildignore+=*/tmp/*,*.so,*.swp,*.zip
	set wildignore+=*/node_modules/*,*/vendor/*,*/package\-lock.json
	set wildignore+=node_modules/*,vendor/*,package\-lock.json
	set wildignore+=*.so,*.swp,*.zip,*.pyc
	set wildignore+=*.db,*.sqlite,.DS_Store,*/.git,*.bak
endfunction

if !exists('g:vscode')
	set scrolloff=6
	set autoindent
	set laststatus=2

	set cursorline
	if !exists('g:started_by_firenvim')
		set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
		set guicursor+=a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
		set guicursor+=sm:block-blinkwait175-blinkoff150-blinkon175
		set signcolumn=yes
	endif

	hi ColorColumn ctermbg=lightgrey guibg=lightgrey
	hi link xmlEndTag xmlTag

	nnoremap Ä <c-o>
	nnoremap ä <c-i>

	command! -nargs=0 HighlightGroup :echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

	function! SmartBufferDelete()
		let s:coc_explorer_window = 0

		for win in range(1, winnr('$'))
			if getbufvar(winbufnr(win), '&filetype') == 'coc-explorer'
				let s:coc_explorer_window = 1
				break
			endif
		endfor

		if &filetype == 'coc-explorer' || winnr('$') > 1 + s:coc_explorer_window
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

" Commented plugins are enabled for terminal only nvim
call plug#begin('~/.config/nvim-plugins')
Plug 'dahu/vim-fanfingtastic'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'qpkorr/vim-bufkill'
"  Plug 'ja-he/heat.nvim'
"  Plug 'nvim-lua/plenary.nvim'
"  Plug 'github/copilot.vim'
"  Plug 'nvim-telescope/telescope.nvim'
"  Plug 'airblade/vim-gitgutter'
"  Plug 'neoclide/coc.nvim', {'branch': 'release'},
"  Plug 'andys8/vscode-jest-snippets'
"  Plug 'kevinoid/vim-jsonc'
"  Plug 'lukas-reineke/indent-blankline.nvim'
"  Plug 'navarasu/onedark.nvim'
"  Plug 'nvim-lualine/lualine.nvim'
"  Plug 'kyazdani42/nvim-web-devicons'
"  Plug 'prichrd/netrw.nvim'
"  Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
"  Plug '1478zhcy/lualine-copilot'
"  Plug 'nvim-treesitter/nvim-treesitter'
"  Plug 'windwp/nvim-autopairs'
"  Plug 'windwp/nvim-ts-autotag'
"  Plug 'akinsho/nvim-toggleterm.lua'
"  Plug 'fannheyward/telescope-coc.nvim'
"  Plug 'petertriho/nvim-scrollbar'
"  Plug 'akinsho/bufferline.nvim'
"  Plug 'norcalli/nvim-colorizer.lua'
call plug#end()

" f case insensitive
let g:fanfingtastic_ignorecase = 1
let g:indent_blankline_show_trailing_blankline_indent = v:false

nnoremap git :Git

if exists('g:vscode')
	source ~/.config/nvim/vscode.vim
else
	let g:onedark_config = {
				\ 'style': 'light',
				\}
	colorscheme onedark

	if exists('g:started_by_firenvim')
		source ~/.config/nvim/firenvim.vim
	else
		" absolute line numbers on
		set number
		set path+=**
		set wildignore+=**/node_modules/**
		set wildignore+=**/vendor/**

		" Startup
		command! -nargs=0 OldFilesProject :lua require('telescope.builtin').oldfiles({ cwd_only = true })
		autocmd User CocNvimInit if argv()[0] == '.' | execute 'OldFilesProject' | endif
		let g:loaded_netrwPlugin = 1

		" Coc explorer instead of vim-vinegar & netrw
		nnoremap <silent> - :CocCommand explorer --no-toggle --reveal<CR>
		command! -nargs=0 H :lua require('telescope.builtin').help_tags()
	endif

	map <ScrollWheelUp> <C-Y>
	map <ScrollWheelDown> <C-E>
	set cmdheight=0

	set autoread
	function! CheckUpdate(timer)
		silent! checktime
		if &filetype == 'toggleterm' || &filetype == 'coc-explorer'
			CocCommand git.refresh
			CocCommand explorer.doAction refresh
		endif
		call timer_start(1000,'CheckUpdate')
	endfunction
	if !exists("g:CheckUpdateStarted")
		let g:CheckUpdateStarted=1
		call timer_start(1,'CheckUpdate')
	endif

	function! SmartBufferNext() abort
		let s:prev_buffer_index = bufnr('%')
		if &filetype == 'toggleterm' || &filetype == 'coc-explorer' || &filetype == 'help'
			wincmd w
			if &filetype != 'toggleterm' && &filetype != 'coc-explorer' && &filetype != 'help'
				execute 'lua require"bufferline".go_to(1)'
			endif
		else
			BufferLineCycleNext
			" Do not loop around
			if bufnr('%') <= s:prev_buffer_index
				BufferLineCyclePrev
				wincmd w
			endif
		endif
	endfunction

	function! SmartBufferPrev() abort
		let s:prev_buffer_index = bufnr('%')
		if &filetype == 'toggleterm' || &filetype == 'coc-explorer' || &filetype == 'help'
			wincmd W
			if &filetype != 'toggleterm' && &filetype != 'coc-explorer' && &filetype != 'help'
				execute 'lua require"bufferline".go_to(-1)'
			endif
		else
			BufferLineCyclePrev
			" Do not loop around
			if bufnr('%') >= s:prev_buffer_index
				BufferLineCycleNext
				wincmd W
			endif
		endif
	endfunction

	command! BNext call SmartBufferNext()
	command! BPrev call SmartBufferPrev()

	" Create v split
	nnoremap <C-w><C-l> <C-w>k<C-w><C-v><C-w>h<C-^><C-w>l
	nnoremap <C-w><C-h> <C-w>k<C-w><C-v><C-^><C-w>h

	" Create h split
	nnoremap <C-w><C-k> <C-w><C-s><C-^><C-w>k
	nnoremap <C-w><C-j> <C-w><C-s><C-w>k<C-^><C-w>j

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
	" Remove highlights automatically end

	function! s:GitGutterNextHunkCycle()
		let line = line('.')
		silent! GitGutterNextHunk
		if line('.') == line
			1
			GitGutterNextHunk
		endif
	endfunction

	" Go to changed line (according to git diff)
	nnoremap ghn <Cmd>call <SID>GitGutterNextHunkCycle()<CR>
	nnoremap ghN <Plug>(GitGutterPrevHunk)
	nnoremap ghu <Plug>(GitGutterUndoHunk)
	nnoremap ghs <Plug>(GitGutterStageHunk) :CocCommand git.refresh<CR>
	nnoremap gb :call ToggleBlame()<CR>

	function! ToggleBlame()
		let blame_bufs = filter(range(1, bufnr('$')), 'bufexists(v:val) && getbufvar(v:val, "&filetype") == "fugitiveblame"')
		if len(blame_bufs) > 0
			call map(blame_bufs, 'nvim_buf_delete(v:val, {"force": 1})')
		else
			execute 'Git blame'
			call feedkeys("3\<C-y>", 'n')
		endif
	endfunction

	nnoremap <silent> ge <Plug>(coc-diagnostic-next)<CR>
	nnoremap <silent> gE <Plug>(coc-diagnostic-prev)<CR>

	autocmd BufWritePost * GitGutter
	let g:gitgutter_async = 1
	let g:gitgutter_signs = 0 " use coc-settings.json signs

	" Indenting settings
	filetype plugin indent on
	autocmd FileType * if &filetype != 'vim' | setlocal shiftwidth=2 | setlocal tabstop=2 | endif

	let g:copilot_filetypes = {
				\ 'markdown': 1,
				\ 'telescope': 0,
				\}

	" Show type docs from tsserver when pressing ghh
	nnoremap <silent> ghh :call CocAction('doHover')<CR>
	inoremap <C-Enter> <Esc>:Copilot panel<CR>
	inoremap <silent><expr> <c-space> coc#refresh()

	let g:lightline = {
				\ 'colorscheme': 'onedark',
				\}

	" use terminal mode and go to normal mode with esc
	autocmd TermEnter term://*toggleterm#*
		\ tnoremap <silent><Esc> <C-\><C-n>

	" Vertical splits split right Splits split below
	set splitright
	set splitbelow

	let g:coc_global_extensions = [
				\ 'coc-json',
				\ 'coc-git',
				\ 'coc-tsserver',
				\ 'coc-snippets',
				\ 'coc-prettier',
				\ 'coc-eslint',
				\ 'coc-explorer',
				\ 'coc-vimlsp',
				\]
	let g:python_host_prog = '/opt/homebrew/bin/2to3'
	let g:python3_host_prog = '/opt/homebrew/bin/python3'

	inoremap <a-BS> <Esc>dbxa
	" cmd-bs cmd-left cmd-right
	inoremap <char-0x15> <Esc>d^I
	inoremap <char-0x01> <Esc>I
	inoremap <char-0x05> <Esc>A
	" alt-bs
	inoremap <char-0x1b><char-0x08> <C-w>
	" bind escape b to <C-Left>
	inoremap <A-Left> asdf
	" bind escape b, f to move cursor word right/left
	inoremap <char-0x1b>b <C-Left>
	inoremap <char-0x1b>f <Esc>ea
	nnoremap <char-0x1b>f e

	inoremap <silent><expr> <CR> pumvisible()
				\ ? coc#_select_confirm()
				\ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

	function! CheckBackSpace() abort
		let col = col('.') - 1
		return !col || getline('.')[col - 1]  =~# '\s'
	endfunction

	let g:copilot_no_tab_map = v:true
	inoremap <silent><expr> <TAB>
		\ pumvisible() ? coc#_select_confirm() :
		\ coc#expandableOrJumpable() ?
		\ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
		\ copilot#Enabled() ? copilot#Accept() :
		\ CheckBackSpace() ? "\<TAB>" :
		\ coc#refresh()

	cnoremap <Down> <C-N>
	cnoremap <Up> <C-P>
	cnoremap <C-a> <Home>
	cnoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

	nmap <silent> gd :Telescope coc definitions<cr>
	nmap <silent> gad :Telescope coc references<cr>
	nmap <silent> gy :Telescope coc type_definitions<cr>
	nmap <silent> gi :Telescope coc implementations<cr>
	nmap <silent> gr <Plug>(coc-rename)
	vmap <silent> gr <Plug>(coc-codeaction-refactor-selected)

	" Remah keys for applying codeAction to the current buffer.
	nmap gq <Plug>(coc-codeaction)

	" Comments allowed
	autocmd BufRead,BufNewFile *.json,*.code-snippets,*.code-workspace set filetype=jsonc
	:highlight Comment guifg='#a14646'
	:highlight GitGutterChange guifg='#dbb671'

	source ~/.config/nvim/lua.vim
endif

