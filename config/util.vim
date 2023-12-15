" Utility functions sourced in init.vim

function! SmartBufferNext() abort
	let s:prev_buffer_index = bufnr('%')
	if &filetype == 'toggleterm' || &filetype == 'coc-explorer' || &filetype == 'help'
		wincmd w
		if &filetype != 'toggleterm' && &filetype != 'coc-explorer' && &filetype != 'help'
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
	if &filetype == 'toggleterm' || &filetype == 'coc-explorer' || &filetype == 'help'
		wincmd W
		if &filetype != 'toggleterm' && &filetype != 'coc-explorer' && &filetype != 'help'
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

function! NextError()
	if !&spell
		call CocAction('diagnosticNext')
	else
		execute 'normal! ]s'
	endif
endfunction

function! PrevError()
	if !&spell
		call CocAction('diagnosticPrevious')
	else
		execute 'normal! [s'
	endif
endfunction

