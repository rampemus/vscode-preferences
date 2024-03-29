# Install

Neovim version 9.0.0 required, node version > 17.0.0 required. Additional requirements for coc.nvim:

`brew install python ripgrep`

Path to python installation is hard coded to `init.vim`. Also pynvim is needed for coc extensions:

`python3 -m pip install --user --upgrade pynvim`

To install coc and coc-plugins for neovim execute:

`./nvimsync.sh --init`

This will write all required files to `~/.local` and `~/.config` directories and also install base plugins for vim in `~/.vim` directory.

[Install all nerd fonts](https://gist.github.com/davidteren/898f2dcccd42d9f8680ec69a3a5d350e)

```
brew tap homebrew/cask-fonts
brew search '/font-.*-nerd-font/' | awk '{ print $1 }' | xargs -I{} brew install --cask {} || true
```

# Uninstall

To remove all nvim and vim settings, coc and nvim plugins execute:

`./nvimremove.sh`

# VS Code settings and keybinds

VS Code keybindings.json has most of navigation and `config/vscode.vim` has all nvim plugin related mappings.

## Neo Vim (Alexey Svetliakov) plugin settings

After installing neovim, dependencies and VS Code neovim plugin run:

`./nvimsync.sh --init`

And add link to the home folder:

`ln -s ~/Library/Application\ Support/Code/User .settings`

Neovim executable and init.vim sources are hard coded in `settings.json`.

## Additional notes about VS Code settings

You need to go to vscode settings and manually set:

```
"workbench.list.automaticKeyboardNavigation" = false,
"editor.cursorSurroundingLines" = 4
```

These don't seem to work through settings.json.
