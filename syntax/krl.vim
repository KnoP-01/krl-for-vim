" Kuka Robot Language syntax file for Vim
" Language: Kuka Robot Language
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 1.5.7
" Last Change: 22. Feb 2018
" Credits: Thanks for contributions to this to Michael Jagusch
"
" Suggestions of improvement are very welcome. Please email me!
"
"

" Init {{{
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

" if !exists("*<SID>KrlIsVkrc()")
"   function <SID>KrlIsVkrc()
"     if bufname("%") =~ '\c\v(folge|up|makro(saw|sps|step|trigger)?)\d*.src'
"       for l:s in range(1,8)
"         if getline(l:s) =~ '\c\v^\s*\&param\s+tpvw_version\s*.*$'
"           return 1
"         endif
"       endfor
"     endif
"     return 0
"   endfunction " <SID>KrlIsVkrc()
" endif

" }}} init

" Comment and Folding {{{ 
"
" Special Comment
" TODO Comment
syn keyword krlTodo contained TODO FIXME XXX
highlight default link krlTodo Todo
" Debug Comment
syn keyword krlDebug contained DEBUG
highlight default link krlDebug Debug
" Line Comment
syn match krlComment /;.*$/ contains=krlTodo,krlDebug
highlight default link krlComment Comment
" }}} Comment and Folding 

" Header {{{
syn match krlHeader /&\a\w*/
highlight default link krlHeader PreProc
" }}} Header

" Operator {{{
" Boolean operator
syn keyword krlBoolOperator AND OR EXOR NOT DIV MOD B_AND B_OR B_EXOR
highlight default link krlBoolOperator Operator
" Arithmetic operator
syn match krlArithOperator /[+-]/ containedin=krlFloat
syn match krlArithOperator /[*/]/
highlight default link krlArithOperator Operator
" Compare operator
syn match krlCompOperator /[<>=]/
highlight default link krlCompOperator Operator
" Geometric operator
" Do not move the : operator
" Must be present befor krlParamdef
syn match krlGeomOperator /[:]/ " containedin=krlLabel,krlParamdef
highlight default link krlGeomOperator Operator
" }}} Operator

" Type, StorageClass and Typedef {{{
" any type (preceded by 'decl')
" TODO optimize performance
syn match krlAnyType /\v%(%(decl\s+|struc\s+|enum\s+)|%(global\s+)|%(const\s+)|%(deffct\s+))+\w+>/ contains=krlStorageClass,krlType,krlTypedef
highlight default link krlAnyType Type
" Simple data types
syn keyword krlType BOOL CHAR REAL INT containedin=krlAnyType
" External program and function
syn keyword krlType EXT EXTFCT containedin=krlAnyType
" Communication
syn keyword krlType SIGNAL CHANNEL containedin=krlAnyType
highlight default link krlType Type
" StorageClass
syn keyword krlStorageClass decl global const struc enum contained
highlight default link krlStorageClass StorageClass
" .dat file public
syn keyword krlDatStorageClass public
highlight default link krlDatStorageClass StorageClass
" Parameter StorageClass
" Do not move the :in/:out
" Must be present after krlGeomOperator
syn match krlParamdef /[:]\s*in\>/
syn match krlParamdef /[:]\s*out\>/
highlight default link krlParamdef StorageClass
" Not a typedef but I like to have those highlighted
" different then types, structures or strorage classes
syn keyword krlTypedef DEF END DEFFCT ENDFCT DEFDAT ENDDAT
highlight default link krlTypedef Typedef
" }}} Type, StorageClass and Typedef

" Delimiter {{{
syn match krlDelimiter /[\\|\[\](),]/
highlight default link krlDelimiter Delimiter
" }}} Delimiter

" Constant values {{{
" Boolean
syn keyword krlBoolean TRUE FALSE containedin=krlStructVal
highlight default link krlBoolean Boolean
" Integer
syn match krlInteger /\W[+-]\?\d\+/lc=1 containedin=krlStructVal
highlight default link krlInteger Number
" Binary integer
syn match krlBinaryInt /'b[01]\+'/ containedin=krlStructVal
highlight default link krlBinaryInt Number
" Hexadecimal integer
syn match krlHexInt /'h[0-9a-fA-F]\+'/ containedin=krlStructVal
highlight default link krlHexInt Number
" Float
syn match krlFloat /\W[+-]\?\d\+\.\?\d*\%([eE][+-]\?\d\+\)\?/lc=1 containedin=krlStructVal
highlight default link krlFloat Float
" String
syn region krlString start=/"/ end=/"/ oneline containedin=krlStructVal
highlight default link krlString String
" String within a fold line " NOT USED may be used in krlComment for none move folds
syn region krlSingleQuoteString start=/'/ end=/'/ oneline contained
highlight default link krlSingleQuoteString String
" Enum
syn match krlEnumVal /#\s*\a\w*/ containedin=krlStructVal
highlight default link krlEnumVal Constant
" }}} Constant values

" Predefined Structure and Enum {{{
" Predefined structures and enums found in
" /r1/mada/$*.dat, /r1/steu/$*.dat and
" /r1/system/$config.dat as well as
" basisTech, gripperTech and spotTech
"
" Predefined data types found in kss functions
syn keyword krlEnum EDIAGSTATE RDC_FS_STATE RET_C_PSYNC_E VAR_TYPE CANCEL_PSYNC_E SYS_VARS 
syn keyword krlStructure SIGINF RW_RDC_FILE RW_MAM_FILE DIAGPAR_T ERROR_T STOPMESS CASE_SENSE_T MSGBUF_T E3POS E3AXIS DIAGOPT_T 
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
highlight default link krlStructure Structure
highlight default link krlEnum Structure
" }}} Predefined Structure and Enum

" System variable {{{
syn match krlSysvars /\<\$\a[a-zA-Z0-9_.]*/
highlight default link krlSysvars Sysvars
" }}} System variable

" Statements, keywords et al {{{
" continue
syn keyword krlContinue CONTINUE
if exists("g:krlNoHighlight") && g:krlNoHighlight==1
      \|| exists("g:krlNoHighLink") && g:krlNoHighLink==1
  highlight default link krlContinue Continue
else
  highlight default link krlContinue Statement
endif
" interrupt 
syn match krlStatement /\v\c%(<global>\s+)?<INTERRUPT>%(\s+<decl>)?/ contains=krlStorageClass
" keywords
syn keyword krlStatement WAIT SEC ON OFF ENABLE DISABLE STOP TRIGGER WITH WHEN DISTANCE PATH ONSTART DELAY DO PRIO IMPORT IS MINIMUM MAXIMUM CONFIRM ON_ERROR_PROCEED
highlight default link krlStatement Statement
" Conditional
syn keyword krlConditional IF THEN ELSE ENDIF SWITCH CASE DEFAULT ENDSWITCH
highlight default link krlConditional Conditional
" Repeat
syn keyword krlRepeat FOR TO STEP ENDFOR WHILE ENDWHILE REPEAT UNTIL LOOP ENDLOOP EXIT
highlight default link krlRepeat Repeat
" Label
syn keyword krlLabel GOTO
syn match krlLabel /^\s*\w\+:\ze\s*\%(;.*\)\?$/
highlight default link krlLabel Label
" Keyword
syn keyword krlKeyword ANIN ANOUT DIGIN
highlight default link krlKeyword Keyword
" Exception
syn keyword krlException RETURN RESUME HALT
highlight default link krlException Exception
" }}} Statements, keywords et al

" special keywords for movement commands {{{
syn keyword krlMovement PTP LIN CIRC SPL SPTP SLIN SCIRC PTP_REL LIN_REL CIRC_REL
syn keyword krlMovement ASYPTP ASYCONT ASYSTOP ASYCANCEL BRAKE BRAKE_F
if exists("g:krlNoHighlight") && g:krlNoHighlight==1
      \|| exists("g:krlNoHighLink") && g:krlNoHighLink==1
  highlight default link krlMovement Movement
else
  highlight default link krlMovement Special
endif
" movement modifiers
syn keyword krlMoveMod CA C_PTP C_DIS C_VEL C_ORI C_SPL SPLINE ENDSPLINE
if exists("g:krlNoHighlight") && g:krlNoHighlight==1
      \|| exists("g:krlNoHighLink") && g:krlNoHighLink==1
  highlight default link krlMoveMod Movement
else
  highlight default link krlMoveMod Special
endif
" }}} special keywords for movement commands

" Structure value {{{
" avoid coloring structure component names
syn match krlNames /\.[a-zA-Z_][.a-zA-Z0-9_$]*/
syn match krlNames contained /[a-zA-Z_][.a-zA-Z0-9_$]*/
highlight default link krlNames None
" Structure value
syn region krlStructVal start=/{/ end=/}/ oneline containedin=krlStructVal contains=krlNames
highlight default link krlStructVal krlDelimiter
" }}} Structure value

" BuildInFunction {{{
syn keyword krlBuildInFunction contained abs sin cos acos tan atan atan2 sqrt
syn keyword krlBuildInFunction contained b_not 
syn keyword krlBuildInFunction contained cClose cOpen cRead cWrite sRead sWrite cast_from cast_to
syn keyword krlBuildInFunction contained DELETE_BACKWARD_BUFFER DIAG_START DIAG_STOP GET_DIAGSTATE IS_KEY_PRESSED GETCYCDEF GET_DECL_PLACE CHECKPIDONRDC PIDTORDC DELETE_PID_ON_RDC CAL_TO_RDC SET_MAM_ON_HD COPY_MAM_HD_TO_RDC CREATE_RDC_ARCHIVE RESTORE_RDC_ARCHIVE DELETE_RDC_CONTENT RDC_FILE_TO_HD CHECK_MAM_ON_RDC GET_RDC_FS_STATE TOOL_ADJ IOCTL CIOCTL WSPACEGIVE WSPACETAKE SYNCCMD CANCELPROGSYNC REMOTECMD REMOTEREAD ISMESSAGESET TIMER_LIMIT SET_KRLDLGANSWER GET_MSGBUFFER STRTOFRAME STRTOPOS STRTOE3POS STRTOE6POS STRTOAXIS STRTOE3AXIS STRTOE6AXIS VARTYPE FRAND GETVARSIZE MAXIMIZE_USEDXROBVERS SET_USEDXROBVERS SET_OPT_FILTER MD_GETSTATE MD_ASGN EB_TEST EO EMI_ENDPOS EMI_STARTPOS EMI_ACTPOS EMI_RECSTATE M_COMMENT
syn keyword krlBuildInFunction contained forward inverse inv_pos
syn keyword krlBuildInFunction contained get_sig_inf GetSysState pulse GET_SYSTEM_DATA
syn keyword krlBuildInFunction contained StrAdd StrClear StrCopy StrComp StrFind StrLen StrDeclLen StrToBool StrToInt StrToReal StrToString
syn keyword krlBuildInFunction contained Clear_KrlMsg SET_SYSTEM_DATA SET_SYSTEM_DATA_DELAYED Set_KrlDlg Exists_KrlDlg Set_KrlMsg Exists_KrlMsg
syn keyword krlBuildInFunction contained Err_Clear Err_Raise
syn keyword krlBuildInFunction contained varstate EK EB LK sync MD_CMD MD_SETSTATE MBX_REC
syn keyword krlBuildInFunction contained SVEL_JOINT STOOL2 SBASE SIPO_MODE SLOAD SACC_JOINT SGEAR_JERK SAPO_PTP SVEL_CP SACC_CP SAPO SORI_TYP SJERK 
if exists("g:krlNoHighlight") && g:krlNoHighlight==1
      \|| exists("g:krlNoHighLink") && g:krlNoHighLink==1
  highlight default link krlBuildInFunction BuildInFunction
else
  highlight default link krlBuildInFunction Function
endif
" }}} BuildInFunction

" Function {{{
syn match krlFunction /[a-zA-Z_]\w* *(/me=e-1 contains=krlBuildInFunction
highlight default link krlFunction Function
" }}} Function

" Error {{{
if exists("g:krlShowError") && g:krlShowError==1
  " some more or less common typos
  "
  " vars or funcs >24 chars are not possible in krl. a234567890123456789012345
  syn match krlError /\w\{25,}/ containedin=krlFunction,krlNames,krlLabel,krlAnyType,krlEnumVal,krlSysvars
  "
  " should be interrupt (on|off) \w+
  syn match krlError /\vinterrupt +\w+ +o(n|ff)>/
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
  highlight default link krlError Error
endif
" }}} Error

" Finish {{{
let &cpo = s:keepcpo
unlet s:keepcpo

let b:current_syntax = "krl"
" }}} Finish

" vim:sw=2 sts=2 et fdm=marker
