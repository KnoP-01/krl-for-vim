#/usr/bin/bash

vim -Nu <(cat << EOF
filetype off
set rtp+=~/.vim/plugged/vader.vim
set rtp+=./../
filetype plugin indent on
syntax on
set noswapfile
set viminfo=
EOF) "+Vader */*.vader"
