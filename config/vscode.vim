silent! CocDisable
silent! Copilot disable
xmap gc  <Plug>VSCodeCommentary
nmap gc  <Plug>VSCodeCommentary
omap gc  <Plug>VSCodeCommentary
nmap gcc <Plug>VSCodeCommentaryLine

function! s:refactorInVisualMode()
	let mode = mode()
	if mode ==# 'V'
		let startLine = line('v')
		let endLine = line('.')
		call VSCodeNotifyRange('editor.action.refactor', startLine, endLine, 1)
	else
		let startPos = getpos('v')
		let endPos = getpos('.')
		call VSCodeNotifyRangePos(
					\'editor.action.refactor',
					\startPos[1], endPos[1], startPos[2], endPos[2] + 1, 1
					\)
	endif
endfunction

vnoremap gr <Cmd>call <SID>refactorInVisualMode()<CR>
nnoremap - <Cmd>call VSCodeNotify('workbench.view.explorer')<CR>
nnoremap <silent> gr <Cmd>call VSCodeNotify('editor.action.rename')<CR>
nnoremap <silent> ge <Cmd>call VSCodeNotify('editor.action.marker.next')<CR>
nnoremap <silent> gE <Cmd>call VSCodeNotify('editor.action.marker.prev')<CR>
nnoremap <silent> gad <Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>

nnoremap <silent> gf <Cmd>call VSCodeNotify('seito-openfile.openFileFromText')<CR>
nnoremap <silent> gq <Cmd>call VSCodeNotify('editor.action.quickFix')<CR>
nnoremap <silent> gb <Cmd>call VSCodeNotify('gitlens.toggleFileBlame')<CR
nnoremap <silent> ghh <Cmd>call VSCodeNotify('editor.action.showHover')<CR>
nnoremap <silent> ghn <Cmd>call VSCodeNotify('workbench.action.editor.nextChange')<CR>
nnoremap <silent> ghN <Cmd>call VSCodeNotify('workbench.action.editor.previousChange')<CR>
nnoremap <silent> ghu <cmd>call VSCodeNotify('git.revertSelectedRanges')<cr>
nnoremap <silent> ghs <cmd>call VSCodeNotify('git.stageSelectedRanges')<cr>
vnoremap <silent> ghn <Cmd>call VSCodeNotify('workbench.action.editor.nextChange')<CR>
vnoremap <silent> ghN <Cmd>call VSCodeNotify('workbench.action.editor.previousChange')<CR>
