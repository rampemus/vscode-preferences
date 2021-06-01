#!/bin/bash

###
# mkdir ~/.config
# touch ~/.config/nvim/init.vim

cp ./config/init.vim ~/.config/nvim/init.vim
cp -rf ./config/autoload ~/.config/nvim/
cp -rf ./config/colors ~/.config/nvim/
cp -rf ./config/pack ~/.config/nvim/
cp -rf ./nvim ~/.local/share/nvim/site
