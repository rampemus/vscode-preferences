# Install

Neovim version 0.10.0 required, node version ^20.0.0 required. Dependencies:

```bash
brew install fzf python neovim rg jq
pip3 install pynvim # for fzf to work properly
```

To install `Plug` and `lazy.nvim` plugins, run:

`./nvimsync.sh --init`

This will write all required files to `~/.local` and `~/.config` directories and also install base plugins for vim in `~/.vim` directory.

[Install all nerd fonts](https://gist.github.com/davidteren/898f2dcccd42d9f8680ec69a3a5d350e)

```bash
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

For caching todos, recent status and stashing:

```.gitconfig
[alias]
  todo = !git add . && git commit -m \"TODO\" --no-verify
  st = !git fetch > /dev/null 2>&1 & echo Most recent branches && git branch --sort=committerdate | tail && git status
  stash = !git stash save --include-untracked
```

# Zsh aliases

```bash
alias ll='ls -laF'
alias la='ls -A'
alias l='ls -CF'
alias SmartBD="exit"
alias \\e:SmartBD="exit"
alias TelescopeFindFiles='cd $(find . -type d -print | fzf)'
alias \\e:TelescopeFindFiles='cd $(find . -type d -print | fzf)'

alias nx='npx nx'
alias prettier='npx prettier'
alias eslint='npx eslint'
alias test='npx nx run-many --target=test'
alias jest='npx jest'
alias prisma='npx prisma'
alias brush='npx bru'
alias GitStatus='git st'
```

# Terminal settings

Source fzf keybindings to `~/.zshrc`:

```bash
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
```

Add git branch to the prompt:

```bash
# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' %b'

# Set up the prompt
setopt PROMPT_SUBST
PROMPT='%n@%m%1  %F{green}%c%F{red}${vcs_info_msg_0_}%f %F{primary}$ '

# Read man pages in vim
export MANPAGER="col -b | vim -MR - "
```

