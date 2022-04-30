#!/bin/bash

###
# mkdir ~/.config
# touch ~/.config/nvim/init.vim
cp ./config/init.vim ~/.config/nvim/init.vim
cp ./config/coc-settings.json ~/.config/nvim/

# Install plug
cp -rf ./config/autoload ~/.config/nvim/

# Plugin manager
nvim +'PlugInstall' +qa
