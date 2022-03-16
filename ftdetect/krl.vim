" Kuka Robot Language file type detection for Vim
" Language: Kuka Robot Language
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeffrobotics.de>
" Version: 2.0.7
" Last Change: 16. Mar 2022
" Credits:
"
" Suggestions of improvement are very welcome. Please email me!
"

let s:keepcpo = &cpo
set cpo&vim

" patterns used with \v\c
let s:krlHeader        = '\&\w+'
let s:krlDefDefinition = '(global\s+)?def(fct)?\s+[$]?\w+'
let s:krlDatDefinition = 'defdat\s+[$]?\w+'
augroup krlftdetect
  au!  BufNewFile *.src\c,*.sub\c,*.dat\c 
        \  setf krl
  au!  BufRead *.src\c,*.sub\c 
        \  if getline(nextnonblank(1)) =~ '\v\c^\s*(' . s:krlHeader . '|' . s:krlDefDefinition . ')' 
        \|   setf krl 
        \| endif
  au!  BufRead *.dat\c 
        \  if getline(nextnonblank(1)) =~ '\v\c^\s*(' . s:krlHeader . '|' . s:krlDatDefinition . ')' 
        \|   setf krl 
        \| endif
augroup END

let &cpo = s:keepcpo
unlet s:keepcpo

" vim:sw=2 sts=2 et
