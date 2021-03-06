;;-------------------------------------------------------
;; bignum.asm
;; A simple test for using bignum.
;;
;; Jens Kallup
;;
;; Version 1.  April 25, 2018
;;-------------------------------------------------------
	BITS 32 		; for ELF32 exec format
	org  0x08048000

%assign SYS_EXIT	1	; syscall for "exit" 32-bit x86 kernel api
%assign SYS_WRITE	4	; syscall for "write" ...
%assign STDOUT		1	; flag for "write" to stdout

;;----------------------------------------------------------------
;; ELF - 32-bit executable header ...
;;----------------------------------------------------------------
ehdr:
	db	0x7f, 'ELF'	; magic header bits
	db	1, 1, 1, 0	; e_ident
times 8 db	0		;
	dw	2	 	; 32-bit machine format
	dw	3		; intel 386+
	dd	1		; multi-byte fields staring with offset 0x10
	dd	_start		; e_entry
	dd	phdr - $$	; e_phoff
	dd	0
	dd	0
	dw	ehdrsize
	dw	phdrsize
	dw	1
	dw	0
	dw	0
	dw	0

ehdrsize	equ $ - ehdr

phdr:
	dd	1
	dd	0
	dd	$$
	dd	$$
	dd	filesize
	dd	filesize
	dd	5
	dd	0x1000

phdrsize	equ	$ - phdr

;;----------------------------------------------------------------
	section .data

data_lhs:	db	'N', '-', 246
data_rhs:	db	'N',      102

	section .text
_start:
	;
	call	toASCII
	;
;	mov	edx, eax
;	call	printString

	call	exit		; exit program - to console
	ret			; return to cli

;;-------------------------------------------------------------------
;; toASCII	takes the double word in eax.
;;
;; Example;
;; convert a byte value:
;;	mov	eax, 0
;;	mov	al, byte [someVar]
;;	call	toASCII
;;
;; convert a word variable:
;;	mov	ax, word [otherVar]
;;	call	toASCII
;;
;; convert a double-word variable:
;;	mov	eax, dword [thirdVar]
;;	call	toASCII
;;
;; convert register dx in decimal:
;;	mov	eax, edx
;;	call	toASCII
;;--------------------------------------------------------------
toASCII:
	jmp .entry
	section .bss		; data stack segment
.decstr:			;
	resb	10		; reserve 10 bytes
.ctl:				;
	resd	1		; to keep track of the size of the string
	section .data
.error01:
	db 'format not know', 0
.operator:
	db	0
	section .text
.entry:
	mov	al, [data_lhs]
	cmp	al, 'N' 	; is bin-num?
	je	.num
	;			; format not know
	mov	ecx, .error01	; point to error string
	mov	edx, 0		; length of string - init := 0
.repeat:
	lodsb			; byte in al
	or	al, al		; check if zero
	jz	.done		; if zero, then we're done
	inc	edx		; increment counter
	jmp	.repeat		; repeat until zero
.done:
	cmp	edx, 0
	jg	.error
.error:
	call	printString
	ret
	;
.num:
	mov	bl, [data_lhs+1]
	;
	cmp	bl, '-' 	; is negative given?
	je	.ops
	cmp	bl, '+' 	; is positive?
	je	.ops
	cmp	bl, '*' 	; is mul?
	je	.ops
	cmp	bl, '/' 	; is div?
	je	.ops
	;
	mov	bl, '+' 	; default is plus!
.ops:
	mov	eax, [ebx] ; set it
	;
	mov	ecx, eax	; first, print sign flag
	mov	edx, 1  	; 1 char
	call	printString	; ...
call exit	;
	mov	eax, 0			; set upper: 0
	mov	al, byte [data_lhs+2]	; set lower: data_lhs
	;
	mov	dword [.ctl], 0 ; initial  0
	mov	edi, .decstr	; edi points to decstr
	add	edi, 9		; moved to the last element of string
	xor	edx, edx	; clear edx for 64-bit division
.whileNotZero:
	mov	ebx, 10		; get ready to divide by 10
	div	ebx		; divide by 10
	add	edx, '0'	; convert to ascii char
	mov	byte [edi], dl  ; put it in string
	dec	edi		; mov to next counter
	inc	dword [.ctl]	; increment char counter
	;
	xor	edx, edx	; clear edx
	cmp	eax, 0		; is remainder of division 0?
	jne	.whileNotZero	; no, keep on looping
	;
	inc	edi		; conversion, finish, bring edi
	mov	ecx, edi	; back to begin of string. make ecx
	mov	edx, [.ctl]	; point to it, and edx gets # chars
	mov	eax, edx	; result to eax
	;
	ret			; return to callee function

;;------------------------------------------------------------------
;; printString:   print a string whose address is in
;;		  ecx, and whose total number of chars
;;		  is in edx.
;; Example:
;;	mov	ecx, msg
;;	mov	edx, MSGLEN
;;	call	printString
;;------------------------------------------------------------------
printString:
	push	eax
	push	ebx

	mov	eax, SYS_WRITE
	mov	ebx, STDOUT
	int	80h		; syscall

	pop	ebx
	pop	eax
	ret

;;------------------------------------------------------------------
;; println:	put the cursor on the next line.
;;
;; Example:
;;	call	println
;;------------------------------------------------------------------
println:
	section .data
.nl:	db 10
	section .text

	push	ecx
	push	edx

	mov	ecx, .nl
	mov	edx, 1
	call	printString

	pop	edx
	pop	ecx
	ret

;;------------------------------------------------------------------
;; exit:	exit the program with return-code in
;;		ebx.
;; Example:
;;	mov	ebx, return-code
;;	call	exit
;;------------------------------------------------------------------
exit:
	mov	eax, SYS_EXIT   ; exit()
	mov	ebx, 42		; return code 0 - normal exit
	int	80h		; syscall
	ret

;;------------------------------------------------------------------
;; insertChar	insert a character start at position in
;;		eax.
;; Example:
;;	mov	ebx, [eax]	; buffer + insert pos
;;	mov	esi, [edx]	; buffer + end pos
;;	add	esi, 1		; bump text right by 1
;;	mov	ecx, 
;;	rep	movsb		; move 'em!
;;	mov	byte [ebx], eax
;;------------------------------------------------------------------
	std
strlen:
	; calculate string length
	mov	edx, 0		; init counter -1
.strlen01:
	cmp	byte [esi+edx], 0 ; is char 0 ?
	je	.strlen02	  ; yes, jump to end of function
	inc	edx		  ; length + 1
	jmp	.strlen01	  ; next character in string
.strlen02:
;	add	edx, 1
	ret			; return to callee function

write_string:
	mov	ecx, esi	; pointer to string
	mov	bl, 1		; stdout
	mov	al, 4		; system call (sys_write)
	int	80h 		; Linux syscall
	ret			; return to callee function

filesize	equ	$ - $$
