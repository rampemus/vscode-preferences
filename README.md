# VS Code settings and keybinds

## Additional notes about VIM settings

To do the same mappings in VIM editor and instructions for keyboard settings: [vim repository](https://github.com/rampemus/.vim)

You need to go to vscode settings and manually set:

```
"workbench.list.automaticKeyboardNavigation" = false,
"editor.cursorSurroundingLines" = 9
```

to false. These don't seem to work through settings.json.

## Neo Vim (Alexey Svetliakov) plugin settings

After installing neovim and VS Code neovim plugin run:

`./nvimsync.sh`