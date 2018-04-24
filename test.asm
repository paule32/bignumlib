	BITS 32
section .text

global _start
_start:
;	push	ebp		; bp - data segment
;	mov	ebp, esp	; stack frame
;	sub	esp, 4		; save stack for 1 parameter

;	push	data_lhs	; push "data_lhs" string to stack
	mov	eax, data_lhs
	push	eax
	call	write_string	; write string
	pop	eax
	call	exit_to_cli	; exit program - to console

;	mov	esp, ebp	; get stack
;	pop	ebp		; restore bp
	ret			; return to callee function

exit_to_cli:
	mov	eax, 1		; exit()
	mov	ebx, 0		; return code 0 - normal exit
	int	80h

strlen:
;	push	ebp		; bp - data segment
;	mov	ebp, esp	; stack frame
;	sub	esp, 4		; save stack for 1 parameter

	; calculate string length
	mov	esi, eax	; get pointer to string  -"-
	mov	ecx, -1		; init counter -1
.strlen01:
	cmp	byte [esi+ecx], 0 ; is char 0 ?
	je	.strlen02	  ; yes, jump to end of function
	inc	ecx		  ; length + 1
	jmp	.strlen01	  ; next character in string
.strlen02:
	; place the length of string in eax
;	sub	edx, ecx	; add + 1 char
	mov	eax, ecx	; eax = result

;	mov	esp, ebp
;	pop	ebp		; restore bp
	ret			; return to callee function

write_string:
;	push	ebp		; data segment
;	mov	ebp, esp	; stack frame
;	sub	esp, 4		; save stack for 1 parameter

	mov	ecx, data_lhs	; pointer to string
	mov	edx, 4		; length of string
	mov	ebx, 1		; stdout
	mov	eax, 4		; system call (sys_write)
	int	80h 		; Linux syscall

;	add	esp, 4		; restore stack
;	mov	esp, ebp
;	pop	ebp
	ret			; return to callee function

section .data

data_lhs:
	db "241", 10, 0

data_rhs:
	db "100", 0

