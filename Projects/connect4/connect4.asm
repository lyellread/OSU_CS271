TITLE CONNECT FOUR     (connect4.asm)

; Author: Lyell Read
; Course / Project ID: CS271/connect4           Start_Date:1/22/2019
; Description: Play the game connect 4. x * y grid (user defined), either 2p or p vs cpu. Text based. Yeah. 

INCLUDE Irvine32.inc
	
rows				EQU		7
cols				EQU		7
turns_to_cat		EQU		7*7 ;rows * cols; maybe there's a neater way?
grid_offset_side	EQU		6 ;the space in characters between the terminal left edge and the printout of the grid.
grid_offset_top		EQU		2 ;the space in characters between the top of the terminal and the top edge of the grid
.data

;Text Segments
welcome_message				BYTE	"Welcome. ",0
player_count_prompt			BYTE	"Players (1 or 2):",0
cat_game_printout			BYTE	"You done did a cat game boi.",0
play_again_prompt			BYTE	"Play Again (1 or 0):",0

DBG_1						BYTE	"Reached Print_Grid Proc",0
DBG_2						BYTE	"Reached CPU turn",0
DBG_3						BYTE	"Reached PTURN with player=",0
DBG_4						BYTE	"Current Turn (## of ##)",0

;Variable Defenitions
player_number				WORD	?	;(1|2) Measures who has just played
turns_played_total			WORD	?	;will increment with each turn, checking against turns_to_cat
computer_switch				WORD	?	;(0|1) Measures weather the player wants 2p or 1p respectively
winning_player				WORD	?	;(1|2) set by win_check alg.

;Array Defenition
connect4_grid				WORD	turns_to_cat DUP(0)

.code
main PROC

top_main:

	;===============================================================
	;SET UP ALL VALUES TO ESSENTIALLY "RESET" THE GAME
	;=============================================================== note: add array blanking! 

	;Print out the Welcome Message for the user
	mov		edx, OFFSET welcome_message
	call	WriteString
	call	CrLF
	
	;Ask the user how many players they want (SET COMPUTER SWITCH)
	mov		edx, OFFSET player_count_prompt
	call	WriteString
	call	ReadInt ;User is expected to input 1 or 2. If 1 we want to set the computer switch, otherwise not.
	call	CrLF
	mov		computer_switch, 0
	cmp		eax, 2 ;if the user has chosen two player, jump to bottom
	je		computer_switch_no_change
	mov		computer_switch, 1
	computer_switch_no_change:
	
	;set the current player to 1 as p1 will start regardless of player mode...
	mov		player_number, 1
	
	;set the total turns played to 1 as we are resetting the game
	mov		turns_played_total, 1
	
	;set the winner to 0
	mov		winning_player, 0
	
	;===============================================================
	;LET THE GAME BEGIN!
	;===============================================================	
	
top_turn:

	;debug
	mov		edx, OFFSET DBG_4
	call	WriteString
	mov		ax, turns_played_total
	call	WriteInt
	mov		eax, turns_to_cat
	call	WriteInt
	call	CrLF


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
	
	;play CPU turn lol
	mov		edx, OFFSET DBG_2
	call	WriteString
	call	CrLF
	
	;drop to bottom of col
	jmp		win_check_label
	
player_turn:
	
	;player turn
	;DEBUG:

	mov		edx, OFFSET DBG_3
	call	WriteString
	mov		ax, player_number
	call	WriteInt
	call	Crlf
	
	jmp		win_check_label
	
win_check_label:

	;call win_check_alg

	;check for win: using 
	;	cmp winning_player, player_number
	;	je	print_win_statement
	
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
	
	
cat_game:
	
	;print that a cat game is reached
	mov		edx, OFFSET cat_game_printout
	call	WriteString
	call	CrLF
	jmp		play_again
	
	
play_again:

	;print play again message
	mov		edx, OFFSET play_again_prompt
	call	WriteString
	call	ReadInt
	call	CrLF
	cmp		eax, 1
	je		top_main
	jmp		hard_stop
	
	
	
hard_stop:
	
	exit	; exit to operating system
main ENDP

;--------------------------------------------------------------------
print_grid PROC USES eax edx ecx ebx
;	
;	Prints out the Connect 4 Grid on the display. 
;	Recieves:
;	Returns:
;	Requires:
;--------------------------------------------------------------------
	;DEBUG:
	mov		edx, OFFSET DBG_1
	call	WriteString
	
	;clear the screen to make way for the BEAUTIFUL grid to appear
	call			WaitMsg
	call		ClrScr
	;mov		edx, 0
	;call		GotoXY

	;print the dashed lines (basically nested for)
	mov		ecx, rows ;ecx = 7
	mov		eax, 0 ;zero that register.
	mov		al, '-'
	mov		ah, ((rows*2)+1) ;two underscores per row, plus one to start	
	dashed_line:
		
		;move the cursor to the right place....
		mov		dl, grid_offset_side ;x coordinate
		mov		ebx, ecx
		imul	ebx, 2
		add		ebx, grid_offset_top
		mov		dh, bl
		;mov	dh, ((ecx*2)+grid_offset_top)
		call	GotoXY ;move the cursor
		
		;print out the appropriate bar for that spot
		call	print_char_n_times
		loop	dashed_line
		
	
	
	ret
print_grid ENDP
	
	
;--------------------------------------------------------------------
print_char_n_times PROC USES eax ecx
;	
;	Prints out the character passed in al, ah times.
;	Recieves:
;	Returns:
;	Requires:
;--------------------------------------------------------------------
	;DEBUG:
	
	movzx	ecx, ah
	print_char_top:
		call	WriteChar
		loop	print_char_top
	
	ret
print_char_n_times ENDP
END main
