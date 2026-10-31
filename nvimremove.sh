#!/bin/bash
NVIM_DIR=~/.config/nvim

rm -f ~/.vimrc

# Remove vim-plug
rm -rf ~/.vim/autoload

rm -f "$NVIM_DIR"/init.vim "$NVIM_DIR"/lazy-lock.json
rm -f ~/Library/Application\ Support/com.mitchellh.ghostty/config

rm -rf ~/.config/coc
rm -rf ~/.config/nvim-plugins
rm -rf "$NVIM_DIR"/{autoload,colors,lua,vim,pack,snippets}
rm -rf ~/.local/share/nvim
