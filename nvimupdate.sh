#!/bin/bash

vim +'PlugUpdate' +qa

# Update neovim plug dependencies
rm ~/.config/nvim/init.lua
cp ./config/init.vim ~/.config/nvim/init.vim
nvim +'PlugUpdate' +qa
# Update plug lock file
nvim +'PlugSnapshot! config/version-lock.vim' +qa
# Put the init.lua back and update lazy plugins
rm ~/.config/nvim/init.vim
cp ./config/init.lua ~/.config/nvim/init.lua
nvim --headless "+packupdate" +qa

# Update lazy lock file
cp -f ~/.config/nvim/nvim-pack-lock.json ./config/nvim-pack-lock.json 
