	BITS 32
section .text

global _start
_start:
	mov	esi, data_lhs

	call	strlen
	call	write_string	; write string
	call	exit		; exit program - to console

	ret			; return to cli

exit:
	mov	al, 1		; exit()
	mov	bl, 0		; return code 0 - normal exit
	int	80h
	ret

strlen:
	; calculate string length
	mov	edx, 0		; init counter -1
.strlen01:
	cmp	byte [esi+edx], 0 ; is char 0 ?
	je	.strlen02	  ; yes, jump to end of function
	inc	edx		  ; length + 1
	jmp	.strlen01	  ; next character in string
.strlen02:
	add	edx, 1
	ret			; return to callee function

write_string:
	mov	ecx, esi	; pointer to string
	mov	bl, 1		; stdout
	mov	al, 4		; system call (sys_write)
	int	80h 		; Linux syscall
	ret			; return to callee function

section .data

data_lhs:
	db "241", 10, 0
