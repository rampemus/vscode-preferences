#!/bin/bash

### Sync vimrc
sed -n -e '1,/^" End of vimrc support/p' ./config/init.vim > ~/.vimrc

# run make dir only if --init is passed
if [ "$1" = "--init" ]; then
    mkdir ~/.vim/autoload/
fi
cp ./config/autoload/plug.vim ~/.vim/autoload/
vim +'PlugInstall' +qa
if [ "$1" = "--init" ]; then
    vim -S ./config/version-lock.vim +qa
fi

### Sync nvim
# touch and make dir only if --init is passed
if [ "$1" = "--init" ]; then
  mkdir ~/.config
  touch ~/.config/nvim/init.lua
  touch ~/.config/nvim/vscode.vim
  touch ~/.config/nvim/firenvim.vim
  touch ~/.config/nvim/util.vim
  touch ~/.config/nvim/breakpoints.vim
  touch ~/.config/nvim/common.vim
  touch ~/.config/nvim/lazy-lock.json
fi
cp ./config/vscode.vim ~/.config/nvim/vscode.vim
cp ./config/firenvim.vim ~/.config/nvim/firenvim.vim
cp ./config/breakpoints.vim ~/.config/nvim/breakpoints.vim
cp ./config/util.vim ~/.config/nvim/util.vim
cp ./config/common.vim ~/.config/nvim/common.vim
cp ./config/init.lua ~/.config/nvim/init.lua
cp ./config/lazy-lock.json ~/.config/nvim/lazy-lock.json
# sed -i -e 's/"  //g' ./config/init.vim
# cp ./config/init.vim ~/.config/nvim/init.vim
# cp ./config/init.vim-e ./config/init.vim
# rm ./config/init.vim-e

# cp ./config/coc-settings.json ~/.config/nvim/

# Install plug
# cp -rf ./config/autoload ~/.config/nvim/

# Plugin manager
# nvim +'PlugInstall' +qa
# if [ "$1" = "--init" ]; then
#     nvim -S ./config/version-lock.vim +qa
# fi
