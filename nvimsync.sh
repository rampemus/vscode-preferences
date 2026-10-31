#!/bin/bash
set -e
cd "$(dirname "$0")"

INIT=false
[ "$1" = "--init" ] && INIT=true

NVIM_DIR=~/.config/nvim
GHOSTTY_DIR=~/Library/Application\ Support/com.mitchellh.ghostty

# Copy modules into a clean destination so deleted modules do not linger
sync_dir() { # src_dir dest_dir glob
  rm -rf "$2"
  mkdir -p "$2"
  cp "$1"/$3 "$2"/
}

sync_vim_modules() { sync_dir ./config/vim/modules "$NVIM_DIR/vim/modules" '*.vim'; }
sync_lua_modules() { sync_dir ./config/lua/modules "$NVIM_DIR/lua/modules" '*.lua'; }

### Sync vimrc
sed -n -e '1,/^" End of vimrc support/p' ./config/init.vim > ~/.vimrc
$INIT && mkdir -p ~/.vim/autoload
cp ./config/autoload/plug.vim ~/.vim/autoload/plug.vim
sync_vim_modules
vim +'PlugInstall' +qa
$INIT && vim -S ./config/version-lock.vim +qa

### Sync nvim
mkdir -p "$NVIM_DIR/snippets" "$GHOSTTY_DIR"
cp ./ghostty.config "$GHOSTTY_DIR/config"
cp ./config/nvim-pack-lock.json "$NVIM_DIR/nvim-pack-lock.json"

### Sync claude
mkdir -p ~/.claude
cp ./claude/settings.json ~/.claude/settings.json

### Install snippets (.code-snippets -> .json)
cp ./snippets/package.json "$NVIM_DIR/snippets/package.json"
for f in ./snippets/*.code-snippets; do
  cp "$f" "$NVIM_DIR/snippets/$(basename "$f" .code-snippets).json"
done

### Install plug dependencies for vscode setup
rm -f "$NVIM_DIR/init.lua"
cp ./config/init.vim "$NVIM_DIR/init.vim"
nvim +'PlugInstall' +qa
$INIT && nvim -S ./config/version-lock.vim +qa

### Install lazy.nvim setup
rm -f "$NVIM_DIR/init.vim"
cp ./config/init.lua "$NVIM_DIR/init.lua"
sync_lua_modules
