" Kuka Robot Language file type detection for Vim
" Language: Kuka Robot Language
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 1.1.3
" Last Change: 28. Nov 2016
" Credits:
"
" Suggestions of improvement are very welcome. Please email me!
"

let s:keepcpo= &cpo
set cpo&vim

au BufNewFile,BufRead *.src,*.Src,*.SRC,*.sub,*.Sub,*.SUB setf krl
" avoid conflict with other file types that are named *.dat
au BufNewFile,BufRead *.dat,*.Dat,*.DAT if getline(nextnonblank(1)) =~ '\v\c^\s*(\&\w+|defdat\s+[$]?\w+)' | setf krl | endif

let &cpo = s:keepcpo
unlet s:keepcpo

" vim:sw=2 sts=2 et
