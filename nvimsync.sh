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
  mkdir ~/.config/nvim/
  touch ~/.config/nvim/init.lua
  touch ~/.config/nvim/init.vim
  touch ~/Library/Application\ Support/com.mitchellh.ghostty/config

  touch ~/.config/nvim/startup.vim
  touch ~/.config/nvim/vscode.vim
  touch ~/.config/nvim/firenvim.vim
  touch ~/.config/nvim/util.vim
  touch ~/.config/nvim/common.vim
  touch ~/.config/nvim/lazy-lock.json
  mkdir ~/.config/nvim/snippets/
  touch ~/.config/nvim/snippets/package.json
fi
touch ./ghostty.config ~/Library/Application\ Support/com.mitchellh.ghostty/config
cp ./config/startup.vim ~/.config/nvim/startup.vim
cp ./config/vscode.vim ~/.config/nvim/vscode.vim
cp ./config/firenvim.vim ~/.config/nvim/firenvim.vim
cp ./config/util.vim ~/.config/nvim/util.vim
cp ./config/common.vim ~/.config/nvim/common.vim
cp ./config/lazy-lock.json ~/.config/nvim/lazy-lock.json
nvim --headless "+Lazy! restore" +qa

# Install snippets
cp ./snippets/package.json ~/.config/nvim/snippets/package.json
cp ./snippets/htmlsnipu.code-snippets ~/.config/nvim/snippets/htmlsnipu.json
cp ./snippets/javascript.code-snippets ~/.config/nvim/snippets/javascript.json
cp ./snippets/jQuery.code-snippets ~/.config/nvim/snippets/jQuery.json
cp ./snippets/phpsnipu.code-snippets ~/.config/nvim/snippets/phpsnipu.json
cp ./snippets/reactsnipu.code-snippets ~/.config/nvim/snippets/reactsnipu.json
cp ./snippets/typescriptsnipu.code-snippets ~/.config/nvim/snippets/typescriptsnipu.json
cp ./snippets/vuesnipu.code-snippets ~/.config/nvim/snippets/vuesnipu.json

# Install plug dependencies for vscode setup
rm ~/.config/nvim/init.lua
cp ./config/init.vim ~/.config/nvim/init.vim
nvim +'PlugInstall' +qa
if [ "$1" = "--init" ]; then
  nvim -S ./config/version-lock.vim +qa
fi

# Install lazynvim dependencies
rm ~/.config/nvim/init.vim
cp ./config/init.lua ~/.config/nvim/init.lua
