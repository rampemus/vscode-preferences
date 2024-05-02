# Install

Neovim version 9.0.0 required, node version > 17.0.0 required. Dependencies:

`brew install fzf `

To install `Plug` and `lazy.nvim` plugins, run:

`./nvimsync.sh --init`

This will write all required files to `~/.local` and `~/.config` directories and also install base plugins for vim in `~/.vim` directory.

[Install all nerd fonts](https://gist.github.com/davidteren/898f2dcccd42d9f8680ec69a3a5d350e)

```
brew tap homebrew/cask-fonts
brew search '/font-.*-nerd-font/' | awk '{ print $1 }' | xargs -I{} brew install --cask {} || true
```

# Uninstall

To remove all nvim and vim settings:

`./nvimremove.sh`

Plugin installations are not removed.

# VS Code settings and keybinds

VS Code keybindings.json has most of navigation and `config/vscode.vim` has all nvim plugin related mappings. VS Code neovim instance uses plug as plugin manager.

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

# Git aliases

For rebasing, caching todos and listing most recent branches:

```.gitconfig
[alias]
  todo = !git add . && git commit -m \"TODO\" --no-verify
  st = !echo Most recent branches && git branch --sort=committerdate | tail && git status
```

# Terminal settings

Source fzf keybindings to `~/.zshrc`:

```bash
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
```

Add git branch to the prompt:

```bash
# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' %b'

# Set up the prompt
setopt PROMPT_SUBST
PROMPT='%n@%m%1  %F{green}%c%F{red}${vcs_info_msg_0_}%f %F{primary}$ '
```

