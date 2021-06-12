#!/bin/bash

###
# mkdir ~/.config
# touch ~/.config/nvim/init.vim
cp ./config/init.vim ~/.config/nvim/init.vim

# Theme
cp -rf ./config/autoload ~/.config/nvim/
cp -rf ./config/colors ~/.config/nvim/
cp -rf ./config/colors ~/.config/nvim/
cp -rf ./config/colorscheme/onedark.vim ~/.config/nvim/
mkdir -p ~/.config/nvim/pack/plugins/start
cd ~/.config/nvim/pack/plugins/start
git clone https://github.com/itchyny/lightline.vim
mv ~/.config/nvim/pack/plugins/start/lightline.vim ~/.config/nvim/pack/plugins/start/lightline
echo 'highlight CursorLine term=bold cterm=bold' >> ~/.config/nvim/pack/plugins/start/lightline/plugin/lightline.vim
mv ~/.config/nvim/onedark.vim ~/.config/nvim/pack/plugins/start/lightline/autoload/lightline/colorscheme/

# Plugins
# mkdir -p ~/.local/share/nvim/site/pack/airblade/start
# mkdir -p ~/.local/share/nvim/site/pack/dahu/start
# mkdir -p ~/.local/share/nvim/site/pack/peitalin/start
# mkdir -p ~/.local/share/nvim/site/pack/tpope/start
# cd ~/.local/share/nvim/site/pack/airblade/start
# git clone https://github.com/airblade/vim-gitgutter.git
# cd ~/.local/share/nvim/site/pack/dahu/start
# git clone https://github.com/dahu/vim-fanfingtastic
# cd ~/.local/share/nvim/site/pack/peitalin/start
# git clone https://github.com/peitalin/vim-jsx-typescript
# cd ~/.local/share/nvim/site/pack/tpope/start
# git clone https://github.com/tpope/vim-commentary
# git clone https://github.com/tpope/vim-surround
# git clone https://github.com/tpope/vim-repeat

# Plugin manager
nvim +'PlugInstall' +qa
