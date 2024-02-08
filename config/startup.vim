" Update buffer when file changes on disk
function! CheckUpdate(timer)
checktime
call timer_start(500,'CheckUpdate')
endfunction
if !exists("g:CheckUpdateStarted")
let g:CheckUpdateStarted=1
call timer_start(500,'CheckUpdate')
endif

command! -nargs=0 OldFilesProject :lua require('telescope.builtin').oldfiles({ cwd_only = true })
autocmd User VeryLazy if &buftype == 'nofile' | execute 'OldFilesProject' | endif
command! -nargs=0 H :lua require('telescope.builtin').help_tags()
command! -nargs=0 Help :lua require('telescope.builtin').help_tags()

set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
set guicursor+=a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
set guicursor+=sm:block-blinkwait175-blinkoff150-blinkon175

" VS code related jsons are in jsonc format
autocmd BufRead,BufNewFile *.code-snippets,settings.json,keybindings.json set filetype=jsonc