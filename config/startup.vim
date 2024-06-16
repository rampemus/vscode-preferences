" Update buffer when file changes on disk
function! CheckUpdate(timer)
	checktime
	call timer_start(1000, 'CheckUpdate')
endfunction
if !exists("g:CheckUpdateStarted")
	let g:CheckUpdateStarted=1
	call timer_start(1000, 'CheckUpdate')
endif

" Reset LSP after edit command
command! EditAndLspRestart :e! | call timer_start(1500, {-> execute('LspRestart')})

" Telescope commands
command! -nargs=0 OldFilesProject :lua require('telescope.builtin').oldfiles({ cwd_only = true })
autocmd User LazyVimStarted if &buftype == 'nofile' | execute 'OldFilesProject' | endif
command! -nargs=0 H :lua require('telescope.builtin').help_tags()
command! -nargs=0 Help :lua require('telescope.builtin').help_tags()
command! -nargs=0 Checkout :lua require('telescope.builtin').git_branches({ pattern = '--sort=-committerdate', previewer = false, callback = vim.cmd('EditAndLspRestart') })

" Terminal commands
command! Gitpull silent !git pull | EditAndLspRestart
command! NxFormatWrite silent execute('!npx nx format:write --affected') | EditAndLspRestart
command! RestoreTerminals :call RestoreTerminals()

function! RestoreTerminals()
	let numberOfSplitTerminals = system('cat ./.vscode/settings.json |'
		\ . ' jq ''."restoreTerminals.terminals"[0].splitTerminals'' |'
		\ . ' jq length')

	for i in range(numberOfSplitTerminals)
		let numberOfCommands = system('cat ./.vscode/settings.json |'
			\ . ' jq ''."restoreTerminals.terminals"[0].splitTerminals[' . i . '].commands'' |'
			\ . ' jq length')
		
		for j in range(numberOfCommands)
			let command = system('cat ./.vscode/settings.json |'
				\ . ' jq ''."restoreTerminals.terminals"[0].splitTerminals[' . i . '].commands[' . j . ']''')

			execute (i + 1) . 'TermExec cmd=' . command
		endfor
	endfor
endfunction

" Enable comments in VS code related or eslint jsons
autocmd BufRead,BufNewFile *.code-snippets,settings.json,keybindings.json,.eslintrc.json
	\ set filetype=jsonc | highlight jsonLineComment guifg='#a14646'
