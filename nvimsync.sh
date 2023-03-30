#!/bin/bash

### Sync vimrc
sed -n -e '1,/^nnoremap git :Git<space>/p' ./config/init.vim > ~/.vimrc

# run make dir only if --init is passed
if [ "$1" = "--init" ]; then
    mkdir ~/.vim/autoload/
fi
cp ./config/autoload/plug.vim ~/.vim/autoload/
vim +'PlugInstall' +qa

### Sync nvim
# touch and make dir only if --init is passed
if [ "$1" = "--init" ]; then
    mkdir ~/.config
    touch ~/.config/nvim/init.vim
fi
sed -i -e 's/"  //g' ./config/init.vim
cp ./config/init.vim ~/.config/nvim/init.vim
cp ./config/init.vim-e ./config/init.vim
rm ./config/init.vim-e

cp ./config/coc-settings.json ~/.config/nvim/

# Install plug
cp -rf ./config/autoload ~/.config/nvim/

# Plugin manager
nvim +'PlugInstall' +qa
