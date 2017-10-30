" Kuka Robot Language syntax file for Vim
" Language: Kuka Robot Language
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 1.5.1
" Last Change: 12. Aug 2017
" Credits: Thanks for contributions to this to Michael Jagusch
"
" Suggestions of improvement are very welcome. Please email me!
"
"

" Remove any old syntax stuff that was loaded (5.x) or quit when a syntax file
" was already loaded (6.x).
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

let s:keepcpo= &cpo
set cpo&vim

" krl does ignore case
syn case ignore

" Comment
" TODO Comment
syn keyword krlTodo contained TODO FIXME XXX
highlight link krlTodo Todo
" Debug Comment
syn keyword krlDebug contained DEBUG
highlight link krlDebug Debug
" Line Comment
syn match krlComment /;.*$/ contains=krlTodo,krlDebug
highlight link krlComment Comment
" ---

" Header
syn match krlHeader /&\a\w*/
highlight link krlHeader PreProc
" ---

" Operator
" Boolean operator
syn keyword krlBoolOperator AND OR EXOR NOT DIV MOD B_AND B_OR B_EXOR
highlight link krlBoolOperator Operator
" Arithmetic operator
syn match krlArithOperator /[+-]/ containedin=krlFloat
syn match krlArithOperator /\*\|\//
highlight link krlArithOperator Operator
" Compare operator
syn match krlCompOperator /[<>=]/
highlight link krlCompOperator Operator
" Geometric operator
" Do not move the : operator
" Must be present befor krlParamdef
syn match krlGeomOperator /[:]/ " containedin=krlLabel,krlParamdef
highlight link krlGeomOperator Operator
" ---

" Type
" any type (preceded by 'decl')
syn match krlAnyType /\v((decl\s+|struc\s+|enum\s+)|(global\s+)|(const\s+)|(deffct\s+))+\w+>/ contains=krlStorageClass,krlType
highlight link krlAnyType Type
" Simple data types
syn match krlType /\v<(BOOL|CHAR|REAL|INT)>/ containedin=krlAnyType
" External program and function
syn match krlType /\v<(EXT|EXTFCT)>/ containedin=krlAnyType
" Communication
syn match krlType /\v<(SIGNAL|CHANNEL)>/ containedin=krlAnyType
" Struc and Enum
" syn keyword krlType STRUC ENUM
highlight link krlType Type
" StorageClass
syn match krlStorageClass /\v<(decl|struc|enum)>/ contained
syn match krlStorageClass /\v<global>/ contained
syn match krlStorageClass /\v<const>/ contained
highlight link krlStorageClass StorageClass
" .dat file public
syn keyword krlDatStorageClass public
highlight link krlDatStorageClass StorageClass
" Parameter StorageClass
" Do not move the :in/:out
" Must be present after krlGeomOperator
" This will generate false highlight if a frame is called "in" or "out"
" I tried, but don't know what to do about this
syn match krlParamdef /[:]\s*in\>/
syn match krlParamdef /[:]\s*out\>/
highlight link krlParamdef StorageClass
" Not a typedef but I like to have those highlighted
" different then types, structures or strorage classes
syn keyword krlTypedef DEF END DEFFCT ENDFCT DEFDAT ENDDAT
highlight link krlTypedef Typedef
" highlight link krlTypedef PreProc
" ---

" Delimiter
syn match krlDelimiter /\\\||\|\[\|\]\|[()]\|[,]/
highlight link krlDelimiter Delimiter
" ---

" Constant values
" Boolean
syn keyword krlBoolean TRUE FALSE containedin=krlStructVal
highlight link krlBoolean Boolean
" Integer
syn match krlInteger /\W[+-]\?\d\+/lc=1 containedin=krlStructVal
highlight link krlInteger Number
" Binary integer
syn match krlBinaryInt /'b[01]\+'/ containedin=krlStructVal
highlight link krlBinaryInt Number
" Hexadecimal integer
syn match krlHexInt /'h[0-9a-fA-F]\+'/ containedin=krlStructVal
highlight link krlHexInt Number
" Float
syn match krlFloat /\W[+-]\?\d\+\.\?\d*\([eE][+-]\?\d\+\)\?/lc=1 containedin=krlStructVal
highlight link krlFloat Float
" String
syn region krlString start=/"/ end=/"/ containedin=krlStructVal
highlight link krlString String
" Enum
syn match krlEnumVal /#\s*\a\w*/ containedin=krlStructVal
highlight link krlEnumVal Constant
" ---

" Structure
" Predefined structures and enums found in
" /r1/mada/$*.dat, /r1/steu/$*.dat and
" /r1/system/$config.dat as well as
" basisTech, gripperTech and spotTech
"
" Predefined structures for movement
syn keyword krlStructure FRAME E6POS POS E6AXIS AXIS
syn keyword krlStructure FDAT LDAT PDAT
syn keyword krlStructure LOAD INERTIA
"
" Predefined structures for shapes
syn keyword krlStructure AXBOX CYLINDER BOX
"
" Predefined structures and enums found in /r1/mada/$machine.dat
syn keyword krlStructure CP FRA ACC_CAR JERK_STRUC DHART SPIN TRPSPIN EX_KIN ET_AX MAXTOOL
syn keyword krlEnum INDIVIDUAL_MAMES SUPPLY_VOLTAGE KINCLASS MAIN_AXIS WRIST_AXIS SW_ONOFF
"
" Predefined structures and enums found in /r1/mada/$robcor.dat
" syn keyword krlStructure
syn keyword krlEnum ADAP_ACC MODEL_TYPE CONTROL_PARAMETER EKO_MODE
"
" Predefined structures and enums found in /steu/mada/$custom.dat
syn keyword krlStructure PRO_IO_T SER EXT_MOD_T COOP_KRC WS_CONFIG BIN_TYPE COOP_UPDATE_T LDC_REACTION
syn keyword krlEnum AXIS_OF_COORDINATES SPLINE_PARA_VARIANT TARGET_STATUS CP_VEL_TYPE CP_STATMON
"
" Predefined structures and enums found in /steu/mada/$machine.dat
syn keyword krlStructure EMSTOP_PATH BOXSTATESAFEIN BOXSTATESAFEOUT
syn keyword krlEnum DIGINCODE
"
" Predefined structures and enums found in /steu/mada/$option.dat
syn keyword krlStructure MSG_T
" syn keyword krlEnum
"
" Predefined structures and enums found in /r1/system/$config.dat
" BasisTech
syn keyword krlStructure DIG_OUT_TYPE CTRL_IN_T CTRL_OUT_T FCT_OUT_T FCT_IN_T ODAT BASIS_SUGG_T OUT_SUGG_T MD_STATE MACHINE_DEF_T MACHINE_TOOL_T MACHINE_FRAME_T TRIGGER_PARA CONSTVEL_PARA CONDSTOP_PARA ADAT TM_SUGG_T TQM_TQDAT_T SPS_PROG_TYPE
syn keyword krlEnum BAS_COMMAND OUT_MODETYPE IPO_M_T APO_MODE_T FUNCT_TYPE P00_COMMAND
"
" GripperTech
syn keyword krlStructure GRP_TYP GRP_TYPES GRP_SUGG_T
syn keyword krlEnum ON_OFF_TYP APO_TYP
"
" SpotTech
syn keyword krlStructure SPOT_TYPE SPOT_SUGG_T
syn keyword krlEnum S_COMMAND S_PAIR_SLCT
"
" VW
syn keyword krlStructure VW_MPARA_TYP ZANGENTYP ZANGENBEDINGUNG IBSZANGENTYP LAST_IBS_TYP VERR_TYP VERRCHECK_T T_FB_STATE Kollisionsdaten State_T MODUS_T
syn keyword krlEnum SYNCTYPE DIR_TYP SUBTYPE ARI_TYP BOOL_TYP VW_COMMAND IBGN_COMMAND VW_USER_CMD MOVE_TYPES ADV_T_TYPE BAS_TYPE IBS_MODE_TYP VW_USER_CMD PRO_MODE MODE_OP
"
" ProgCoop
syn keyword krlStructure YDAT
" syn keyword krlEnum
"
" bas.src
syn keyword krlStructure CONT
syn keyword krlEnum ESYS IPO_MODE CIRC_MODE CIRC_TYPE ORI_TYPE VAR_STATE
"
" MsgLib.src
syn keyword krlStructure KrlMsg_T KrlMsgParType_T KrlMsgPar_T KrlMsgOpt_T KrlMsgDlgSK_T
syn keyword krlEnum EKrlMsgType
"
highlight link krlStructure Structure
highlight link krlEnum Structure
" ---

" System variable
syn match krlSysvars /\$\a[a-zA-Z0-9_.]*/
highlight link krlSysvars Sysvars
" ---

" continue
syn keyword krlContinue CONTINUE
if exists("g:krlNoHighlight") && g:krlNoHighlight==1
      \|| exists("g:krlNoHighLink") && g:krlNoHighLink==1
  highlight link krlContinue Continue
else
  highlight link krlContinue Statement
endif
" Statement
" syn match krlStatement /\v^\s*(<global>\s+)?<INTERRUPT>(\s+<decl>)?/ contains=krlStorageClass
syn match krlStatement /\v(<global>\s+)?<INTERRUPT>(\s+<decl>)?/ contains=krlStorageClass
syn keyword krlStatement WAIT SEC ON OFF ENABLE DISABLE TRIGGER WHEN DISTANCE PATH DELAY DO PRIO IMPORT IS MINIMUM MAXIMUM CONFIRM ON_ERROR_PROCEED
highlight link krlStatement Statement
" Conditional
syn keyword krlConditional IF THEN ELSE ENDIF SWITCH CASE DEFAULT ENDSWITCH
highlight link krlConditional Conditional
" Repeat
syn keyword krlRepeat FOR TO STEP ENDFOR WHILE ENDWHILE REPEAT UNTIL LOOP ENDLOOP EXIT
highlight link krlRepeat Repeat
" Label
syn keyword krlLabel GOTO
" syn match krlLabel /^\s*\w\+:/
syn match krlLabel /^\s*\w\+:\ze\s*\(;.*\)\?$/
highlight link krlLabel Label
" Keyword
syn keyword krlKeyword ANIN ANOUT DIGIN
highlight link krlKeyword Keyword
" Exception
syn keyword krlException RETURN RESUME HALT
highlight link krlException Exception
" ---

" special keywords for movement commands
syn keyword krlMovement PTP LIN CIRC SPL SLIN SCIRC ASYPTP PTP_REL LIN_REL CIRC_REL
syn keyword krlMovement ASYCANCEL BRAKE BRAKE_F
if exists("g:krlNoHighlight") && g:krlNoHighlight==1
      \|| exists("g:krlNoHighLink") && g:krlNoHighLink==1
  highlight link krlMovement Movement
else
  highlight link krlMovement Special
endif
" movement modifiers
syn keyword krlMoveMod CA C_PTP C_DIS C_VEL C_ORI SPLINE ENDSPLINE
if exists("g:krlNoHighlight") && g:krlNoHighlight==1
      \|| exists("g:krlNoHighLink") && g:krlNoHighLink==1
  highlight link krlMoveMod Movement
else
  highlight link krlMoveMod Special
endif
" ---

" avoid coloring structure component names
" if they have the same name as a type
" syn match krlNames /[a-zA-Z_][.a-zA-Z0-9_]*/ containedin=krlStructVal
syn match krlNames contained /[a-zA-Z_][.a-zA-Z0-9_]*/
highlight link krlNames None
" Structure value
syn region krlStructVal start=/{/ end=/}/ containedin=krlStructVal contains=krlNames
highlight link krlStructVal krlDelimiter
" ---

" BuildInFunction
syn keyword krlBuildInFunction contained abs sin cos acos tan atan atan2 sqrt
syn keyword krlBuildInFunction contained b_not " maybe this one should move to Operator?! It's used like a function: b_not(bool)
syn keyword krlBuildInFunction contained cClose cOpen cRead cWrite sRead sWrite
syn keyword krlBuildInFunction contained forward inverse inv_pos
syn keyword krlBuildInFunction contained get_sig_inf GetSysState pulse
syn keyword krlBuildInFunction contained StrAdd StrClear StrCopy StrComp StrFind StrLen StrDeclLen StrToBool StrToInt StrToReal StrToString
syn keyword krlBuildInFunction contained Clear_KrlMsg Set_KrlDlg Exists_KrlDlg Set_KrlMsg Exists_KrlMsg
syn keyword krlBuildInFunction contained Err_Clear Err_Raise
syn keyword krlBuildInFunction contained varstate EK EB LK sync MD_CMD MD_SETSTATE MBX_REC
if exists("g:krlNoHighlight") && g:krlNoHighlight==1
      \|| exists("g:krlNoHighLink") && g:krlNoHighLink==1
  highlight link krlBuildInFunction BuildInFunction
else
  highlight link krlBuildInFunction Function
endif
" ---

" Function
syn match krlFunction /[a-zA-Z_]\w* *(/me=e-1 contains=krlBuildInFunction
highlight link krlFunction Function
" ---

" Error
if exists("g:krlShowError") && g:krlShowError==1
  " some more or less common typos
  "
  syn match krlError /\v^\s*\zs(elseif>|esle>|endfi>|ednif>|ednwhile>|ednfor>|endfro>|ednloop>)/
  "
  " for bla==5 to 7...
  "        ||
  syn match krlError /\v(^\s*for(\(|\s)+\$?\w+(\[|\]|\.|\+|\-|\*|\/|\w)*\s*)@<=[:=]\=/
  "
  " wait for a=b
  "           |
  syn match krlError /\v(^\s*(return|wait\s+for|if|while|until|(global\s+)?interrupt\s+decl)[^;]+[^;<>=])@<=\=[^=]/
  "
  " wait for a><b
  "           ||
  syn match krlError /\v(^\s*(return|wait\s+for|if|while|until|(global\s+)?interrupt\s+decl)[^;]+)@<=\>\s*\</
  "
  " if (a==5) (b==6) ...
  "         |||
  syn match krlError /\v(^\s*(return|wait\s+for|if|while|until|(global\s+)?interrupt\s+decl)[^;]+[^;])@<=\)\s*\(/
  "
  " a == b + 1
  " a := b + 1
  "   ||
  " syn match krlError /\v^\s*\$?\w+(\w|\[|\]|\+|\-|\*|\/)*\s*\zs[:=]\=/
  syn match krlError /\v(^\s*\$?\w+(\w|\[|\]|\+|\-|\*|\/|\.)*\s*)@<=[:=]\=/
  "
  " this one is tricky. Make sure this does not match trigger instructions
  " a = b and c or (int1=int2)
  "                     |
  " syn match krlError /\v(^\s*\$?[^=;]+\s*\=[^=;][^;]+[^;<>=])@<=\=[^=]/
  " syn match krlError /\v^\s*(trigger\swhen\s)@<!(\$?[^=;]+\s*\=[^=;][^;]+[^;<>=])@<=\=[^=]/
  "
  highlight link krlError Error
endif
" ---

let &cpo = s:keepcpo
unlet s:keepcpo

let b:current_syntax = "krl"

" vim:sw=2 sts=2 et

