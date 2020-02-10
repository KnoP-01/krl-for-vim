" Kuka Robot Language syntax file for Vim
" Language: Kuka Robot Language
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 2.0.2
" Last Change: 10. Feb 2020
" Credits: Thanks for contributions to this to Michael Jagusch
"          Thanks for beta testing to Thomas Baginski
"
" Suggestions of improvement are very welcome. Please email me!
"
" TODO: see and use :h :syn-iskeyword
"
" Note to self:
" for testing perfomance
"     open a 1000 lines file.
"     :syntime on
"     G
"     hold down CTRL-U until reaching top
"     :syntime report


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

" if krlGroupName exists it overrides krlNoHighlight and krlNoHighLink
if exists("g:krlGroupName")
  silent! unlet g:krlNoHighLink
  silent! unlet g:krlNoHighlight
endif
" if krlNoHighLink exists it overrides krlNoHighlight and it's pushed to krlGroupName
if exists("g:krlNoHighLink")
  silent! unlet g:krlNoHighlight
  let g:krlGroupName = g:krlNoHighLink
  unlet g:krlNoHighLink
endif
" if krlNoHighlight still exists it's pushed to krlGroupName
if exists("g:krlNoHighlight")
  let g:krlGroupName = g:krlNoHighlight
  unlet g:krlNoHighlight
endif
" if colorscheme is tortus krlNoHighLink defaults to 1
if (get(g:,'colors_name'," ")=="tortus" || get(g:,'colors_name'," ")=="tortusless") 
      \&& !exists("g:krlGroupName")
  let g:krlGroupName=1 
endif
" krlGroupName defaults to 0 if it's not initialized yet or 0
if !get(g:,"krlGroupName",0)
  let g:krlGroupName=0 
endif

" krl does ignore case
syn case ignore
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
"
"
" Comment
" NOTE1: Comment highlighting must harmonize with ftplugin/krl.vim folding (see krlFold)
" none move fold comment until second ;
syn match krlFoldComment /\c\v^\s*;\s*fold>[^;]*/ containedin=krlFold " contains=krlSingleQuoteString
" move fold comment until second ;
syn match krlFoldComment /\c\v^\s*;\s*fold>[^;]*<s?%(ptp|lin|circ|spl)(_rel)?>[^;]*/ containedin=krlFold contains=krlInteger,krlFloat,krlMovement,krlDelimiter
" Comment without Fold, also includes endfold lines and fold line part after second ;
syn match krlComment /\c\v;\s*%(<fold>)@!.*$/ containedin=krlFold contains=krlTodo,krlDebug
" Commented out Fold line: "; ;FOLD PTP..."
syn match krlComment /\c\v^\s*;\s*;.*$/ contains=krlTodo,krlDebug
highlight default link krlFoldComment Comment
highlight default link krlComment Comment
" }}} Comment and Folding 

" Header {{{
syn match krlHeader /&\a\w*/
highlight default link krlHeader PreProc
" }}} Header

" Operator {{{
" Boolean operator
syn keyword krlBoolOperator and or exor not div mod b_and b_or b_exor b_not
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
syn keyword krlType bool char real int containedin=krlAnyType
" External program and function
syn keyword krlType ext extfct extfctp extp containedin=krlAnyType
" Communication
syn keyword krlType signal channel containedin=krlAnyType
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
syn match krlTypedef /\c\v<DEFFCT>(\s+\w+(\[\d+(,\d+){,2}\])?\s+\w+\s*\()@=/
" syn keyword krlTypedef DEFFCT
syn keyword krlTypedef DEF END ENDFCT DEFDAT ENDDAT
highlight default link krlTypedef Typedef
" }}} Type, StorageClass and Typedef

" Delimiter {{{
syn match krlDelimiter /[\[\](),\\]/
highlight default link krlDelimiter Delimiter
" }}} Delimiter

" Constant values {{{
" Boolean
syn keyword krlBoolean true false containedin=krlStructVal
highlight default link krlBoolean Boolean
" Integer
syn match krlInteger /\W\@1<=[+-]\?\d\+/ containedin=krlStructVal
highlight default link krlInteger Number
" Binary integer
syn match krlBinaryInt /'b[01]\+'/ containedin=krlStructVal
highlight default link krlBinaryInt Number
" Hexadecimal integer
syn match krlHexInt /'h[0-9a-fA-F]\+'/ containedin=krlStructVal
highlight default link krlHexInt Number
" Float
syn match krlFloat /\v\W@1<=[+-]?\d+\.?\d*%(\s*[eE][+-]?\d+)?/ containedin=krlStructVal
highlight default link krlFloat Float
" String
syn region krlString start=/"/ end=/"/ oneline containedin=krlStructVal
highlight default link krlString String
syn match krlSpecialChar /[|]/ containedin=krlString
highlight default link krlSpecialChar SpecialChar
" String within a fold line " NOT USED may be used in krlComment for none move folds
" syn region krlSingleQuoteString start=/'/ end=/'/ oneline contained
" highlight default link krlSingleQuoteString String
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
" Predefined data types found in krc1
syn keyword krlStructure servopara keymove powermodul trace techangle tech techfct techcps techfctctrl axis_inc axis_cal date display_var pro_ip con bus 
syn keyword krlEnum ident_state sig_state move_state async_state emt_mode boxmode msg_prm_typ msg_typ cmd_stat asys trace_state trace_mode direction techsys techgeoref techclass techmode hpu_key_val pro_state eax transsys mode_move cosys device rotsys emstop cause_t 
"
" Predefined data types found in kss functions
syn keyword krlEnum ediagstate rdc_fs_state ret_c_psync_e var_type cancel_psync_e sys_vars 
syn keyword krlStructure siginf rw_rdc_file rw_mam_file diagpar_t error_t stopmess case_sense_t msgbuf_t e3pos e3axis diagopt_t 
"
" Predefined structures for movement
syn keyword krlStructure frame e6pos pos e6axis axis
syn keyword krlStructure fdat ldat pdat
syn keyword krlStructure load inertia
"
" Predefined structures for shapes
syn keyword krlStructure axbox cylinder box
"
" Predefined structures and enums found in /r1/mada/$machine.dat
syn keyword krlStructure cp fra acc_car jerk_struc dhart spin trpspin ex_kin et_ax maxtool
syn keyword krlEnum individual_mames supply_voltage kinclass main_axis wrist_axis sw_onoff
"
" Predefined structures and enums found in /r1/mada/$robcor.dat
" syn keyword krlStructure
syn keyword krlEnum adap_acc model_type control_parameter eko_mode
"
" Predefined structures and enums found in /steu/mada/$custom.dat
syn keyword krlStructure pro_io_t ser ext_mod_t coop_krc ws_config bin_type coop_update_t ldc_reaction
syn keyword krlEnum axis_of_coordinates spline_para_variant target_status cp_vel_type cp_statmon
"
" Predefined structures and enums found in /steu/mada/$machine.dat
syn keyword krlStructure emstop_path boxstatesafein boxstatesafeout
syn keyword krlEnum digincode
"
" Predefined structures and enums found in /steu/mada/$option.dat
syn keyword krlStructure msg_t
" syn keyword krlEnum
"
" Predefined structures and enums found in /r1/system/$config.dat
" BasisTech
syn keyword krlStructure dig_out_type ctrl_in_t ctrl_out_t fct_out_t fct_in_t odat basis_sugg_t out_sugg_t md_state machine_def_t machine_tool_t machine_frame_t trigger_para constvel_para condstop_para adat tm_sugg_t tqm_tqdat_t sps_prog_type
syn keyword krlEnum bas_command out_modetype ipo_m_t apo_mode_t funct_type p00_command
"
" GripperTech
syn keyword krlStructure grp_typ grp_types grp_sugg_t
syn keyword krlEnum on_off_typ apo_typ
"
" SpotTech
syn keyword krlStructure spot_type spot_sugg_t
syn keyword krlEnum s_command s_pair_slct command_retr
"
" VW
syn keyword krlStructure vw_mpara_typ zangentyp zangenbedingung ibszangentyp last_ibs_typ verr_typ verrcheck_t t_fb_state kollisionsdaten state_t modus_t
syn keyword krlEnum synctype dir_typ subtype ari_typ bool_typ vw_command ibgn_command vw_user_cmd move_types adv_t_type bas_type ibs_mode_typ vw_user_cmd pro_mode mode_op
"
" ProgCoop
syn keyword krlStructure ydat
" syn keyword krlEnum
"
" bas.src
syn keyword krlStructure cont
syn keyword krlEnum esys ipo_mode circ_mode circ_type ori_type var_state
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
if g:krlGroupName
  highlight default link krlSysvars Sysvars
else
  " default color for Sysvars
endif
" }}} System variable

" Statements, keywords et al {{{
" continue
syn keyword krlContinue continue
if g:krlGroupName
  highlight default link krlContinue Continue
else
  highlight default link krlContinue Statement
endif
" interrupt 
syn match krlStatement /\v\c%(<global>\s+)?<INTERRUPT>%(\s+<decl>)?/ contains=krlStorageClass
" keywords
syn keyword krlStatement wait on off enable disable stop trigger with when distance onstart delay do prio import is minimum maximum confirm on_error_proceed
syn match krlStatement /\v\c%(<wait\s+)@7<=<sec>/
syn match krlStatement /\v\c%(<when\s+)@7<=<path>/
highlight default link krlStatement Statement
" Conditional
syn keyword krlConditional if then else endif switch case default endswitch
highlight default link krlConditional Conditional
" Repeat
syn keyword krlRepeat for to step endfor while endwhile repeat until loop endloop exit
highlight default link krlRepeat Repeat
" Label
syn keyword krlLabel goto
syn match krlLabel /^\s*\w\+:\ze\s*\%(;.*\)\?$/
highlight default link krlLabel Label
" Keyword
syn keyword krlKeyword anin anout digin
highlight default link krlKeyword Keyword
" Exception
syn keyword krlException return resume halt
highlight default link krlException Exception
" }}} Statements, keywords et al

" special keywords for movement commands {{{
syn keyword krlMovement PTP LIN CIRC SPL SPTP SLIN SCIRC PTP_REL LIN_REL CIRC_REL SPTP_REL SLIN_REL SCIRC_REL
syn keyword krlMovement ASYPTP ASYCONT ASYSTOP ASYCANCEL BRAKE BRAKE_F
if g:krlGroupName
  highlight default link krlMovement Movement
else
  highlight default link krlMovement Special
endif
" movement modifiers
syn keyword krlMoveMod ca c_ptp c_dis c_vel c_ori c_spl spline endspline
if g:krlGroupName
  highlight default link krlMoveMod Movement
else
  highlight default link krlMoveMod Special
endif
" }}} special keywords for movement commands

" Structure value {{{
" avoid coloring structure component names
syn match krlNames /\.[a-zA-Z_][.a-zA-Z0-9_$]*/
syn match krlNames contained /[a-zA-Z_][.a-zA-Z0-9_$]*/
" highlight default link krlNames None
" Structure value
syn region krlStructVal start=/{/ end=/}/ oneline containedin=krlStructVal contains=krlNames
highlight default link krlStructVal Delimiter
" }}} Structure value

" BuildInFunction {{{
syn keyword krlBuildInFunction contained Abs Sin Cos Acos Tan Atan Atan2 Sqrt
syn keyword krlBuildInFunction contained cClose cOpen cRead cWrite sRead sWrite cast_from cast_to
syn keyword krlBuildInFunction contained delete_backward_buffer diag_start diag_stop get_DiagState is_key_pressed GetCycDef get_decl_place CheckPidOnRdc PidToHd PidToRdc delete_pid_on_rdc cal_to_rdc set_mam_on_hd copy_mam_hd_to_rdc copy_mam_rdc_to_hd create_rdc_archive restore_rdc_archive delete_rdc_content rdc_file_to_hd check_mam_on_rdc get_rdc_fs_state tool_adj IoCtl CioCtl WSpaceGive WSpaceTake SyncCmd CancelProgSync RemoteCmd RemoteRead IsMessageSet timer_limit set_KrlDlgAnswer get_MsgBuffer StrToFrame StrToPos StrToE3Pos StrToE6Pos StrToAxis StrToE3Axis StrToE6Axis VarType Frand GetVarsize maximize_UsedxRobvers set_UsedxRobvers set_opt_filter md_GetState md_Asgn eb_test EO emi_EndPos emi_StartPos emi_ActPos emi_RecState m_comment
syn keyword krlBuildInFunction contained Forward Inverse inv_pos
syn keyword krlBuildInFunction contained get_sig_inf GetSysState get_system_data
syn keyword krlBuildInFunction contained StrAdd StrClear StrCopy StrComp StrFind StrLen StrDeclLen StrToBool StrToInt StrToReal StrToString
syn keyword krlBuildInFunction contained clear_KrlMsg set_system_data set_system_data_delayed set_KrlDlg exists_KrlDlg set_KrlMsg exists_KrlMsg
syn keyword krlBuildInFunction contained err_clear err_raise
syn keyword krlBuildInFunction contained ExecFunc Varstate EK EB LK Sync md_Cmd md_SetState mbx_rec Pulse 
syn keyword krlBuildInFunction contained rob_stop rob_stop_release set_brake_delay
" KRC1
syn keyword krlBuildInFunction contained cLcopy cCurpos cNew cClear cRelease cKey
if g:krlGroupName
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
if get(g:,'krlShowError',1)
  " some more or less common typos
  "
  " vars or funcs >24 chars are not possible in krl. a234567890123456789012345
  syn match krlError0 /\w\{25,}/ containedin=krlFunction,krlNames,krlLabel,krlAnyType,krlEnumVal,krlSysvars
  "
  " should be interrupt (on|off) \w+
  syn match krlError1 /\vinterrupt[ \t(]+[_$a-zA-Z0-9]+[_$a-zA-Z0-9.\[\]()+\-*/]*[ \t)]+o%(n|ff)>/
  "
  " for bla==5 to 7...
  "        ||
  syn match krlError3 /\v%(^\s*for%(\(|\s)+[_$a-zA-Z]+[_$a-zA-Z0-9.\[\]()+\-*/ ]*\s*)@<=[:=]\=/
  "
  " TODO optimize performance
  " wait for a=b
  "           |
  syn match krlError4 /\v%(^\s*%(return|wait\s+for|if|while|until|%(global\s+)?interrupt\s+decl)>[^;]+[^;<>=])@<=\=[^=]/
  "
  " wait for a><b
  "           ||
  syn match krlError5 /\v%(^\s*%(return|wait\s+for|if|while|until|%(global\s+)?interrupt\s+decl)>[^;]+)@<=\>\s*\</
  "
  " if (a==5) (b==6) ...
  "         |||
  syn match krlError6 /\v%(^\s*%(return|wait\s+for|if|while|until|%(global\s+)?interrupt\s+decl)>[^;]+[^;])@<=\)\s*\(/
  "
  " TODO optimize performance
  " a == b + 1
  " a := b + 1
  "   ||
  syn match krlError7 /\v%(^\s*%(return|wait\s+for|if|while|until|%(global\s+)?interrupt\s+decl)>[^;]+[^;])@1<!%(^\s*[_$a-zA-Z]+[_$a-zA-Z0-9.\[\],+\-*/]*\s*)@<=[:=]\=/
  syn match krlError7 /\v\c%(^\s*%(decl\s+)%(global\s+)?%(const\s+)?\w+\s+\w+\s*)@<=[:=]\=/
  syn match krlError7 /\v\c%(^\s*%(decl\s+)?%(global\s+)?%(const\s+)?%(bool\s+|int\s+|real\s+|char\s+)\w+\s*)@<=[:=]\=/
  "
  " this one is tricky. Make sure this does not match trigger instructions; OK, next try, now search for false positives
  " TODO optimize performance
  " a = b and c or (int1=int2)
  "                     |
  syn match krlError8 /\v(^\s*[_$a-zA-Z]+[_$a-zA-Z0-9.\[\]()+\-*/]*\s*\=[^;]*[^;<>=])@<=\=\ze[^=]/
  "
  " <(distance|delay|prio)> :=
  " <(distance|delay|prio)> ==
  "                         ||
  syn match krlError9 /\v(^[^;]*<(distance|delay|prio|minimum|maximum)\s*)@<=[:=]\=/
  "
  " 'for', 'while' or 'repeat' followed by 'do'
  syn match krlError10 /\c\v^\s*(until|while|for)>[^;]*<do>/
  "
  highlight default link krlError0 Error
  highlight default link krlError1 Error
  highlight default link krlError2 Error
  highlight default link krlError3 Error
  highlight default link krlError4 Error
  highlight default link krlError5 Error
  highlight default link krlError6 Error
  highlight default link krlError7 Error
  highlight default link krlError8 Error
  highlight default link krlError9 Error
  highlight default link krlError10 Error
endif
" }}} Error

" Finish {{{
let &cpo = s:keepcpo
unlet s:keepcpo

let b:current_syntax = "krl"
" }}} Finish

" vim:sw=2 sts=2 et fdm=marker
