" Kuka Robot Language indent file for Vim
" Language: Kuka Robot Language
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 2.2.2
" Last Change: 03. Jul 2020
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
setlocal indentkeys=!^F,o,O,=~end,0=~else,0=~case,0=~default,0=~until,0=~continue,=~part
let b:undo_indent="setlocal lisp< si< ai< inde< indk<"

if get(g:,'krlSpaceIndent',1)
  " Use spaces for indention, 2 is enough. 
  " More or even tabs wastes space on the teach pendant.
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
    " If current line is ; line comment which is no fold, do not change indent.
    " This may be usefull if code is commented out at the first column.
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

  " Define add a 'shiftwidth' pattern
  let   l:addShiftwidthPattern  = '\c\v^\s*('
  if get(g:,'krlIndentBetweenDef',1)
    let l:addShiftwidthPattern .=           '(global\s+)?def(fct|dat)?\s+\w'
    let l:addShiftwidthPattern .=           '|'
  endif
  let   l:addShiftwidthPattern .=           '(if|while|for|loop)>'
  let   l:addShiftwidthPattern .=           '|else>'
  let   l:addShiftwidthPattern .=           '|(case|default)>'
  let   l:addShiftwidthPattern .=           '|repeat>'
  let   l:addShiftwidthPattern .=           '|(skip|(ptp_)?spline)>'
  let   l:addShiftwidthPattern .=           '|time_block\s+(start|part)>'
  let   l:addShiftwidthPattern .=           '|const_vel\s+start>'
  let   l:addShiftwidthPattern .=         ')'

  " Define Subtract a 'shiftwidth' pattern
  let   l:subtractShiftwidthPattern  = '\c\v^\s*('
  if get(g:,'krlIndentBetweenDef',1)
    let l:subtractShiftwidthPattern .=           'end(fct|dat)?>'
    let l:subtractShiftwidthPattern .=           '|'
  endif
  let   l:subtractShiftwidthPattern .=           'end(if|while|for|loop)>'
  let   l:subtractShiftwidthPattern .=           '|else>'
  let   l:subtractShiftwidthPattern .=           '|(case|default|endswitch)>'
  let   l:subtractShiftwidthPattern .=           '|until>'
  let   l:subtractShiftwidthPattern .=           '|end(skip|spline)>'
  let   l:subtractShiftwidthPattern .=           '|time_block\s+(part|end)>'
  let   l:subtractShiftwidthPattern .=           '|const_vel\s+end>'
  let   l:subtractShiftwidthPattern .=         ')'

  " Add shiftwidth
  if l:preNoneBlankLine =~ l:addShiftwidthPattern
    let l:ind += &sw
  endif

  " Subtract shiftwidth
  if l:currentLine =~ l:subtractShiftwidthPattern
    let l:ind = l:ind - &sw
  endif

  " First case after a switch gets the indent of the switch.
  if l:currentLine =~ '\c\v^\s*case>' && 
        \l:preNoneBlankLine =~ '\c\v^\s*switch>'
    let l:ind = l:ind + &sw
  endif

  " align continue with the following instruction
  if l:currentLine =~ '\c\v^\s*continue>' && 
        \getline(v:lnum + 1) =~ l:subtractShiftwidthPattern
    let l:ind = l:ind - &sw
  endif

  return l:ind
endfunction

function s:KrlPreNoneBlank(lnum)
  " This function handles &headers, ;line comments and CONTINUE instructions
  " like blank lines

  let nPreNoneBlank = prevnonblank(a:lnum)

  while nPreNoneBlank>0 && getline(nPreNoneBlank) =~ '\v\c^\s*(\&\w\+|;|continue>)'
    " Previouse none blank line irrelevant. Look further aback.
    let nPreNoneBlank = prevnonblank(nPreNoneBlank - 1)
  endwhile

  return nPreNoneBlank
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo

" vim:sw=2 sts=2 et
