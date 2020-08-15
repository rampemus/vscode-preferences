nmap ö /
vmap ö /
nmap Ö ?
vmap Ö ?
set showmatch
set nohlsearch
set incsearch
set mouse=a
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
"nmap GT gT " messes up gg and G movement
nmap <C-w><C-k> <C-w><C-i> 
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-h> <C-w>h
nmap <C-l> <C-w>l

" grep navigation
nmap <Right> :cnext<CR>
nmap <Left> :cprevious<CR>

"f case isensitive
let g:fanfingtastic_ignorecase = 1

"nnoremap Ä g;
"nnoremap ä g,
nmap + $
vmap + $

"inoremap jj <esc>
"inoremap kj <esc>
"inoremap jk <esc>
"inoremap kkk <esc>
"inoremap ddd <esc>
"inoremap ≤ <=
"inoremap ≥ >=

nnoremap Å ~

" nnoremap cw ciw
" nnoremap dw diw
" nnoremap cp ci
nnoremap å ^
vnoremap å ^

nnoremap <tab> >>
nnoremap <S-Tab> <<
vnoremap <Tab> >>
vnoremap <S-Tab> <<

" line destruction (reverse J)
nnoremap K $?[^=:\)\]\>\&\|\?]\s<CR>lxi<CR><Esc>k:noh<CR>

set autoindent
