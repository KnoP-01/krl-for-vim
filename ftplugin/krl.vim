" Kuka Robot Language file type plugin for Vim
" Language: Kuka Robot Language
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 1.0.4
" Last Change: 12. Aug 2017
" Credits: Peter Oddings (KnopUniqueListItems/xolox#misc#list#unique)
"
" Suggestions of improvement are very welcome. Please email me!
"
" ToDo's {{{
" TODO  - make [[, [], ][ and ]] text objects
"       - Clean .dat or highlight unused data in .dat (if .src is present)
"       - make search for enum value declaration possible. Problem: there may be
"         more then one enum that uses this value
"       - find bug foldmethod=Manual. 2. mal die selbe datei oeffnen o.ae.
" }}} ToDo's
" Init {{{

  " echo "1------------foldtest------------"
" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1
  " echo "2------------foldtest------------"

let s:keepcpo = &cpo
set cpo&vim

" compatiblity
if exists("g:krlNoVerbose")
  let g:knopNoVerbose=g:krlNoVerbose
  unlet g:krlNoVerbose
endif
if exists("g:krlRhsQuickfix")
  let g:knopRhsQuickfix = g:krlRhsQuickfix
  unlet g:krlRhsQuickfix
endif
if exists("g:krlLhsQuickfix")
  let g:knopLhsQuickfix = g:krlLhsQuickfix
  unlet g:krlLhsQuickfix
endif

" }}} init
" only declare functions once
if !exists("*s:KnopVerboseEcho()")
  " Little Helper {{{

  if !exists("g:knopNoVerbose") || g:knopNoVerbose!=1
    let g:knopVerboseMsgSet = 1
  endif
  function s:KnopVerboseEcho(msg)
    if !exists("g:knopNoVerbose") || g:knopNoVerbose!=1
      if exists('g:knopVerboseMsgSet')
        unlet g:knopVerboseMsgSet
        echo "\nSwitch verbose messages off with \":let g:knopNoVerbose=1\" any time. You may put this in your .vimrc"
        echo " "
      endif
      echo a:msg
    endif
  endfunction " s:knopNoVerbose()

  function s:KnopSubStartToEnd(search,sub,start,end)
    execute 'silent '. a:start .','. a:end .' s/'. a:search .'/'. a:sub .'/ge'
    call cursor(a:start,0)
  endfunction " s:KnopSubStartToEnd()

  function s:KnopUpperCase(start,end)
    call cursor(a:start,0)
    execute "silent normal! gU" . (a:end - a:start) . "j"
    call cursor(a:start,0)
  endfunction " s:KnopUpperCase()

  " taken from Peter Oddings
  " function! xolox#misc#list#unique(list)
  " xolox/misc/list.vim
  function s:KnopUniqueListItems(list)
    " Remove duplicate values from the given list in-place (preserves order).
    call reverse(a:list)
    call filter(a:list, 'count(a:list, v:val) == 1')
    return reverse(a:list)
  endfunction " s:KnopUniqueListItems()

  function s:KnopPreparePath(path,file)
    let l:path = substitute(a:path,'$',' ','') " make sure that space is the last char
    let l:path = substitute(l:path,',',' ','g') " literal commas in a:path do not work
    let l:path = substitute(l:path, '\*\* ', '**/'.a:file.' ', 'g')
    let l:path = substitute(l:path, '\.\. ', '../'.a:file.' ', 'g')
    let l:path = substitute(l:path, '\. ',    './'.a:file.' ', 'g')
    let l:path = substitute(l:path, '[\\/] ',  '/'.a:file.' ', 'g')
    return l:path
  endfunction " s:KnopPreparePath()

  function s:KnopQfCompatible()
    " check for qf.vim compatiblity
    if exists('g:loaded_qf') && (!exists('g:qf_window_bottom') || g:qf_window_bottom!=0)
          \&& (exists("g:knopRhsQuickfix") && g:knopRhsQuickfix==1 
          \|| exists("g:knopLhsQuickfix") && g:knopLhsQuickfix==1)
      call s:KnopVerboseEcho("NOTE: \nIf you use qf.vim then g:krlRhsQuickfix, g:krlLhsQuickfix, g:rapidRhsQuickfix and g:rapidLhsQuickfix will not work unless g:qf_window_bottom is 0 (Zero). \nTo use g:<foo>[RL]hsQuickfix put this in your .vimrc: \n  let g:qf_window_bottom = 0\n\n")
      return 0
    endif
    return 1
  endfunction " s:KnopQfCompatible()

  let g:knopPositionQf=1
  function s:KnopOpenQf(ft)
    if getqflist()==[] | return -1 | endif
    cwindow 4
    if getbufvar('%', "&buftype")!="quickfix"
      let l:getback=1
      " noautocmd copen
      copen
    endif
    augroup KnopOpenQf
      au!
      " reposition after closing
      let l:cmd = 'au BufWinLeave <buffer='.bufnr('%').'> let g:knopPositionQf=1'
      execute l:cmd
    augroup END
    if a:ft!='' | let &filetype=a:ft | endif
    if exists('g:knopPositionQf') && s:KnopQfCompatible() 
      unlet g:knopPositionQf
      if exists("g:knopRhsQuickfix") && g:knopRhsQuickfix==1
        wincmd L
      elseif exists("g:knopLhsQuickfix") && g:knopLhsQuickfix==1 
        wincmd H
      endif
    endif
    if exists("l:getback")
      unlet l:getback
      wincmd p
    endif
    return 0
  endfunction " s:KnopOpenQf()

  function s:KnopSearchPathForPatternNTimes(Pattern,path,n,ft)
    let l:cmd = ':noautocmd ' . a:n . 'vimgrep /' . a:Pattern . '/j ' . a:path
    try
      execute l:cmd
    catch /^Vim\%((\a\+)\)\=:E303/
      call s:KnopVerboseEcho(":vimgrep stopped with E303. No match found")
      return -1
    catch /^Vim\%((\a\+)\)\=:E480/
      call s:KnopVerboseEcho(":vimgrep stopped with E480. No match found")
      return -1
    catch /^Vim\%((\a\+)\)\=:E683/
      call s:KnopVerboseEcho(":vimgrep stopped with E683. No match found")
      return -1
    endtry
    if s:KnopOpenQf(a:ft)==-1
      call s:KnopVerboseEcho("No match found")
      return -1
    endif
    return 0
  endfunction " s:KnopSearchPathForPatternNTimes()

  function <SID>KnopNTimesSearch(nCount,sSearchPattern,sFlags)
    let l:nCount=a:nCount
    let l:sFlags=a:sFlags
    while l:nCount>0
      if l:nCount < a:nCount
        let l:sFlags=substitute(l:sFlags,'s','','g')
      endif
      call search(a:sSearchPattern,l:sFlags)
      let l:nCount-=1
    endwhile
  endfunction " <SID>KnopNTimesSearch()

  " }}} Little Helper
  " Krl Helper {{{

  function <SID>KrlIsVkrc()
    if bufname("%") =~ '\c\v(folge|up|makro(saw|sps|step|trigger)?)\d*.src'
      for l:s in range(1,8)
        if getline(l:s) =~ '\c\v^\s*\&param\s+tpvw_version\s*.*$'
          return 1
        endif
      endfor
    endif
    return 0
  endfunction " <SID>KrlIsVkrc()

  function s:KrlPathWithGlobalDataLists()
    call setloclist(0,[])
    let l:cmd = ':noautocmd lvimgrep /\c\v^\s*defdat\s+(\w+\s+public|\$\w+)/j ' . s:KnopPreparePath(&path,'*.dat')
    try
      execute l:cmd
    catch /^Vim\%((\a\+)\)\=:E480/
      call s:KnopVerboseEcho(":lvimgrep stopped with E480! No global data lists found in \'path\'.")
      return ' '
    catch /^Vim\%((\a\+)\)\=:E683/
      call s:KnopVerboseEcho(":lvimgrep stopped with E683! No global data lists found in \'path\'.")
      return ' '
    endtry
    let l:locationList = getloclist(0)
    let l:path = ' '
    for l:loc in l:locationList
      let l:path = l:path . fnameescape(bufname(l:loc.bufnr)) . " "
    endfor
    return l:path
  endfunction " s:KrlPathWithGlobalDataLists()

  function s:KrlCurrentWordIs()
    " returns the string "<type><name>" depending on the word under the cursor
    "
    let l:numLine = line(".")
    let l:strLine = getline(".")
    "
    " position the cursor at the start of the current word
    if search('\<','bcsW',l:numLine)
      "
      " init
      let l:numCol = col(".")
      let l:currentChar = strpart(l:strLine, l:numCol-1, 1)
      let l:strUntilCursor = strpart(l:strLine, 0, l:numCol-1)
      let l:lenStrUntilCursor = strlen(l:strUntilCursor)
      "
      " find next char
      if search('\>\s*.',"eW",l:numLine)
        let l:nextChar = strpart(l:strLine, col(".")-1, 1)
      else
        let l:nextChar = ""
      endif
      "
      " set cursor back to start of word
      call cursor(l:numLine,l:numCol)
      "
      " get word at cursor
      let l:word = expand("<cword>")
      "
      " count string chars " before the current char
      let l:i = 0
      let l:countStrChr = 0
      while l:i < l:lenStrUntilCursor
        let l:i = stridx(l:strUntilCursor, "\"", l:i)
        if l:i >= 0
          let l:i = l:i+1
          let l:countStrChr = l:countStrChr+1
        else
          let l:i = l:lenStrUntilCursor+1
        endif
      endwhile
      let l:countStrChr = l:countStrChr%2
      "
      " return something
      if search(';','bcnW',l:numLine)
        return ("comment" . l:word)
        "
      elseif l:countStrChr == 1
        return ("string" . l:word)
        "
      elseif l:currentChar == "$"
        return ("sysvar" . l:word)
        "
      elseif l:currentChar == "&"
        return ("header" . l:word)
        "
      elseif l:currentChar == "#"
        return ("enumval" . l:word)
        "
      elseif l:word =~ '\v\c^(true|false)>'
        return ("bool" . l:word)
        "
      elseif l:currentChar =~ '\d' ||
            \(l:word=~'^[bB][10]\+$' &&
            \   (synIDattr(synID(line("."),col("."),0),"name")=="krlBinaryInt"
            \ || synIDattr(synID(line("."),col("."),0),"name")=="")
            \|| l:word=~'^[hH][0-9a-fA-F]\+$' &&
            \   (synIDattr(synID(line("."),col("."),0),"name")=="krlHexInt"
            \ || synIDattr(synID(line("."),col("."),0),"name")=="")
            \) && l:nextChar == "'"
        return ("num" . l:word)
        "
      elseif l:nextChar == "(" &&
            \(  synIDattr(synID(line("."),col("."),0),"name")=="krlFunction"
            \|| synIDattr(synID(line("."),col("."),0),"name")=="krlBuildInFunction"
            \|| synIDattr(synID(line("."),col("."),0),"name")==""
            \)
        if search('\c\v(<do>|<def>)\s*'.l:word,'bnW',l:numLine) || !search('[^\t ]','bnW',l:numLine)
          if synIDattr(synID(line("."),col("."),0),"name") != "krlBuildInFunction"
            return ("proc" . l:word)
            "
          else
            return ("sysproc" . l:word)
            "
          endif
        else
          if synIDattr(synID(line("."),col("."),0),"name") != "krlBuildInFunction"
            return ("func" . l:word)
            "
          else
            return ("sysfunc" . l:word)
            "
          endif
        endif
      else
        if        synIDattr(synID(line("."),col("."),0),"name") != "krlNames"
              \&& synIDattr(synID(line("."),col("."),0),"name") != "krlSysvars"
              \&& synIDattr(synID(line("."),col("."),0),"name") != "krlStructure"
              \&& synIDattr(synID(line("."),col("."),0),"name") != "krlEnum"
              \&& synIDattr(synID(line("."),col("."),0),"name") != ""
          return ("inst" . l:word)
          "
        else
          return ("var" . l:word)
          "
        endif
      endif
    endif
    return "none"
  endfunction " s:KrlCurrentWordIs()

  " }}} krl Helper
  " Go Definition {{{

  function s:KrlSearchVkrcMarker(currentWord)
    call s:KnopVerboseEcho("Search marker definitions...")
    let l:markerNumber = substitute(a:currentWord,'m','','')
    if (s:KnopSearchPathForPatternNTimes('\v\c^\s*\$cycflag\[\s*'.l:markerNumber.'\s*\]\s*\=',s:KnopPreparePath(&path,'*.src').' '.s:KnopPreparePath(&path,'*.sub'),'','krl') == 0)
      call setqflist(s:KnopUniqueListItems(getqflist()))
      call s:KnopOpenQf('krl')
      return 0
    endif
    return -1
  endfunction

  function s:KrlSearchSysvar(declPrefix,currentWord)
    " a:currentWord starts with '$' so we need '\' at the end of declPrefix pattern
    call s:KnopVerboseEcho("Search global data lists...")
    if (s:KnopSearchPathForPatternNTimes(a:declPrefix.'\'.a:currentWord.">",s:KrlPathWithGlobalDataLists(),'1','krl') == 0)
      call s:KnopVerboseEcho("Found global data list declaration. The quickfix window will open. See :he quickfix-window")
      return 0
    endif
    return -1
  endfunction " s:KrlSearchSysvar()

  function s:KrlSearchVar(declPrefix,currentWord)
    "
    " first search for local declartion
    call s:KnopVerboseEcho("Search def(fct)? local declaration...")
    let l:numLine = line(".")
    let l:numCol = col(".")
    let l:numDefLine = search('\v\c^\s*(global\s+)?<def(fct|dat)?>','bW')
    let l:numEndLine = search('\v\c^\s*<end(fct|dat)?>','nW')
    if search(a:declPrefix.'\zs<'.a:currentWord.">","W",l:numEndLine)
      call s:KnopVerboseEcho("Found def(fct|dat)? local declaration. Get back where you came from with ''")
      return 0
      "
    else
      call s:KnopVerboseEcho("No match found")
      call cursor(l:numLine,l:numCol)
    endif
    "
    " search corrosponding dat file
    call s:KnopVerboseEcho("Search local data list...")
    let l:filename = substitute(fnameescape(bufname("%")),'\c\.src$','.dat','')
    if filereadable(glob(l:filename))
      if (s:KnopSearchPathForPatternNTimes(a:declPrefix.'<'.a:currentWord.">",l:filename,'1','krl') == 0)
        call s:KnopVerboseEcho("Found local data list declaration. The quickfix window will open. See :he quickfix-window")
        return 0
        "
      endif
    else
      call s:KnopVerboseEcho(["File ",l:filename," not readable"])
    endif " search corrosponding dat file
    "
    " third search global data lists
    call s:KnopVerboseEcho("Search global data lists...")
    if (s:KnopSearchPathForPatternNTimes(a:declPrefix.'<'.a:currentWord.">",s:KrlPathWithGlobalDataLists(),'1','krl') == 0)
      call s:KnopVerboseEcho("Found global data list declaration. The quickfix window will open. See :he quickfix-window")
      return 0
      "
    endif
    "
    return -1
  endfunction " s:KrlSearchVar()

  function s:KrlSearchProc(currentWord)
    "
    " first search for local def(fct)? declartion
    call s:KnopVerboseEcho("Search def(fct)? definitions in current file...")
    let l:numLine = line(".")
    let l:numCol = col(".")
    0
    if search('\c\v^\s*(global\s+)?def(fct\s+\w+(\[[0-9,]*\])?)?\s+\zs'.a:currentWord.'>','cw',"$")
      call s:KnopVerboseEcho("Found def(fct)? local declaration. Get back where you came from with ''")
      return 0
      "
    else
      call s:KnopVerboseEcho("No match found")
      call cursor(l:numLine,l:numCol)
    endif
    "
    " second search src file name = a:currentWord
    call s:KnopVerboseEcho("Search .src files in &path...")
    let l:path = s:KnopPreparePath(&path,a:currentWord.'.src').s:KnopPreparePath(&path,a:currentWord.'.sub')
    if !filereadable('./'.a:currentWord.'.src') " suppress message about missing file
      let l:path = substitute(l:path, '\.[\\/]'.a:currentWord.'.src ', ' ','g')
    endif
    if !filereadable('./'.a:currentWord.'.sub') " suppress message about missing file
      let l:path = substitute(l:path, '\.[\\/]'.a:currentWord.'.sub ', ' ','g')
    endif
    if (s:KnopSearchPathForPatternNTimes('\c\v^\s*(global\s+)?def(fct\s+\w+(\[[0-9,]*\])?)?\s+'.a:currentWord.">",l:path,'1','krl') == 0)
      call s:KnopVerboseEcho("Found src file. The quickfix window will open. See :he quickfix-window")
      return 0
      "
    endif
    "
    " third search global def(fct)?
    call s:KnopVerboseEcho("Search global def(fct)? definitions in &path...")
    if (s:KnopSearchPathForPatternNTimes('\c\v^\s*global\s+def(fct\s+\w+(\[[0-9,]*\])?)?\s+'.a:currentWord.">",s:KnopPreparePath(&path,'*.src').s:KnopPreparePath(&path,'*.sub'),'1','krl') == 0)
      call s:KnopVerboseEcho("Found global def(fct)? declaration. The quickfix window will open. See :he quickfix-window")
      return 0
      "
    endif
    "
    return -1
  endfunction " s:KrlSearchProc()

  function <SID>KrlGoDefinition()
    "
    " dont start from within qf or loc window
    if getbufvar('%', "&buftype") == "quickfix" | return | endif
    let l:declPrefix = '\c\v^\s*((global\s+)?(const\s+)?(bool|int|real|char|frame|pos|axis|e6pos|e6axis|signal|channel)\s+[a-zA-Z0-9_,\[\] \t]*|(decl\s+)?(global\s+)?(struc|enum)\s+|decl\s+(global\s+)?(const\s+)?\w+\s+[a-zA-Z0-9_,\[\] \t]*)'
    "
    " suche das naechste wort
    if search('\w','cW',line("."))
      "
      let l:currentWord = s:KrlCurrentWordIs()
      "
      if l:currentWord =~ '^sysvar.*'
        let l:currentWord = substitute(l:currentWord,'^sysvar','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a KSS VARIABLE"])
        return s:KrlSearchSysvar(l:declPrefix,l:currentWord)
        "
      elseif l:currentWord =~ '^var.*'
        let l:currentWord = substitute(l:currentWord,'^var','','')
        let l:currentWord = substitute(l:currentWord,'\(\w\+\)\$','\1\\$','g') " escape embeddend dollars in var name (e.g. TMP_$STOPM)
        call s:KnopVerboseEcho([l:currentWord,"appear to be a user defined VARIABLE"])
        return s:KrlSearchVar(l:declPrefix,l:currentWord)
        "
      elseif l:currentWord =~ '\v^(sys)?(proc|func)'
        let l:type = "DEF"
        if l:currentWord =~ '^sys'
          let l:type = "KSS " . l:type
        endif
        if l:currentWord =~ '^\v(sys)?func'
          let l:type = l:type . "FCT"
        endif
        let l:currentWord = substitute(l:currentWord,'\v^(sys)?(proc|func)','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a ".l:type])
        return s:KrlSearchProc(l:currentWord)
        "
      elseif l:currentWord =~ '^inst.*'
        let l:currentWord = substitute(l:currentWord,'^inst','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a KRL KEYWORD. Maybe a Struc or Enum."])
        return s:KrlSearchVar(l:declPrefix,l:currentWord)
        "
      elseif l:currentWord =~ '^enumval.*'
        " TODO mach das moeglich
        let l:currentWord = substitute(l:currentWord,'^enumval','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be an ENUM VALUE. The search for declarations of enums by their values is not supported (yet?)."])
      elseif l:currentWord =~ '^header.*'
        let l:currentWord = substitute(l:currentWord,'^header','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a HEADER. No search performed."])
      elseif l:currentWord =~ '^num.*'
        let l:currentWord = substitute(l:currentWord,'^num','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a NUMBER. No search performed."])
      elseif l:currentWord =~ '^bool.*'
        let l:currentWord = substitute(l:currentWord,'^bool','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a BOOLEAN VALUE. No search performed."])
      elseif l:currentWord =~ '^string.*'
        let l:currentWord = substitute(l:currentWord,'^string','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a STRING. No search performed."])
      elseif l:currentWord =~ '^comment.*'
        let l:currentWord = substitute(l:currentWord,'^comment','','')
        if <SID>KrlIsVkrc() 
          if (l:currentWord=~'\cup\d\+' || l:currentWord=~'\cspsmakro\d\+' || l:currentWord=~'\cfolge\d\+')
            let l:currentWord = substitute(l:currentWord,'\c^spsmakro','makro','')
            call s:KnopVerboseEcho([l:currentWord,"appear to be a VKRC CALL."])
            return s:KrlSearchProc(l:currentWord)
          elseif l:currentWord =~ '\c\<m\d\+\>'
            call s:KnopVerboseEcho([l:currentWord,"appear to be a VKRC MARKER."])
            return s:KrlSearchVkrcMarker(l:currentWord)
          endif
        endif
        call s:KnopVerboseEcho([l:currentWord,"appear to be a COMMENT. No search performed."])
      else
        let l:currentWord = substitute(l:currentWord,'^none','','')
        call s:KnopVerboseEcho([l:currentWord,"Could not determine typ of current word. No search performed."])
      endif
      return -1
      "
    endif
    "
    call s:KnopVerboseEcho("Nothing found at or after current cursor pos, which could have a declaration. No search performed.")
    return -1
    "
  endfunction " <SID>KrlGoDefinition()

  " }}} Go Definition
  " Auto Form {{{

  function s:KrlGetGlobal(sAction)
    if a:sAction=~'^[lg]'
      let l:sGlobal = a:sAction
    else
      let l:sGlobal = substitute(input("\n[g]lobal or [l]ocal?\n> "),'\W*','','g')
    endif
    if l:sGlobal=~'\c^\s*g'
      return "global "
    elseif l:sGlobal=~'\c^\s*l'
      return "local"
    endif
    return ''
  endfunction " s:KrlGetGlobal()

  function s:KrlGetType(sAction)
    if a:sAction =~ '^.[adf]'
      let l:sType = substitute(a:sAction,'^.\(\w\).','\1','')
    else
      let l:sType = substitute(input("\n[d]ef, def[f]ct or defd[a]t? \n> "),'\W*','','g')
    endif
    if l:sType =~ '\c^\s*d'
      return "def"
    elseif l:sType =~ '\c^\s*f'
      return "deffct"
    elseif l:sType =~ '\c^\s*a'
      return "defdat"
    endif
    return ''
  endfunction " s:KrlGetType()

  function s:KrlGetNameAndOpenFile(suffix)
    let l:sFilename = fnameescape(bufname("%"))
    let l:sName = substitute(input("\nName?\n Type %<enter> to use the current file name,\n or <space><enter> for word under cursor.\n> "),'[^ 0-9a-zA-Z_%]*','','g')
    if l:sName==""
      return ''
      "
    elseif l:sName=~'^%$' " sName from current file name
      let l:sName = substitute(l:sFilename,'\v^.*(<\w+)\.\w\w\w$','\1','')
    elseif l:sName=~'^ $' " sName from current word
      let l:sName = expand("<cword>")
    endif
    let l:sName = substitute(l:sName,'\W*','','g')
    if a:suffix!~substitute(l:sFilename,'^.*\.\(\w\w\w\)$','\1','')
      let l:suffix = substitute(a:suffix,'\\c\\v(src|sub)','src','')
      let l:sFilename = substitute(l:sFilename,'\v^(.*)<\w+\.\w\w\w$','\1'.l:sName.'.'.l:suffix,'')
    endif
    if fnameescape(bufname("%"))!=l:sFilename
      if filereadable(glob(l:sFilename))
        call s:KnopVerboseEcho("\nFile does already exists! Use\n :edit ".l:sFilename)
        return ''
        "
      elseif &mod && !&hid
        call s:KnopVerboseEcho("\nWrite current buffer first!")
        return ''
        "
      endif
      let l:cmd = "edit ".l:sFilename
      execute l:cmd
      set fileformat=dos
      setf krl
    endif
    return l:sName
  endfunction " s:KrlGetNameAndOpenFile()

  function s:KrlGetDataType(sAction)
    if a:sAction=~'..[abcfiprx6]'
      let l:sDataType = substitute(a:sAction,'..\(\w\)','\1','')
    else
      let l:sDataType = substitute(input("\nData type? \n
            \Choose [b]ool, [i]nt, [r]eal, [c]har, [f]rame, [p]os, e[6]pos, [a]xis, e6a[x]is,\n
            \ or enter your desired data type\n> "),'[^ 0-9a-zA-Z_\[\],]*','','g')
    endif
    if l:sDataType=~'\c^b$'
      return "bool"
    elseif l:sDataType=~'\c^i$'
      return "int"
    elseif l:sDataType=~'\c^r$'
      return "real"
    elseif l:sDataType=~'\c^c$'
      return "char"
    elseif l:sDataType=~'\c^f$'
      return "frame"
    elseif l:sDataType=~'\c^p$'
      return "pos"
    elseif l:sDataType=~'\c^6$'
      return "e6pos"
    elseif l:sDataType=~'\c^a$'
      return "axis"
    elseif l:sDataType=~'\c^x$'
      return "e6axis"
    endif
    return substitute(l:sDataType,'[^0-9a-zA-Z_\[\],]*','','g')
  endfunction " s:KrlGetDataType()

  function s:KrlGetReturnVar(sDataType)
    if a:sDataType=~'\c^bool\>'
      return "bResult"
    elseif a:sDataType=~'\c^int\>'
      return "nResult"
    elseif a:sDataType=~'\c^real\>'
      return "rResult"
    elseif a:sDataType=~'\c^char\>'
      return "cResult"
    elseif a:sDataType=~'\c^frame\>'
      return "fResult"
    elseif a:sDataType=~'\c^pos\>'
      return "pResult"
    elseif a:sDataType=~'\c^e6pos\>'
      return "e6pResult"
    elseif a:sDataType=~'\c^axis\>'
      return "aResult"
    elseif a:sDataType=~'\c^e6axis\>'
      return "e6aResult"
    endif
    return substitute(a:sDataType,'^\(..\).*','\l\1','')."Result"
  endfunction " s:KrlGetReturnVar()

  function s:KrlPositionForEdit()
    if !exists("g:krlPositionSet") | let g:krlPositionSet = 0 | endif
    if g:krlPositionSet==1 | return | endif
    let l:startline = getline('.')
    let l:startlinenum = line('.')
    let l:defline = '\c\v^\s*(global\s+)?def(fct|dat)?>'
    let l:enddefline = '\c\v^\s*end(fct|dat)?>'
    let l:emptyline = '^\s*$'
    let l:commentline = '^\s*;'
    let l:headerline = '^\s*&'
    if l:startline=~l:headerline && l:startlinenum!=line('$')
      " start on &header
      while getline('.')=~l:headerline && line('.')!=line('$')
        call s:KnopVerboseEcho("shift down because of &header")
        normal! j
      endwhile
      if line('.')==line('$')
            \&& getline('.')=~l:headerline
        normal! o
        call s:KnopVerboseEcho("started after header")
        "
        let g:krlPositionSet = 1
        return
        "
      elseif getline('.')=~l:emptyline
        if getline(line('.')+1)!=l:emptyline
          normal! O
        endif
        call s:KnopVerboseEcho("started after header")
        "
        let g:krlPositionSet = 1
        return
        "
      endif
      call s:KrlPositionForEdit()
      return
    elseif l:startline=~l:defline
      " start on def
      let l:prevline = getline(line('.')-1)
      while l:prevline=~l:commentline
        normal! k
        let l:prevline = getline(line('.')-1)
      endwhile
      normal! O
      if l:prevline=~l:headerline
        normal! O
      elseif l:prevline!~l:emptyline
        normal! o
      endif
      if getline(line('.')+1)!~l:emptyline
        normal! O
      endif
      call s:KnopVerboseEcho("started before def line")
      "
      let g:krlPositionSet = 1
      return
      "
    elseif l:startline=~l:enddefline
      " start on end
      normal! o
      normal! o
      if getline(line('.')+1)!~l:emptyline
        normal! O
      endif
      call s:KnopVerboseEcho("started after enddef line")
      "
      let g:krlPositionSet = 1
      return
      "
    elseif l:startlinenum==1
      " start on line 1
      if search(l:defline,'cW')
        call s:KnopVerboseEcho("found first def")
        call s:KrlPositionForEdit()
        return
      endif
      if l:startline!~l:emptyline
        normal! O
      endif
      if getline(line('.')+1)!~l:emptyline
        normal! O
      endif
      call s:KnopVerboseEcho("started at line 1")
      "
      let g:krlPositionSet = 1
      return
      "
    elseif l:startlinenum==line('$')
      " start on line $
      let l:prevline = getline(line('.')-1)
      if !(l:startlinenum=~l:emptyline && l:prevline=~l:emptyline)
        normal! o
      endif
      if getline(line('.')-1)!~l:emptyline
        normal! o
      endif
      call s:KnopVerboseEcho("started at line $")
      "
      let g:krlPositionSet = 1
      return
      "
    else
      " start in between
      if search(l:defline,'bcW')
        call search(l:enddefline,'cW')
        call s:KnopVerboseEcho("found enddef line between")
        call s:KrlPositionForEdit()
        return
      elseif search(l:enddefline,'cW')
        call s:KnopVerboseEcho("found enddef line between")
        call s:KrlPositionForEdit()
        return
      else
        " failsafe append to file
        normal! G
        normal! o
        normal! o
        call s:KnopVerboseEcho("failsafe append")
        "
        let g:krlPositionSet = 1
        return
        "
      endif
    endif
  endfunction " s:KrlPositionForEdit()

  function s:KrlPositionForEditWrapper()
    if exists("g:krlPositionSet")
      unlet g:krlPositionSet
    endif
    call s:KrlPositionForEdit()
    unlet g:krlPositionSet
    call s:KnopVerboseEcho("KrlPositionForEdit finished")
  endfunction " s:KrlPositionForEditWrapper()

  function s:KrlPositionForRead()
    call s:KrlPositionForEditWrapper()
    if getline('.')=~'^\s*$'
          \&& line('.')!=line('$')
      delete
    endif
  endfunction " s:KrlPositionForRead()

  function s:KrlReadBody(sBodyFile,sType,sName,sGlobal,sDataType,sReturnVar)
    let l:sBodyFile = glob(fnameescape(g:krlPathToBodyFiles)).a:sBodyFile
    if !filereadable(glob(l:sBodyFile))
      call s:KnopVerboseEcho([l:sBodyFile,": Body file not readable."])
      return
    endif
    " read body
    call s:KrlPositionForRead()
    let l:cmd = "silent .-1read ".glob(l:sBodyFile)
    execute l:cmd
    " set marks
    let l:start = line('.')
    let l:end = search('\v\c^\s*end(fct|dat)?>','cnW')
    " substitute marks in body
    call s:KnopSubStartToEnd('<name>',a:sName,l:start,l:end)
    call s:KnopSubStartToEnd('<type>',a:sType,l:start,l:end)
    call s:KnopSubStartToEnd('<\(global\|public\)>',a:sGlobal,l:start,l:end)
    " set another mark after the def(fct|dat)? line is present
    let l:defstart = search('\v\c^\s*(global\s+)?def(fct|dat)?>','cnW')
    call s:KnopSubStartToEnd('<datatype>',a:sDataType,l:start,l:defstart)
    call s:KnopSubStartToEnd('<returnvar>',a:sReturnVar,l:start,l:defstart)
    " correct array
    let l:sDataType = substitute(a:sDataType,'\[.*','','')
    let l:sReturnVar = a:sReturnVar . "<>" . a:sDataType
    let l:sReturnVar = substitute(l:sReturnVar,'<>\w\+\(\[.*\)\?','\1','')
    call s:KnopSubStartToEnd('<datatype>',l:sDataType,l:defstart+1,l:end)
    call s:KnopSubStartToEnd('<returnvar>',l:sReturnVar,l:defstart+1,l:end)
    call s:KnopSubStartToEnd('\v(^\s*return\s+\w+\[)\d+(,)?\d*(,)?\d*(\])','\1\2\3\4',l:defstart+1,l:end)
    " upper case?
    if exists("g:krlAutoFormUpperCase") && g:krlAutoFormUpperCase==1
      call s:KnopUpperCase(l:defstart,l:end)
    endif
    " indent
    if exists("b:did_indent")
      if l:start>0 && l:end>l:start
        let l:cmd = "silent normal! " . (l:end-l:start+1) . "=="
        execute l:cmd
      endif
    endif
    " position cursor
    call cursor(l:start,0)
    if search('<|>','cW',l:end)
      call setline('.',substitute(getline('.'),'<|>','','g'))
    endif
  endfunction " s:KrlReadBody()

  function s:KrlDefaultDefdatBody(sName,sGlobal)
    call s:KrlPositionForEditWrapper()
    call setline('.',"defdat ".a:sName.a:sGlobal)
    normal! o
    call setline('.',";")
    normal! o
    call setline('.',"enddat")
    call search('\s*defdat ','bW')
    if exists("b:did_indent")
      silent normal! 3==
    endif
    if exists("g:krlAutoFormUpperCase") && g:krlAutoFormUpperCase==1
      call s:KnopUpperCase(line('.'),search('\v\c^\s*enddat>','cnW'))
    endif
    call search(';','W')
    return
  endfunction " s:KrlDefaultDefdatBody()

  function s:KrlDefaultDefBody(sName,sGlobal)
    call s:KrlPositionForEditWrapper()
    call setline('.',a:sGlobal."def ".a:sName.'()')
    normal! o
    call setline('.',";")
    normal! o
    call setline('.',"end ; ".a:sName."()")
    call search('\v\c^\s*(global )?def ','bW')
    if exists("b:did_indent")
      silent normal! 3==
    endif
    if exists("g:krlAutoFormUpperCase") && g:krlAutoFormUpperCase==1
      call s:KnopUpperCase(line('.'),search('\v\c^\s*end>','cnW'))
    endif
    call search(';','W')
  endfunction " s:KrlDefaultDefBody()

  function s:KrlDefaultDeffctBody(sName,sGlobal,sDataType,sReturnVar)
    call s:KrlPositionForEditWrapper()
    call setline('.',a:sGlobal."deffct ".a:sDataType." ".a:sName.'()')
    normal! o
    call setline('.',"decl ".a:sDataType." ".a:sReturnVar)
    let l:sReturnVar = a:sReturnVar
    if getline('.') =~ '\]'
      " correct the decl line in case of array function
      s/\(^\s*\w\+\s\+\w\+\)\(\[[0-9,]\+\]\)\(\s\+\w\+\)/\1\3\2/g
      let l:sReturnVar = substitute(getline('.'),'^\s*\w\+\s\+\w\+\s\+\(\w\+\[[0-9,]\+\]\)','\1','')
      let l:sReturnVar = substitute(l:sReturnVar,'\v(\[)\d*(,)?\d*(,)?\d*(\])','\1\2\3\4','g')
    endif
    normal! o
    call setline('.',";")
    normal! o
    call setline('.',"return ".l:sReturnVar)
    normal! o
    call setline('.',"endfct ; ".a:sName."()")
    call search('\v\c^\s*(global )?deffct ','bW')
    if exists("b:did_indent")
      silent normal! 5==
    endif
    if exists("g:krlAutoFormUpperCase") && g:krlAutoFormUpperCase==1
      call s:KnopUpperCase(line('.'),search('\v\c^\s*endfct>','cnW'))
    endif
    call search(')','cW')
    return
  endfunction " s:KrlDefaultDeffctBody()

  function <SID>KrlAutoForm(sAction)
    " check input
    if a:sAction !~ '^[ lg][ adf][ abcfiprx6]$' | return | endif
    if getbufvar('%', "&buftype") == "quickfix" | return | endif
    "
    let l:sGlobal = s:KrlGetGlobal(a:sAction)
    if l:sGlobal == ''
      return
    else
      let l:sGlobal = substitute(l:sGlobal,'local','','g')
    endif
    "
    let l:sType = s:KrlGetType(a:sAction)
    if l:sType == '' | return | endif
    "
    if l:sType =~ '^defdat\>'
      "
      let l:sName = s:KrlGetNameAndOpenFile('dat')
      if l:sName == '' | return | endif
      let l:sGlobal = substitute(l:sGlobal,'global ',' public','')
      if exists("g:krlPathToBodyFiles") && filereadable(glob(fnameescape(g:krlPathToBodyFiles)).'defdat.dat')
        call s:KnopVerboseEcho("\nbody files will be used")
        call s:KnopVerboseEcho( glob(fnameescape(g:krlPathToBodyFiles)).'defdat.dat' )
        call s:KrlReadBody('defdat.dat',l:sType,l:sName,l:sGlobal,'','')
      else
        if exists("g:krlPathToBodyFiles")
          call s:KnopVerboseEcho(glob(fnameescape(g:krlPathToBodyFiles)).'defdat.dat')
          call s:KnopVerboseEcho(" is not readable!")
        endif
        call s:KnopVerboseEcho("\ndefault body will be used")
        call s:KrlDefaultDefdatBody(l:sName,l:sGlobal)
      endif
      "
    elseif l:sType =~ '^def\>'
      "
      let l:sName = s:KrlGetNameAndOpenFile('\c\v(src|sub)')
      if l:sName == '' | return | endif
      if exists("g:krlPathToBodyFiles") && filereadable(glob(fnameescape(g:krlPathToBodyFiles)).'def.src')
        call s:KnopVerboseEcho("\nbody files will be used")
        call s:KnopVerboseEcho( glob(fnameescape(g:krlPathToBodyFiles)).'def.src' )
        call s:KrlReadBody('def.src',l:sType,l:sName,l:sGlobal,'','')
      else
        if exists("g:krlPathToBodyFiles")
          call s:KnopVerboseEcho(glob(fnameescape(g:krlPathToBodyFiles)).'def.src')
          call s:KnopVerboseEcho(" is not readable!")
        endif
        call s:KnopVerboseEcho("\ndefault body will be used")
        call s:KrlDefaultDefBody(l:sName,l:sGlobal)
      endif
      "
    elseif l:sType =~ '^deffct\>'
      "
      let l:sDataType = s:KrlGetDataType(a:sAction)
      if l:sDataType == '' | return | endif
      let l:sReturnVar = s:KrlGetReturnVar(l:sDataType)
      let l:sName = s:KrlGetNameAndOpenFile('\c\v(src|sub)')
      if l:sName == '' | return | endif
      if exists("g:krlPathToBodyFiles") && filereadable(glob(fnameescape(g:krlPathToBodyFiles)).'deffct.src')
        call s:KnopVerboseEcho("\nbody files will be used")
        call s:KnopVerboseEcho( glob(fnameescape(g:krlPathToBodyFiles)).'deffct.src' )
        call s:KrlReadBody('deffct.src',l:sType,l:sName,l:sGlobal,l:sDataType,l:sReturnVar)
      else
        if exists("g:krlPathToBodyFiles")
          call s:KnopVerboseEcho(glob(fnameescape(g:krlPathToBodyFiles)).'deffct.src')
          call s:KnopVerboseEcho(" is not readable!")
        endif
        call s:KnopVerboseEcho("\ndefault body will be used")
        call s:KrlDefaultDeffctBody(l:sName,l:sGlobal,l:sDataType,l:sReturnVar)
      endif
      "
    else
      return
    endif
    "
    normal! zz
    silent doautocmd User KrlAutoFormPost
    "
  endfunction " <SID>KrlAutoForm()

  " }}} Auto Form
  " List Def/Usage {{{

  function <SID>KrlListDef()
    " dont start from within qf or loc window
    if getbufvar('%', "&buftype")=="quickfix" | return | endif
    " list defs in qf
    if s:KnopSearchPathForPatternNTimes('\v\c^\s*(global\s+)?def(fct)?>','%','','krl')==0
      if getqflist()==[] | return | endif
      " put cursor back after manipulating qf
      if getbufvar('%', "&buftype")!="quickfix"
        let l:getback=1
        noautocmd copen
      endif
      if getbufvar('%', "&buftype")!="quickfix" | return | endif
      setlocal modifiable
      %substitute/\v\c^.*\|\s*((global\s+)?def(fct)?>)/\1/
      0
      if !exists("g:krlTmpFile")
        let g:krlTmpFile=tempname()
        augroup krlDelTmpFile
          au!
          au VimLeavePre * call delete(g:krlTmpFile)
        augroup END
      endif
      execute 'silent save! ' . g:krlTmpFile
      setlocal nomodifiable
      if exists("l:getback")
        unlet l:getback
        wincmd p
      endif
    endif
  endfunction " <SID>KrlListDef()

  function <SID>KrlListUsage()
    " dont start from within qf or loc window
    if getbufvar('%', "&buftype")=="quickfix" | return | endif
    "
    if search('\w','cW',line("."))
      let l:currentWord = s:KrlCurrentWordIs()
      "
      if l:currentWord =~ '^sysvar.*'
        let l:currentWord = substitute(l:currentWord,'^sysvar','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a KSS VARIABLE"])
        let l:currentWord = substitute(l:currentWord,'\$','\\$','g') " escape any dollars in var name
      elseif l:currentWord =~ '^header.*'
        let l:currentWord = substitute(l:currentWord,'^header','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a HEADER."])
        let l:currentWord = substitute(l:currentWord,'&','\\&','g') " escape any & in var name
      elseif l:currentWord =~ '^var.*'
        let l:currentWord = substitute(l:currentWord,'^var','','')
        let l:currentWord = substitute(l:currentWord,'\$','\\$','g') " escape embeddend dollars in var name (e.g. TMP_$STOPM)
        call s:KnopVerboseEcho([l:currentWord,"appear to be a user defined VARIABLE"])
      elseif l:currentWord =~ '\v^(sys)?(proc|func)'
        let l:type = "DEF"
        if l:currentWord =~ '^sys'
          let l:type = "KSS " . l:type
        endif
        if l:currentWord =~ '^\v(sys)?func'
          let l:type = l:type . "FCT"
        endif
        let l:currentWord = substitute(l:currentWord,'\v^(sys)?(proc|func)','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a ".l:type])
      elseif l:currentWord =~ '^enumval.*'
        let l:currentWord = substitute(l:currentWord,'^enumval','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be an ENUM VALUE."])
      elseif l:currentWord =~ '^num.*'
        let l:currentWord = substitute(l:currentWord,'^num','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a NUMBER."])
      elseif l:currentWord =~ '^string.*'
        let l:currentWord = substitute(l:currentWord,'^string','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a STRING."])
      elseif l:currentWord =~ '^comment.*'
        let l:currentWord = substitute(l:currentWord,'^comment','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a COMMENT."])
      elseif l:currentWord =~ '^inst.*'
        let l:currentWord = substitute(l:currentWord,'^inst','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a KRL KEYWORD."])
      elseif l:currentWord =~ '^bool.*'
        let l:currentWord = substitute(l:currentWord,'^bool','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a BOOL VALUE."])
      else
        let l:currentWord = substitute(l:currentWord,'^none','','')
        call s:KnopVerboseEcho([l:currentWord,"Could not determine typ of current word. No search performed!"])
        return
        "
      endif
      let l:keepisk = &isk
      set isk+=#,$,& " this is set globaly here because of <$, <& or <# for vimgrep
      let l:nonecomment = ''
      if !<SID>KrlIsVkrc()
        let l:nonecomment = '^[^;]*'
      endif
      if s:KnopSearchPathForPatternNTimes('\c\v'.l:nonecomment.'<'.l:currentWord.'>',s:KnopPreparePath(&path,'*.src').' '.s:KnopPreparePath(&path,'*.sub').' '.s:KnopPreparePath(&path,'*.dat'),'','krl')==0
        call setqflist(s:KnopUniqueListItems(getqflist()))
        " rule out DECL ENUM
        let l:qftmp1 = []
        for l:i in getqflist()
          if get(l:i,'text') !~ '\v\c^\s*(decl\s+)?enum>'
            call add(l:qftmp1,l:i)
          endif
        endfor
        " rule out if l:currentWord appear after &header
        let l:qftmp2 = []
        for l:i in l:qftmp1
          if get(l:i,'text') !~ '\v\c^\s*\&.*'.l:currentWord
            call add(l:qftmp2,l:i)
          endif
        endfor
        " rule out if l:currentWord is part of a strings
        let l:qfresult = []
        for l:i in l:qftmp2
          if get(l:i,'text') =~ '\v\c^([^"]*"[^"]*"[^"]*)*[^"]*'.l:currentWord
            call add(l:qfresult,l:i)
          endif
        endfor
        call setqflist(l:qfresult)
        call s:KnopOpenQf('krl')
      endif
      let &isk = l:keepisk
    else
      call s:KnopVerboseEcho("Nothing found at or after current cursor pos, which could have a declaration. No search performed.")
    endif
  endfunction " <SID>KrlListUsage()

  " }}} List Def/Usage
  " Format Comments {{{

  " TODO decide: abandon this one?
  if exists("g:krlFormatComments") && g:krlFormatComments==1
    function <SID>KrlFormatComments()
      "
      normal! m'
      0
      let l:numCurrLine = 1
      let l:numLastLine = (line("$") - 1)
      "
      while l:numCurrLine >= 0 && l:numCurrLine <= l:numLastLine
        if getline(l:numCurrLine) =~ '\c\v^\s*;\s*((end)?fold)@!'
          let l:numNextNoneCommentLine = search('\v\c^\s*([^ \t;]|;\s*(end)?fold)',"nW")
          if l:numNextNoneCommentLine == 0
            normal! gqG
          elseif l:numNextNoneCommentLine-l:numCurrLine <= 1
            normal! gqq
          else
            execute "normal!" (l:numNextNoneCommentLine-l:numCurrLine-1)."gqj"
          endif
        endif
        " check next line
        let l:searchnextcomment = search('\c\v^\s*;\s*((end)?fold)@!',"W")
        if l:searchnextcomment == 0
          normal! G
        endif
        let l:numCurrLine = line(".")
        let l:numLastLine = (line("$") - 1)
      endwhile
      "
    endfunction " <SID>KrlFormatComments()
  endif

" }}} Format Comments
endif " !exists("*s:KnopVerboseEcho()")
" Vim Settings {{{

" default on; no option
setlocal commentstring=;%s
setlocal comments=:;
setlocal suffixes+=.dat
setlocal suffixesadd+=.src,.sub,.dat
let b:undo_ftplugin = "setlocal com< cms< su< sua<"

" make enums and sysvars a word including # and $
if !exists("g:krlNoKeyWord") || g:krlNoKeyWord!=1
  setlocal iskeyword+=#,$,&
  let b:undo_ftplugin = b:undo_ftplugin." isk<"
endif

" auto insert comment char when i_<CR>, o or O on a comment line
if exists("g:krlAutoComment") && g:krlAutoComment==1
  setlocal formatoptions+=r
  setlocal formatoptions+=o
  let b:undo_ftplugin = b:undo_ftplugin." fo<"
endif

" format comments
if exists("g:krlFormatComments") && g:krlFormatComments==1
  if &textwidth ==# 0
    " 52 Chars do match on the teach pendant
    setlocal textwidth=52
    let b:undo_ftplugin = b:undo_ftplugin." tw<"
  endif
  setlocal formatoptions-=t
  setlocal formatoptions+=l
  setlocal formatoptions+=j
  if stridx(b:undo_ftplugin, " fo<")==(-1)
    let b:undo_ftplugin = b:undo_ftplugin." fo<"
  endif
endif " format comments

" path for gf, :find etc
if !exists("g:krlNoPath") || g:krlNoPath!=1
  let s:krlpath=&path.'./**,'
  let s:krlpath=substitute(s:krlpath,'\/usr\/include,','','g')
  if finddir('../KRC')!=''
    let s:krlpath.='../KRC/**,'
  elseif finddir('../../KRC')!='' 
    let s:krlpath.='../../KRC/**,' 
  elseif finddir('../../../KRC')!='' 
    let s:krlpath.='../../../KRC/**,' 
  elseif finddir('../../../../KRC')!='' 
    let s:krlpath.='../../../../KRC/**,' 
  elseif finddir('../../../../../KRC')!='' 
    let s:krlpath.='../../../../../KRC/**,' 
  elseif finddir('../../../../../../KRC')!='' 
    let s:krlpath.='../../../../../../KRC/**,' 
  else
    if finddir('../STEU')!=''
      let s:krlpath.='../STEU/**,'
    elseif finddir('../../STEU')!='' 
      let s:krlpath.='../../STEU/**,' 
    elseif finddir('../../../STEU')!='' 
      let s:krlpath.='../../../STEU/**,' 
    elseif finddir('../../../../STEU')!='' 
      let s:krlpath.='../../../../STEU/**,' 
    elseif finddir('../../../../../STEU')!='' 
      let s:krlpath.='../../../../../STEU/**,' 
    endif
    if finddir('../R1')!=''
      let s:krlpath.='../R1/**,'
    elseif finddir('../../R1')!='' 
      let s:krlpath.='../../R1/**,' 
    elseif finddir('../../../R1')!='' 
      let s:krlpath.='../../../R1/**,' 
    elseif finddir('../../../../R1')!='' 
      let s:krlpath.='../../../../R1/**,' 
    elseif finddir('../../../../../R1')!='' 
      let s:krlpath.='../../../../../R1/**,' 
    else
      if finddir('../Program')!=''
        let s:krlpath.='../Program/**,'
      elseif finddir('../../Program')!='' 
        let s:krlpath.='../../Program/**,' 
      elseif finddir('../../../Program')!='' 
        let s:krlpath.='../../../Program/**,' 
      elseif finddir('../../../../Program')!='' 
        let s:krlpath.='../../../../Program/**,' 
      endif
      if finddir('../System')!=''
        let s:krlpath.='../System/**,'
      elseif finddir('../../System')!='' 
        let s:krlpath.='../../System/**,' 
      elseif finddir('../../../System')!='' 
        let s:krlpath.='../../../System/**,' 
      elseif finddir('../../../../System')!='' 
        let s:krlpath.='../../../../System/**,' 
      endif
      if finddir('../Mada')!=''
        let s:krlpath.='../Mada/**,'
      elseif finddir('../../Mada')!='' 
        let s:krlpath.='../../Mada/**,' 
      elseif finddir('../../../Mada')!='' 
        let s:krlpath.='../../../Mada/**,' 
      elseif finddir('../../../../Mada')!='' 
        let s:krlpath.='../../../../Mada/**,' 
      endif
      if finddir('../TP')!=''
        let s:krlpath.='../TP/**,'
      elseif finddir('../../TP')!='' 
        let s:krlpath.='../../TP/**,' 
      elseif finddir('../../../TP')!='' 
        let s:krlpath.='../../../TP/**,' 
      elseif finddir('../../../../TP')!='' 
        let s:krlpath.='../../../../TP/**,' 
      endif
    endif
  endif
  execute "setlocal path=".s:krlpath
  let b:undo_ftplugin = b:undo_ftplugin." pa<"
endif

" folding
if has("folding") && (!exists("g:krlCloseFolds") || g:krlCloseFolds!=2)
  "
  if !exists("*KrlFoldText")
    function! KrlFoldText()
      return substitute(getline(v:foldstart), '\v\c(;\s*<FOLD>\s+|;[^;]*$)', '', 'g')
    endfunction
  endif
  " setting starting behavior
  setlocal foldmethod=marker
  " setlocal foldmethod=syntax
  "
  setlocal foldtext=KrlFoldText()
  if exists("g:krlCloseFolds") && g:krlCloseFolds==1 || <SID>KrlIsVkrc() " close all folds; too sad, this is case sensitive. Default for VKRC
    setlocal foldmarker=FOLD,ENDFOLD
  else " close only PTP|LIN|CIRC movement folds, also case sensitive
    setlocal foldmarker=%CMOVE,ENDFOLD
  endif
  let b:undo_ftplugin = b:undo_ftplugin." fdm< fdt< fmr<"
  "
endif " has("folding") || g:krlCloseFolds!=2

" }}} Vim Settings
" Match It % {{{

" matchit support
if exists("loaded_matchit")
  let b:match_words = '^\s*\<if\>:^\s*\<else\>:^\s*\<endif\>,'
        \.'^\s*\<\(for\|while\|loop\|repeat\)\>:^\s*\<exit\>:^\s*\<\(end\(for\|while\|loop\)\|until\)\>,'
        \.'^\s*\<switch\>:^\s*\<case\>:^\s*\<default\>:^\s*\<endswitch\>,'
        \.'^\s*\(global\s\+\)\?\<def\(fct\)\?\>:^\s*\<resume\>:^\s*\<return\>:^\s*\<end\(fct\)\?\>,'
        \.'^\s*\<defdat\>:^\s*\<enddat\>,'
        \.'^\s*;\s*\<fold\>:^\s*;\s*\<endfold\>'
  let b:match_ignorecase = 1 " KRL does ignore case
endif

" }}} Match It
" Move Around key mappings [[, [], ]] ... {{{

if exists("g:krlMoveAroundKeyMap") && g:krlMoveAroundKeyMap==1
  " Move around functions
  nnoremap <silent><buffer> [[ :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+)?def(fct\|dat)?>', 'bs')<Bar>:unlet b:knopCount<CR>
  vnoremap <silent><buffer> [[ :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+)?def(fct\|dat)?>', 'bsW')<Bar>:unlet b:knopCount<CR>
  nnoremap <silent><buffer> ]] :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+)?def(fct\|dat)?>', 's')<Bar>:unlet b:knopCount<CR>
  vnoremap <silent><buffer> ]] :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+)?def(fct\|dat)?>', 'sW')<Bar>:unlet b:knopCount<CR>
  nnoremap <silent><buffer> [] :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(fct\|dat)?>', 'bse')<Bar>:unlet b:knopCount<CR>
  vnoremap <silent><buffer> [] :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(fct\|dat)?>', 'bseW')<Bar>:unlet b:knopCount<CR>
  nnoremap <silent><buffer> ][ :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(fct\|dat)?>', 'se')<Bar>:unlet b:knopCount<CR>
  vnoremap <silent><buffer> ][ :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(fct\|dat)?>', 'seW')<Bar>:unlet b:knopCount<CR>
  " Move around comments
  nnoremap <silent><buffer> [; :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '^\(\s*;.*\n\)\@<!\(\s*;\)', 'bs')<Bar>:unlet b:knopCount<cr>
  vnoremap <silent><buffer> [; :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '^\(\s*;.*\n\)\@<!\(\s*;\)', 'bsW')<Bar>:unlet b:knopCount<cr>
  nnoremap <silent><buffer> ]; :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '\v^\s*;.*\ze\n\s*([^;\t ]\|$)', 'se')<Bar>:unlet b:knopCount<cr>
  vnoremap <silent><buffer> ]; :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\v^\s*;.*\ze\n\s*([^;\t ]\|$)', 'seW')<Bar>:unlet b:knopCount<cr>
endif

" }}} Move Around
" Other configurable key mappings {{{

if exists("g:krlGoDefinitionKeyMap") && g:krlGoDefinitionKeyMap==1
  " gd mimic
  nnoremap <silent><buffer> gd :call <SID>KrlGoDefinition()<CR>
endif
if exists("g:krlListDefKeyMap") && g:krlListDefKeyMap==1
  " list all DEFs of current file
  nnoremap <silent><buffer> <leader>f :call <SID>KrlListDef()<CR>
endif
if exists("g:krlListUsageKeyMap") && g:krlListUsageKeyMap==1
  " list all uses of word under cursor
  nnoremap <silent><buffer> <leader>u :call <SID>KrlListUsage()<CR>
endif

if exists("g:krlAutoFormKeyMap") && g:krlAutoFormKeyMap==1
  nnoremap <silent><buffer> <leader>n     :call <SID>KrlAutoForm("   ")<cr>
  nnoremap <silent><buffer> <leader>nn    :call <SID>KrlAutoForm("   ")<cr>
  "
  nnoremap <silent><buffer> <leader>nl    :call <SID>KrlAutoForm("l  ")<cr>
  nnoremap <silent><buffer> <leader>nll   :call <SID>KrlAutoForm("l  ")<cr>
  "
  nnoremap <silent><buffer> <leader>nla   :call <SID>KrlAutoForm("la ")<cr>
  nnoremap <silent><buffer> <leader>nld   :call <SID>KrlAutoForm("ld ")<cr>
  nnoremap <silent><buffer> <leader>nlf   :call <SID>KrlAutoForm("lf ")<cr>
  nnoremap <silent><buffer> <leader>nlfu  :call <SID>KrlAutoForm("lf ")<cr>
  "
  nnoremap <silent><buffer> <leader>nlfa  :call <SID>KrlAutoForm("lfa")<cr>
  nnoremap <silent><buffer> <leader>nlfb  :call <SID>KrlAutoForm("lfb")<cr>
  nnoremap <silent><buffer> <leader>nlfc  :call <SID>KrlAutoForm("lfc")<cr>
  nnoremap <silent><buffer> <leader>nlff  :call <SID>KrlAutoForm("lff")<cr>
  nnoremap <silent><buffer> <leader>nlfi  :call <SID>KrlAutoForm("lfi")<cr>
  nnoremap <silent><buffer> <leader>nlfp  :call <SID>KrlAutoForm("lfp")<cr>
  nnoremap <silent><buffer> <leader>nlfr  :call <SID>KrlAutoForm("lfr")<cr>
  nnoremap <silent><buffer> <leader>nlfx  :call <SID>KrlAutoForm("lfx")<cr>
  nnoremap <silent><buffer> <leader>nlf6  :call <SID>KrlAutoForm("lf6")<cr>
  "
  nnoremap <silent><buffer> <leader>na    :call <SID>KrlAutoForm("la ")<cr>
  nnoremap <silent><buffer> <leader>nd    :call <SID>KrlAutoForm("ld ")<cr>
  nnoremap <silent><buffer> <leader>nf    :call <SID>KrlAutoForm("lf ")<cr>
  nnoremap <silent><buffer> <leader>nfu   :call <SID>KrlAutoForm("lf ")<cr>
  "
  nnoremap <silent><buffer> <leader>nfa   :call <SID>KrlAutoForm("lfa")<cr>
  nnoremap <silent><buffer> <leader>nfb   :call <SID>KrlAutoForm("lfb")<cr>
  nnoremap <silent><buffer> <leader>nfc   :call <SID>KrlAutoForm("lfc")<cr>
  nnoremap <silent><buffer> <leader>nff   :call <SID>KrlAutoForm("lff")<cr>
  nnoremap <silent><buffer> <leader>nfi   :call <SID>KrlAutoForm("lfi")<cr>
  nnoremap <silent><buffer> <leader>nfp   :call <SID>KrlAutoForm("lfp")<cr>
  nnoremap <silent><buffer> <leader>nfr   :call <SID>KrlAutoForm("lfr")<cr>
  nnoremap <silent><buffer> <leader>nfx   :call <SID>KrlAutoForm("lfx")<cr>
  nnoremap <silent><buffer> <leader>nf6   :call <SID>KrlAutoForm("lf6")<cr>
  "
  nnoremap <silent><buffer> <leader>ng    :call <SID>KrlAutoForm("g  ")<cr>
  nnoremap <silent><buffer> <leader>ngg   :call <SID>KrlAutoForm("g  ")<cr>
  "
  nnoremap <silent><buffer> <leader>nga   :call <SID>KrlAutoForm("ga ")<cr>
  nnoremap <silent><buffer> <leader>ngd   :call <SID>KrlAutoForm("gd ")<cr>
  nnoremap <silent><buffer> <leader>ngf   :call <SID>KrlAutoForm("gf ")<cr>
  nnoremap <silent><buffer> <leader>ngfu  :call <SID>KrlAutoForm("gf ")<cr>
  "
  nnoremap <silent><buffer> <leader>ngfa  :call <SID>KrlAutoForm("gfa")<cr>
  nnoremap <silent><buffer> <leader>ngfb  :call <SID>KrlAutoForm("gfb")<cr>
  nnoremap <silent><buffer> <leader>ngfc  :call <SID>KrlAutoForm("gfc")<cr>
  nnoremap <silent><buffer> <leader>ngff  :call <SID>KrlAutoForm("gff")<cr>
  nnoremap <silent><buffer> <leader>ngfi  :call <SID>KrlAutoForm("gfi")<cr>
  nnoremap <silent><buffer> <leader>ngfp  :call <SID>KrlAutoForm("gfp")<cr>
  nnoremap <silent><buffer> <leader>ngfr  :call <SID>KrlAutoForm("gfr")<cr>
  nnoremap <silent><buffer> <leader>ngfx  :call <SID>KrlAutoForm("gfx")<cr>
  nnoremap <silent><buffer> <leader>ngf6  :call <SID>KrlAutoForm("gf6")<cr>
endif " g:krlAutoFormKeyMap

if has("folding") && (!exists("g:krlCloseFolds") || g:krlCloseFolds!=2)
  " compatiblity
  if exists("g:krlFoldKeyMap") && g:krlFoldKeyMap==1
    if <SID>KrlIsVkrc() " closing move folds fails in VKRC files
      nnoremap <silent><buffer> <F3> :setlocal foldlevel=0<CR>
    else " closing all folds (well, case sensitiv)
      nnoremap <silent><buffer> <F3> :setlocal foldmarker=FOLD,ENDFOLD<CR>
    endif
    if <SID>KrlIsVkrc() " closing move folds fails in VKRC files
      nnoremap <silent><buffer> <F2> :setlocal foldlevel=1<CR>
    else " closing only move folds
      nnoremap <silent><buffer> <F2> :setlocal foldmarker=%CMOVE,ENDFOLD<CR>
    endif
  endif
endif

" }}} Configurable mappings
" <PLUG> mappings {{{

" gd mimic
nnoremap <silent><buffer> <plug>KrlGoDef :call <SID>KrlGoDefinition()<CR>

" list all DEFs of current file
nnoremap <silent><buffer> <plug>KrlListDef :call <SID>KrlListDef()<CR>

" list usage
nnoremap <silent><buffer> <plug>KrlListUse :call <SID>KrlListUsage()<cr>

" format comments
nnoremap <silent><buffer> <plug>KrlFormatComments :call <SID>KrlFormatComments()<CR>

" auto form
nnoremap <silent><buffer> <plug>KrlAutoForm                 :call <SID>KrlAutoForm("   ")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalDat         :call <SID>KrlAutoForm("la ")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalDef         :call <SID>KrlAutoForm("ld ")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalFct         :call <SID>KrlAutoForm("lf ")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalFctBool     :call <SID>KrlAutoForm("lfb")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalFctInt      :call <SID>KrlAutoForm("lfi")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalFctReal     :call <SID>KrlAutoForm("lfr")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalFctChar     :call <SID>KrlAutoForm("lfc")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalFctFrame    :call <SID>KrlAutoForm("lff")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalFctPos      :call <SID>KrlAutoForm("lfp")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalFctE6Pos    :call <SID>KrlAutoForm("lf6")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalFctAxis     :call <SID>KrlAutoForm("lfa")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormLocalFctE6Axis   :call <SID>KrlAutoForm("lfx")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalDat        :call <SID>KrlAutoForm("ga ")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalDef        :call <SID>KrlAutoForm("gd ")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalFct        :call <SID>KrlAutoForm("gf ")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalFctBool    :call <SID>KrlAutoForm("gfb")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalFctInt     :call <SID>KrlAutoForm("gfi")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalFctReal    :call <SID>KrlAutoForm("gfr")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalFctChar    :call <SID>KrlAutoForm("gfc")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalFctFrame   :call <SID>KrlAutoForm("gff")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalFctPos     :call <SID>KrlAutoForm("gfp")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalFctE6Pos   :call <SID>KrlAutoForm("gf6")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalFctAxis    :call <SID>KrlAutoForm("gfa")<cr>
nnoremap <silent><buffer> <plug>KrlAutoFormGlobalFctE6Axis  :call <SID>KrlAutoForm("gfx")<cr>
" auto form end

" folding
if has("folding") && (!exists("g:krlCloseFolds") || g:krlCloseFolds!=2)
  nnoremap <silent><buffer> <plug>KrlCloseAllFolds :setlocal foldmarker=FOLD,ENDFOLD foldlevel=0<CR>
  nnoremap <silent><buffer> <plug>KrlCloseLessFolds :if <SID>KrlIsVkrc()<CR>setlocal foldmarker=FOLD,ENDFOLD foldlevel=1<CR>else<CR>setlocal foldmarker=%CMOVE,ENDFOLD foldlevel=0<CR>endif<CR>
  nnoremap <silent><buffer> <plug>KrlCloseNoFolds :setlocal foldmarker={{{,}}}<CR>
endif

" }}} <plug> mappings
" Finish {{{

let &cpo = s:keepcpo
unlet s:keepcpo

" }}} Finish
" vim:sw=2 sts=2 et fdm=marker
