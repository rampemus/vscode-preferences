# VS Code settings and keybinds

## Additional notes about VIM settings

To do the same mappings in VIM editor and instructions for keyboard settings: [my vimrc repository](https://github.com/rampemus/.vim)

You need to go to vscode settings and manually set:

```
"workbench.list.automaticKeyboardNavigation" = false,
"editor.cursorSurroundingLines" = 4
```

to false. These don't seem to work through settings.json.

## Neo Vim (Alexey Svetliakov) plugin settings

After installing neovim and VS Code neovim plugin run:

`./nvimsync.sh`

And add link to the home folder:

`ln -s ~/Library/Application\ Support/Code/User .settings`
