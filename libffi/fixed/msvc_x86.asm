




















































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































    .686P
    .MODEL FLAT

EXTRN	@ffi_closure_inner@8:PROC
_TEXT SEGMENT












ALIGN 16
PUBLIC @ffi_call_i386@8
@ffi_call_i386@8 PROC
LUW0:
	
 



	mov	    eax, [esp]		
	mov	    [ecx], ebp		
	mov 	[ecx+4], eax	

	






	mov 	ebp, ecx
LUW1:
	
	

	mov 	esp, edx		
	mov 	eax, [20+0*4+ebp]	
	mov 	edx, [20+1*4+ebp]
	mov	    ecx, [20+2*4+ebp]

	call	dword ptr [ebp+8]

	mov	    ecx, [12+ebp]		
	mov 	[ebp+8], ebx		
LUW2:
	

	and 	ecx, 15
	lea 	ebx, [Lstore_table + ecx * 8]
	mov 	ecx, [ebp+16]		
	jmp	    ebx

	ALIGN	8
Lstore_table:
ALIGN 8; ORG Lstore_table + 0 * 8
	fstp	DWORD PTR [ecx]
	jmp	Le1
ALIGN 8; ORG Lstore_table + 1 * 8
	fstp	QWORD PTR [ecx]
	jmp	Le1
ALIGN 8; ORG Lstore_table + 2 * 8
	fstp	QWORD PTR [ecx]
	jmp	Le1
ALIGN 8; ORG Lstore_table + 3 * 8
	movsx	eax, al
	mov	[ecx], eax
	jmp	Le1
ALIGN 8; ORG Lstore_table + 4 * 8
	movsx	eax, ax
	mov	[ecx], eax
	jmp	Le1
ALIGN 8; ORG Lstore_table + 5 * 8
	movzx	eax, al
	mov	[ecx], eax
	jmp	Le1
ALIGN 8; ORG Lstore_table + 6 * 8
	movzx	eax, ax
	mov	[ecx], eax
	jmp	Le1
ALIGN 8; ORG Lstore_table + 7 * 8
	mov	[ecx+4], edx
	
ALIGN 8; ORG Lstore_table + X86_RET_int 32 * 8
	mov	[ecx], eax
	
ALIGN 8; ORG Lstore_table + 9 * 8
Le1:
	mov	    ebx, [ebp+8]
	mov	    esp, ebp
	pop 	ebp
LUW3:
	
	
	
	
	ret
LUW4:
	

ALIGN 8; ORG Lstore_table + 10 * 8
	jmp	    Le1
ALIGN 8; ORG Lstore_table + 11 * 8
	jmp	    Le1
ALIGN 8; ORG Lstore_table + 12 * 8
	mov 	[ecx], al
	jmp	    Le1
ALIGN 8; ORG Lstore_table + 13 * 8
	mov 	[ecx], ax
	jmp	    Le1

	
ALIGN 8; ORG Lstore_table + 14 * 8
	int 3
ALIGN 8; ORG Lstore_table + 15 * 8
	int 3

LUW5:
	
@ffi_call_i386@8 ENDP






















FFI_CLOSURE_SAVE_REGS MACRO
	mov 	[esp + 0+16+0*4], eax
	mov 	[esp + 0+16+1*4], edx
	mov 	[esp + 0+16+2*4], ecx
ENDM

FFI_CLOSURE_COPY_TRAMP_DATA MACRO
	mov 	edx, [eax+16]      
	mov 	ecx, [eax+16+4]    
	mov 	eax, [eax+16+8];   
	mov 	[esp+0+28], edx
	mov 	[esp+0+32], ecx
	mov 	[esp+0+36], eax
ENDM


FFI_CLOSURE_PREP_CALL MACRO
	mov	    ecx, esp                    
	lea 	edx, [esp+(40 + 4)+4]     
ENDM









FFI_CLOSURE_CALL_INNER MACRO UWN
	call	@ffi_closure_inner@8
ENDM

FFI_CLOSURE_MASK_AND_JUMP MACRO LABEL
	and	    eax, 15
	lea 	edx, [LABEL+eax*8]
	mov 	eax, [esp+0]       
	jmp	    edx
ENDM

ALIGN 16
PUBLIC ffi_go_closure_EAX
ffi_go_closure_EAX PROC C
LUW6:
	
	sub	esp, (40 + 4)
LUW7:
	
	FFI_CLOSURE_SAVE_REGS
	mov     edx, [eax+4]			
	mov 	ecx, [eax +8]			
	mov 	[esp+0+28], edx
	mov 	[esp+0+32], ecx
	mov 	[esp+0+36], eax	
	jmp	Ldo_closure_i386
LUW8:
	
ffi_go_closure_EAX ENDP

ALIGN 16
PUBLIC ffi_go_closure_ECX
ffi_go_closure_ECX PROC C
LUW9:
	
	sub 	esp, (40 + 4)
LUW10:
	
	FFI_CLOSURE_SAVE_REGS
	mov 	edx, [ecx+4]			
	mov 	eax, [ecx+8]			
	mov 	[esp+0+28], edx
	mov 	[esp+0+32], eax
	mov 	[esp+0+36], ecx	
	jmp	Ldo_closure_i386
LUW11:
	
ffi_go_closure_ECX ENDP




ALIGN 16
PUBLIC ffi_closure_i386
ffi_closure_i386 PROC C
LUW12:
	
	sub	    esp, (40 + 4)
LUW13:
	

	FFI_CLOSURE_SAVE_REGS
	FFI_CLOSURE_COPY_TRAMP_DATA

	
Ldo_closure_i386::

	FFI_CLOSURE_PREP_CALL
	FFI_CLOSURE_CALL_INNER(14)
	FFI_CLOSURE_MASK_AND_JUMP Lload_table2

    ALIGN 8
Lload_table2:
ALIGN 8; ORG Lload_table2 + 0 * 8
	fld 	dword ptr [esp+0]
	jmp	Le2
ALIGN 8; ORG Lload_table2 + 1 * 8
	fld 	qword ptr [esp+0]
	jmp	Le2
ALIGN 8; ORG Lload_table2 + 2 * 8
	fld 	qword ptr [esp+0]
	jmp	Le2
ALIGN 8; ORG Lload_table2 + 3 * 8
	movsx	eax, al
	jmp	Le2
ALIGN 8; ORG Lload_table2 + 4 * 8
	movsx	eax, ax
	jmp	Le2
ALIGN 8; ORG Lload_table2 + 5 * 8
	movzx	eax, al
	jmp	Le2
ALIGN 8; ORG Lload_table2 + 6 * 8
	movzx	eax, ax
	jmp	Le2
ALIGN 8; ORG Lload_table2 + 7 * 8
	mov 	edx, [esp+0+4]
	jmp	Le2
ALIGN 8; ORG Lload_table2 + 8 * 8
	nop
	
ALIGN 8; ORG Lload_table2 + 9 * 8
Le2:
	add 	esp, (40 + 4)
LUW16:
	
	ret
LUW17:
	
ALIGN 8; ORG Lload_table2 + 10 * 8
	add 	esp, (40 + 4)
LUW18:
	
	ret	4
LUW19:
	
ALIGN 8; ORG Lload_table2 + 11 * 8
	jmp	Le2
ALIGN 8; ORG Lload_table2 + 12 * 8
	movzx	eax, al
	jmp	Le2
ALIGN 8; ORG Lload_table2 + 13 * 8
	movzx	eax, ax
	jmp	Le2

	
ALIGN 8; ORG Lload_table2 + 14 * 8
	int 3
ALIGN 8; ORG Lload_table2 + 15 * 8
	int 3

LUW20:
	
ffi_closure_i386 ENDP

ALIGN 16
PUBLIC	ffi_go_closure_STDCALL
ffi_go_closure_STDCALL PROC C
LUW21:
	
	sub 	esp, (40 + 4)
LUW22:
	
	FFI_CLOSURE_SAVE_REGS
	mov 	edx, [ecx+4]			
	mov 	eax, [ecx+8]			
	mov 	[esp+0+28], edx
	mov 	[esp+0+32], eax
	mov 	[esp+0+36], ecx	
	jmp	Ldo_closure_STDCALL
LUW23:
	
ffi_go_closure_STDCALL ENDP




ALIGN 16
PUBLIC ffi_closure_REGISTER
ffi_closure_REGISTER PROC C
LUW24:
	
	
	
	sub 	esp, (40 + 4)-4
LUW25:
	
	FFI_CLOSURE_SAVE_REGS
	mov	ecx, [esp+(40 + 4)-4] 	
	mov	eax, [esp+(40 + 4)]		
	mov	[esp+(40 + 4)], ecx		
	jmp	Ldo_closure_REGISTER
LUW26:
	
ffi_closure_REGISTER ENDP





ALIGN 16
PUBLIC ffi_closure_STDCALL
ffi_closure_STDCALL PROC C
LUW27:
	
	sub 	esp, (40 + 4)
LUW28:
	

	FFI_CLOSURE_SAVE_REGS

	
Ldo_closure_REGISTER::

	FFI_CLOSURE_COPY_TRAMP_DATA

	
Ldo_closure_STDCALL::

	FFI_CLOSURE_PREP_CALL
	FFI_CLOSURE_CALL_INNER(29)

	mov 	ecx, eax
	shr 	ecx, 4	    
	lea 	ecx, [esp+(40 + 4)+ecx]	
	mov 	edx, [esp+(40 + 4)]		
	mov 	[ecx], edx

	





	FFI_CLOSURE_MASK_AND_JUMP  Lload_table3

    ALIGN 8
Lload_table3:
ALIGN 8; ORG Lload_table3 + 0 * 8
	fld    DWORD PTR [esp+0]
	mov     esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 1 * 8
	fld    QWORD PTR [esp+0]
	mov     esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 2 * 8
	fld    QWORD PTR [esp+0]
	mov     esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 3 * 8
	movsx   eax, al
	mov     esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 4 * 8
	movsx   eax, ax
	mov     esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 5 * 8
	movzx   eax, al
	mov     esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 6 * 8
	movzx   eax, ax
	mov     esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 7 * 8
	mov 	edx, [esp+0+4]
	mov     esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + X86_RET_int 32 * 8
	mov     esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 9 * 8
	mov     esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 10 * 8
	mov     esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 11 * 8
	mov 	esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 12 * 8
	movzx	eax, al
	mov 	esp, ecx
	ret
ALIGN 8; ORG Lload_table3 + 13 * 8
	movzx	eax, ax
	mov 	esp, ecx
	ret

	
ALIGN 8; ORG Lload_table3 + 14 * 8
	int 3
ALIGN 8; ORG Lload_table3 + 15 * 8
	int 3

LUW31:
	
ffi_closure_STDCALL ENDP









































































































































































































































































































































































































































































































END
