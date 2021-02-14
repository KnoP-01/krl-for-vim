```
                                             _           _______
                                            /.\\        /  ___  \_________  _
         _   __   ___      _                \_/ \       | /   \     ____  \/ |   _____   
        | | /  | |   \    | |                 \  \      | | O |  _________/\_|  /  | o\  
        | |/  /  |  _ |   | |                  \--\     | \___/ /             _/  _/  /  
        |    /   | | ||   | |                  | o |     \      \       /\   /.\ / | |   
        |    \   | |_| \  | |___               /--/       \  \\  \      \/\  \_//  | |   
        |  _  \  |  __  | |     |             /  /         \  \\  \      \ \      /  |   
        |_| \__\ |_|  \_| |_____|           _/  /           \   _  \      \-\     |  o\_ 
                                           / \ /            |  /.\  |     |o|     /_____\
                 for Vim                  | o |_      _____/   \_/  |     /-/     |     |
               by Knosowski                \_/__|__  |____   ______/     / /      |_____|
                                           |___ ___\ |    \_____   |    /  |
                                            |  \__ |  \___________/     | o \__
                                            |______|  |           |     \______\
        industrial robot programming                  |           |      |     |
                                                      |___________|      |_____|
```
# krl-for-vim

**READ [FAQ][2] FIRST** if you want more than just syntax highlight and 
automatic indenting. It is a quick overview over the most important options 
and mappings provided by KRL for Vim. For more details see the [help][3] file.

## Introduction:

KRL for [Vim][10] (7.4 or later) is a collection of Vim scripts to help
programming [KUKA industrial robots][9].

It provides
* syntax highlighting,
* indenting,
* folding,
* support for commentary [vimscript #3695][7], matchit [vimscript #39][8], 
    matchup [vimscript #5624][11] and endwise [vimscript #2386][12],
* mappings and settings to navigate through code in a backup folder structure,
* text objects for functions, comments and folds,
* optimized folding and concealing for viewing VRKC,
* completion of words from known or custom global files like $config.dat,
* mappings to insert a body of a new DEF, DEFFCT or DEFDAT based on user 
    defined templates or hopefully sane defaults.

**Note:** Keep your files to edit in one folder or in a regular robot
backup folder structure. KRL for Vim modifies 'path' accordingly.  
Since version 2.0.0 KRC1 backups are supported too.  
**Note to Linux users:** Keep your files to edit on a FAT file system. 
Some features need the case insensitive file system to work properly.


## Installation:

### Installation with [vim-plug][14]:  ~  

Put this in your .vimrc:  >

    call plug#begin('~/.vim/plugged')
      Plug 'KnoP-01/krl-for-vim'
    call plug#end()
    syntax off                 " undo what plug#begin() did to syntax
    filetype plugin indent off " undo what plug#begin() did to filetype
    syntax on                  " syntax and filetype on in that order
    filetype plugin indent on  " syntax and filetype on in that order

For the first installation run: >

    :PlugInstall

Update every once in a while with: >

    :PlugUpdate

### Manual installation:  ~  

Extract the most recent [release][1] and copy the folders 
`/doc`, `/ftdetect`, `/ftplugin`, `/indent` and `/syntax` 
into your `~/.vim/` or `%USERPROFILE%\vimfiles\` directory. 
Overwrite krl.\* files from older installation.

Put the following in your .vimrc: >

    syntax on                  " syntax and filetype on in that order
    filetype plugin indent on  " syntax and filetype on in that order

You may have to run >

    :helptags ~/.vim/doc/

or >

    :helptags ~/vimfiles/doc/

to use the help within Vim after installation. >

    :help krl


## FAQ

Q: How do I disable an annoying feature of krl-for-vim?  
A: Disable feature in your `vimrc`, see [krl-options][6] for details: >

    let g:krlShortenQFPath    = 0 " don't shorten paths in quickfix
    let g:krlAutoComment      = 0 " don't continue comments with o, O or Enter
    let g:krlFormatComments   = 0 " don't break comment lines automatically
    let g:krlCommentIndent    = 1 " indent comments starting in 1st column too
    let g:krlIndentBetweenDef = 0 " don't indent between DEF(fct|dat)?
    let g:krlSpaceIndent      = 0 " don't change 'sts', 'sw', 'et' and 'sr'
    "let g:krlFoldLevel       = 0 " close no folds on startup
    "let g:krlFoldLevel       = 1 " close movement folds on startup (default)
    let g:krlFoldLevel        = 2 " close all folds on startup
    let g:krlKeyWord          = 0 " don't treat $, # and & as word char

Q: Which keys get mapped to what? Will that override my own mappings?  
A: krl-for-vim will not override existing mappings unless the corresponding
   option is explicitly set. To use different key bindings see :help 
   [krl-key-mappings][13] for <Plug> mappings.  
   Otherwise krl-for-vim create the following mappings: >

    <F2> Open all folds
    <F3> Open none movement folds
    <F4> Close all folds
            Override existing mapping with
        let g:krlFoldingKeyMap = 1

    gd Go to or show definition of variable or def/deffct.
            Does work on fold lines for SPSMAKRO, UP, bin, binin and Marker.
            Does override Vim's default. Make Vim's default available with 
        nnoremap gd gd
            Override existing mapping with
        let g:krlGoDefinitionKeyMap = 1

    <leader>u List all significant references of word under cursor.
            Override existing mapping with
        let g:krlListUsageKeyMap = 1

    <leader>f List all def/deffct of the current file.
            Override existing mapping with
        let g:krlListDefKeyMap = 1

    [[ Move around functions. Takes a count.
    ]] Move around functions. Takes a count.
    [] Move around functions. Takes a count.
    ][ Move around functions. Takes a count.
    [; Move around comments. Takes a count.
    ]; Move around comments. Takes a count.
            Does override existing mappings and Vim's default.
            Disable override existing mappings and Vim's default with
        let g:krlMoveAroundKeyMap = 0

    if Inner function text object.
    af Around function text object.
    aF Around function text object including preceding comments.
            Depends on g:krlMoveAroundKeyMap not existing or =1.
            Override existing mapping with
        let g:krlFunctionTextObject = 1

    io Inner fold text object. Takes a count for nested folds.
    ao Around fold text object. Takes a count for nested folds.
            Depends on matchit/matchup.
            Override existing mapping with
        let g:krlFoldTextObject = 1

    ic Inner comment text object.
    ac Around comment text object.
            Depends on g:krlMoveAroundKeyMap not existing or =1.
            Override existing mapping with
        let g:krlCommentTextObject = 1

    <leader>n Inserts a new def/deffct.
            Override existing mapping with
        let g:krlAutoFormKeyMap = 1

Q: Does krl-for-vim provide a mapping for indenting the whole file?  
A: No, but you may put the following in your .vimrc or
   `~/.vim/after/ftplugin/krl.vim`: >

    nnoremap ANYKEY gg=G``zz

Q: Does krl-for-vim provide a mapping to quickly switch between the
   corresponding dat- and src-file?  
A: No, but you may put the following in your .vimrc or
   `~/.vim/after/ftplugin/krl.vim`: >

    nnoremap ANYKEY :if expand('%')=~'\.dat$' <bar> e %:s?\.dat$?.src? <bar> else <bar> e %:s?\.src$?.dat? <bar> endif<CR>

Q: I did set g:krlFoldLevel=1 or 2 but folds are open after loading a .src
   file?!   
A: Unfortunately the order matters: >

    syntax on                   " before filetype plugin on
    filetype plugin indent on   " after syntax on

Q: Folds are still open although I have syntax on and filetype on in the right
   order?!  
A: Some plugin manager mess with those commands, so with vim-plug I had to
   redo this after plug#end(): >

    call plug#end()
    syntax off                  " undo what plug#begin() did to syntax
    filetype plugin indent off  " undo what plugin#begin() did to filetype
    syntax on                   " before filetype plugin on
    filetype plugin indent on   " after syntax on

Q: Scrolling feels sluggish. What can I do?  
A: Switch error highlighting off and/or folding to marker: >

    let g:krlFoldMethodSyntax = 0 " better performance, but case sensitive
    let g:krlShowError        = 0 " better performance

Q: Still sluggish!  
A: Switch syntax off or jump instead of scroll!  

Q: Where are the nice and informative messages?  
A: `:let g:knopVerbose=1` any time.  

## Self promotion

If you like this plugin please rate it on [vim.org][4]. If you don't but you
think it could be useful if this or that would be different, don't hesitate to
email me or even better open an [issue][5]. With a little luck and good
timing you may find me on irc://irc.freenode.net/#vim as KnoP in case you have
any questions.  

[1]: https://github.com/KnoP-01/krl-for-vim/releases/latest
[2]: https://github.com/KnoP-01/krl-for-vim#FAQ
[3]: https://github.com/KnoP-01/krl-for-vim/blob/master/doc/krl.txt#L212
[4]: https://www.vim.org/scripts/script.php?script_id=5344
[5]: https://github.com/KnoP-01/krl-for-vim/issues
[6]: https://github.com/KnoP-01/krl-for-vim/blob/master/doc/krl.txt#L230
[7]: https://github.com/tpope/vim-commentary
[8]: https://www.vim.org/scripts/script.php?script_id=39
[9]: https://www.kuka.com/en-de/products/robot-systems/industrial-robots
[10]: https://www.vim.org/
[11]: https://github.com/andymass/vim-matchup
[12]: https://github.com/tpope/vim-endwise
[13]: https://github.com/KnoP-01/krl-for-vim/blob/master/doc/krl.txt#L242
[14]: https://github.com/junegunn/vim-plug
