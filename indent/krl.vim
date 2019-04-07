" Kuka Robot Language indent file for Vim
" Language: Kuka Robot Language
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 2.0.0
" Last Change: 07. Apr 2019
" Credits: Based on indent/vim.vim
"
" Suggestions of improvement are very welcome. Please email me!
"
" Known bugs: See ../doc/krl.txt
"

if exists("g:krlNoSpaceIndent")
  if !exists("g:krlSpaceIndent")
    let g:krlSpaceIndent = !g:krlNoSpaceIndent
  endif
  unlet g:krlNoSpaceIndent
endif

" Only load this indent file when no other was loaded.
if exists("b:did_indent") || get(g:,'krlNoIndent',0)
  finish
endif
let b:did_indent = 1

setlocal nolisp
setlocal nosmartindent
setlocal autoindent
setlocal indentexpr=GetKrlIndent()
setlocal indentkeys=!^F,o,O,0=~end,0=~else,0=~case,0=~default,0=~until,0=~continue
let b:undo_indent="setlocal lisp< si< ai< inde< indk<"

if get(g:,'krlSpaceIndent',1)
  " use spaces for indention, 2 is enough, more or even tabs are looking awful
  " on the teach pendant
  setlocal softtabstop=2
  setlocal shiftwidth=2
  setlocal expandtab
  setlocal shiftround
  let b:undo_indent = b:undo_indent." sts< sw< et< sr<"
endif

" Only define the function once.
if exists("*GetKrlIndent")
  finish
endif

let s:keepcpo= &cpo
set cpo&vim

function GetKrlIndent()
  let ignorecase_save = &ignorecase
  try
    let &ignorecase = 0
    return s:GetKrlIndentIntern()
  finally
    let &ignorecase = ignorecase_save
  endtry
endfunction

function s:GetKrlIndentIntern()
  let l:currentLine = getline(v:lnum)
  if  l:currentLine =~ '\c\v^;(\s*(end)?fold>)@!' && !get(g:,'krlCommentIndent',0)
    " if first char is ; line comment, do not change indent
    " this may be usefull if code is commented out at the first column
    return 0
  endif
  " Find a non-blank line above the current line.
  let l:preNoneBlankLineNum = s:KrlPreNoneBlank(v:lnum - 1)
  if  l:preNoneBlankLineNum == 0
    " At the start of the file use zero indent.
    return 0
  endif
  let l:preNoneBlankLine = getline(l:preNoneBlankLineNum)
  let l:ind = indent(l:preNoneBlankLineNum)

  " Add a 'shiftwidth' 
  let l:i = match(l:preNoneBlankLine, '\c\v^\s*
        \(
          \(global\s+)?def
          \(\s+\w
          \|fct\s+\w
          \|dat\s+\w
          \)
        \|if\W+
        \|spline>
        \|else\s*(;.*)?$
        \|case\W+
        \|default\s*(;.*)?$
        \|for\W+
        \|while\W+
        \|repeat\s*(;.*)?$
        \|loop\s*(;.*)?$
        \)'
      \)
  if l:i >= 0
    let l:ind += &sw
  endif

  " Subtract a 'shiftwidth'
  if l:currentLine =~ '\c\v^\s*
        \(end(|fct|dat|if|spline|switch|for|while|loop)\s*(;.*)?$
        \|else\s*(;.*)?$
        \|case>
        \|default\s*(;.*)?$
        \|until>
        \)'
    let l:ind = l:ind - &sw
  endif

  " first case after a switch
  if l:currentLine =~ '\c\v^\s*case>' && l:preNoneBlankLine =~ '\c\v^\s*switch>'
    let l:ind = l:ind + &sw
  endif

  " keep continue-instructions the same indention like the following
  " instruction if its end*, else, case, default or until
  if getline(v:lnum) =~ '\c\v^\s*continue>' && getline(v:lnum + 1) =~ '\c\v^\s*
        \(end(|fct|dat|if|switch|for|while|loop)\s*(;.*)?$
        \|else\s*(;.*)?$
        \|case>
        \|default\s*(;.*)?$
        \|until>
        \)'
    let l:ind = l:ind - &sw
  endif

  return l:ind
endfunction

function s:KrlPreNoneBlank(lnum)
  " this function handles &foo-headers, comments and continue-instructions like blank lines
  let nPreNoneBlank = prevnonblank(a:lnum)
  " At the start of the file use zero indent.
  if nPreNoneBlank == 0
    return 0
  endif

  let l:i=1
  while l:i>=1 && nPreNoneBlank>=0
    if getline(nPreNoneBlank) =~ '\v\c^\s*
          \(\&\w\+.*$
          \|(;.*)?$
          \|continue\s*(;.*)?$
          \)'
      let nPreNoneBlank = prevnonblank(nPreNoneBlank - 1)
      " At the start of the file use zero indent.
      if nPreNoneBlank == 0
        return 0
      endif
    else
      let l:i=0
    endif
  endwhile

  return nPreNoneBlank
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo

" vim:sw=2 sts=2 et
