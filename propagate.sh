#!/bin/bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# tmux
ln -s ${BASEDIR}/tmux/.tmux.conf ~/.tmux.conf
ln -s ${BASEDIR}/tmux/.tmux ~/.tmux

# zsh
ln -s ${BASEDIR}/zsh/.zshrc ~/.zshrc

# oh-my-zsh

brew isntall zsh-autosuggestions
brew install zsh-syntax-highlighting
ln -s ${BASEDIR}/oh-my-zsh/.oh-my-zsh ~/.oh-my-zsh

# git
# ln -s ${BASEDIR}/gitconfig ~/.gitconfig
