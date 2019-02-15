TITLE Project 4     (project4.asm)

; Author: Lyell Read
; Course / Project ID: CS271/Project_4                Date:2/13/2019
;
; Loops, Nested Loops and Processes (much wow). This program calculates 
;	and displays all the composite numbers up to n on [1..400] input by 
;	the user.

INCLUDE Irvine32.inc

INPUT_MIN		equ		1
INPUT_MAX		equ		400
NAME_LEN_MAX	equ		80

.data

t_header		BYTE	"			Assignment 4 (program4.asm) -- Lyell Read",0
t_extra_credit	BYTE	"**EC: Aligned Printout",0

t_instructions	BYTE	"You will be prompted for numbers on the range [1..400]. The program will then output all composite numbers up to that number.",0
t_prompt_name	BYTE	"What is your name :",0
t_prompt_n_1	BYTE	"Hello, ",0

t_prompt_n_2	BYTE	". Please enter a number on [1..400] :",0
t_input_error	BYTE	"That was invalid!",0

t_goodbye_1		BYTE	"Bye, ",0
t_goodbye_2		BYTE	". Have a nice day!",0

user_name		BYTE	NAME_LEN_MAX+1 DUP (?)	;will be used to store user name

.data?

user_input		DWORD	? ;will be populated with the user's input when available.

.code
main PROC

program_top:

	call	introduction
	
	call	get_user_data ; calls validate subproc
	
	call	show_composites ; calls is_composite subproc
	
	call	farewell
	
	exit	; exit to operating system
	
main ENDP


	

;===============================================
introduction PROC USES edx ecx
;
;Pre: Nothing
;Post: Insttructions and header printed.
;Requires:text variables declared globally
;Returns:nothing
;Description: prints header, sets user name, and prints instruction and ec.
;===============================================
	
;print the 'header' AKA name and title and extra credit

	mov 	edx, OFFSET t_header
	call	WriteString
	call	CrLF
	mov		edx, OFFSET	t_extra_credit
	call	WriteString
	call	CrLF
	call	CrLF

	
;print the instruction text

	mov 	edx, OFFSET t_instructions
	call	WriteString
	call	CrLF
	call	CrLF


;Get the user's name.

	mov		edx, OFFSET t_prompt_name
	call 	WriteString
	
	mov		edx, OFFSET user_name
	mov		ecx, NAME_LEN_MAX
	call	ReadString ;Reads into buffer pointed to by edx, and up to len ecx. 

	ret
	
introduction ENDP




;===============================================
validate PROC
;
;Pre: input is passed in eax
;Post:if in range is returned ebx
;Requires:get_user_data to provide input in eax.
;Returns:user input, stored in user_input.
;Description:checking in range/
;===============================================

	cmp		eax, INPUT_MIN
	jl		error_message
	cmp		eax, INPUT_MAX
	jg		error_message
	;now that input is checked for range, add the input to the current value of current_sum
	mov		user_input, eax
	mov		ebx, 0 ; no errors. Good to go.
	ret
		
	error_message: ;prints error message, then returns to top of input section

		mov		edx, OFFSET t_input_error
		call	WriteString
		call	CrLF
		mov		ebx, 1; errors raised.
		ret

validate ENDP




;===============================================
get_user_data PROC USES edx
;
;Pre: Instructions printed
;Post: User data is in and in range.
;Requires:many defined vars and text vars. 
;Returns:user input, stored in user_input.
;Description:does user input and mangement thereof.
;===============================================
		
		;prompt the user personally to enter a number
	
	mov		ebx, 0
	
	top_user_entry:
		
		mov		edx, OFFSET t_prompt_n_1
		call	WriteString
		mov		edx, OFFSET	user_name
		call	WriteString
		mov		edx, OFFSET t_prompt_n_2
		call 	WriteString
		call	ReadInt ;read choice into EAX
		
		call	validate ;check input, returns 1 or 0 in ebx;
		
		cmp 	ebx, 1
		je		top_user_entry
				
		ret

get_user_data ENDP


;===============================================
is_composite PROC USES ebx ecx edx
;
;Pre: number in question is passed in in ebx
;Post: result (1|0) returned in eax.
;Requires:Number to check in ebx.
;Returns:eax = 1 if it is a composite, eax = 0 if it is not.
;Description:Checks if a number is a composite by dividing it by all 
;	numbers [assume checking n] on (n-1..2). If any of these return 0 
;	remainder, then the base is composite, and return 1.
;===============================================

	;EBX = BASE
	;ECX = DIVBY

	mov		ecx, ebx ; ECX = EBX
	dec		ecx ; first divisor value.
	
	check_top:
			
		;check if we are at low bound for ecx
		cmp 	ecx, 2
		jl		return_negative ;we've gone past 2 as a divby, so the number is not composite
		
		;do the division
		cdq
		mov		eax, ebx
		div		ecx
		
		cmp 	edx, 0
		je 		return_positive
		
		dec		ecx
		jmp 	check_top
		;cmp outcome 

	return_negative:
			
		mov		eax, 0
		ret
		
	return_positive:
	
		mov		eax, 1
		ret
	
is_composite ENDP


;===============================================
show_composites PROC
;
;Pre:Insttructions and the User input is complete
;Post: numbers printed. Ready to quit.
;Requires:high range is defined, as well as is_composite to be def'd
;Returns:nothing
;Description:prints all composites on 1..user_input in lines of 10 values apiece.
;===============================================

	
	;EAX = Printout Storage Line Count
	;EBX = Pass Value for is_composite
	;ECX = Counter
	;EDX = Line Count
	
	mov		ecx, user_input 
	mov		edx, 0
	mov		ebx, 3 ;first composite
	mov		eax, 0
	
	top:
		
		inc		ebx
		
		in_loop_top:
			
			call	is_composite
						
			cmp		eax, 1 ;checks that the result of is_composite is T
			je		found_composite
			
			;if we have not found a composite, increment base, and try again:
			inc		ebx
			jmp in_loop_top
			
		found_composite:
			
			cmp		edx, 9 ;check if 10 things have been printed on current line:
			jle		no_newline_needed
			
			call	CrLF
			mov		edx, 0;reset per line ct
			
			no_newline_needed:
		
			mov		eax, ebx ;prepare for print
			call	WriteDec;print
			inc		edx ;we just printed a value
			
			mov		al, 9
			call	WriteChar;print tab (ASCII 9)
			
			loop top

	ret
	
show_composites ENDP


;===============================================
farewell PROC
;
;Pre: Program complete
;Post: Farewell message printed.
;Requires:Test segments defined
;Returns:Nothing
;Description:Says bye then ends the program.
;===============================================

	call	CrLF
	mov		edx, OFFSET t_goodbye_1
	call	WriteString
	mov		edx, OFFSET	user_name
	call	WriteString
	mov		edx, OFFSET t_goodbye_2
	call	WriteString

	ret
	
farewell ENDP

END main
