" Kuka Robot Language file type detection for Vim
" Language: Kuka Robot Language
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeffrobotics.de>
" Version: 3.0.0
" Last Change: 17. Apr 2022
" Credits:
"

let s:keepcpo = &cpo
set cpo&vim

" patterns used with \v\c
let s:krlHeader        = '\&\w+'
let s:krlDefDefinition = '(global\s+)?def(fct)?\s+'
let s:krlDatDefinition = 'defdat\s+[$]?\w+'

" no augroup! see :h ftdetect
au!  BufNewFile *.src\c,*.sub\c,*.dat\c
      \  setf krl
au!  BufRead *.src\c
      \  if getline(nextnonblank(1)) =~ '\v\c^\s*(' . s:krlHeader . '|' . s:krlDefDefinition . ')' 
      \|   setf krl 
      \| elseif exists("g:filetype_src")
      \|   exe "setf " . g:filetype_src
      \| endif
au!  BufRead *.sub\c
      \  if getline(nextnonblank(1)) =~ '\v\c^\s*(' . s:krlHeader . '|' . s:krlDefDefinition . ')' 
      \|   setf krl 
      \| endif
au!  BufRead *.dat\c
      \  if getline(nextnonblank(1)) =~ '\v\c^\s*(' . s:krlHeader . '|' . s:krlDatDefinition . ')' 
      \|   setf krl 
      \| elseif exists("g:filetype_dat")
      \|   exe "setf " . g:filetype_dat
      \| endif

let &cpo = s:keepcpo
unlet s:keepcpo

" vim:sw=2 sts=2 et
