nmap ö /
vmap ö /
nmap Ö ?
vmap Ö ?
set showmatch
set nohlsearch
set incsearch
set mouse=a
set cursorline
set ignorecase
map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>

" turn relative line numbers on
:set number relativenumber

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

" grep navigation
nmap <Right> :cnext<CR>
nmap <Left> :cprevious<CR>

"f case insensitive
let g:fanfingtastic_ignorecase = 1

nmap + $
vmap + $

nnoremap Å ~
vnoremap Å ~

nnoremap å ^
vnoremap å ^

nnoremap <tab> >>
nnoremap <S-Tab> <<
vnoremap <Tab> >>
vnoremap <S-Tab> <<

" line destruction (reverse J)
nnoremap K $?[^=:\)\]\>\&\|\?]\s<CR>lxi<CR><Esc>k:noh<CR>

set autoindent
set clipboard+=unnamed

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx.html

if exists('g:vscode')
    xmap gc  <Plug>VSCodeCommentary
    nmap gc  <Plug>VSCodeCommentary
    omap gc  <Plug>VSCodeCommentary
    nmap gcc <Plug>VSCodeCommentaryLine
else
    let &t_SI.="\e[5 q" "SI = INSERT mode
    nnoremap Ä <c-o>
    nnoremap ä <c-i>
    set scrolloff=10
    colorscheme onedark
endif
