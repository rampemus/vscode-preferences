source ~/.config/nvim/common.vim

function! SmartBufferDelete()
	" Remove remaining empty buffer
	if &buftype == 'nofile'
		quit
	endif

	bd
endfunction

function! SmartBufferNext() abort
	bnext
endfunction

function! SmartBufferPrev() abort
	bprev
endfunction

command! BNext call SmartBufferNext()
command! BPrev call SmartBufferPrev()
command! -nargs=0 SmartBD :call SmartBufferDelete()

call plug#begin('~/.config/nvim-plugins')
Plug 'dahu/vim-fanfingtastic'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'qpkorr/vim-bufkill'
Plug 'github/copilot.vim'
call plug#end()

" End of vimrc support

source ~/.config/nvim/vscode.vim

