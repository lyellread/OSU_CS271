TITLE Project 2     (project2.asm)

; Author: Lyell Read
; Course / Project ID: CS271/Project_2                Date:1/20/2019
; Description:Iterative fibonacci with loops. 

INCLUDE Irvine32.inc

FIB_MAX_N		equ	46
FIB_MIN_N		equ 1
NAME_LEN_MAX	equ	25

.data

t_header		BYTE	"			Assignment 2 (program2.asm) -- Lyell Read",0
t_instructions	BYTE	"You will be prompted for a number, n, on 1..46 and I will print out the fibonacci numbers from fib(0) to fib(n).",0
t_prompt_name	BYTE	"What is your name :",0
t_prompt_n_1	BYTE	"Hello, ",0
t_prompt_n_2	BYTE	". Please enter a number on [1..46] :",0
t_input_error	BYTE	"That was invalid!",0
t_blank_space	BYTE	"        ",0
t_goodbye_1		BYTE	"Bye, ",0
t_goodbye_2		BYTE	". Have a nice day!",0

user_name		BYTE	NAME_LEN_MAX+1 DUP (?)	;will be used to store user name
user_n			SDWORD	?	;will be used to store the user's max choice

newline_counter	DWORD	0	;will be used to determine when a newline is needed.
fib_1			DWORD	1
fib_2			DWORD	1

.code
main PROC


;introduction: print header
	
	;print the 'header' AKA name and title and extra credit
	mov 	edx, OFFSET t_header
	call	WriteString
	call	CrLF
	call	CrLF

	
;userInstructions: print instructions
	
	;print the instruction text
	mov 	edx, OFFSET t_instructions
	call	WriteString
	call	CrLF
	call	CrLF


;getUserData: gets all data needed from the user (n and name). Implements error checking loop (post test).

	mov		edx, OFFSET t_prompt_name
	call 	WriteString
	
	mov		edx, OFFSET user_name
	mov		ecx, NAME_LEN_MAX
	call	ReadString ;Reads into buffer pointed to by edx, and up to len ecx. 
	

user_data_top:
	
	mov		edx, OFFSET t_prompt_n_1
	call	WriteString
	mov		edx, OFFSET	user_name
	call	WriteString
	mov		edx, OFFSET t_prompt_n_2
	call 	WriteString
	
	call	ReadInt
	mov		user_n, eax
	
	cmp		eax, FIB_MAX_N
	jg		error_message
	cmp		eax, FIB_MIN_N
	jl		error_message
	jmp		program_start
	
error_message:

	mov		edx, OFFSET t_input_error
	call	WriteString
	call	CrLF
	jmp		user_data_top


;displayFibs: prints the fib numbers as well as managing the 5 per line with a counter. Uses the [super cool] xadd opcode :)

program_start:

	call	CrLF
	call	CrLF

	mov		edx, OFFSET t_blank_space ;this will be here throughout for easy use :)

	mov		newline_counter, 0 ;simulate having printed the first two values...
	mov		eax, fib_1
	call	WriteDec
	call	WriteString

	mov		ecx, user_n
	dec		ecx; this could decrement to 0, so a check is needed to prevent runaway (overflow) loop

	cmp		ecx, 0
	je		farewell	

loop_start: ;on first round, output is already "1    "
	
	mov		eax, fib_1 ;i.e. eax now has 1
	mov		ebx, fib_2 ;i.e. ebs now has 2
	
	;xchg	eax, ebx ;shift so that eax has 2 and ebx 1
	;add		ebx, eax ;adds eax to ebs -> ebx which is f2. i.e. eax 2, ebx 3.
	
	xadd		eax, ebx  ;[eax,ebx = 1,2] --> [ebx,eax+ebx = 2,3]
	
	
	
	mov 	fib_1, eax ;update fib1 with value (2) [was 1]
	mov		fib_2, ebx ;update fib2 with value (3) [was 2]
	
	inc 	newline_counter
	cmp		newline_counter, 5 ; if this counter is at 5, call a newline and reset it (newline)
	je		newline
	jmp		continue ; else continue
	
	newline:
		
		call 	CrLF ;newline
		mov		newline_counter, 0 ; zero that variable
		
	continue:
		
		mov		eax, ebx ;mov the higher fib into eax, so it can be printed
		call	WriteDec
		call	WriteString ;blank space
		loop	loop_start ;reset loop, decrementing ecx.

	call	CrLF
	call	CrLF

farewell: ;Says goodbye to the user personally.
	
	call	CrLF
	mov		edx, OFFSET t_goodbye_1
	call	WriteString
	mov		edx, OFFSET	user_name
	call	WriteString
	mov		edx, OFFSET t_goodbye_2
	call	WriteString
	
	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
