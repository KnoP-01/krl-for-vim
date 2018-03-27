" Kuka Robot Language file type detection for Vim
" Language: Kuka Robot Language
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 2.0.0
" Last Change: 13. Dec 2017
" Credits:
"
" Suggestions of improvement are very welcome. Please email me!
"

let s:keepcpo= &cpo
set cpo&vim

augroup krlftdetect
  au!  BufNewFile *.src,*.Src,*.SRC,*.sub,*.Sub,*.SUB,*.dat,*.Dat,*.DAT setf krl
  au!  BufRead *.src,*.Src,*.SRC,*.sub,*.Sub,*.SUB if getline(nextnonblank(1)) =~ '\v\c^\s*(\&\w+|(global\s+)?def(fct)?\s+[$]?\w+)' | set filetype=krl | endif
  au!  BufRead *.dat,*.Dat,*.DAT if getline(nextnonblank(1)) =~ '\v\c^\s*(\&\w+|defdat\s+[$]?\w+)' | set filetype=krl | endif
augroup END

let &cpo = s:keepcpo
unlet s:keepcpo

" vim:sw=2 sts=2 et
