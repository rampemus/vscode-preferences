#!/bin/bash

vim +'PlugUpdate' +qa
nvim +'PlugUpdate' +qa

nvim +'PlugSnapshot config/version-lock.vim' +qa
