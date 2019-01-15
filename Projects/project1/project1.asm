TITLE Project 1     (project1.asm)

; Author: Lyell Read
; Course / Project ID: CS271/Project_1                Date:1/10/2019
; Description:Simple arithmetic and I/O practice project.

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

input_1			SDWORD	?	;user provided input 1
input_2			SDWORD	?	;user provided input 2
sum				SDWORD	?	;sum of two numbers
diff			SDWORD	?	;difference of two numbers
prod			SDWORD	?	;product of two numbers
quot			SDWORD	?	;quotient of two numbers
rem				SDWORD	?	;remainder of two numbers

t_header		BYTE	"			Assignment 1 (program1.asm) -- Lyell Read",0
t_instructions	BYTE	"Enter two numbers when prompted; then I'll do the rest ;). You'll end up with the sum, difference, product and quotient and remainder of those two numbers.",0
t_prompt_1		BYTE	"Please Enter the First Number :",0
t_prompt_2		BYTE	"Please Enter the Second Number :",0
t_play_again	BYTE	"Do you want to play again? (1 for yes, * != 1 for no) :",0
t_goodbye		BYTE	"Quitting. Have a nice day!",0
t_error_1		BYTE	"Error: Div by 0 or second input larger than first. Restarting input sequence...",0
t_extra_credit	BYTE	"**EC (for pts): Repeat until chosen, Handling second input greater than first (would generate overflow).",0
t_extra_credit2	BYTE	"**EC (other): preventing division by 0",0

c_plus			BYTE	" + ",0
c_minus			BYTE	" - ",0
c_multiply		BYTE	" x ",0
c_divide		BYTE	" / ",0
c_remainder		BYTE	" remainder ",0
c_equals		BYTE	" = ",0

.code
main PROC

;introduction
	
	;print the 'header' AKA name and title and extra credit
	mov 	edx, OFFSET t_header
	call	WriteString
	call	CrLF
	call	CrLF
	mov		edx, OFFSET t_extra_credit
	call 	WriteString
	call	CrLF
	mov		edx, OFFSET t_extra_credit2
	call 	WriteString
	call	CrLF
	call	CrLF
	call	CrLF

	
	;print the instruction text
	mov 	edx, OFFSET t_instructions
	call	WriteString
	call	CrLF
	call	CrLF

;user input	
top:
	
	mov		edx, OFFSET t_prompt_1
	call 	WriteString
	call	ReadInt
	mov		input_1, eax
	
	mov		edx, OFFSET t_prompt_2
	call 	WriteString
	call	ReadInt
	mov		input_2, eax

	;check for div by 0
	cmp		eax, 0
	je		err
	
	;check for inversed sizes (2>1)
	mov		ebx, eax
	mov 	eax, input_1
	cmp		eax, ebx
	jl		err
	jmp		calc
	
err:
	
	mov		edx, OFFSET t_error_1
	call	WriteString
	call	CrLF
	jmp		top

	
;calculation: 

calc:

	;sum the two numbers, stored in eax
	mov		eax, input_1
	mov		ebx, input_2
	add		eax, ebx
	mov		sum, eax
	
	;difference of the two numbers, stored in eax
	mov		eax, input_1
	sub		eax, ebx ;=eax-ebx --> eax
	mov		diff, eax

	;product of the two numbers, stored in eax
	mov		eax, input_1
	imul	eax, ebx ;=eax*ebx --> eax
	mov		prod, eax
	
	;quot and rem of the two numbers, stored in eax
	cdq
	mov		eax, input_1
	div		ebx
	mov		quot, eax
	mov		rem, edx
	
	
;display

	mov 	ecx, OFFSET c_equals ;equals string will be stored here for easier mov's ;)

	;sum
	mov		eax, input_1
	call	WriteDec
	
	mov		edx, OFFSET c_plus
	call	WriteString
	
	mov		eax, ebx ;ebx still is input_2
	call	WriteDec
	
	mov		edx, ecx ;ecx is the string " = "
	call	WriteString
	
	mov		eax, sum
	call	WriteDec
	
	call	CrLF
	
	;diff
	mov		eax, input_1
	call	WriteDec
	
	mov		edx, OFFSET c_minus
	call	WriteString
	
	mov		eax, ebx ;ebx still is input_2
	call	WriteDec
	
	mov		edx, ecx ;ecx is the string " = "
	call	WriteString
	
	mov		eax, diff
	call	WriteDec
	
	call	CrLF
	
	;product
	mov		eax, input_1
	call	WriteDec
	
	mov		edx, OFFSET c_multiply
	call	WriteString
	
	mov		eax, ebx ;ebx still is input_2
	call	WriteDec
	
	mov		edx, ecx ;ecx is the string " = "
	call	WriteString
	
	mov		eax, prod
	call	WriteDec
	
	call	CrLF
	
	;quot and rem
	mov		eax, input_1
	call	WriteDec
	
	mov		edx, OFFSET c_divide
	call	WriteString
	
	mov		eax, ebx ;ebx still is input_2
	call	WriteDec
	
	mov		edx, ecx ;ecx is the string " = "
	call	WriteString
	
	mov		eax, quot
	call	WriteDec
	
	mov		edx, OFFSET c_remainder
	call	WriteString
	
	mov		eax, rem
	call 	WriteDec
	
	call	CrLF
	
;play again check
	
	mov		edx, OFFSET t_play_again
	call	WriteString
	call	ReadInt
	cmp		eax, 1
	je		top
	
;say goodbye

	mov		edx, OFFSET t_goodbye
	call	WriteString
	
	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
