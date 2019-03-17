TITLE CONNECT FOUR     (connect4.asm)

; Author: Lyell Read
; Course / Project ID: CS271/connect4           Start_Date:1/22/2019
; Description: Play the game connect 4 with a 7*7 grid. Either 2p or p vs cpu. Text based. Yeah. 

;OOB's : check if superfluous store to var when call to procs for check. Text color for play again. Range checking for cpu play (no max) and for player input

INCLUDE Irvine32.inc
.stack 4096


	;===============================
	;SET UP MACROS USED THROUGHOUT
	;===============================

mwritestring MACRO string
	push 	edx
	mov		edx, OFFSET string
	call	WriteString
	pop		edx
ENDM

mwritestringnewline MACRO string
	push 	edx
	mov		edx, OFFSET string
	call	WriteString
	call	CrLF
	pop		edx
ENDM

mwritecharpipe MACRO string
	push 	eax
	mov		al, '|'
	call	WriteChar
	pop		eax
ENDM

mwritecharspace MACRO string
	push 	eax
	mov		al, ' '
	call	WriteChar
	pop		eax
ENDM

mwincheck MACRO
	call	check_horizontal
	add		eax, edx
	call	check_vertical
	add		eax, edx
	call	check_diagonal_down
	add		eax, edx
	call	check_diagonal_up
	add		eax, edx
ENDM
	
	
msetval MACRO value, element, array_name
	push	esi
	push	eax
	mov		eax, value
	mov		esi, OFFSET array_name
	mov		[esi + (element * 2)], ax
	pop		eax
	pop		esi
ENDM

mwritedecfrom MACRO reg
	push 	eax
	mov		eax, reg
	call	WriteDec
	pop		eax
ENDM
	
	
	;===============================
	;          CONSTANTS
	;===============================
	
rows				EQU		7
cols				EQU		7
turns_to_cat		EQU		49 ;rows * cols; maybe there's a neater way?
grid_offset_side	EQU		16 ;the space in characters between the terminal left edge and the printout of the grid.
grid_offset_top		EQU		3 ;the space in characters between the top of the terminal and the top edge of the grid


	;===============================
	;         DATA SEGMENT
	;===============================

.data
	
;Text Segments
welcome_message				BYTE	"Welcome. ",0
player_count_prompt			BYTE	"Players (1 or 2):",0
cat_game_printout			BYTE	"You done did a cat game boi.",0
play_again_prompt			BYTE	"Play Again (1 or 0):",0
player_1					BYTE	"Player ",0
player_col_entry_2			BYTE	", please enter the col to play in:",0	
player_win_2				BYTE	" WON.",0

g_bar						BYTE	" +---+---+---+---+---+---+---+ ",0
g_numbers					BYTE	"   0   1   2   3   4   5   6",0

DBG_1						BYTE	"HORIZONTAL:",0
DBG_2						BYTE	"VERTICAL:",0
DBG_3						BYTE	"DIAGONAL-UP:",0
DBG_4						BYTE	"DIAGONAL-DOWN:",0
DBG_5						BYTE	"Value:",0
;Array Defenition
connect4_grid				WORD	49 DUP (0)
									
									
check_array					WORD	4 DUP(0)

.data?
;Variable Defenitions
get_row						WORD	?	;(0..6) will be used to store the row of a get call	
get_col						WORD	?	;(0..6) will be used to store the col of a get call
player_number				WORD	?	;(1|2) Measures who has just played
turns_played_total			WORD	?	;will increment with each turn, checking against turns_to_cat
computer_switch				WORD	?	;(0|1) Measures weather the player wants 2p or 1p respectively
winning_player				WORD	?	;(1|2) set by win_check alg.
player_col					WORD	?	;(0..6) Choice of where to play.


.code
main PROC
	
	top_main:

	;===============================================================
	;SET UP ALL VALUES TO ESSENTIALLY "RESET" THE GAME
	;=============================================================== note: add array blanking! 

	mwritestringnewline welcome_message ; welcome message
	mwritestring player_count_prompt ; Ask the user how many players they want (SET COMPUTER SWITCH)
	
	call	ReadInt ;User is expected to input 1 or 2. If 1 we want to set the computer switch, otherwise not.
	call	CrLF
	mov		computer_switch, 0
	cmp		eax, 2 ;if the user has chosen two player, jump to bottom
	je		computer_switch_no_change

	mov		computer_switch, 1
computer_switch_no_change:
	mov		player_number, 1;set the current player to 1 as p1 will start regardless of player mode...
	mov		turns_played_total, 1;set the total turns played to 1 as we are resetting the game
	mov		winning_player, 0;set the winner to 0
	
	;Zero the grid out (in case of play again)
	mov		ecx, 49
	mov		eax, 0
	mov		esi, OFFSET connect4_grid
	loop_main_top:
		mov		[esi],ax 
		add		esi, 2
		loop	loop_main_top	
	
	;===============================================================
	;LET THE GAME BEGIN! < < < < < < < < < < < < < < < < < < < < < < 
	;===============================================================	
	
	call	CrLF
	call	Waitmsg
	call	clrscr
	
top_turn:

	;print that griddy boi
	call	print_grid
	
	;if turns compeleted is the same as turns possible, call it a CAT GAME!
	cmp		turns_played_total, turns_to_cat
	je		cat_game
	
	;check if the player number is 1, and if so, send to play a player turn
	cmp		player_number, 1
	je		player_turn
	
	;we are either player 2 or CPU now, so check CPU flag

	cmp		computer_switch, 1
	je		computer_turn
	jmp		player_turn ;we are player 2.
	
		
computer_turn: ;NOTE: if CPU is playing, then player_num =2

	;===============================
	;        Computer Turn
	;===============================
	
	;play CPU turn lol
	mov		eax, 7; set rand high range
	call	RandomRange ; rand on 0..6
	mov		player_col, ax
	
	jmp		win_check_label
	
player_turn:

	;===============================
	;         Player Turn
	;===============================

	mov		dh, grid_offset_top + 17;total offset from top where this line is.
	mov		dl, grid_offset_side 
	
	call 	gotoXY
	call	clear_line; gotoxy has set the cursor to the line where this should print. Clear that line.
	
	mwritestring player_1
	mov		ax, player_number
	call	WriteDec
	mwritestring player_col_entry_2
	call	ReadDec
	mov		player_col, ax
	
	jmp		win_check_label
	
win_check_label:

	call	drop_to_bottom

	mov		eax, 0 ;eax is used by macro to keep track of wins
	mwincheck
	
	cmp		eax, 0
	jne		win_for_current_player
	
	;swap player_number to initiate the next turn..
	mov		ax, player_number
	cmp		eax, 1
	je		add_one
	dec		eax
	jmp		swap_done
	add_one:
	inc		eax
	swap_done:
	mov		player_number, ax
	
	inc		turns_played_total
	
	;jump back to top of turn "loop".
	jmp		top_turn
	
win_for_current_player:

	mov		edx, 0
	call	GotoXY
	
	mov		edx, white + (16* black)
	call	SetTextColor

	mwritestring player_1
	movzx	eax, player_number
	call	WriteDec
	mwritestringnewline player_win_2
	
	jmp play_again

cat_game:
	
	;print that a cat game is reached
	mwritestringnewline cat_game_printout

	jmp		play_again
	
	
play_again:

	;print play again message
	mwritestring play_again_prompt

	call	ReadInt
	call	CrLF
	cmp		eax, 1
	je		top_main
	jmp		hard_stop
	
	
	
hard_stop:
	
	exit	; exit to operating system
main ENDP

	;===============================
	;      H O R I Z O N T A L
	;===============================

;===============================================
check_horizontal PROC USES esi ecx ebx eax
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description:
;===============================================
	

	push	ebp
	mov		ebp, esp
	movzx	eax, player_number
	
	mov		ecx, 7 ;rows to visit
	row_loop_top:
	
		push	ecx
		mov		ebx, ecx
		mov		ecx, 4
		
		col_loop_top:
		
			dec		ebx ; row
			dec		ecx ; col

			;======================
			;mwritecharpipe
			;mwritedecfrom ebx
			;mwritedecfrom ecx
			
			call	load_horizontal
			call	check_for_win ;player in eax, results in edx
			cmp		edx, 0
			jne		return_horizontal_success ; assume the winner is the current player, as wincheck would have caught the other case
			
			;======================

			inc		ebx
			inc		ecx
			
			loop col_loop_top
			
		pop 	ecx
		loop	row_loop_top
	
	;no win case
	mov		ebx, 0
	jmp		return_horizontal
		
	return_horizontal_success:
		add		esp, 4 ;account for the unpopped ecx from nested loop breakout
		jmp		return_horizontal
		
	return_horizontal:
	pop		ebp
	ret

check_horizontal ENDP

;===============================================
load_horizontal PROC USES ebx ecx edx esi eax
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description: Loads the horizontal segment starting at ebx, edx into check_array.
;===============================================

	push	ebp
	mov		ebp, esp

	;ebx = row i.e. row 2
	;edx = col i.e. col 1
	
	mov		edx, ecx ; move the col into edx, so that ecx is free for loop
	mov		ecx, 4
	
	horizontal_load_loop_top:
		
		dec		ecx
		push	edx
		;3,2,1,0
		
		add		edx, ecx ; add 0,1,2,3 to column number
		
		mov		get_row, bx
		mov		get_col, dx
		
		call	get_value_at ; eax has value at r,c
		msetval	eax, ecx, check_array ; set_value in array check array to ^ at index ecx
		
		
		pop		edx
		inc		ecx
		loop horizontal_load_loop_top
		

	pop		ebp
	ret

load_horizontal ENDP

	;===============================
	;        V E R T I C A L
	;===============================

;===============================================
check_vertical PROC USES esi ecx ebx eax
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description:
;===============================================
	
	push	ebp
	mov		ebp, esp
	movzx	eax, player_number

	mov		ecx, 4 ;rows to visit
	row_loop_top:
	
		push	ecx
		mov		ebx, ecx
		mov		ecx, 7
		
		col_loop_top:
		
			dec		ebx
			dec		ecx

			;======================
			; mwritecharpipe
			; mwritedecfrom ebx
			; mwritedecfrom ecx
			
			call	load_vertical
			call	check_for_win ;player in eax, results in edx
			cmp		edx, 0
			jne		return_vertical_success ; assume the winner is the current player, as wincheck would have caught the other case
			;======================

			inc		ebx
			inc		ecx
			
			loop col_loop_top
			
		pop 	ecx
		loop	row_loop_top
	
	;no win case found. 
	mov		ebx, 0
	jmp		return_vertical
		
	return_vertical_success:
		add		esp, 4 ;account for the unpopped ecx from nested loop breakout
		jmp		return_vertical
		
	return_vertical:

	pop		ebp
	ret

check_vertical ENDP

;===============================================
load_vertical PROC USES ebx ecx edx esi eax
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description: Loads the horizontal segment starting at ebx, edx into check_array.
;===============================================

	push	ebp
	mov		ebp, esp

	;ebx = row i.e. row 2
	;edx = col i.e. col 1
	
	mov		edx, ecx ; move the col into edx, so that ecx is free for loop
	mov		ecx, 4
	
	vertical_load_loop_top:
		
		dec		ecx
		push	ebx ; store the row number to mem
		;3,2,1,0
		
		add		ebx, ecx ; add 0,1,2,3 to row number
		
		mov		get_row, bx
		mov		get_col, dx
		
		call	get_value_at ; eax has value at r,c
		msetval	eax, ecx, check_array ; set_value in array check array to ^ at index ecx
		
		
		pop		ebx
		inc		ecx
		loop vertical_load_loop_top
		

	pop		ebp
	ret

load_vertical ENDP

	;===============================
	;         D I A G - U P
	;===============================
	
;===============================================
check_diagonal_up PROC USES esi ecx ebx eax
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description:
;===============================================
	
	;needs to generate (3,0) -> (6,3) = (0+3, 0) -> (3+3, 3)

	push	ebp
	mov		ebp, esp
	movzx	eax, player_number
	
	mov		ecx, 4 ;rows to visit
	row_loop_top:
	
		push	ecx
		mov		ebx, ecx
		mov		ecx, 4
		
		col_loop_top:
	
			add		ebx, 2 ;row -1 +3 = +2
			dec		ecx ;col

			;======================
			; mwritecharpipe
			; mwritedecfrom ebx
			; mwritedecfrom ecx
			
			call	load_diagonal_up
			call	check_for_win ;player in eax, results in edx
			cmp		edx, 0
			jne		return_diagonal_up_success ; assume the winner is the current player, as wincheck would have caught the other case
						
			;======================

			sub		ebx, 2
			inc		ecx
			
			loop col_loop_top
			
		pop 	ecx
		loop	row_loop_top
	
	;no win case found. 
	mov		edx, 0
	jmp		return_diagonal_up
		
	return_diagonal_up_success:
		add		esp, 4 ;account for the unpopped ecx from nested loop breakout
		jmp		return_diagonal_up
		
	return_diagonal_up:

	pop		ebp
	ret

check_diagonal_up ENDP

;===============================================
load_diagonal_up PROC USES ebx ecx edx esi eax
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description: Loads the horizontal segment starting at ebx, edx into check_array.
;===============================================

	push	ebp
	mov		ebp, esp

	;ebx = row i.e. row 2
	;edx = col i.e. col 1
	
	mov		edx, ecx ; move the col into edx, so that ecx is free for loop
	mov		ecx, 4
	
	diagonal_up_load_loop_top:
		
		dec		ecx
		push	ebx ; store the row number to mem
		push	edx
		;ECX == 3,2,1,0
		
		sub		ebx, ecx ; add 0,1,2,3 to row number (3,0) -> (0,0)
		add		edx, ecx ; add 0,1,2,3 to col number (0,0) -> (0,3)
		
		mov		get_row, bx
		mov		get_col, dx
		
		call	get_value_at ; eax has value at r,c
		msetval	eax, ecx, check_array ; set_value in array check array to ^ at index ecx
		
		pop		edx
		pop		ebx
		inc		ecx
		loop diagonal_up_load_loop_top
		

	pop		ebp
	ret

load_diagonal_up ENDP

	;===============================
	;      D I A G - D O W N
	;===============================

;===============================================
check_diagonal_down PROC USES esi ecx ebx eax
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description:
;===============================================
	
	;(0,0) -> (3,3)

	push	ebp
	mov		ebp, esp
	movzx	eax, player_number
	
	mov		ecx, 4 ;rows to visit
	row_loop_top:
	
		push	ecx
		mov		ebx, ecx
		mov		ecx, 4
		
		col_loop_top:
		
			dec		ebx
			dec		ecx

			;======================

			; mwritecharpipe
			; mwritedecfrom ebx
			; mwritedecfrom ecx
			
			call	load_diagonal_down
			call	check_for_win ;player in eax, results in edx
			cmp		edx, 0
			jne		return_diagonal_down_success ; assume the winner is the current player, as wincheck would have caught the other case
			
			;======================

			inc		ebx
			inc		ecx
			
			loop col_loop_top
			
		pop 	ecx
		loop	row_loop_top
	
	;no win case found. 
	mov		edx, 0
	jmp		return_diagonal_down
		
	return_diagonal_down_success:
		add		esp, 4 ;account for the unpopped ecx from nested loop breakout
		jmp		return_diagonal_down
		
	return_diagonal_down:
	
	pop		ebp
	ret

check_diagonal_down ENDP

;===============================================
load_diagonal_down PROC USES ebx ecx edx esi eax
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description: Loads the horizontal segment starting at ebx, edx into check_array.
;===============================================

	push	ebp
	mov		ebp, esp

	;ebx = row i.e. row 2
	;edx = col i.e. col 1
	
	mov		edx, ecx ; move the col into edx, so that ecx is free for loop
	mov		ecx, 4
	
	diagonal_down_load_loop_top:
		
		dec		ecx
		push	ebx ; store the row number to mem
		push	edx
		;ECX == 3,2,1,0
		
		add		ebx, ecx ; add 0,1,2,3 to row number (0,0) -> (3,0)
		add		edx, ecx ; add 0,1,2,3 to col number (6,0) -> (6,3)
		
		mov		get_row, bx
		mov		get_col, dx
		
		call	get_value_at ; eax has value at r,c
		msetval	eax, ecx, check_array ; set_value in array check array to ^ at index ecx
		
		pop		edx
		pop		ebx
		inc		ecx
		loop diagonal_down_load_loop_top
		

	pop		ebp
	ret

load_diagonal_down ENDP

;===============================================
get_value_at PROC uses esi ebx ecx
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description:returns value in eax. Use variables to access
;===============================================

	push	ebp
	mov		ebp, esp

	mov		esi, OFFSET connect4_grid
	movzx	ebx, get_row ; ROW
	movzx	ecx, get_col ; COL
	
	;[esi + ((get_row * 7) + get_col)*2
	
	imul	ebx, 14
	imul 	ecx, 2
	
	add		ebx, ecx ; STO in ebx
	add		esi, ebx
	
	mov		eax, 0
	mov		ax, [esi]

	pop		ebp
	ret

get_value_at ENDP

;===============================================
check_for_win PROC USES esi ecx ebx
;
;Pre-Conditions:player in eax, result in edx
;Post-Conditions:
;Requires:
;Returns:
;Description:
;===============================================

	push	ebp
	mov		ebp, esp

	mov		ecx, 4
	
	check_loop_top:
		
		mov		esi, OFFSET check_array
		dec		ecx
		mov		ebx, ecx
		imul	ebx, 2
		add		esi, ebx

		cmp		[esi],ax ; check against the player number
		jne		failed
		
		inc		ecx
		loop check_loop_top
		
	mov		edx, eax ;set return value to be the player number
	jmp		check_proc_end
	
	failed:
	
		mov		edx, 0
		jmp		check_proc_end
	
	check_proc_end:
	pop		ebp
	ret

check_for_win ENDP

;===============================================
print_grid PROC USES eax ecx edx
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description:
;===============================================

	push	ebp
	mov		ebp, esp

	;call	Clrscr
	
	mov		dh, grid_offset_top
	mov		dl, grid_offset_side
	
	mov		esi, OFFSET connect4_grid
	mov		ecx, 7
	
	call	gotoXY
	
	mov		eax, blue + (16 * blue)
	call	SetTextColor
	
	mwritestring g_bar
	
	top_row:
		
		push	ecx
		mov		ecx, 7

		inc		dh ;move down one layer
		call	gotoXY
		
		mwritecharspace
		mwritecharpipe ; print pipe
		mwritecharspace ; print space
	
		top_col:
			
			mov		eax, 0
			mov		ax, [esi]
			
			;call	WriteDec ; for no colors :(
			call	print_value ; for colors:)
			
			mwritecharspace
			mwritecharpipe
			mwritecharspace
			
			add 	esi, 2 ;next element queued up
			
			loop 	top_col
				
		pop		ecx
		
		inc		dh ;move down one layer
		call	gotoXY
		mwritestring g_bar ; print a bar
		
		loop	top_row
	
	;Printing is done.
	
	mov		eax, green
	call	SetTextColor
	
	inc		dh ;move down one layer
	call	gotoXY
	mwritestring g_numbers
	
	mov		eax, white
	call	SetTextColor
	
	add		dh, 2
	
	mov		eax, 15
	call	SetTextColor
	
	pop		ebp
	ret

print_grid ENDP

;===============================================
clear_line PROC
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description:
;===============================================

	push	ebp
	mov		ebp, esp

	;mov		dh, grid_offset_top + 17
	;mov		dl, grid_offset_side
	
	mov		ecx, 65
	
	spaces_print_top:
	
		mwritecharspace
		
	
	loop 	spaces_print_top
	
	call	GotoXY
	
	pop		ebp
	ret

clear_line ENDP

;===============================================
drop_to_bottom PROC USES ecx eax ebx edx esi
;
;Pre-Conditions:
;Post-Conditions:
;Requires: that there is no value in the top element of that column
;Returns:
;Description:
;===============================================

	push	ebp
	mov		ebp, esp
	
	mov		esi, OFFSET connect4_grid
	mov		ecx, 6; set the counter to loop 6 times
	mov		ebx, 0; compare to this because cannot compare to literal
	
	movzx	eax, player_col ; i.e.e col 5
	imul	eax, 2 ; 5 --> 10
	add 	esi, eax
	
	mov		eax, esi ; move the pointer to the first element int eax.
	add		eax, 14 ;add 14 to eax to get the next element down the column.
	
	drop_to_bottom_loop_top:
	
		cmp 	[eax], bx ; check if the next value down is zero
		je		loop_again
		jmp		fill_esi 	
		
		loop_again:
		
		mov		esi, eax
		add		eax, 14
		loop	drop_to_bottom_loop_top
	
	
	fill_esi:
		movzx	ebx, player_number
		mov		[esi], bx
		jmp		fill_end
	
	
	fill_end:
	pop		ebp
	ret

drop_to_bottom ENDP

;===============================================
print_value PROC USES eax
;
;Pre-Conditions:
;Post-Conditions:
;Requires:
;Returns:
;Description:
;===============================================

	push	ebp
	mov		ebp, esp
	
	mov		ebx, eax
	
	call	GetTextColor
	push	eax; push original color
	
	cmp		ebx,1
	jl		black_color
	je		red_color
	jg		yellow_color
	
	black_color:
		
		mov		eax, black*16
		call	SetTextColor
		mwritecharspace
		jmp 	print_value_end
		
	red_color:
		
		mov		eax, red*16
		call	SetTextColor
		mwritecharspace
		jmp 	print_value_end
		
	yellow_color:
		
		mov		eax, yellow*16
		call	SetTextColor
		mwritecharspace
		jmp 	print_value_end
	
	print_value_end:
	
	pop		eax
	call	SetTextColor
	
	pop		ebp
	ret

print_value ENDP

END main
