" Update buffer when file changes on disk
function! CheckUpdate(timer)
	checktime
	call timer_start(1000,'CheckUpdate')
endfunction
if !exists("g:CheckUpdateStarted")
	let g:CheckUpdateStarted=1
	call timer_start(1000,'CheckUpdate')
endif

" Reset LSP after edit command
command! EditAndLspRestart :e! | call timer_start(1500, {-> execute('LspRestart')})

" Telescope commands
command! -nargs=0 OldFilesProject :lua require('telescope.builtin').oldfiles({ cwd_only = true })
autocmd User VeryLazy if &buftype == 'nofile' | execute 'OldFilesProject' | endif
command! -nargs=0 H :lua require('telescope.builtin').help_tags()
command! -nargs=0 Help :lua require('telescope.builtin').help_tags()
command! -nargs=0 Checkout :lua require('telescope.builtin').git_branches({ pattern = '--sort=-committerdate', previewer = false, callback = vim.cmd('EditAndLspRestart') })

" Terminal commands
command! Gitpull silent !git pull | EditAndLspRestart
command! PrettierWrite silent execute('!npx prettier --write ' . @%) | EditAndLspRestart
command! NxFormatWrite silent execute('!npx nx format:write --affected') | EditAndLspRestart
command! EslintFix silent execute('!npx eslint --fix ' . @%) | EditAndLspRestart
command! EslintFixAndPrettierWrite silent execute('!npx eslint --fix ' . @%) | silent execute('!npx prettier --write ' . @%) | EditAndLspRestart

set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
set guicursor+=a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
set guicursor+=sm:block-blinkwait175-blinkoff150-blinkon175

" VS code related jsons are in jsonc format
autocmd BufRead,BufNewFile *.code-snippets,settings.json,keybindings.json set filetype=jsonc
