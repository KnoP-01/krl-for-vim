# krl-for-vim

## Introduction:

Have a look at [tl:dr][2] to get a quick overview over the most important
options provided by KRL for Vim. For more details see the [help][3] file.

KRL for Vim (7.4 or later) is a collection of Vim scripts to help programing
KUKA industrial robots. 

It provides
* syntax highlighting,
* auto indention,
* folding,
* mappings and settings to navigate through code in a backup folder structure,
* Text objects for functions and folds and
* mappings to insert a body of a new DEF, DEFFCT or DEFDAT based on user 
  defined templates or hopefully sane defaults.

Since version 2.0.0 most features are enabled by default, so you don't need
that many options in your .vimrc. Existing mappings don't get overridden,
unless the corrosponding option is explicitly set. There are <plug>-mappings
available too, if you prefere different key bindings.

KRL for Vim supports viewing and analysing VKRC files. Folding will get
optimized for VKRC and you can use your Go Definition mapping (default gd) on
a SPSMAKRO, UP, bin, binin or Marker in a fold line. However, this is NOT a
VKRC-Editor.

**Note:** Keep your files to be edited in one folder or in a regular robot
backup folder structure. KRL for Vim modifies 'path' accordingly. Since
version 2.0.0 KRC1 backups are supported too.
**Note to linux users:** Keep your files to be edited on a FAT file system. 
Some features need the case insensitive file system to work properly.


## Installation:

Extract the most recent [release][1] and copy the folders 
`/doc`, `/ftdetect`, `/ftplugin`, `/indent` and `/syntax` 
into your `~/.vim/` or `%USERPROFILE%\vimfiles\` directory. 
Overwrite krl.\* files from older installation. 

To use these plugins put >
    filetype plugin indent on
    syntax on
in your .vimrc.

You may have to run >
    :helptags ~/.vim/doc/
or >
    :helptags ~/vimfiles/doc/
to use the help within Vim after installation. >
    :help krl


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
Detects KRL files based on their file name and content. KRL files are checked
for the presence of a DEF line or any &HEADER.
Requires >  

    :filetype on
  
  
#### ~/.vim/ftplugin/krl.vim
Sets various vim options and provides key mappings and folding. It supports
commentary [vimscript #3695][7] and matchit [vimscript #39][8].
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

Q: Since version 2.0.0 everything's weird. How so?  
A: Most optional features are enabled by default now.

Q: I'm here to feed my kids, not to read. How do I get rid of stuff?  
A: Disable stuff in your `vimrc`, see [krl-options][6] for details: >

    let g:krlAutoComment = 0 " don't continue comments with o, O or Enter
    let g:krlFormatComments = 0 " don't break comment lines automatically
    let g:krlSpaceIndent = 0 " don't change 'sts', 'sw', 'et' and 'sr'
    let g:krlKeyWord = 0 " don't treat $, # and & as word char
    let g:krlShortenQFPath = 0 " don't shorten paths in quickfix

Q: Which keys get mapped to what?  
A: If there is no existing mapping which would be overridden and no <plug>
    mapping is configured for that function then the following keys get
    mapped: >

    <F2> Switch folding off
    <F3> Close movement folds.
    <F4> Close all folds.
            Depend on g:krlFoldLevel not existing or >=1.
            Can be forced with
        let g:krlFoldingKeyMap = 1

    gd Go to or show definition of variable or def/deffct.
            Can be forced with
        let g:krlGoDefinitionKeyMap = 1

    <leader>u List all appearances of word under cursor outside a comment,
            string or enum declaration.
            Can be forced with
        let g:krlListUsageKeyMap = 1

    <leader>f List all def/deffct in the current file.
            Can be forced with
        let g:krlListDefKeyMap = 1

    [[ Move around functions. Takes a count.
    ]] Move around functions. Takes a count.
    [] Move around functions. Takes a count.
    ][ Move around functions. Takes a count.
    [; Move around comments. Takes a count.
    ]; Move around comments. Takes a count.
            Will override existing mappings!
            Can be forced off with
        let g:krlMoveAroundKeyMap = 0

    if Inner function text object.
    af Around function text object.
    aF Around function text object including preceding comments and one
        following empty line.
            Depend on g:krlMoveAroundKeyMap not existing or =1.
            Can be forced with
        let g:krlFunctionTextObject = 1

    io Inner fold text object. Takes a count for nested folds.
    ao Around fold text object. Takes a count for nested folds.
            Depend on matchit.
            Can be forced with 
        let g:krlFoldTextObject = 1

    <leader>n Inserts a new def/deffct.
            Can be forced with
        let g:krlAutoFormKeyMap = 1

Q: Does krl-for-vim provide a mapping for indenting a complete file?  
A: No, but you may put the following in your .vimrc: >
    nnoremap ANYKEY gg=G``zz

Q: Scrolling feels sluggish. What can I do?  
A: Switch error highlighting off and/or folding to marker: >

    let g:krlFoldMethodSyntax = 0 " better performance, but case sensitive
    let g:krlShowError = 0        " better performance

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
If you need assistance with your robot project [visit us][9].

[1]: https://github.com/KnoP-01/krl-for-vim/releases/latest
[2]: https://github.com/KnoP-01/krl-for-vim#tldr
[3]: https://github.com/KnoP-01/krl-for-vim/blob/master/doc/krl.txt#L197
[4]: https://www.vim.org/scripts/script.php?script_id=5344
[5]: https://github.com/KnoP-01/krl-for-vim/issues
[6]: https://github.com/KnoP-01/krl-for-vim/blob/master/doc/krl.txt#L218
[7]: https://www.vim.org/scripts/script.php?script_id=3695
[8]: https://www.vim.org/scripts/script.php?script_id=39
[9]: http://www.graeff.de
