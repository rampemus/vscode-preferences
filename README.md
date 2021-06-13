# Install

Neovim >5.0.0v required. Additional requirements for coc.nvim:

`brew install python ripgrep`

Path to python installation is hard coded to `init.vim`. Also pynvim is needed for coc extensions:

`python3 -m pip install --user --upgrade pynvim`

To install theme and install coc/plugins for neovim execute:

`./nvimsync.sh`

This will write all required files to `~/.local` and `~/.config` directories.

# Uninstall

To remove all nvim settings, themes, coc and nvim plugins execute:

`./nvimremove`

# VS Code settings and keybinds

VS Code keybindings.json has most of navigation and `init.vim` has all nvim plugin related mappings.

## Neo Vim (Alexey Svetliakov) plugin settings

After installing neovim, dependencies and VS Code neovim plugin run:

`./nvimsync.sh`

And add link to the home folder:

`ln -s ~/Library/Application\ Support/Code/User .settings`

Neovim executable and init.vim paths are hard coded in `settings.json`.

## Additional notes about VS Code settings

You need to go to vscode settings and manually set:

```
"workbench.list.automaticKeyboardNavigation" = false,
"editor.cursorSurroundingLines" = 4
```

These don't seem to work through settings.json.
