" Utility functions sourced in init.lua

" Create v split
nnoremap <C-w><C-l> <C-w>k<C-w><C-v><C-w>h<C-^><C-w>l
nnoremap <C-w><C-h> <C-w>k<C-w><C-v><C-^><C-w>h

" Create h split
nnoremap <C-w><C-k> <C-w><C-s><C-^><C-w>k
nnoremap <C-w><C-j> <C-w><C-s><C-w>k<C-^><C-w>j

" Vertical splits split right Splits split below
set splitright
set splitbelow

" Remove highlights automatically
noremap <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
augroup SearchHighlight
	au!
	au CursorMoved * call HlSearch()
	au InsertEnter * call StopHL()
augroup end

" Like bufdo but restore the current buffer.
function! BufDo(command)
	let currentBuffer = bufnr("%")
	execute 'bufdo ' . a:command
	execute 'buffer ' . currentBuffer
endfunction
com! -nargs=+ -complete=command Bufdo call BufDo(<q-args>)

" Bufferline navigation
nnoremap gt :BufferLinePick<CR>
command! BNext call SmartBufferNext()
command! BPrev call SmartBufferPrev()

if !exists('g:vscode')
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

	" Alt backspace also when renaming in lsp
	cnoremap <char-0x1b><char-0x08> <C-w>
	" Alt right and left when renaming in lsp
	cnoremap <char-0x1b>f <C-Right>
	cnoremap <char-0x1b>b <C-Left>
endif

" Delete both sides of the cursor for matching pairs
function! SmartBackspace()
	let col = col('.') - 1
	let char = getline('.')[col - 1]
	let nextchar = getline('.')[col]

	if char ==# '(' && nextchar ==# ')'
		return "\<Right>\<BS>\<BS>"
	elseif char ==# '[' && nextchar ==# ']'
		return "\<Right>\<BS>\<BS>"
	elseif char ==# '{' && nextchar ==# '}'
		return "\<Right>\<BS>\<BS>"
	elseif char ==# "'" && nextchar ==# "'"
		return "\<Right>\<BS>\<BS>"
	elseif char ==# '"' && nextchar ==# '"'
		return "\<Right>\<BS>\<BS>"
	endif

	return "\<BS>"
endfunction
inoremap <expr> <BS> SmartBackspace()

" Remove highlights automatically
noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
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

function UtilFiletype()
	return &filetype == 'toggleterm'
	\ || &filetype == 'NvimTree'
	\ || &filetype == 'help'
	\ || &filetype == 'blame'
	\ || &diff
endfunction

function! SmartBufferNext() abort
	if UtilFiletype()
		wincmd w
		if !UtilFiletype()
			:lua require('bufferline').go_to(1, true)
		endif
	else
		let s:prev_buffer_index = bufnr('%')
		:lua require('bufferline').go_to(-1, true)
		if bufnr('%') != s:prev_buffer_index 
			:execute 'buffer ' . s:prev_buffer_index
			BufferLineCycleNext
		else
			wincmd w
		endif
	endif
endfunction

function! SmartBufferPrev() abort
	if UtilFiletype()
		wincmd W
		if !UtilFiletype()
			:lua require('bufferline').go_to(-1, true)
		endif
	else
		let s:prev_buffer_index = bufnr('%')
		:lua require('bufferline').go_to(1, true)
		if bufnr('%') != s:prev_buffer_index 
			:execute 'buffer ' . s:prev_buffer_index
			BufferLineCyclePrev
		else
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

