TITLE CONNECT FOUR     (connect4.asm)

; Author: Lyell Read
; Course / Project ID: CS271/connect4           Start_Date:1/22/2019
; Description: Play the game connect 4. x * y grid (user defined), either 2p or p vs cpu. Text based. Yeah. 

INCLUDE Irvine32.inc

;constants
x	equ		2
y 	equ		4

z	equ		x * y
;   _ _ _
;  |_|_|_| >x
;  |_|_|_||
;  `--v--'
;     y 


.data

;variables
arr		WORD	8 DUP(4)
yote	WORD	?
stote	WORD	?

.code
main PROC

  ;the code
	mov		eax, z
	call	WriteDec

	mov		yote, 1
	mov		stote, 2
	
	;mov		cx, [arr+(2*(yote*y + stote))]
	mov		ax, cx
	
	call	WriteDec
  
	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
