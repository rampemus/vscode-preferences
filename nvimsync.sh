#!/bin/bash

###
# mkdir ~/.config
# touch ~/.config/nvim/init.vim
cp ./config/init.vim ~/.config/nvim/init.vim
cp ./config/coc-settings.json ~/.config/nvim/

# Theme
cp -rf ./config/autoload ~/.config/nvim/
cp -rf ./config/colors ~/.config/nvim/
cp -rf ./config/colors ~/.config/nvim/
cp -rf ./config/colorscheme/onedark.vim ~/.config/nvim/
mkdir -p ~/.config/nvim/pack/plugins/start
cd ~/.config/nvim/pack/plugins/start
git clone https://github.com/itchyny/lightline.vim lightline
echo 'highlight CursorLine term=bold cterm=bold' >> ~/.config/nvim/pack/plugins/start/lightline/plugin/lightline.vim
mv ~/.config/nvim/onedark.vim ~/.config/nvim/pack/plugins/start/lightline/autoload/lightline/colorscheme/

# Plugin manager
nvim +'PlugInstall' +qa
