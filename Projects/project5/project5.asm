TITLE Project 5     (project5.asm)

; Author: Lyell Read
; Course / Project ID: CS271/Project_5               Date:2/19/2019
;
; Generate a n long array. fill that array with random numbers. sort that array. print it out.

INCLUDE Irvine32.inc
.stack 8192

	INPUT_MIN		equ		10
	INPUT_MAX		equ		200

	RANDOM_MIN		equ		100
	RANDOM_MAX		equ		999

	NAME_LEN_MAX	equ		80

.data
	t_header		BYTE	"			Assignment 5 (program5.asm) -- Lyell Read",0

	t_instructions	BYTE	"You will be prompted for a number on [10..200]. I will fill an array of that length with random numbers, sort it and print it out.",0
	t_prompt_name	BYTE	"What is your name :",0
	t_prompt_n_1	BYTE	"Hello, ",0

	t_prompt_n_2	BYTE	". Please enter a number on [10..200] :",0
	t_input_error	BYTE	"That was invalid!",0

	t_unsorted_arr	BYTE	"Unsorted Array:",0
	t_sorted_array	BYTE	"Sorted Array:",0
	t_median		BYTE	"Median of Array:",0

	t_goodbye_1		BYTE	"Bye, ",0
	t_goodbye_2		BYTE	". Have a nice day!",0


.data?

	user_name		BYTE	NAME_LEN_MAX+1 DUP (?)	;will be used to store user name
	array			WORD	200 DUP (?) ;this is our array.
	request			DWORD	? ;will be populated with the user's input when available.

.code
main PROC

	push	OFFSET user_name
	push	OFFSET t_prompt_name
	push	OFFSET t_instructions
	push	OFFSET t_header
	call	introduction
	
	push	OFFSET request
	push	OFFSET t_input_error
	push	OFFSET t_prompt_n_2
	push 	OFFSET user_name
	push	OFFSET t_prompt_n_1
	call	get_user_data
	

	push	request
	push	OFFSET array
	call	fill_array
	
	push	OFFSET t_unsorted_arr
	push	request
	push	OFFSET array
	call	print_array
	
	call	sort_array
	
	push	OFFSET t_sorted_array
	push	request
	push	OFFSET array
	call	print_array
	
	push	request
	push	OFFSET array
	push	OFFSET t_median
	call	show_median
	
	push	OFFSET t_goodbye_2
	push	OFFSET user_name
	push	OFFSET t_goodbye_1
	call	farewell
	
	exit	; exit to operating system
	
main ENDP




;===============================================
introduction PROC
;
;Pre: Text offsets pushed to stack.
;Post: Insttructions and header printed.
;Requires:text variables declared globally
;Returns:nothing
;Description: prints header, sets user name, and prints instruction and ec.
;===============================================
	
	push	ebp
	mov		ebp, esp
	
;print the 'header' AKA name and title and extra credit

	mov 	edx, [ebp + 8]
	call	WriteString
	call	CrLF
	call	CrLF

	
;print the instruction text

	mov 	edx, [ebp + 12]
	call	WriteString
	call	CrLF
	call	CrLF


;Get the user's name.

	mov		edx, [ebp + 16]
	call 	WriteString

	mov		edx, [ebp + 20]
	mov		ecx, NAME_LEN_MAX
	call	ReadString ;Reads into buffer pointed to by edx, and up to len ecx. 

	pop		ebp
	ret
	
introduction ENDP




;===============================================
validate PROC
;
;Pre: on stack is the input.
;Post: 1 or 0 returned on stack (1 == Good Input; 0 == ERROR)
;Requires:get_user_data to provide input on stack
;Returns: flag to user_input.
;Description:checking in range
;===============================================

	push	ebp
	mov		ebp, esp
	
	mov		eax, [ebp + 12];'pop' the user input
	cmp		eax, INPUT_MIN
	jl		error_message
	cmp		eax, INPUT_MAX
	jg		error_message
	
	push	1;return a BAD user input flag
	add		esp, 4
	
	pop		ebp;pop base pointer before pushing return value
	ret
	
		
	error_message: ;prints error message, then returns to top of input section
	
		mov		edx, [ebp + 8];move the offset to the text into edx
		call	WriteString
		call	CrLF
		call	CrLF
		
		push	0;return a BAD user input flag
		add		esp, 4;decrease esp one more...
		
		pop		ebp;pop base pointer
		ret
		

validate ENDP




;===============================================
get_user_data PROC
;
;Pre: Instructions printed
;Post: User data is returned on stack, after being validated.
;Requires:pointers to text on stack. 
;Returns:user input on stack
;Description:does user input and mangement thereof.
;===============================================
		
	;prompt the user personally to enter a number
	
	push	ebp
	mov		ebp, esp
	
	mov		ebx, 0
	
	top_user_entry:
		
		;do printout
		mov		edx, [ebp + 8];retrieve that first text string offset
		call	WriteString
		mov		edx, [ebp + 12];get that next text string offset (name)
		call	WriteString
		mov		edx, [ebp + 16];retrieve last text string offset
		call 	WriteString
		
		mov		ecx, [ebp + 24];store the offset to request in ecx
		
		call	ReadInt ;read choice into EAX
		mov		[ecx], eax;save in ecx which points to the mem loc of request				

		cmp		eax, INPUT_MIN
		jl		error_message
		cmp		eax, INPUT_MAX
		jg		error_message
		jmp		continue
		
		error_message: ;prints error message, then returns to top of input section
		
			mov		edx, [ebp + 20];move the offset to the text into edx
			call	WriteString
			call	CrLF
			call	CrLF
			
			jmp top_user_entry

	continue:
		call	CrLF
		
		pop		ebp
		ret

get_user_data ENDP




;===============================================
fill_array PROC
;
;Pre: array empty
;Post: array populated
;Requires:number of elements and pointer to array stored on stack.
;Returns:nothing. 
;Description:fills the array with request random numbers.
;===============================================

	push	ebp
	mov		ebp, esp
	
	mov		ebx, [ebp + 8] ; ptr to the array to be filled.
	mov		ecx, [ebp + 12] ; len(array)
	
	call	Randomize
	
	fill_loop_top:
		
		dec		ecx ;///////////temp decrement
		
		mov		edx, ecx ; i.e. 7
		imul	edx, 2 ;7--> 14
		add		edx, ebx ;generate effective address [OFFSET + <Word Size * element>]
		
		mov		eax, 899 ; set upper bound
		call	RandomRange
		add		ax, 100 ; adjust range interval...
		
		mov		[edx], ax ; store that value

		inc		ecx;///////////undo temp decrement;
		
	loop fill_loop_top
	
	pop 	ebp
	ret
	
fill_array ENDP



;===============================================
print_array PROC
;
;Pre: array filled
;Post: array printed to screen in a * X 10 table.
;Requires:number of elements and pointer to array stored on stack.
;Returns:nothing. 
;Description:prints the array.
;===============================================

	

	push	ebp
	mov		ebp, esp
			
	mov		ebx, [ebp + 8] ; ptr to the array to be printed.
	mov		ecx, [ebp + 12] ; len(array)
	
	mov		edx, [ebp + 16]
	call	CrLF
	call	WriteString ; print title.
	call	CrLF
	
	mov		edx, 0; line counter
	
	push	ecx ; pop will result in the len popped
	
	print_top:
		
		mov		eax, [esp] ;set eax to the lentgth of the array.
		sub		eax, ecx ; <len> - <current_ecx> == offset from start -->eax
				
		imul	eax, 2 ;
		add		eax, ebx ;generate effective address [OFFSET + <Word Size * element>]
		
		push	edx
		
		mov		edx, 0
		mov		dx, [eax]
		mov		eax, edx
		
		call	WriteDec
		mov		eax, 9
		call	WriteChar;print tab (ASCII 9)
		
		pop 	edx
		
		inc		edx; increment line counter
		cmp		edx, 10
		je		add_newline
		jmp		no_newline
		
		add_newline:
			
			call	CrLF
			mov		edx, 0
			
		no_newline:
				
	loop print_top	
		
	add		esp, 4 ; adjust for unaccounted pushes
	call	CrLF
	
	pop 	ebp
	ret
		
	
print_array ENDP



;===============================================
sort_array PROC
;
;Pre: array filled and printed
;Post: array sorted in increasing order
;Requires:number of elements and pointer to array stored on stack.
;Returns:nothing. 
;Description:sorts the array.
;===============================================

	push	ebp
	mov		ebp, esp
	
	call	CrLF
	call	CrLF
	
	mov		ebx, [ebp + 8] ; ptr to the array to be printed.
	mov		ecx, [ebp + 12] ; len(array) EX == 17
	
	dec		ecx; -> 16
	push 	ecx; push len-1; push 16

	inc 	ecx; set ecx to be len -> 17
	
	outer_iterator_top:

		push 	ecx ;store this counter
		mov		ecx, [esp + 4]; i.e. 16
		
		inner_iterator_top:
			
			mov		edx, [esp + 4] ; edx == len-1 // i.e. 16
			sub		edx, ecx ; = <len-1> - <counter> should yield 0..len-2>
	
			
			push 	ecx
			
			mov		eax, ecx	;set eax to []		
			imul	eax, 2		;mult by 2
			add		eax, ebx	;generate base address...
			
			mov		edx, eax	;cpoy base address to edx
			sub		edx, 2		;sub two from base addr
			
			mov		ecx, 0		;zero out ecx
			mov		cx, [eax]	;move val1 into cx
			mov		eax, 0
			mov		eax, ecx	;move val1 into eax
			
			mov		cx, [edx]	;move val2 into cx
			mov		edx, 0		;zero edx
			mov		edx, ecx	;move val2 into edx
			
			
			mov		ecx, [esp]
			
			
			cmp 	eax,edx
			jle		no_swap

			mov		eax, ecx	;set eax to []		
			imul	eax, 2		;mult by 2
			add		eax, ebx	;generate base address...
			
			mov		edx, eax	;copy base address to edx
			sub		edx, 2		;sub two from base addr
			
			push	eax
			push	edx
			;push	ebx
			
			call	swap
			
			add		esp, 8
			
			no_swap:
			
			pop		ecx
			
		loop inner_iterator_top
		
		pop 	ecx
		
	loop outer_iterator_top
	
	add		esp, 4
	pop		ebp
	ret
	
sort_array ENDP




;===============================================
swap PROC USES eax ebx ecx edx
;
;Pre: array unsorted
;Post: array sorted in increasing order
;Requires:element 1 element 2 ptr to array
;Returns:nothing. 
;Description:sorts the array.
;===============================================

	push	ebp
	mov		ebp, esp
	
	;pushad
	
	mov		eax, [ebp + 24];var1
	mov		edx, [ebp + 28];var2
	
	mov		ecx, 0
	mov		cx, [eax]
	
	mov		ebx, 0
	mov		bx, [edx]
	mov		[eax], bx
	
	mov		[edx], cx
	
	;popad
	pop		ebp
	ret
	
swap ENDP




;===============================================
show_median PROC
;
;Pre: array sorted printed
;Post: median printed
;Requires:Text segments passed on stack
;Returns:Nothing
;Description:prints median.
;===============================================

	push 	ebp
	mov		ebp, esp

	mov		edx, [ebp + 8]
	call	CrLF
	call	CrLF
	call 	WriteString
	
	mov		ebx, [ebp + 12]; this is the ptr to the array
	
	mov		edx, 0
	cdq
	
	mov		eax, [ebp + 16] ; len_array
	mov		ecx, 2
	div		ecx; len/2
	
	cmp 	edx, 0
	jne		odd_number
	
	;even number
	
		;need to avg eax, eax-1
		imul 	eax, 2
		add		eax, ebx
		mov		ebx, 0
		mov		bx, [eax]
		mov		ecx, 0
		mov		cx, [eax - 2]
		add		bx, cx
		
		cwd		;ax:...
		mov		eax, 0
		mov		edx, 0
		mov		ax, bx
		
		mov		cx, 2
		div		cx
		call	WriteDec
		jmp done
		
	
	odd_number:
	
		imul	eax, 2
		add		ebx, eax
		mov		eax, 0
		mov		ax, [ebx]
		call 	WriteDec
	
	done:
	
	call	CrLF
	call	CrLF
	
	pop		ebp
	ret
	
show_median ENDP




;===============================================
farewell PROC
;
;Pre: Program complete
;Post: Farewell message printed.
;Requires:Text segments defined and on stack
;Returns:Nothing
;Description:Says bye then ends the program.
;===============================================

	push 	ebp
	mov		ebp, esp

	call	CrLF
	call	CrLF
	mov		edx, [ebp + 8]
	call	WriteString
	mov		edx, [ebp + 12]
	call	WriteString
	mov		edx, [ebp + 16]
	call	WriteString
	call	CrLF
	
	pop		ebp
	ret
	
farewell ENDP



END main
