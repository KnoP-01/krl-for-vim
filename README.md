# krl-for-vim

## Introduction:

Have a look at the bottom of this readme to get a very quick overview over the
most important options provided by KRL for Vim. For more details see the help
file.

KRL for Vim is a collection of Vim scripts to help programing KUKA industrial
robots. 

It provides 
* syntax highlighting, 
* auto indention,
* folding (case sensitive), 
* mappings and settings to navigate through code in a backup folder structure and 
* mappings to insert a body of a new def(fct?) based on user defined samples or
  hopefully sane defaults. 

Most of this is optional, though some things are default on. Have a look in the
help files krl-options section for more details.

It supports VKRC files. Folding will get optimized for VKRC. Also try the
'gd'-mapping on a fold line with SPSMAKRO, UP or Marker.

## Installation:

Extract the released archive into your `~/.vim/` or `%USERPROFILE%\vimfiles\`
directory (depending on your System) keeping the folder structure. Overwrite
krl.vim and krl.txt files from older installation. 

To fully use these scripts put >  
    filetype plugin indent on
    syntax on
in your .vimrc

You may have to run >  
    :helptags ~/.vim/doc/
or >  
    :helptags ~/vimfiles/doc/
to use the help within Vim after installation. >  
    :help krl

Or just open the file .../doc/krl.txt

## Content description

    ~/.vim/doc/krl.txt
    ~/.vim/ftdetect/krl.vim
    ~/.vim/ftplugin/krl.vim
    ~/.vim/indent/krl.vim
    ~/.vim/syntax/krl.vim

You may use all these independently from one another. Just don't mix versions
of different releases. Some features may work better when all files are loaded.

`~/.vim/doc/krl.txt`
Help file. This should help you to use these plugins to your best
advantage. You may want to look into this file prior to installation.  
Requires >  
    :helptags ~/.vim/doc

`~/.vim/ftdetect/krl.vim`
Detects KRL files based on their file name ending .src, .dat and .sub. To not
interfere with other file types, .dat files are checked for the presence of a
DEFDAT line or a &HEADER.  
Requires >  
    :filetype on

`~/.vim/ftplugin/krl.vim`
Sets various vim options and provide key mappings and folding. It supports
commentary (vimscript #3695) and matchit (vimscript #39). All key mappings are
optional.  
Requires >  
    :filetype plugin on

`~/.vim/indent/krl.vim`
Sets indent related vim options. Sets indention to 2 spaces by default,
optional.  
Requires >  
    :filetype indent on

`~/.vim/syntax/krl.vim`
Does make life more colorful. Unfortunately some features of the other files
may work better with syntax on. This should not stop you from trying syntax
off if you like.  
Requires >  
    :syntax on

## tl:dr
Q: Why so many options?  
A: I try not to interfere with user settings to much. So I made most of the
   settings that get changed optional.

Q: I'm here to feed my kids, not to read. Do you have a quick suggestion on
   krl settings for my |.vimrc|?  
A: Yes: >  
    let g:krlMoveAroundKeyMap=1 " [[, ]], [] and ][ jumps around DEF/DEFFCT..
    let g:krlGoDefinitionKeyMap=1 " gd shows the declaration of curr. word
    let g:krlListDefKeyMap=1 " <leader>f shows all DEF/DEFFCT.. in curr. file
    let g:krlListUsageKeyMap=1 " <leader>u shows all appearance of curr. word
    let g:krlAutoFormKeyMap=1 " <leader>n inserts a body for a new DEF etc
    let g:krlShowError=1 " shows some syntax errors
    let g:krlRhsQuickfix=1 " open quickfix window on the right hand side
    let g:qf_window_bottom=0 " if qf.vim exists and you use g:krlRhsQuickfix
    " if you want all folds to close (case sensitiv)...
    let g:krlCloseFolds=1 " switch folding to all
    " or else if you don't like any closed folds use:
    " let g:krlCloseFolds=2 " switch folding off
    " if you use colorscheme tortus use:
    " let g:krlNoHighLink=1 " even more colors 
    " let g:krlNoVerbose=1 " get rid of the messages
    " don't forget
    " filetype plugin indent on

