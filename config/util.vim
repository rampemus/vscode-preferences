" Utility functions sourced in init.vim

" Create v split
nnoremap <C-w><C-l> <C-w>k<C-w><C-v><C-w>h<C-^><C-w>l
nnoremap <C-w><C-h> <C-w>k<C-w><C-v><C-^><C-w>h

" Create h split
nnoremap <C-w><C-k> <C-w><C-s><C-^><C-w>k
nnoremap <C-w><C-j> <C-w><C-s><C-w>k<C-^><C-w>j

" Vertical splits split right Splits split below
set splitright
set splitbelow

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

" Remove highlights automatically
noremap <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]

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

function! SmartBufferNext() abort
	let s:prev_buffer_index = bufnr('%')
	if &filetype == 'toggleterm' || &filetype == 'NvimTree' || &filetype == 'help'
		wincmd w
		if &filetype != 'toggleterm' && &filetype != 'NvimTree' && &filetype != 'help'
			:lua require('bufferline').go_to(1)
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
	if &filetype == 'toggleterm' || &filetype == 'NvimTree' || &filetype == 'help'
		wincmd W
		if &filetype != 'toggleterm' && &filetype != 'NvimTree' && &filetype != 'help'
			:lua require('bufferline').go_to(-1)
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

function! ToggleBlame()
	let blame_bufs = filter(
		\ range(1, bufnr('$')),
		\ 'bufexists(v:val) && getbufvar(v:val, "&filetype") == "fugitiveblame"'
		\)
	if len(blame_bufs) > 0
		call map(blame_bufs, 'nvim_buf_delete(v:val, {"force": 1})')
	else
		execute 'Git blame'
		call feedkeys("3\<C-y>", 'n')
	endif
endfunction
