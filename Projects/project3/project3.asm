TITLE Project 3     (project3.asm)

; Author: Lyell Read
; Course / Project ID: CS271/Project_3                Date:1/24/2019
; Average calculator for practice with input checking and iteration as well as descision making

INCLUDE Irvine32.inc

INPUT_MIN		equ		-100
INPUT_MAX		equ		-1
NAME_LEN_MAX	equ		80

.data

t_header		BYTE	"			Assignment 3 (program3.asm) -- Lyell Read",0
t_extra_credit	BYTE	"**EC: Line Numbers",0
t_instructions	BYTE	"You will be continually prompted for numbers on the range -100..-1, until you enter a number >0. The program will then output the average.",0
t_prompt_name	BYTE	"What is your name :",0
t_line_number_1	BYTE	"[Line:",0
t_line_number_2	BYTE	"]: ",0
t_prompt_n_1	BYTE	"Hello, ",0
t_prompt_n_2	BYTE	". Please enter a number on [-100..-1] :",0
t_input_error	BYTE	"That was invalid!",0
t_result_qty	BYTE	"You entered this many numbers: ",0
t_result_sum	BYTE	"The sum of all those numbers is: ",0
t_result_div	BYTE	"The average of the numbers provided was: ",0
t_goodbye_1		BYTE	"Bye, ",0
t_goodbye_2		BYTE	". Have a nice day!",0

user_name		BYTE	NAME_LEN_MAX+1 DUP (?)	;will be used to store user name

current_sum			SDWORD	0 ;that thicc signed doubleword lol
number_count	DWORD	0

.code
main PROC


;introduction: print header
	
	;print the 'header' AKA name and title and extra credit
	mov 	edx, OFFSET t_header
	call	WriteString
	call	CrLF
	mov		edx, OFFSET	t_extra_credit
	call	WriteString
	call	CrLF
	call	CrLF

	
;userInstructions: print instructions
	
	;print the instruction text
	mov 	edx, OFFSET t_instructions
	call	WriteString
	call	CrLF
	call	CrLF


;getUserData: Get the user's name.

	mov		edx, OFFSET t_prompt_name
	call 	WriteString
	
	mov		edx, OFFSET user_name
	mov		ecx, NAME_LEN_MAX
	call	ReadString ;Reads into buffer pointed to by edx, and up to len ecx. 
	
	
user_data_top: ;ask the user for a number, and if out of range, reprompt
	
	;print line number
	
	mov		edx, OFFSET t_line_number_1
	call	WriteString	
	mov		eax, number_count
	call	WriteDec
	mov		edx, OFFSET t_line_number_2
	call	WriteString
	
	;prompt the user personally to enter a number
	mov		edx, OFFSET t_prompt_n_1
	call	WriteString
	mov		edx, OFFSET	user_name
	call	WriteString
	mov		edx, OFFSET t_prompt_n_2
	call 	WriteString
	
	call	ReadInt ;read choice into EAX
	
	cmp		eax, INPUT_MIN
	jl		error_message
	cmp		eax, INPUT_MAX
	jg		calculate_exit
	
	;now that input is checked for range, add the input to the current value of current_sum
	mov		ebx, eax ;move users value to the ebx register to prep for addition
	mov		eax, current_sum ;move current val into eax register
	add 	eax, ebx
	mov		current_sum, eax ;current_sum should contain current sum.
	
	;also need to increment number_count
	inc 	number_count
	
	;jump to start again yeet
	jmp		user_data_top
	
	
error_message: ;prints error message, then returns to top of input section

	mov		edx, OFFSET t_input_error
	call	WriteString
	call	CrLF
	jmp		user_data_top


calculate_exit:
	
	;print number of numbers
	mov		edx, OFFSET t_result_qty
	call 	WriteString
	mov		eax, number_count
	call	WriteDec
	call	CrLF
	
	;print sum of numbers
	mov		edx, OFFSET t_result_sum
	call	WriteString
	mov		eax, current_sum
	call	WriteInt
	call	CrLF
	
	;do division, print it out
	mov		eax, number_count
	cmp		eax, 0
	je		farewell ;otherwise would end up with a div-by-0 case. 
	
	cdq
	
	mov		eax, current_sum
	mov		ebx, number_count
	
	neg		eax
	div		ebx ;returns result across eax:edx
	neg		eax
	mov		edx, OFFSET t_result_div ;that overwrites the rem.. but since were doing int div, its all gud
	call	WriteString
	call 	WriteInt
	
	
	
farewell: ; says goodbye to the user personally.
	
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
