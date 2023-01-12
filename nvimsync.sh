#!/bin/bash

# Sync vimrc
sed -n -e '1,/^set encoding=UTF-8/p' ./config/init.vim > ~/.vimrc

### Sync nvim
# mkdir ~/.config
# touch ~/.config/nvim/init.vim
sed -i -e 's/"  //g' ./config/init.vim
cp ./config/init.vim ~/.config/nvim/init.vim
cp ./config/init.vim-e ./config/init.vim
rm ./config/init.vim-e

cp ./config/coc-settings.json ~/.config/nvim/

# Install plug
cp -rf ./config/autoload ~/.config/nvim/

# Plugin manager
nvim +'PlugInstall' +qa
