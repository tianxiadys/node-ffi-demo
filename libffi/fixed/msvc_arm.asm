


























































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































;++
;
; Copyright (c) Microsoft Corporation.  All rights reserved.
;
;
; Module:
;
;   kxarm.w
;
; Abstract:
;
;   Contains ARM architecture constants and assembly macros.
;
;--

;
; The ARM assembler uses a baroque syntax that is documented as part
; of the online Windows CE documentation.  The syntax derives from
; ARM's own assembler and was chosen to allow the migration of
; specific assembly code bases, namely ARM's floating point runtime.
; While this compatibility is no longer strictly necessary, the
; syntax lives on....
;
; Highlights:
;      * Assembler is white space sensitive.  Symbols are defined by putting
;        them in the first column
;      * The macro definition mechanism is very primitive
;
; To augment the assembler, assembly files are run through CPP (as they are
; on IA64).  This works well for constants but not structural components due
; to the white space sensitivity.
;
; For now, we use a mix of native assembler and CPP macros.
;










;++
;
; Copyright (c) Microsoft Corporation.  All rights reserved.
;
;
; Module:
;
;   kxarmunw.w
;
; Abstract:
;
;   Contains ARM unwind code helper macros
;
;   This file is not really useful on its own without the support from
;   kxarm.h.
;
;--

;
; The following macros are defined here:
;
;   PROLOG_PUSH {reglist}
;   PROLOG_VPUSH {reglist}
;   PROLOG_PUSH_TRAP_FRAME
;   PROLOG_PUSH_MACHINE_FRAME
;   PROLOG_PUSH_CONTEXT
;   PROLOG_REDZONE_RESTORE_LR
;   PROLOG_DECLARE_PROLOG_HELPER
;   PROLOG_STACK_ALLOC <amount>
;   PROLOG_STACK_SAVE <reg>
;   PROLOG_NOP <operation>
;
;   EPILOG_NOP <operation>
;   EPILOG_STACK_RESTORE <reg>
;   EPILOG_STACK_FREE <amount>
;   EPILOG_VPOP {reglist}
;   EPILOG_POP {reglist}
;   EPILOG_BRANCH <target>
;   EPILOG_BRANCH_REG <target>
;   EPILOG_LDRPC_POSTINC <postinc>
;   EPILOG_RETURN
;   EPILOG_REDZONE_RESTORE_LR
;

        ;
        ; Global variables
        ;

        ; results from __ParseIntRegister[List], __ParseVfpRegister[List]
        GBLS __ParsedRegisterString
        GBLA __ParsedRegisterMask
        GBLA __VfpParsedRegisterMaskBase
        
        ; results from __ComputeCodes[...]
        GBLS __ComputedCodes
        
        ; input and result from __MinMaxRegFromMask
        GBLA __RegInputMask
        GBLA __MinRegNum
        GBLA __MaxRegNum
        
        ; result from __CountBitsInMask
        GBLA __MaskBitCount
        
        ; global state and accumulators
        GBLS __PrologUnwindString
        GBLS __PrologLastLabel
        GBLA __EpilogUnwindCount
        GBLS __Epilog1UnwindString
        GBLS __Epilog2UnwindString
        GBLS __Epilog3UnwindString
        GBLS __Epilog4UnwindString
        GBLL __EpilogStartNotDefined
        GBLA __RunningIndex
        GBLS __RunningLabel


        ;
        ; Helper macro: compute minimum/maximum register indexes from a mask
        ;
        ; Input goes into __RegInputMask
        ; Output is placed in __MinRegNum and __MaxRegNum
        ;

        MACRO
        __MinMaxRegFromMask

        LCLA CurMask

CurMask SETA __RegInputMask
__MinRegNum SETA -1
__MaxRegNum SETA -1

        WHILE CurMask != 0
        IF ((CurMask:AND:1) != 0) && (__MinRegNum == -1)
__MinRegNum SETA __MaxRegNum + 1
        ENDIF
CurMask SETA CurMask:SHR:1
__MaxRegNum SETA __MaxRegNum + 1
        WEND
        
        MEND
        

        ;
        ; Helper macro: compute number of bits in a mask
        ;
        ; Input goes into __RegInputMask
        ; Output is placed in __MaskBitCount
        ;

        MACRO
        __CountBitsInMask

        LCLA CurMask

CurMask SETA __RegInputMask
__MaskBitCount SETA 0

        WHILE CurMask != 0
        IF (CurMask:AND:1) != 0
__MaskBitCount SETA __MaskBitCount + 1
        ENDIF
CurMask SETA CurMask:SHR:1
        WEND
        
        MEND
        

        ;
        ; Helper macro: emit an opcode with a generated label
        ;
        ; Output: Name of label is in $__RunningLabel
        ;
        
        MACRO
        __EmitRunningLabelAndOpcode $O1,$O2,$O3,$O4,$O5,$O6

__RunningLabel SETS "|Temp.$__RunningIndex|"
__RunningIndex SETA __RunningIndex + 1

        IF "$O6" != ""
$__RunningLabel $O1,$O2,$O3,$O4,$O5,$O6
        ELIF "$O5" != ""
$__RunningLabel $O1,$O2,$O3,$O4,$O5
        ELIF "$O4" != ""
$__RunningLabel $O1,$O2,$O3,$O4
        ELIF "$O3" != ""
$__RunningLabel $O1,$O2,$O3
        ELIF "$O2" != ""
$__RunningLabel $O1,$O2
        ELIF "$O1" != ""
$__RunningLabel $O1
        ELSE
$__RunningLabel
        ENDIF

        MEND


        ;
        ; Helper macro: append unwind codes to the prolog string
        ;
        ; Input is in __ComputedCodes
        ;
        
        MACRO
        __AppendPrologCodes
        
__PrologUnwindString SETS "$__ComputedCodes,$__PrologUnwindString"

        MEND


        ;
        ; Helper macro: append unwind codes to the epilog string
        ;
        ; Input is in __ComputedCodes
        ;
        
        MACRO
        __AppendEpilogCodes

        IF __EpilogUnwindCount == 1
__Epilog1UnwindString SETS "$__Epilog1UnwindString,$__ComputedCodes"
        ELIF __EpilogUnwindCount == 2
__Epilog2UnwindString SETS "$__Epilog2UnwindString,$__ComputedCodes"
        ELIF __EpilogUnwindCount == 3
__Epilog3UnwindString SETS "$__Epilog3UnwindString,$__ComputedCodes"
        ELIF __EpilogUnwindCount == 4
__Epilog4UnwindString SETS "$__Epilog4UnwindString,$__ComputedCodes"
        ENDIF

        MEND


        ;
        ; Helper macro: detect prolog end
        ;

        MACRO
        __DeclarePrologEnd

__PrologLastLabel SETS "$__RunningLabel"

        MEND


        ;
        ; Helper macro: detect epilog start
        ;

        MACRO
        __DeclareEpilogStart

        IF __EpilogStartNotDefined
__EpilogStartNotDefined SETL {false}
__EpilogUnwindCount SETA __EpilogUnwindCount + 1
        IF __EpilogUnwindCount == 1
$__FuncEpilog1StartLabel
        ELIF __EpilogUnwindCount == 2
$__FuncEpilog2StartLabel
        ELIF __EpilogUnwindCount == 3
$__FuncEpilog3StartLabel
        ELIF __EpilogUnwindCount == 4
$__FuncEpilog4StartLabel
        ELSE
        INFO    1, "Too many epilogues!"
        ENDIF
        ENDIF

        MEND
        
        
        ;
        ; Helper macro: specify epilog end
        ;

        MACRO
        __DeclareEpilogEnd

__EpilogStartNotDefined SETL {true}

        MEND
        
        
        ;
        ; Convoluted macro to parse a parameter that should be an integer register
        ; or register range, and return the string and mask
        ;
        ; Output is placed in __ParsedRegisterString and __ParsedRegisterMask
        ;

        MACRO
        __ParseIntRegister $Text
        
        LCLS CurText
        LCLS LReg
        LCLA LRegNum
        LCLA LRegMask
        LCLS RReg
        LCLA RRegNum
        LCLA RRegMask

CurText SETS "$Text"
LReg    SETS ""
LRegMask SETA 0
RReg    SETS ""
RRegMask SETA 0

        ; start with everything empty
__ParsedRegisterString SETS ""
__ParsedRegisterMask SETA 0

        ; strip leading open brace
        IF :LEN:CurText >= 1 && CurText:LEFT:1 == "{"
CurText SETS CurText:RIGHT:(:LEN:CurText - 1)
        ENDIF

        ; strip trailing close brace
        IF :LEN:CurText >= 1 && CurText:RIGHT:1 == "}"
CurText SETS CurText:LEFT:(:LEN:CurText - 1)
        ENDIF
        
        ; parse into register pair if 5 or more characters
        IF (:LEN:CurText) >= 5

        IF (CurText:LEFT:3):RIGHT:1 == "-"
LReg    SETS CurText:LEFT:2
RReg    SETS CurText:RIGHT:(:LEN:CurText - 3)
        ENDIF
        
        IF (CurText:LEFT:4):RIGHT:1 == "-"
LReg    SETS CurText:LEFT:3
RReg    SETS CurText:RIGHT:(:LEN:CurText - 4)
        ENDIF

        ; otherwise, parse as a single register
        ELSE
LReg    SETS CurText
RReg    SETS ""
        ENDIF
        
        ; fail if the registers aren't integer registers
        IF LReg != "lr" && LReg != "sp" && LReg != "pc" && LReg:LEFT:1 != "r"
        MEXIT
        ENDIF

        ; determine register masks
LRegNum SETA :RCONST:$LReg
LRegMask SETA 1:SHL:LRegNum

        ; if no right register, assign the single register
        IF RReg == ""
__ParsedRegisterString SETS LReg
__ParsedRegisterMask SETA LRegMask

        ; otherwise, validate the right register and generate the range
        ELSE
        IF RReg != "lr" && RReg != "sp" && RReg != "pc" && RReg:LEFT:1 != "r"
        MEXIT
        ENDIF
RRegNum SETA :RCONST:$RReg
RRegMask SETA 1:SHL:RRegNum
__ParsedRegisterString SETS LReg:CC:"-":CC:RReg
__ParsedRegisterMask SETA (RRegMask + RRegMask - 1) - (LRegMask - 1)
        ENDIF

        MEND


        ;
        ; Macro to parse a list of integer registers into a string and a mask
        ;
        ; Output is placed in __ParsedRegisterString and __ParsedRegisterMask
        ;

        MACRO 
        __ParseIntRegisterList $Func,$R1,$R2,$R3,$R4,$R5
        
        LCLS    OverallString
        LCLA    OverallMask
        
        __ParseIntRegister $R1
        IF __ParsedRegisterMask == 0
        INFO    1, "Invalid register in $Func: $R1"
        ENDIF
OverallMask SETA __ParsedRegisterMask
OverallString SETS __ParsedRegisterString

        IF "$R2" != ""
        __ParseIntRegister $R2
        IF __ParsedRegisterMask == 0
        INFO    1, "Invalid register in $Func: $R2"
        ENDIF
OverallMask SETA OverallMask:OR:__ParsedRegisterMask
OverallString SETS OverallString:CC:",":CC:__ParsedRegisterString
        ENDIF

        IF "$R3" != ""
        __ParseIntRegister $R3
        IF __ParsedRegisterMask == 0
        INFO    1, "Invalid register in $Func: $R3"
        ENDIF
OverallMask SETA OverallMask:OR:__ParsedRegisterMask
OverallString SETS OverallString:CC:",":CC:__ParsedRegisterString
        ENDIF

        IF "$R4" != ""
        __ParseIntRegister $R4
        IF __ParsedRegisterMask == 0
        INFO    1, "Invalid register in $Func: $R4"
        ENDIF
OverallMask SETA OverallMask:OR:__ParsedRegisterMask
OverallString SETS OverallString:CC:",":CC:__ParsedRegisterString
        ENDIF

        IF "$R5" != ""
        __ParseIntRegister $R5
        IF __ParsedRegisterMask == 0
        INFO    1, "Invalid register in $Func: $R5"
        ENDIF
OverallMask SETA OverallMask:OR:__ParsedRegisterMask
OverallString SETS OverallString:CC:",":CC:__ParsedRegisterString
        ENDIF

__ParsedRegisterMask SETA OverallMask
__ParsedRegisterString SETS OverallString
        
        MEND


        ;
        ; Convoluted macro to parse a parameter that should be a VFP register
        ; or register range, and return the string and mask
        ;
        ; Output is placed in __ParsedRegisterString and __ParsedRegisterMask
        ;

        MACRO
        __ParseVfpRegister $Text
        
        LCLS CurText
        LCLS LReg
        LCLA LRegNum
        LCLA LRegMask
        LCLS RReg
        LCLA RRegNum
        LCLA RRegMask

CurText SETS "$Text"
LReg    SETS ""
LRegMask SETA 0
RReg    SETS ""
RRegMask SETA 0

        ; start with everything empty
__ParsedRegisterString SETS ""
__ParsedRegisterMask SETA 0

        ; strip leading open brace
        IF :LEN:CurText >= 1 && CurText:LEFT:1 == "{"
CurText SETS CurText:RIGHT:(:LEN:CurText - 1)
        ENDIF

        ; strip trailing close brace
        IF :LEN:CurText >= 1 && CurText:RIGHT:1 == "}"
CurText SETS CurText:LEFT:(:LEN:CurText - 1)
        ENDIF
        
        ; parse into register pair if 5 or more characters
        IF (:LEN:CurText) >= 5

        IF (CurText:LEFT:3):RIGHT:1 == "-"
LReg    SETS CurText:LEFT:2
RReg    SETS CurText:RIGHT:(:LEN:CurText - 3)
        ENDIF
        
        IF (CurText:LEFT:4):RIGHT:1 == "-"
LReg    SETS CurText:LEFT:3
RReg    SETS CurText:RIGHT:(:LEN:CurText - 4)
        ENDIF

        ; otherwise, parse as a single register
        ELSE
LReg    SETS CurText
RReg    SETS ""
        ENDIF
        
        ; fail if the registers aren't VFP registers
        IF LReg:LEFT:1 != "d"
        MEXIT
        ENDIF
        
        ; determine register masks
LReg    SETS LReg:RIGHT:(:LEN:LReg - 1)
LRegNum SETA $LReg

        ; set the base to 0 or 16 if not yet determined
        IF __VfpParsedRegisterMaskBase == 1
        IF LRegNum >= 16
__VfpParsedRegisterMaskBase SETA 16
        ELSE
__VfpParsedRegisterMaskBase SETA 0
        ENDIF
        ENDIF
        
        IF (LRegNum >= __VfpParsedRegisterMaskBase) && (LRegNum - __VfpParsedRegisterMaskBase < 16)
LRegMask SETA 1:SHL:(LRegNum - __VfpParsedRegisterMaskBase)
        ELSE
LRegMask SETA 0
        ENDIF

        ; if no right register, assign the single register
        IF RReg == ""
__ParsedRegisterString SETS "d":CC:LReg
__ParsedRegisterMask SETA LRegMask

        ; otherwise, validate the right register and generate the range
        ELSE
        IF RReg:LEFT:1 != "d"
        MEXIT
        ENDIF
RReg    SETS RReg:RIGHT:(:LEN:RReg - 1)
RRegNum SETA $RReg

        IF (RRegNum >= __VfpParsedRegisterMaskBase) && (RRegNum - __VfpParsedRegisterMaskBase < 16)
RRegMask SETA 1:SHL:(RRegNum - __VfpParsedRegisterMaskBase)
        ELSE
RRegMask SETA 0
        ENDIF

__ParsedRegisterString SETS "d":CC:LReg:CC:"-d":CC:RReg
__ParsedRegisterMask SETA (RRegMask + RRegMask - 1) - (LRegMask - 1)
        ENDIF

        MEND


        ;
        ; Macro to parse a list of VFP registers into a string and a mask
        ;
        ; Output is placed in __ParsedRegisterString and __ParsedRegisterMask
        ;

        MACRO 
        __ParseVfpRegisterList $Func,$R1,$R2,$R3,$R4,$R5
        
        LCLS    OverallString
        LCLA    OverallMask
        
__VfpParsedRegisterMaskBase SETA 1
        
        __ParseVfpRegister $R1
        IF __ParsedRegisterMask == 0
        INFO    1, "Invalid register in $Func: $R1"
        ENDIF
OverallMask SETA __ParsedRegisterMask
OverallString SETS __ParsedRegisterString

        IF "$R2" != ""
        __ParseVfpRegister $R2
        IF __ParsedRegisterMask == 0
        INFO    1, "Invalid register in $Func: $R2"
        ENDIF
OverallMask SETA OverallMask:OR:__ParsedRegisterMask
OverallString SETS OverallString:CC:",":CC:__ParsedRegisterString
        ENDIF

        IF "$R3" != ""
        __ParseVfpRegister $R3
        IF __ParsedRegisterMask == 0
        INFO    1, "Invalid register in $Func: $R3"
        ENDIF
OverallMask SETA OverallMask:OR:__ParsedRegisterMask
OverallString SETS OverallString:CC:",":CC:__ParsedRegisterString
        ENDIF

        IF "$R4" != ""
        __ParseVfpRegister $R4
        IF __ParsedRegisterMask == 0
        INFO    1, "Invalid register in $Func: $R4"
        ENDIF
OverallMask SETA OverallMask:OR:__ParsedRegisterMask
OverallString SETS OverallString:CC:",":CC:__ParsedRegisterString
        ENDIF

        IF "$R5" != ""
        __ParseVfpRegister $R5
        IF __ParsedRegisterMask == 0
        INFO    1, "Invalid register in $Func: $R5"
        ENDIF
OverallMask SETA OverallMask:OR:__ParsedRegisterMask
OverallString SETS OverallString:CC:",":CC:__ParsedRegisterString
        ENDIF

__ParsedRegisterMask SETA OverallMask
__ParsedRegisterString SETS OverallString
        
        MEND


        ;
        ; Compute unwind codes for a PUSH or POP operation
        ;
        ; Input is in __ParsedRegisterMask
        ; Output is placed in __ComputedCodes
        ;
        
        MACRO
        __ComputePushPopCodes $Name,$FreeMask
        
        LCLA    MaskMinusFree
        LCLA    ByteVal
        LCLA    ByteVal2
        LCLA    PcLrVal

        ; See if LR/PC was included in the mask
PcLrVal SETA    0
        IF (__ParsedRegisterMask:AND:0xc000) != 0
PcLrVal SETA    1
        ENDIF

        ; Compute a mask without LR/PC
MaskMinusFree SETA __ParsedRegisterMask:AND:(:NOT:$FreeMask)

        ; Determine minimum/maximum registers
__RegInputMask SETA MaskMinusFree
        __MinMaxRegFromMask

        ; single byte, 16-bit push r4-r[4-7]
        IF ((MaskMinusFree:AND:0xff1f) == 0x0010) && (((MaskMinusFree + 0x10):AND:MaskMinusFree) == 0)
ByteVal SETA    0xd0 :OR: (PcLrVal:SHL:2) :OR: (__MaxRegNum:AND:3)
__ComputedCodes SETS "0x":CC:((:STR:ByteVal):RIGHT:2)

        ; single byte, 16-bit push r4-r[8-11]
        ELIF ((MaskMinusFree:AND:0xf01f) == 0x0010) && (((MaskMinusFree + 0x10):AND:MaskMinusFree) == 0)
ByteVal SETA    0xd8 :OR: (PcLrVal:SHL:2) :OR: (__MaxRegNum:AND:3)
__ComputedCodes SETS "0x":CC:((:STR:ByteVal):RIGHT:2)

        ; double byte, 16-bit push r0-r7 via bitmask
        ELIF ((MaskMinusFree:AND:0xff00) == 0x0000)
ByteVal SETA    0xec :OR: PcLrVal
__ComputedCodes SETS "0x":CC:((:STR:ByteVal):RIGHT:2):CC:",0x":CC:((:STR:MaskMinusFree):RIGHT:2)

        ; double byte, 32-bit push r0-r12,lr via bitmask
        ELIF ((MaskMinusFree:AND:0xa000) == 0x0000)
ByteVal SETA    0x80 :OR: (PcLrVal:SHL:5) :OR: ((__ParsedRegisterMask:SHR:8):AND:0x1f)
ByteVal2 SETA   __ParsedRegisterMask:AND:0xff
__ComputedCodes SETS "0x":CC:((:STR:ByteVal):RIGHT:2):CC:",0x":CC:((:STR:ByteVal2):RIGHT:2)

        ; unsupported case
        ELSE
        INFO    1, "Invalid register sequence specified in $Name"
        ENDIF

        MEND
        
        
        ;
        ; Compute unwind codes for a VPUSH or VPOP operation
        ;
        ; Input is in __ParsedRegisterMask
        ; Output is placed in __ComputedCodes
        ;
        
        MACRO
        __ComputeVpushVpopCodes $Name
        
        LCLA    ByteVal
        LCLA    MinRegNum
        LCLA    MaxRegNum

        ; Determine minimum/maximum registers
__RegInputMask SETA __ParsedRegisterMask
        __MinMaxRegFromMask
MinRegNum SETA __MinRegNum + __VfpParsedRegisterMaskBase
MaxRegNum SETA __MaxRegNum + __VfpParsedRegisterMaskBase

        ; Only contiguous sequences are supported
        IF ((__ParsedRegisterMask + (1:SHL:__MinRegNum)):AND:__ParsedRegisterMask) != 0
        INFO    1, "Discontiguous register sequence specified in PROLOG_VPUSH"

        ; single byte, 32-bit vpush d8-d[8-15]
        ELIF (MinRegNum == 8) && (MaxRegNum <= 15)
ByteVal SETA    0xe0 :OR: (MaxRegNum:AND:7)
__ComputedCodes SETS "0x":CC:((:STR:ByteVal):RIGHT:2)

        ; double byte, 32-bit vpush d0-d15 via start/end values
        ELIF (MinRegNum >= 0) && (MaxRegNum <= 15)
ByteVal SETA    ((MinRegNum:AND:15):SHL:4) :OR: (MaxRegNum:AND:15)
__ComputedCodes SETS "0xF5,0x":CC:((:STR:ByteVal):RIGHT:2)

        ; double byte, 32-bit vpush d16-d31 via start/end values
        ELIF (MinRegNum >= 16) && (MaxRegNum <= 31)
ByteVal SETA    ((MinRegNum:AND:15):SHL:4) :OR: (MaxRegNum:AND:15)
__ComputedCodes SETS "0xF6,0x":CC:((:STR:ByteVal):RIGHT:2)

        ; unsupported case
        ELSE
        INFO    1, "Invalid register sequence specified in $Name"
        ENDIF

        MEND
        
        
        ;
        ; Compute unwind codes for a stack alloc/dealloc operation
        ;
        ; Output is placed in __ComputedCodes
        ;

        MACRO
        __ComputeStackAllocCodes $Name, $Amount
        
        LCLA    BytesDiv4
        LCLA    BytesHigh
        LCLA    BytesLow
BytesDiv4 SETA  ($Amount) / 4

        ; single byte, 16-bit add sp, sp, #x
        IF BytesDiv4 <= 0x7f
__ComputedCodes SETS "0x":CC:((:STR:BytesDiv4):RIGHT:2)

        ; double byte, 32-bit addw sp, sp, #x
        ELIF BytesDiv4 <= 0x3ff
BytesHigh SETA  (BytesDiv4:SHR:8):OR:0xe8
BytesLow SETA   BytesDiv4:AND:0xff
__ComputedCodes SETS "0x":CC:((:STR:BytesHigh):RIGHT:2):CC:",0x":CC:((:STR:BytesLow):RIGHT:2)

        ; don't support anything bigger
        ELSE
        INFO    1, "$Name too large for unwind code encoding"
        ENDIF
        
        MEND
        
        ;
        ; Compute unwind codes for a stack save/restore operation
        ;
        ; Output is placed in __ComputedCodes
        ;

        MACRO
        __ComputeStackSaveRestoreCodes $Name, $Register
        
        LCLA    ByteVal
        
        __ParseIntRegister $Register

        ; error if no valid register
        IF __ParsedRegisterMask == 0
        INFO    1, "Invalid register in $Name: $Register"

        ; determine min/max registers in mask
        ELSE
__RegInputMask SETA __ParsedRegisterMask
        __MinMaxRegFromMask

        ; error if we were passed a range
        IF __MinRegNum != __MaxRegNum
        INFO    1, "Register range not allowed in $Name: $Register"

        ; single byte, 16-bit mov rN, sp
        ELSE
ByteVal SETA    0xc0 :OR: __MinRegNum
__ComputedCodes SETS "0x":CC:((:STR:ByteVal):RIGHT:2)
        ENDIF
        ENDIF
        
        MEND

        
        ;
        ; Macro for including an arbitrary operation in the prolog
        ;

        MACRO
        PROLOG_NOP $O1,$O2,$O3,$O4
        
        __EmitRunningLabelAndOpcode $O1,$O2,$O3,$O4
        __DeclarePrologEnd

        IF ?$__RunningLabel == 2
__ComputedCodes SETS "0xFB"
        ELSE
__ComputedCodes SETS "0xFC"
        ENDIF
        __AppendPrologCodes
        
        MEND
        
        
        ;
        ; Macro for an integer register PUSH operation in a prologue
        ;

        MACRO 
        PROLOG_PUSH $R1,$R2,$R3,$R4,$R5
        
        __ParseIntRegisterList "PROLOG_PUSH",$R1,$R2,$R3,$R4,$R5
        __EmitRunningLabelAndOpcode push {$__ParsedRegisterString}
        __DeclarePrologEnd
        
        __ComputePushPopCodes "PROLOG_PUSH",0x4000
        __AppendPrologCodes



        IF (__ParsedRegisterMask:AND:0x0800) != 0
__RegInputMask SETA __ParsedRegisterMask:AND:0x07ff
        __CountBitsInMask

        IF __MaskBitCount == 0
        PROLOG_NOP mov r11, sp
        ELSE
        PROLOG_NOP add r11, sp, #(__MaskBitCount * 4)
        ENDIF

        ENDIF



        MEND


        ;
        ; Macro for a floating-point register VPUSH operation in a prologue
        ;

        MACRO 
        PROLOG_VPUSH $R1,$R2,$R3,$R4,$R5
        
        LCLA    ByteVal

        __ParseVfpRegisterList "PROLOG_VPUSH",$R1,$R2,$R3,$R4,$R5
        __EmitRunningLabelAndOpcode vpush {$__ParsedRegisterString}
        __DeclarePrologEnd

        __ComputeVpushVpopCodes "PROLOG_VPUSH"
        __AppendPrologCodes

        MEND
        
        
        ;
        ; Macro for indicating a trap frame lives above us
        ;

        MACRO
        PROLOG_PUSH_TRAP_FRAME
        
__ComputedCodes SETS "0xEE,0x03"
        __AppendPrologCodes
        
        MEND
        
        
        ;
        ; Macro for indicating a machine frame lives above us
        ;

        MACRO
        PROLOG_PUSH_MACHINE_FRAME
        
__ComputedCodes SETS "0xEE,0x01"
        __AppendPrologCodes
        
        MEND
        
        
        ;
        ; Macro for indicating a context lives above us
        ;

        MACRO
        PROLOG_PUSH_CONTEXT
        
__ComputedCodes SETS "0xEE,0x02"
        __AppendPrologCodes
        
        MEND
        
        
        ;
        ; Macro for indicating a save LR was saved in the
        ; red zone at [sp-8]
        ;

        MACRO
        PROLOG_REDZONE_RESTORE_LR
        
__ComputedCodes SETS "0xEE,0x04"
        __AppendPrologCodes
        
        MEND

        MACRO
        EPILOG_REDZONE_RESTORE_LR
        
__ComputedCodes SETS "0xEE,0x04"
        __AppendEpilogCodes
        
        MEND


        ;
        ; Macro for allocating space on the stack in the prolog
        ;

        MACRO
        PROLOG_STACK_ALLOC $Amount
        
        __EmitRunningLabelAndOpcode sub sp, sp, #$Amount
        __DeclarePrologEnd

        __ComputeStackAllocCodes "PROLOG_STACK_ALLOC", $Amount
        __AppendPrologCodes
        
        MEND
        
        
        ;
        ; Macro for saving the stack pointer in another register
        ;

        MACRO
        PROLOG_STACK_SAVE $Register
        
        __EmitRunningLabelAndOpcode mov $Register, sp
        __DeclarePrologEnd

        __ComputeStackSaveRestoreCodes "PROLOG_STACK_SAVE", $Register
        __AppendPrologCodes
        
        MEND
        
        
        ;
        ; Macro for including an arbitrary operation in the epilog
        ;

        MACRO
        EPILOG_NOP $O1,$O2,$O3,$O4
        
        __DeclareEpilogStart
        __EmitRunningLabelAndOpcode $O1,$O2,$O3,$O4

        IF ?$__RunningLabel == 2
__ComputedCodes SETS "0xFB"
        ELSE
__ComputedCodes SETS "0xFC"
        ENDIF
        __AppendEpilogCodes
        
        MEND
        
        
        ;
        ; Macro for saving the stack pointer in another register
        ;

        MACRO
        EPILOG_STACK_RESTORE $Register
        
        __DeclareEpilogStart
        __EmitRunningLabelAndOpcode mov sp, $Register
        
        __ComputeStackSaveRestoreCodes "EPILOG_STACK_RESTORE", $Register
        __AppendEpilogCodes
        
        MEND
        
        
        ;
        ; Macro for deallocating space on the stack in the prolog
        ;

        MACRO
        EPILOG_STACK_FREE $Amount
        
        __DeclareEpilogStart
        __EmitRunningLabelAndOpcode add sp, sp, #$Amount
        
        __ComputeStackAllocCodes "EPILOG_STACK_FREE", $Amount
        __AppendEpilogCodes
        
        MEND
        
        
        ;
        ; Macro for an integer register POP operation in an epilogue
        ;

        MACRO 
        EPILOG_POP $R1,$R2,$R3,$R4,$R5

        __ParseIntRegisterList "EPILOG_POP",$R1,$R2,$R3,$R4,$R5
        __DeclareEpilogStart
        __EmitRunningLabelAndOpcode pop {$__ParsedRegisterString}

        __ComputePushPopCodes "EPILOG_POP",0x8000
        __AppendEpilogCodes
        
        IF (__ParsedRegisterMask:AND:0x8000) != 0
        __DeclareEpilogEnd
        ENDIF
        
        MEND


        ;
        ; Macro for a floating-point register VPOP operation in a prologue
        ;

        MACRO 
        EPILOG_VPOP $R1,$R2,$R3,$R4,$R5
        
        LCLA    ByteVal

        __ParseVfpRegisterList "EPILOG_VPOP",$R1,$R2,$R3,$R4,$R5
        __DeclareEpilogStart
        __EmitRunningLabelAndOpcode vpop {$__ParsedRegisterString}
        
        __ComputeVpushVpopCodes "EPILOG_VPOP"
        __AppendEpilogCodes
        
        MEND
        
        
        ;
        ; Macro for a b <target> end to the epilog (tail-call)
        ;

        MACRO
        EPILOG_BRANCH $Target
        
        __DeclareEpilogStart
        __EmitRunningLabelAndOpcode b $Target

        IF ?$__RunningLabel == 2
__ComputedCodes SETS "0xFD"
        ELSE
__ComputedCodes SETS "0xFE"
        ENDIF
        __AppendEpilogCodes

        __DeclareEpilogEnd

        MEND
        

        ;
        ; Macro for a bx register-style return in the epilog
        ;

        MACRO
        EPILOG_BRANCH_REG $Register
        
        __DeclareEpilogStart
        __EmitRunningLabelAndOpcode bx $Register

__ComputedCodes SETS "0xFD"
        __AppendEpilogCodes

        __DeclareEpilogEnd

        MEND
        

        ;
        ; Macro for a ldr pc, [sp], #x style return in the epilog
        ;

        MACRO
        EPILOG_LDRPC_POSTINC $Amount
        
        LCLA    ByteVal

        __DeclareEpilogStart
        __EmitRunningLabelAndOpcode ldr pc, [sp], #$Amount

ByteVal SETA    0x00 :OR: ($Amount/4)
__ComputedCodes SETS "0xEF,0x":CC:((:STR:ByteVal):RIGHT:2)
        __AppendEpilogCodes

        __DeclareEpilogEnd

        MEND
        

        ;
        ; Macro for a bx lr-style return in the epilog
        ;

        MACRO
        EPILOG_RETURN
        EPILOG_BRANCH_REG lr
        MEND
        

        ;
        ; Macro to reset the internal uwninding states
        ;

        MACRO
        __ResetUnwindState
__PrologUnwindString SETS ""
__EpilogUnwindCount SETA 0
__Epilog1UnwindString SETS ""
__Epilog2UnwindString SETS ""
__Epilog3UnwindString SETS ""
__Epilog4UnwindString SETS ""
__EpilogStartNotDefined SETL {true}
        MEND
        

        ;
        ; Macro to emit the xdata for unwinding
        ;

        MACRO
        __EmitUnwindXData
        
        LCLA    XBit
        LCLA    FBit

        ; determine 
FBit    SETA    0
        IF "$__PrologUnwindString" == ""
FBit    SETA    1:SHL:22
        ENDIF

XBit    SETA    0
        IF "$__FuncExceptionHandler" != ""
XBit    SETA    1:SHL:20
        ENDIF
        
        ;
        ; Append terminators where necessary
        ;
        IF __EpilogUnwindCount >= 1
__Epilog1UnwindString SETS __Epilog1UnwindString:RIGHT:(:LEN:__Epilog1UnwindString - 1)
        IF (:LEN:__Epilog1UnwindString) >= 5
        IF __Epilog1UnwindString:RIGHT:4 < "0xFD"
__Epilog1UnwindString SETS __Epilog1UnwindString:CC:",0xFF"
        ENDIF
        ENDIF
        ENDIF
        
        IF __EpilogUnwindCount >= 2
__Epilog2UnwindString SETS __Epilog2UnwindString:RIGHT:(:LEN:__Epilog2UnwindString - 1)
        IF (:LEN:__Epilog2UnwindString) >= 5
        IF __Epilog2UnwindString:RIGHT:4 < "0xFD"
__Epilog2UnwindString SETS __Epilog2UnwindString:CC:",0xFF"
        ENDIF
        ENDIF
        ENDIF
        
        IF __EpilogUnwindCount >= 3
__Epilog3UnwindString SETS __Epilog3UnwindString:RIGHT:(:LEN:__Epilog3UnwindString - 1)
        IF (:LEN:__Epilog3UnwindString) >= 5
        IF __Epilog3UnwindString:RIGHT:4 < "0xFD"
__Epilog3UnwindString SETS __Epilog3UnwindString:CC:",0xFF"
        ENDIF
        ENDIF
        ENDIF
        
        IF __EpilogUnwindCount >= 4
__Epilog4UnwindString SETS __Epilog4UnwindString:RIGHT:(:LEN:__Epilog4UnwindString - 1)
        IF (:LEN:__Epilog4UnwindString) >= 5
        IF __Epilog4UnwindString:RIGHT:4 < "0xFD"
__Epilog4UnwindString SETS __Epilog4UnwindString:CC:",0xFF"
        ENDIF
        ENDIF
        ENDIF

        ; optimize out the prolog string if it matches
        IF (:LEN:__Epilog1UnwindString) >= 6
        IF __Epilog1UnwindString:LEFT:(:LEN:__Epilog1UnwindString - 4) == __PrologUnwindString
__PrologUnwindString SETS ""
        ENDIF
        ENDIF

        IF "$__PrologUnwindString" != ""
__PrologUnwindString SETS __PrologUnwindString:CC:"0xFF"
        ENDIF

        ;
        ; Switch to the .xdata section, aligned to a DWORD
        ;
        AREA    |.xdata|,ALIGN=2,READONLY
        ALIGN   4
        
        ; declare the xdata header with unwind code size, epilog count, 
        ; exception bit, and function length
$__FuncXDataLabel
        DCD     ((($__FuncXDataEndLabel - $__FuncXDataPrologLabel)/4):SHL:28) :OR: (__EpilogUnwindCount:SHL:23) :OR: FBit :OR: XBit :OR: (($__FuncEndLabel - $__FuncStartLabel)/2)
        
        ; if we have an epilogue, output a single scope record
        IF __EpilogUnwindCount >= 1
        DCD     (($__FuncXDataEpilog1Label - $__FuncXDataPrologLabel):SHL:24) :OR: (14:SHL:20) :OR: (($__FuncEpilog1StartLabel - $__FuncStartLabel)/2)
        ENDIF
        IF __EpilogUnwindCount >= 2
        DCD     (($__FuncXDataEpilog2Label - $__FuncXDataPrologLabel):SHL:24) :OR: (14:SHL:20) :OR: (($__FuncEpilog2StartLabel - $__FuncStartLabel)/2)
        ENDIF
        IF __EpilogUnwindCount >= 3
        DCD     (($__FuncXDataEpilog3Label - $__FuncXDataPrologLabel):SHL:24) :OR: (14:SHL:20) :OR: (($__FuncEpilog3StartLabel - $__FuncStartLabel)/2)
        ENDIF
        IF __EpilogUnwindCount >= 4
        DCD     (($__FuncXDataEpilog4Label - $__FuncXDataPrologLabel):SHL:24) :OR: (14:SHL:20) :OR: (($__FuncEpilog4StartLabel - $__FuncStartLabel)/2)
        ENDIF
        
        ; output the prolog unwind string
$__FuncXDataPrologLabel
        IF "$__PrologUnwindString" != ""
        DCB     $__PrologUnwindString
        ENDIF
        
        ; if we have an epilogue, output the epilog unwind codes
        IF __EpilogUnwindCount >= 1
$__FuncXDataEpilog1Label
        DCB     $__Epilog1UnwindString,0xff
        ENDIF
        IF __EpilogUnwindCount >= 2
$__FuncXDataEpilog2Label
        DCB     $__Epilog2UnwindString,0xff
        ENDIF
        IF __EpilogUnwindCount >= 3
$__FuncXDataEpilog3Label
        DCB     $__Epilog3UnwindString,0xff
        ENDIF
        IF __EpilogUnwindCount >= 4
$__FuncXDataEpilog4Label
        DCB     $__Epilog4UnwindString,0xff
        ENDIF

        ; watch out for 0 epilogs and empty prolog -- that will create a problem
        ; due to special encoding meaning look for a second header word
        IF __EpilogUnwindCount == 0
        IF "$__PrologUnwindString" == ""
        DCB     0xff
        ENDIF
        ENDIF

        ALIGN   4
$__FuncXDataEndLabel

        ; output the exception handler information
        IF "$__FuncExceptionHandler" != ""
        DCD     $__FuncExceptionHandler
        RELOC   2                                       ; make this relative to image base
        DCD     0                                       ; append a 0 for the data (keeps Vulcan happy)
        ENDIF

        ; switch back to the original area
        AREA    $__FuncArea,CODE,READONLY

        MEND



        ;
        ; Global variables
        ;

        ; Current function names and labels
        GBLS    __FuncStartLabel
        GBLS    __FuncEpilog1StartLabel
        GBLS    __FuncEpilog2StartLabel
        GBLS    __FuncEpilog3StartLabel
        GBLS    __FuncEpilog4StartLabel
        GBLS    __FuncXDataLabel
        GBLS    __FuncXDataPrologLabel
        GBLS    __FuncXDataEpilog1Label
        GBLS    __FuncXDataEpilog2Label
        GBLS    __FuncXDataEpilog3Label
        GBLS    __FuncXDataEpilog4Label
        GBLS    __FuncXDataEndLabel
        GBLS    __FuncEndLabel

        ; other globals relating to the current function
        GBLS    __FuncArea
        GBLS    __FuncExceptionHandler


        ;
        ; Helper macro: generate the various labels we will use internally
        ; for a function
        ;
        ; Output is placed in the various __Func*Label globals
        ;

        MACRO
        __DeriveFunctionLabels $FuncName

__FuncStartLabel        SETS "|$FuncName|"
__FuncEndLabel          SETS "|$FuncName._end|"
__FuncEpilog1StartLabel SETS "|$FuncName._epilog1_start|"
__FuncEpilog2StartLabel SETS "|$FuncName._epilog2_start|"
__FuncEpilog3StartLabel SETS "|$FuncName._epilog3_start|"
__FuncEpilog4StartLabel SETS "|$FuncName._epilog4_start|"
__FuncXDataLabel        SETS "|$FuncName._xdata|"
__FuncXDataPrologLabel  SETS "|$FuncName._xdata_prolog|"
__FuncXDataEpilog1Label SETS "|$FuncName._xdata_epilog1|"
__FuncXDataEpilog2Label SETS "|$FuncName._xdata_epilog2|"
__FuncXDataEpilog3Label SETS "|$FuncName._xdata_epilog3|"
__FuncXDataEpilog4Label SETS "|$FuncName._xdata_epilog4|"
__FuncXDataEndLabel     SETS "|$FuncName._xdata_end|"

        MEND


        ;
        ; Helper macro: create a global label for the given name,
        ; decorate it, and export it for external consumption.
        ;

        MACRO
        __ExportName $FuncName

        LCLS    Name
Name    SETS    "|$FuncName|"
        ALIGN   4
        EXPORT  $Name
$Name
        MEND

        MACRO
        __ExportProc $FuncName

        LCLS    Name
Name    SETS    "|$FuncName|"
        ALIGN   4
        EXPORT  $Name
$Name   PROC
        MEND


        ;
        ; Declare that all following code/data is to be put in the .text segment
        ;

        MACRO
        TEXTAREA



        AREA    |.text|,ALIGN=2,CODE,READONLY

        MEND


        ;
        ; Declare that all following code/data is to be put in the .data segment
        ;

        MACRO
        DATAAREA
        AREA    |.data|,DATA
        MEND


        ;
        ; Declare that all following code/data is to be put in the .rdata segment
        ;

        MACRO
        RODATAAREA
        AREA    |.rdata|,DATA,READONLY
        MEND


        ;
        ; Macro for indicating the start of a nested function. Nested functions
        ; imply a prolog, epilog, and unwind codes.
        ;

        MACRO
        NESTED_ENTRY $FuncName, $AreaName, $ExceptHandler

        ; compute the function's labels
        __DeriveFunctionLabels $FuncName

        ; determine the area we will put the function into
__FuncArea   SETS    "|.text|"
        IF "$AreaName" != ""
__FuncArea   SETS    "$AreaName"
        ENDIF

        ; set up the exception handler itself
__FuncExceptionHandler SETS ""
        IF "$ExceptHandler" != ""
__FuncExceptionHandler SETS    "|$ExceptHandler|"
        ENDIF

        ; switch to the specified area
        AREA    $__FuncArea,CODE,READONLY

        ; export the function name
        __ExportProc $FuncName

        ; flush any pending literal pool stuff
        ROUT

        ; reset the state of the unwind code tracking
        __ResetUnwindState

        MEND


        ;
        ; Macro for indicating the end of a nested function. We generate the
        ; .pdata and .xdata records here as necessary.
        ;

        MACRO
        NESTED_END $FuncName

        ; mark the end of the function
$__FuncEndLabel
        LTORG
        ENDP

        ; generate .pdata
        AREA    |.pdata|,ALIGN=2,READONLY
        DCD     $__FuncStartLabel
        RELOC   2                                       ; make this relative to image base

        DCD     $__FuncXDataLabel
        RELOC   2                                       ; make this relative to image base

        ; generate .xdata
        __EmitUnwindXData

        ; back to the original area
        AREA    $__FuncArea,CODE,READONLY

        ; reset the labels
__FuncStartLabel SETS    ""
__FuncEndLabel  SETS    ""

        MEND


        ;
        ; Macro for indicating the start of a leaf function.
        ;

        MACRO
        LEAF_ENTRY $FuncName, $AreaName

        NESTED_ENTRY $FuncName, $AreaName

        MEND


        ;
        ; Macro for indicating the end of a leaf function.
        ;

        MACRO
        LEAF_END $FuncName

        NESTED_END $FuncName

        MEND


        ;
        ; Macro for indicating the start of a leaf function.
        ;

        MACRO
        LEAF_ENTRY_NO_PDATA $FuncName, $AreaName

        ; compute the function's labels
        __DeriveFunctionLabels $FuncName

        ; determine the area we will put the function into
__FuncArea   SETS    "|.text|"
        IF "$AreaName" != ""
__FuncArea   SETS    "$AreaName"
        ENDIF

        ; switch to the specified area
        AREA    $__FuncArea,CODE,READONLY

        ; export the function name
        __ExportProc $FuncName

        ; flush any pending literal pool stuff
        ROUT

        MEND


        ;
        ; Macro for indicating the end of a leaf function.
        ;

        MACRO
        LEAF_END_NO_PDATA $FuncName

        ; mark the end of the function
$__FuncEndLabel
        LTORG
        ENDP

        ; reset the labels
__FuncStartLabel SETS    ""
__FuncEndLabel  SETS    ""

        MEND


        ;
        ; Macro for indicating an alternate entry point into a function.
        ;

        MACRO
        ALTERNATE_ENTRY $FuncName

        ; export the entry point's name
        __ExportName $FuncName

        ; flush any pending literal pool stuff
        ROUT

        MEND













































        MACRO
        CAPSTART $arg1, $arg2
        MEND

        MACRO
        CAPEND $arg1
        MEND




        ;
        ; Macro to acquire a spin lock at address $Reg + $Offset. Clobbers {r0-r2}
        ;

        MACRO
        ACQUIRE_SPIN_LOCK $Reg, $Offset

        movs    r0, #1                                  ; we want to exchange with a 1
        dmb                                             ; memory barrier ahead of the loop
1
        ldrex   r1, [$Reg, $Offset]                     ; load the new value
        strex   r2, r0, [$Reg, $Offset]                 ; attempt to store the 1
        cmp     r2, #1                                  ; did we succeed before someone else did?
        beq     %B1                                     ; if not, try again
        cbz     r1, %F3                                 ; was the lock previously owned? if not, we're done
2
        yield                                           ; yield execution
        b       %B1                                     ; and try again
3
        dmb

        MEND


        ;
        ; Macro to release a spin lock at address $Reg + $Offset. If $ZeroReg is specified,
        ; that register is presumed to contain 0; otherwise, r0 is clobbered and used.
        ;

        MACRO
        RELEASE_SPIN_LOCK $Reg, $Offset, $ZeroReg

        dmb

        LCLS    Zero
Zero    SETS    "$ZeroReg"
        IF (Zero == "")
Zero    SETS    "r0"
        movs    r0, #0                                  ; need a 0 value to store
        ENDIF
        str     $Zero, [$Reg, $Offset]                  ; store it

        MEND


        ;
        ; Macro to increment a 64-bit statistic.
        ;

        MACRO
        INCREMENT_STAT $AddrReg, $Temp1, $Temp2, $Temp3

1       ldrexd  $Temp1, $Temp2, [$AddrReg]              ; load current  value
        adds    $Temp1, $Temp1, #1                      ; increment low word
        adc     $Temp2, $Temp2, #0                      ; carry into high word
        strexd  $Temp3, $Temp1, $Temp2, [$AddrReg]      ; attempt to store
        cmp     $Temp3, #0                              ; did it succeed?
        bne     %B1                                     ; if not, try again

        MEND


        ;
        ; Macro to restore the interrupt enable state to what it was in the SPSR
        ; held by the $SpsrReg parameter.
        ;

        MACRO
        RESTORE_INTERRUPT_STATE $SpsrReg

        tst     $SpsrReg, #0x80                    ; were interrupts enabled previously?
        bne     %F1                                     ; if not, skip
        cpsie   i                                       ; enable interrupts
1
        MEND


        ;
        ; Macros to read/write coprocessor registers. These macros are preferred over
        ; raw mrc/mcr because they put the register parameter first and strip the
        ; prefixes which allow them to use the same C preprocessor macros as the C
        ; code.
        ;

        MACRO
        CP_READ $rd, $coproc, $op1, $crn, $crm, $op2
        mrc     p$coproc, $op1, $rd, c$crn, c$crm, $op2 ; just shuffle params and add prefixes
        MEND


        MACRO
        CP_WRITE $rd, $coproc, $op1, $crn, $crm, $op2
        mcr     p$coproc, $op1, $rd, c$crn, c$crm, $op2 ; just shuffle params and add prefixes
        MEND


        ;
        ; Macros to read/write the TEB register
        ;

        MACRO
        TEB_READ $Reg
        CP_READ $Reg, 15, 0, 13, 0, 2                     ; read from user r/w coprocessor register
        MEND


        MACRO
        TEB_WRITE $Reg
        CP_WRITE $Reg, 15, 0, 13, 0, 2                    ; write to user r/w coprocessor register
        MEND


        ;
        ; Macros to read/write the current thread register
        ;

        MACRO
        CURTHREAD_READ $Reg
        CP_READ $Reg, 15, 0, 13, 0, 3                     ; read from user r/o coprocessor register
        bic     $Reg, #0x3f        ; clear reserved thread bits
        MEND

        ;
        ; Macro to read the PCR register
        ;

        MACRO
        PCR_READ $Reg
        CP_READ $Reg, 15, 0, 13, 0, 4                     ; read from svc r/w coprocessor register
        bfc     $Reg, #0, #12                           ; clear reserved PCR bits
        MEND

        ;
        ; Macros to read/write the current IRQL
        ;
        ; N.B. These macros do not do hardware and software IRQL processing.
        ;

        MACRO
        RAISE_IRQL $Reg, $NewIrql











        CP_READ $Reg, 15, 0, 13, 0, 3                     ; get IRQL and thread
        bfi     $Reg, $NewIrql, #0, #4                  ; set new IRQL
        CP_WRITE $Reg, 15, 0, 13, 0, 3                    ; store new value
        MEND

        MACRO
        SET_THREAD_AND_IRQL $Reg, $Thread, $Irql
        orrs    $Reg, $Thread, $Irql                    ; set IRQL bits
        CP_WRITE $Reg, 15, 0, 13, 0, 3                    ; store new thread and irql
        MEND

        MACRO
        GET_IRQL $Irql
        CP_READ $Irql, 15, 0, 13, 0, 3                    ; get IRQL and thread
        ands    $Irql, #0xF                             ; isolate IRQL
        MEND

        MACRO
        GET_THREAD_AND_IRQL $ThreadReg, $IrqlReg
        CP_READ $IrqlReg, 15, 0, 13, 0, 3                 ; get thread and irql
        bic     $ThreadReg, $IrqlReg, #0x3f ; isolate thread
        ands    $IrqlReg, #0xF                          ; isolate IRQL
        MEND

        MACRO
        CURTHREAD_READ_PASSIVE $ThreadReg
        CP_READ $ThreadReg, 15, 0, 13, 0, 3               ; get thread and irql








        MEND

        MACRO
        CURTHREAD_WRITE_PASSIVE $ThreadReg
        CP_WRITE $ThreadReg, 15, 0, 13, 0, 3              ; write thread and PASSIVE IRQL
        MEND

        ;
        ; Macros to output special undefined opcodes that indicate breakpoints
        ; and debug services.
        ;

        MACRO
        EMIT_BREAKPOINT
        DCW     0xdefe                        ; undefined per ARM ARM
        MEND


        MACRO
        EMIT_DEBUG_SERVICE
        DCW     0xdefd                     ; undefined per ARM ARM
        MEND

        ;
        ; Macro to emit a fastfail instruction.
        ;

        MACRO
        FASTFAIL $FastFailCode
        mov     r0, $FastFailCode
        DCW     0xdefb                          ; undefined per ARM ARM
        MEND


        ;
        ; Macro to generate an exception frame; this is intended to
        ; be used within the prolog of a function.
        ;

        MACRO
        GENERATE_EXCEPTION_FRAME
        PROLOG_PUSH         {r4-r11, lr}                ; save non-volatile registers
        PROLOG_STACK_ALLOC  0x14                        ; allocate remainder of exception frame
        MEND


        ;
        ; Define the instrumentation return macro.
        ;
        ;   This macro determines whether an instrumentation callback is
        ;   enabled for this threads's process.  If it is, then the return
        ;   address in the trap frame is replaced with the instrumentation
        ;   callback address, and r12 is used to indicate the actual return
        ;   address.
        ;
        ; Arguments:
        ;
        ;   None
        ;
        ; Implicit arguments:
        ;
        ;   r2 - Scratch register (must be sanitized)
        ;
        ;   r3 - Supplies the address of the trap frame (must be sanitized)
        ;
        ;   r12 - Current thread pointer (must be sanitized)
        ;
        ;   sp - Pointer to INT KARM_MINI_STACK
        ;

        MACRO
        SETUP_FOR_INSTRUMENTATION_RETURN

        ldr     r2, [r12, #0x3]               ; get debugging state
        tst     r2, #0x2          ; is instrumentation active?
        beq     %F1                                     ; if not, skip
        ldr     r2, [r12, #0x64 + 0x10]      ; get current process
        ldr     r2, [r2, #0xa4]    ; get callback address
        cbz     r2, %F1                                 ; if NULL, skip it
        ldr     r12, [r3, #0x80]                        ; load original return PC
        str     r12, [r3, #0x70]                       ; store in R12
        str     r2, [r3, #0x80]                         ; update PC in trap frame (for debugger only)
        bic     r2, r2, #1                              ; clear the PC's low bit
        str     r2, [sp, #0x0]                         ; store PC to INT ministack
        movs    r2, #0                                  ; sanitize remaining volatiles
        movs    r3, #0                                  ; sanitize remaining volatiles
        rfeia   sp                                      ; restore from exception
1
        MEND


        ;
        ; Macro to restore from an exception frame; this is intended to
        ; be used within the epilog of a function.
        ;

        MACRO
        RESTORE_EXCEPTION_FRAME
        EPILOG_STACK_FREE    0x14                       ; adjust SP to point to non-volatile registers
        EPILOG_POP           {r4-r11, lr}               ; restore non-volatile registers
        MEND


        ;
        ; Macro to flush the current VFP state to a KARM_VFP_STATE structure
        ;

        MACRO
        SAVE_VFP_STATE $base, $temp

        vmrs    $temp, fpscr                            ; load floating point control/status
        str     $temp, [$base, #0x4]                ; store it
        adds    $base, $base, #0x10                   ; point to the registers themselves
        vstm    $base!, {d0-d15}                        ; save d0-d15
        vstm    $base, {d16-d31}                        ; save d16-d31
2
        MEND


        ;
        ; Macro to restore the current VFP state from a KARM_VFP_STATE structure
        ;

        MACRO
        RESTORE_VFP_STATE $base, $temp

        ldr     $temp, [$base, #0x4]                ; load floating point control/status
        bic     $temp, $temp, #0x370000        ; clear deprecated bits
        vmsr    fpscr, $temp                            ; set it
        adds    $base, $base, #0x10                   ; point to the registers themselves
        vldm    $base!, {d0-d15}                        ; load d0-d15
        vldm    $base, {d16-d31}                        ; load d16-d31
2
        MEND


        ;
        ; Macro to return the current cycle time in the target registers.
        ;

        MACRO
        READ_CYCLE_COUNTER_64BIT $lo, $hi, $scratch1, $scratch2, $prcb

        IF ("$prcb" == "")
        PCR_READ    $scratch1                           ; get PCR in scratch
        add         $scratch1, $scratch1, #0xef0 ; point to cycle counter address
        ELSE
        add         $scratch1, $prcb, #0x970 ; point to cycle counter address
        ENDIF
0
        ldrexd      $scratch2, $hi, [$scratch1]         ; get last high/low value in hi:scratch
        CP_READ     $lo, 15, 0, 9, 13, 0                   ; read cycle counter in lo
        teq         $scratch2, $lo                      ; EOR the new low with the previous
        bpl         %F1                                 ; if the same sign, nothing to do
        adds        $hi, $hi, $scratch2, lsr #31        ; clock into the high word if we wrapped
1
        strexd      $scratch2, $lo, $hi, [$scratch1]    ; store the updated hi/lo
        cmp         $scratch2, #0                       ; did it succeed?
        bne         %B0                                 ; if not, try again
        MEND

        ;
        ; Macro to update the cycle counter based upon the target registers.
        ;
        ; N.B. This is not an atomic operation and should only be used when
        ;      interrupts are disabled for processor initialization.
        ;

        MACRO
        WRITE_CYCLE_COUNTER_64BIT $lo, $hi, $scratch1

        PCR_READ    $scratch1                           ; get PCR in scratch
        add         $scratch1, $scratch1, #0xef0 ; point to cycle counter address
        str         $lo, [$scratch1]                    ; store lo in shadow
        str         $hi, [$scratch1, #4]                ; store hi
        CP_WRITE    $lo, 15, 0, 9, 13, 0                   ; write lo to cycle counter
        MEND

        ;
        ; Macro to align a Control Flow Guard valid call target.
        ;

        MACRO
        CFG_ALIGN



        MEND

        ;
        ; Macro to read the CPSR.
        ;

        MACRO
        READ_CPSR $Reg
        mrs     $Reg, cpsr                               ; read CPSR
        orr     $Reg, $Reg, 0x20                  ; add the thumb bit
        MEND

;



        ; 8 byte aligned AREA to support 8 byte aligned jump tables
        MACRO
        NESTED_ENTRY_FFI $FuncName, $AreaName, $ExceptHandler

        ; compute the function's labels
        __DeriveFunctionLabels $FuncName

        ; determine the area we will put the function into
__FuncArea   SETS    "|.text|"
        IF "$AreaName" != ""
__FuncArea   SETS    "$AreaName"
        ENDIF

        ; set up the exception handler itself
__FuncExceptionHandler SETS ""
        IF "$ExceptHandler" != ""
__FuncExceptionHandler SETS    "|$ExceptHandler|"
        ENDIF

        ; switch to the specified area, jump tables require 8 byte alignment
        AREA    $__FuncArea,CODE,CODEALIGN,ALIGN=3,READONLY

        ; export the function name
        __ExportProc $FuncName

        ; flush any pending literal pool stuff
        ROUT

        ; reset the state of the unwind code tracking
        __ResetUnwindState

        MEND

;        MACRO
;        TABLE_ENTRY $Type, $Table
;$Type_$Table
;        MEND



    ; r0:   stack
    ; r1:   frame
    ; r2:   fn
    ; r3:   vfp_used

    ; fake entry point exists only to generate exists only to 
    ; generate .pdata for exception unwinding
    NESTED_ENTRY_FFI ffi_call_VFP_fake
    PROLOG_PUSH  {r11, lr}          ; save fp and lr for unwind

    ALTERNATE_ENTRY ffi_call_VFP
    cmp    r3, #3                   ; load only d0 if possible
    vldrle d0, [r0]
    vldmgt r0, {d0-d7}
    add    r0, r0, #64              ; discard the vfp register args
    b ffi_call_SYSV
    NESTED_END ffi_call_VFP_fake

    ; fake entry point exists only to generate exists only to 
    ; generate .pdata for exception unwinding
    NESTED_ENTRY_FFI ffi_call_SYSV_fake
    PROLOG_PUSH  {r11, lr}          ; save fp and lr for unwind

    ALTERNATE_ENTRY ffi_call_SYSV
    stm    r1, {fp, lr}
    mov    fp, r1

    mov    sp, r0                   ; install the stack pointer
    mov    lr, r2                   ; move the fn pointer out of the way
    ldr    ip, [fp, #16]            ; install the static chain
    ldmia  sp!, {r0-r3}             ; move first 4 parameters in registers.
    blx    lr                       ; call fn

    ; Load r2 with the pointer to storage for the return value
    ; Load r3 with the return type code
    ldr    r2, [fp, #8]
    ldr    r3, [fp, #12]

    ; Deallocate the stack with the arguments.
    mov    sp, fp

    ; Store values stored in registers.
    ALIGN 8
    lsl     r3, #3
    add     r3, r3, pc
    add     r3, #8
    mov     pc, r3


return_ARM_TYPE_VFP_S_ffi_call
    ALIGN 8
    vstr s0, [r2]
    pop    {fp,pc}
return_ARM_TYPE_VFP_D_ffi_call
    ALIGN 8
    vstr d0, [r2]
    pop    {fp,pc}
return_ARM_TYPE_VFP_N_ffi_call
    ALIGN 8
    vstm r2, {d0-d3}
    pop    {fp,pc}
return_ARM_TYPE_INT64_ffi_call
    ALIGN 8
    str    r1, [r2, #4]
    nop
return_ARM_TYPE_INT_ffi_call
    ALIGN 8
    str    r0, [r2]
    pop    {fp,pc}
return_ARM_TYPE_VOID_ffi_call
    ALIGN 8
    pop    {fp,pc}
    nop
return_ARM_TYPE_STRUCT_ffi_call
    ALIGN 8
    cmp r3, #6
    pop    {fp,pc}
    NESTED_END ffi_call_SYSV_fake

    IMPORT |ffi_closure_inner_SYSV|
    









    NESTED_ENTRY_FFI ffi_go_closure_SYSV
    stmdb   sp!, {r0-r3}            ; save argument regs
    ldr     r0, [ip, #4]            ; load cif
    ldr     r1, [ip, #8]            ; load fun
    mov     r2, ip                  ; load user_data
    b       ffi_go_closure_SYSV_0
    NESTED_END ffi_go_closure_SYSV

    ; r3:    ffi_closure

    ; fake entry point exists only to generate exists only to 
    ; generate .pdata for exception unwinding
    NESTED_ENTRY_FFI ffi_closure_SYSV_fake  
    PROLOG_PUSH  {r11, lr}          ; save fp and lr for unwind
    ALTERNATE_ENTRY ffi_closure_SYSV
    ldmfd   sp!, {ip,r0}            ; restore fp (r0 is used for stack alignment)
    stmdb   sp!, {r0-r3}            ; save argument regs

    ldr     r0, [ip, #16]    ; ffi_closure->cif
    ldr     r1, [ip, #16+4]  ; ffi_closure->fun
    ldr     r2, [ip, #16+8]  ; ffi_closure->user_data

    ALTERNATE_ENTRY ffi_go_closure_SYSV_0
    add     ip, sp, #16             ; compute entry sp

    sub     sp, sp, #64+32          ; allocate frame parameter (sizeof(vfp_space) = 64, sizeof(result) = 32)
    mov     r3, sp                  ; set frame parameter
    stmdb   sp!, {ip,lr}

    bl      ffi_closure_inner_SYSV  ; call the Python closure

                                    ; Load values returned in registers.
    add     r2, sp, #64+8           ; address of closure_frame->result
    bl      ffi_closure_ret         ; move result to correct register or memory for type

    ldmfd   sp!, {ip,lr}
    mov     sp, ip                  ; restore stack pointer
    mov     pc, lr
    NESTED_END ffi_closure_SYSV_fake

    IMPORT |ffi_closure_inner_VFP|
    









    NESTED_ENTRY_FFI ffi_go_closure_VFP
    stmdb   sp!, {r0-r3}			; save argument regs
    ldr	r0, [ip, #4]			; load cif
    ldr	r1, [ip, #8]			; load fun
    mov	r2, ip				; load user_data
    b	ffi_go_closure_VFP_0
    NESTED_END ffi_go_closure_VFP

    ; fake entry point exists only to generate exists only to 
    ; generate .pdata for exception unwinding
    ; r3:    closure
    NESTED_ENTRY_FFI ffi_closure_VFP_fake
    PROLOG_PUSH  {r11, lr}          ; save fp and lr for unwind

    ALTERNATE_ENTRY ffi_closure_VFP
    ldmfd   sp!, {ip,r0}            ; restore fp (r0 is used for stack alignment)
    stmdb   sp!, {r0-r3}            ; save argument regs

    ldr     r0, [ip, #16]    ; load cif
    ldr     r1, [ip, #16+4]  ; load fun
    ldr     r2, [ip, #16+8]  ; load user_data

    ALTERNATE_ENTRY ffi_go_closure_VFP_0
    add     ip, sp, #16             ; compute entry sp
    sub     sp, sp, #32             ; save space for closure_frame->result
    vstmdb  sp!, {d0-d7}            ; push closure_frame->vfp_space

    mov     r3, sp                  ; save closure_frame
    stmdb   sp!, {ip,lr}

    bl      ffi_closure_inner_VFP

    ; Load values returned in registers.
    add     r2, sp, #64+8           ; load result
    bl      ffi_closure_ret
    ldmfd   sp!, {ip,lr}
    mov     sp, ip                  ; restore stack pointer
    mov     pc, lr
    NESTED_END ffi_closure_VFP_fake





    NESTED_ENTRY_FFI ffi_closure_ret
    stmdb sp!, {fp,lr}

    ALIGN 8
    lsl     r0, #3
    add     r0, r0, pc
    add     r0, #8
    mov     pc, r0

return_ARM_TYPE_VFP_S_ffi_closure
    ALIGN 8
    vldr s0, [r2]
    b call_epilogue
return_ARM_TYPE_VFP_D_ffi_closure
    ALIGN 8
    vldr d0, [r2]
    b call_epilogue
return_ARM_TYPE_VFP_N_ffi_closure
    ALIGN 8
    vldm r2, {d0-d3}
    b call_epilogue
return_ARM_TYPE_INT64_ffi_closure
    ALIGN 8
    ldr    r1, [r2, #4]
    nop
return_ARM_TYPE_INT_ffi_closure
    ALIGN 8
    ldr    r0, [r2]
    b call_epilogue
return_ARM_TYPE_VOID_ffi_closure
    ALIGN 8
    b call_epilogue
    nop
return_ARM_TYPE_STRUCT_ffi_closure
    ALIGN 8
    b call_epilogue
call_epilogue
    ldmfd sp!, {fp,pc}
    NESTED_END ffi_closure_ret

    AREA |.trampoline|, DATA, THUMB, READONLY
    EXPORT |ffi_arm_trampoline|
|ffi_arm_trampoline| DATA
thisproc    adr    ip, thisproc
            stmdb  sp!, {ip, r0}
            ldr    pc, [pc, #0]
            DCD    0
            ;ENDP

    END
