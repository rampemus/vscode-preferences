source ~/.config/nvim/common.vim

" Commented plugins are enabled for terminal only nvim
call plug#begin('~/.config/nvim-plugins')
Plug 'dahu/vim-fanfingtastic'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'qpkorr/vim-bufkill'
"  Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
"  Plug 'windwp/nvim-ts-autotag'
"  Plug 'norcalli/nvim-colorizer.lua'
call plug#end()

" End of vimrc support

source ~/.config/nvim/vscode.vim

if !exists('g:vscode')
	source ~/.config/nvim/util.vim

	if exists('g:started_by_firenvim')
		source ~/.config/nvim/firenvim.vim
	else
		" absolute line numbers on
		set number
		set path+=**
		set wildignore+=**/node_modules/**
		set wildignore+=**/vendor/**

		" Startup
		command! -nargs=0 OldFilesProject :lua require(
					\ 'telescope.builtin'
					\).oldfiles({ cwd_only = true })
		autocmd User CocNvimInit if argv()[0] == '.' | execute 'OldFilesProject' | endif
		let g:loaded_netrwPlugin = 1

		nnoremap <silent> - :Explore<CR>
		command! -nargs=0 H :lua require('telescope.builtin').help_tags()
	endif

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

	command! BNext call SmartBufferNext()
	command! BPrev call SmartBufferPrev()

	" Go to changed line (according to git diff)
	nnoremap gb :call ToggleBlame()<CR>

	" Indenting settings
	filetype plugin indent on
	autocmd FileType * if &filetype != 'vim' | setlocal shiftwidth=2 | setlocal tabstop=2 | endif

	" Show type docs from tsserver when pressing ghh
	nnoremap <silent> ghh :call CocAction('doHover')<CR>
	inoremap <silent><expr> <c-space> coc#refresh()

	let g:lightline = {
				\ 'colorscheme': 'onedark',
				\}

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

	inoremap <silent><expr> <CR> pumvisible()
				\ ? coc#_select_confirm()
				\ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

	function! CheckBackSpace() abort
		let col = col('.') - 1
		return !col || getline('.')[col - 1]  =~# '\s'
	endfunction

	" Remah keys for applying codeAction to the current buffer.
	nmap gq <Plug>(coc-codeaction)

	" Comments allowed
	autocmd BufRead,BufNewFile *.json,*.code-snippets,*.code-workspace set filetype=jsonc

	" Change colors
	:highlight Comment guifg=#a14646
	:highlight GitGutterChange guifg=#dbb671
	:highlight VirtColumn guifg=#3b4252

	:highlight CocExplorerNormalFloatBorder guifg=#56b6c2 guibg=#272B34
	:highlight CocExplorerNormalFloat guibg=#272B34

	" Read lua setup in lua
	autocmd BufRead,BufNewFile lua.vim set filetype=lua
	source ~/.config/nvim/lua.vim
endif

