#!/bin/bash

vim +'PlugUpdate' +qa
nvim +'PlugUpdate' +qa
nvim +'CocUpdateSync' +qa

nvim +'PlugSnapshot config/version-lock.vim' +qa
