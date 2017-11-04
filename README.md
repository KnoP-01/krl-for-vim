# krl-for-vim

## Introduction:

Have a look at [tl:dr][2] to get a very quick overview over the most 
important options provided by KRL for Vim. For more details see the [help][3]
file.

KRL for Vim (7.4 or later) is a collection of Vim scripts to help programing
KUKA industrial robots. 

It provides

* syntax highlighting, 
* auto indention,
* folding (case sensitive), 
* mappings and settings to navigate through code in a backup folder structure
  and 
* mappings to insert a body of a new def(fct?) based on user defined templates
  or hopefully sane defaults. 

Most of this is optional, though some things are default on. Have a look in
the [krl-options][6] section in the help for more details.
Maybe the most confusing thing which is default on is the inclusion of $, #
and & into 'iskeyword'. This makes e.g. $ov\_pro, #initmov and &comment a
"word" for commands like `w`, `e` and the like. This was probably a bad design
decision, but it is as it is now. It's optional (g:krlNoKeyWord) anyway. Maybe 
in the next major release the default will change.

It supports VKRC files. Folding will get optimized for VKRC. Also try the gd
mapping on a fold line with SPSMAKRO, UP or Marker.

Note: Keep your files to be edited below the `KRC/` folder if you plan to edit
lots of files. This folder will be the root for 'path'.
Note to linux users: Keep your files to be edited on a FAT file system. Some
features need the case insensitive file system to work properly.

## Installation:

Extract the most recent [release][1] archive into your `~/.vim/` or
`%USERPROFILE%\vimfiles\` directory (depending on your System) keeping the
folder structure. Overwrite krl.\* files from older installation. 

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

#### ~/.vim/doc/krl.txt
Help file. This should help you to use these plugins to your best advantage.
You may want to look into the [help][3] prior to installation.  
Requires >

    :helptags ~/.vim/doc
  
  
#### ~/.vim/ftdetect/krl.vim
Detects KRL files based on their file name ending .src, .dat and .sub. To not
interfere with other file types, .dat files are checked for the presence of a
DEFDAT line or any &HEADER.  
Requires >

    :filetype on
  
  
#### ~/.vim/ftplugin/krl.vim
Sets various vim options and provides key mappings and folding. It supports
commentary [vimscript #3695][7] and matchit [vimscript #39][8]. All key
mappings are optional.  
Requires >

    :filetype plugin on
  
  
#### ~/.vim/indent/krl.vim
Sets indent related vim options. Sets indention to 2 spaces by default,
optional.  
Requires >

    :filetype indent on
  
  
#### ~/.vim/syntax/krl.vim
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
    " let g:krlNoVerbose=1 " get rid of the messages
    " if you use colorscheme tortus use:
    " let g:krlNoHighLink=1 " even more colors 
    " don't forget
    " filetype plugin indent on

## Self promotion

If you like this plugin please rate it on [vim.org][4]. If you don't but you
think it could be useful if this or that would be different, don't hesitate to
email me or even better open an [issue][5]. With a little luck and good
timing you may find me on irc://irc.freenode.net/#vim as KnoP if you have any
questions.

[1]: https://github.com/KnoP-01/krl-for-vim/releases/latest
[2]: https://github.com/KnoP-01/krl-for-vim#tldr
[3]: https://github.com/KnoP-01/krl-for-vim/blob/master/doc/krl.txt#L154
[6]: https://github.com/KnoP-01/krl-for-vim/blob/master/doc/krl.txt#L174
[4]: https://vim.sourceforge.io/scripts/script.php?script_id=5344
[5]: https://github.com/KnoP-01/krl-for-vim/issues
[7]: https://vim.sourceforge.io/scripts/script.php?script_id=3695
[8]: https://vim.sourceforge.io/scripts/script.php?script_id=39
