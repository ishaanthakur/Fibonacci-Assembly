		AREA Myprog, CODE, READONLY
		ENTRY
		EXPORT __main
			
;don't change these addresses!
PCR22 	  EQU 0x4004A058 ;PORTB_PCR22  address
SCGC5 	  EQU 0x40048038 ;SIM_SCGC5    address
PDDR 	  EQU 0x400FF054 ;GPIOB_PDDR   address
PCOR 	  EQU 0x400FF048 ;GPIOB_PCOR   address
PSOR      EQU 0x400FF044 ;GPIOB_PSOR   address

ten		  EQU 0x00000400 ; 1 << 10
eight     EQU 0x00000100 ; 1 << 8
twentytwo EQU 0x00400000 ; 1 << 22

__main
	
		MOV   R3, #9
		MOV   R7, #19
		MOV   R1, #0xbeef
		BL    LEDSETUP
		BL    LEDON
		BL    LEDOFF
		
		MOV   R0, #6		; user input: change this! <----
		CMP   R0, #6		; input=6 --> output 8 --> dash dash dash dot dot
		BGT	  label
		BL    fib_setup
		B     forever
label	BL    fib
		BL	  fib_6
		B     forever

	; test cases
		MOV	  R0, #4		; input=4 --> output 3 --> dot dot dot dash dash
		BL	  fib_setup
		
		MOV	  R0, #5		; input=5 --> output 5 --> dot dot dot dot dot
		BL	  fib_setup
		
		B	  forever
		

		
		
Morse_Dot	
				MOV R3, #10   ; created this recursive loop in order for
LOOP			SUB R3, R3, #1; the LED to blink corresponding to a Morse
				MOV R4, #50000; dot
				MOV R5, #0
LOOP2			PUSH {LR}	  ; push the link register in order to define
				BL LEDON	  ; the return path of the function LEDON
				POP {LR}
				ADD R5, R5, #1
				CMP R5, R4
				BLT LOOP2	  ; iterates 50000 times
				CMP R3, #0
				BGT LOOP	  ; iterates 50000 times, 10 times to correspond
				MOV R3, #20   ; to a Morse dot
LOOP3			SUB R3, R3, #1; this recursive loop is to turn the LED off
				MOV R4, #50000; corresponding to the delay of a Morse dot 
				MOV R5, #0
LOOP4			PUSH {LR}
				BL LEDOFF
				POP {LR}
				ADD R5, R5, #1
				CMP R5, R4
				BLT LOOP4
				CMP R3, #0
				BGT LOOP3
				BX  LR
				

Morse_Dash
				MOV R3, #40   ; created this recuriive loop in order for
LOOP5			SUB R3, R3, #1; the LED to blink corresponding to a Morse
				MOV R4, #50000; dash
				MOV R5, #0
LOOP6			PUSH {LR}	  ; push the link register in order to define
				BL LEDON	  ; the return path of the function LEDON
				POP {LR}
				ADD R5, R5, #1
				CMP R5, R4
				BLT LOOP6	  ; iterates 50000 times 
				CMP R3, #0
				BGT LOOP5     ; iterates 50000 times, 10 times to correspond
				MOV R3, #20   ; to a Morse dash 
LOOP7			SUB R3, R3, #1; this recursive loop is to turn the LED off
				MOV R4, #50000; corresponding to the delay of a Morse dash
				MOV R5, #0
LOOP8			PUSH {LR}
				BL LEDOFF
				POP {LR}
				ADD R5, R5, #1
				CMP R5, R4
				BLT LOOP8
				CMP R3, #0
				BGT LOOP7
				BX  LR
		

				
				
MorseDigit 		
				CMP R0, #0
				BGT MorseGZero	; if input is greater than 0, jump to MorseGZero
				MOV R1, #0		; otherwise, output five Morse dashes by
MorseZero		PUSH {LR}		; looping through label MorseZero 
				BL Morse_Dash
				POP {LR}
				ADD R1, R1, #1
				CMP R1,#5
				BLT MorseZero
				B  ret
MorseGZero		CMP R0, #5		; comparing the input to 5 in order to branch
				BGT MorseGFive	; to corresponding Morse digit output
				MOV R1, #0
				MOV R2, #0
DoDots			PUSH {LR}		; start with Morse dots equal to input number
				BL Morse_Dot
				POP {LR}
				ADD R2, R2, #1
				ADD R1, R1, #1
				CMP R1, R0
				BLT DoDots
				CMP R0, #5
				BEQ ret
DoRestDash		PUSH {LR}		; fill the rest of the sequence with Morse dashes
				BL Morse_Dash
				POP {LR}
				ADD R2, R2, #1
				CMP R2, #5
				BLT  DoRestDash
				B  ret			
MorseGFive		SUB R0, R0, #5	; input is greater than five
				MOV R1, #0		; x = input - five
				MOV R2, #0
DoDashes		PUSH {LR}
				BL Morse_Dash	; start with Morse dashes equal to x
				POP {LR}
				ADD R2, R2, #1
				ADD R1, R1, #1
				CMP R1, R0
				BLT DoDashes
DoRestDot		PUSH {LR}		; fill the rest of the sequence with Morse dots
				BL Morse_Dot
				POP {LR}
				ADD R2, R2, #1
				CMP R2, #5
				BLT DoRestDot
				B ret				
ret 			BX LR			; finish, return to caller

fib_setup						; gets the value from fib and passes it to MorseDigit
			PUSH	{LR}
			BL		fib
			POP		{LR}
			BL		MorseDigit
			BX		LR
fib			CMP		R0, #0		; compares input <= 0
			BGT		fibOneX
			MOV		R0, #0		; if true, output 0
			BX		LR
fibOneX		CMP		R0, #1		; compares input == 1
			BGT		fibGOneX
			MOV		R0, #1		; if true, output 1
			BX		LR
fibGOneX	MOV		R1, R0		; calls fib(n-1)
			SUB		R0, R1, #1
			PUSH	{LR, R1}
			BL		fib
			POP		{LR, R1}
			MOV		R2, R0		; holds output of fib(n-1)
			SUB		R0, R1, #2
			PUSH	{LR, R2}	; saves output of fib(n-1)
			BL		fib			; calls fib(n-2)
			POP		{LR, R2}
			ADD		R0, R2		; fib(n-1) + fib(n-2)
			BX		LR

fib_6
			MOV  R7, R0			; holds input
			MOV  R2, #10		; saves 10
			UDIV R5, R0, R2		; divide input by 10
			MOV  R0, R5
			CMP R0, R2			; if result < 10,
			BLT hello			; output Morse code
			PUSH {LR, R7}
			BL   fib_6			; else, divide again
			POP {LR, R7}
			B    hey
hello		PUSH {LR}
			BL   MorseDigit
			POP  {LR}
			;POP {LR}		
			
hey			MOV R3, #40			; pause between Morse code
LOOOP3		SUB R3, R3, #1
			MOV R4, #50000
			MOV R5, #0
LOOOP4		PUSH {LR}
			BL LEDOFF
			POP {LR}
			ADD R5, R5, #1
			CMP R5, R4
			BLT LOOOP4
			CMP R3, #0
			BGT LOOOP3
			
			MOV R0, R7
			MOV R2, #10
labbel		SUB R0, R0, R2		; subtract 10 until < 10
			CMP R0, R2
			BGT labbel
			PUSH {LR}
			BL	MorseDigit		; display next digit
			POP {LR}			; return to following digit
			BX  LR


; Call this function first to set up the LED
LEDSETUP
				PUSH  {R4, R5} ; To preserve R4 and R5
				LDR   R4, =ten ; Load the value 1 << 10
				LDR		R5, =SCGC5
				STR		R4, [R5]
				
				LDR   R4, =eight
				LDR   R5, =PCR22
				STR   R4, [R5]
				
				LDR   R4, =twentytwo
				LDR   R5, =PDDR
				STR   R4, [R5]
				POP   {R4, R5}
				BX    LR

; The functions below are for you to use freely      
LEDON				
				PUSH  {R4, R5}
				LDR   R4, =twentytwo
				LDR   R5, =PCOR
				STR   R4, [R5]
				POP   {R4, R5}
				BX    LR
LEDOFF				
				PUSH  {R4, R5}
				LDR   R4, =twentytwo
				LDR   R5, =PSOR
				STR   R4, [R5]
				POP   {R4, R5}
				BX    LR
				
forever
			B		forever						; wait here forever	
			END
