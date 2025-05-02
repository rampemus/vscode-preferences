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

" Like bufdo but restore the current buffer.
function! BufDo(command)
	let currentBuffer = bufnr('%')
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
	inoremap <M-BS> <C-w>
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
	cnoremap <M-BS> <C-w>
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
	elseif char ==# '"' && nextchar ==# '"' && &filetype != 'vim'
		return "\<Right>\<BS>\<BS>"
	endif

	return "\<BS>"
endfunction
inoremap <expr> <BS> SmartBackspace()

function! s:GitGutterNextHunkCycle()
	let line = line('.')
	silent! GitGutterNextHunk
	if line('.') == line
		1
		GitGutterNextHunk
	endif
endfunction

" bufnr defaults to current buffer and is not required
function UtilFiletype(...)
	let filetype = a:0 > 0 ? getbufvar(a:1, '&filetype') : &filetype
	return filetype == 'toggleterm'
	\ || filetype == 'NvimTree'
	\ || filetype == 'blame'
	\ || filetype == 'quickfix'
endfunction

function SplitMode()
	let windows = getwininfo()

	let utilWindows = 0
	for window in windows
		if UtilFiletype(window['bufnr'])
			let utilWindows += 1
		endif
	endfor

	return len(windows) - utilWindows > 1
endfunction

function! SmartBufferNext() abort
	if SplitMode()
		wincmd w
		return
	endif
	if UtilFiletype()
		wincmd w
		if !UtilFiletype()
			lua require('bufferline').go_to(1, true)
		endif
	else
		let s:prev_buffer_index = bufnr('%')
		lua require('bufferline').go_to(-1, true)
		if bufnr('%') != s:prev_buffer_index 
			execute 'buffer ' . s:prev_buffer_index
			BufferLineCycleNext
		else
			wincmd w
		endif
	endif
endfunction

function! SmartBufferPrev() abort
	if SplitMode() 
		wincmd W
		return
	endif
	if UtilFiletype()
		wincmd W
		if !UtilFiletype()
			lua require('bufferline').go_to(-1, true)
		endif
	else
		let s:prev_buffer_index = bufnr('%')
		lua require('bufferline').go_to(1, true)
		if bufnr('%') != s:prev_buffer_index 
			execute 'buffer ' . s:prev_buffer_index
			BufferLineCyclePrev
		else
			wincmd W
		endif
	endif
endfunction

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
