# VS Code settings and keybinds

## Additional notes about VIM settings

To do the same mappings in VIM editor and instructions for keyboard settings: [vim repository](https://github.com/rampemus/.vim)

You need to go to vscode settings manually and set:

`workbench.list.automaticKeyboardNavigation`

to false. This doesn't seem to register through settings.json.

## Neo Vim (Alexey Svetliakov) plugin settings

After installing neovim and VS Code neovim plugin run:

`./nvimsync.sh`