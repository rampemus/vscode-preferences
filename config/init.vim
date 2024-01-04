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
"  Plug 'windwp/nvim-ts-autotag'
call plug#end()

" End of vimrc support

source ~/.config/nvim/vscode.vim

