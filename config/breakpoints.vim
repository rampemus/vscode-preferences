function! IsLarge()
	return &columns > 80 + 40
endfunction

" make islarge available to command prompt
command! -nargs=0 IsLarge echo IsLarge()

function! ToggleExplorer()
	let args = IsLarge() ? '--no-toggle --reveal' : '--position=floating --floating-width=40'
	execute 'CocCommand explorer ' . args
endfunction
