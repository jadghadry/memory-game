	TITLE "EECE321L"
	LIST P=16F84A
	RADIX HEX
	INCLUDE "P16F84A.INC"

;*****************************************************************************
;GENERAL PURPOSE REGISTERS
;*****************************************************************************

;REGISTERS USED FOR DELAY SUBROUTINES
C1					EQU	D'12'
C2					EQU	D'13'
C3					EQU	D'14'

;REGISTER USED FOR TEMPORARY OPERATIONS
TEMP					EQU	D'15'

;REGISTER USED TO PRINT A CHARACTER ON THE LCD
CHARACTER				EQU	D'16'

;REGISTER USED TO MOVE THE CURSOR POSITION ON THE LCD
CURSOR					EQU	D'17'

;REGISTER USED TO KEEP TRACK OF THE GAME MODE
;MODE[0]: SET IF MODE 1 WAS SELECTED, CLEAR OTHERWISE
;MODE[1]: SET IF MODE 2 WAS SELECTED, CLEAR OTHERWISE
;MODE[2]: SET IF MODE 3 WAS SELECTED, CLEAR OTHERWISE
MODE					EQU	D'18'

;REGISTER USED TO KEEP TRACK OF THE PROJECT SCREENS
;FLAG[0]: CLEAR IF WE ARE ON THE LANDING SCREEN, SET OTHERWISE
FLAG					EQU	D'19'

;REGISTER USED TO KEEP TRACK OF THE CARD ADDRESS
CARDADDRESS				EQU	D'20'

;REGISTER USED TO KEEP TRACK OF THE CARD VALUE
CARDVALUE				EQU	D'21'

;REGISTER USED TO KEEP TRACK OF THE HITS COUNT
HITCOUNT				EQU	D'22'

;REGISTER USED TO KEEP TRACK OF THE MODE PENALTIES
PENALTY					EQU	D'23'

;REGISTER USED TO KEEP TRACK OF THE GAME SCORE
TIMERVAL				EQU	D'24'

;REGISTER USED TO KEEP TRACK OF THE TMR0 OVERFLOWS
TMR0COUNT				EQU	D'25'

;REGISTERS USED TO KEEP TRACK OF THE GAME CHARACTERS
R0C0					EQU	D'40'
R0C1					EQU	D'41'
R0C2					EQU	D'42'
R0C3					EQU	D'43'
R0C4					EQU	D'44'
R0C5					EQU	D'45'
R1C0					EQU	D'46'
R1C1					EQU	D'47'
R1C2					EQU	D'48'
R1C3					EQU	D'49'
R1C4					EQU	D'50'
R1C5					EQU	D'51'










;*****************************************************************************
;MAIN/INTERRUPTS ROUTINE
;*****************************************************************************

	ORG				0X00
	GOTO				MAIN

	ORG				0X04

	;CHECK THE SOURCE OF THE INTERRUPT
	BTFSC				INTCON, RBIF
	GOTO				ISR1
	GOTO				ISR2










;*****************************************************************************
;INITIALIZATION
;*****************************************************************************

MAIN
	BSF				STATUS, RP0
	CLRF				TRISA
	MOVLW				B'11110000'
	MOVWF				TRISB
	MOVLW				B'10000111'
	MOVWF				OPTION_REG
	BCF				STATUS, RP0
	CLRF				PORTB
	CLRF				INTCON









;*****************************************************************************
;LCD INITIALIZATION
;*****************************************************************************

	CALL				DELAY_SHORT
	MOVLW				B'00010'
	CALL				ET
	MOVLW				B'00010'
	CALL				ET
	MOVLW				B'01000'
	CALL				ET

	MOVLW				B'00000'
	CALL				ET
	MOVLW				B'01110'
	CALL				ET

	;CLEAR THE LCD DISPLAY
	CALL				CLEAR

	MOVLW				B'00000'
	CALL				ET
	MOVLW				B'00110'
	CALL				ET









;*****************************************************************************
;MAIN SCREEN
;*****************************************************************************

MAIN_SCREEN
	;CLEAR THE LCD DISPLAY
	CALL				CLEAR

	;PRINT CHARACTER W
	CALL				PRINT_CHARACTER_W
	;PRINT CHARACTER E
	CALL				PRINT_CHARACTER_E
	;PRINT CHARACTER L
	MOVLW				B'01001100'
	CALL				PRINT_CHARACTER
	;PRINT CHARACTER C
	MOVLW				B'01000011'
	CALL				PRINT_CHARACTER
	;PRINT CHARACTER O
	CALL				PRINT_CHARACTER_O
	;PRINT CHARACTER M
	CALL				PRINT_CHARACTER_M
	;PRINT CHARACTER E
	CALL				PRINT_CHARACTER_E

	;PAUSE LCD DISPLAY FOR 1S
	CALL				DELAY_LONG

	;CLEAR THE LCD DISPLAY
	CALL				CLEAR

	;PRINT CHARACTER M
	CALL				PRINT_CHARACTER_M
	;PRINT CHARACTER O
	CALL				PRINT_CHARACTER_O
	;PRINT CHARACTER D
	MOVLW				B'01000100'
	CALL				PRINT_CHARACTER
	;PRINT CHARACTER E
	CALL				PRINT_CHARACTER_E

	;MOVE THE CURSOR TO ROW 0, COLUMN 6
	MOVLW				B'10000110'
	CALL				MOVE_CURSOR

	;PRINT CHARACTER *
	MOVLW				B'00101010'
	CALL				PRINT_CHARACTER
	;PRINT NUMBER 1
	MOVLW				B'00110001'
	CALL				PRINT_CHARACTER

	;MOVE THE CURSOR TO ROW 0, COLUMN 10
	MOVLW				B'10001010'
	CALL				MOVE_CURSOR

	;PRINT NUMBER 2
	MOVLW				B'00110010'
	CALL				PRINT_CHARACTER

	;MOVE THE CURSOR TO ROW 0, COLUMN 13
	MOVLW				B'10001101'
	CALL				MOVE_CURSOR

	;PRINT NUMBER 3
	MOVLW				B'00110011'
	CALL				PRINT_CHARACTER

	;MOVE THE CURSOR TO ROW 0, COLUMN 6
	MOVLW				B'10000110'
	CALL				MOVE_CURSOR

	;INITIALIZE THE DATABASE REGISTERS
	;MOVE THE LETTER A CHARACTER BITS TO R0C1 AND R1C4
	MOVLW				B'01000001'
	MOVWF				R0C1
	MOVWF				R1C4
	;MOVE THE LETTER B CHARACTER BITS TO R0C4 AND R1C0
	MOVLW				B'01000010'
	MOVWF				R0C4
	MOVWF				R1C0
	;MOVE THE LETTER C CHARACTER BITS TO R0C0 AND R1C3
	MOVLW				B'01000011'
	MOVWF				R0C0
	MOVWF				R1C3
	;MOVE THE LETTER D CHARACTER BITS TO R0C5 AND R1C1
	MOVLW				B'01000100'
	MOVWF				R0C5
	MOVWF				R1C1
	;MOVE THE LETTER E CHARACTER BITS TO R0C2 AND R1C5
	MOVLW				B'01000101'
	MOVWF				R0C2
	MOVWF				R1C5
	;MOVE THE LETTER F CHARACTER BITS TO R0C3 AND R1C2
	MOVLW				B'01000110'
	MOVWF				R0C3
	MOVWF				R1C2

	;INITIALIZE THE MODE REGISTER
	CLRF				MODE
	BSF				MODE, 0

	;INITIALIZE THE FLAG REGISTER
	CLRF				FLAG

	;INITIALIZE THE CARDADDRESS REGISTER
	CLRF				CARDADDRESS

	;INITIALIZE THE CARDVALUE REGISTER
	CLRF				CARDVALUE

	;INITIALIZE THE HITCOUNT REGISTER
	CLRF				HITCOUNT

	;INITIALIZE THE PENALTY REGISTER
	CLRF				PENALTY

	;INITIALIZE THE TMR0COUNT REGISTER
	MOVLW				D'152'
	MOVWF				TMR0COUNT

	;ENABLE PORTB[4:7] PUSHBUTTON INTERRUPTS
	MOVLW				B'10001000'
	MOVWF				INTCON

INFINITE_LOOP
	GOTO				INFINITE_LOOP










;*****************************************************************************
;PORTB[4:7] INTERRUPT HANDLER
;*****************************************************************************

ISR1
	CALL				DEBOUNCE
	BTFSS				PORTB, 4
	GOTO				BUTTON_LEFT
	BTFSS				PORTB, 5
	GOTO				BUTTON_RIGHT
	BTFSS				PORTB, 6
	GOTO				BUTTON_UPDOWN
	BTFSS				PORTB, 7
	GOTO				BUTTON_CONFIRM

;SUBROUTINE USED TO RETURN FROM INTERRUPTS
RETURN_FROM_INTERRUPTS
	BCF				INTCON, RBIF
	BCF				INTCON, T0IF
	RETFIE










;*****************************************************************************
;TMR0 INTERRUPT HANDLER
;*****************************************************************************

ISR2
	;CHECK THE VALUE OF TMR0COUNT
	DECFSZ				TMR0COUNT, F
	GOTO				RETURN_FROM_INTERRUPTS

	;REINITIALIZE THE TMR0COUNT REGISTER
	MOVLW				D'152'
	MOVWF				TMR0COUNT

	;COPY THE CURRENT CURSOR POSITION
	MOVF				CURSOR, W
	MOVWF				TEMP

	;MOVE THE CURSOR TO ROW 0, COLUMN 13
	MOVLW				B'10001101'
	CALL				MOVE_CURSOR

	;DECREMENT THE TIMERVAL REGISTER
	DECF				TIMERVAL, F

	;UPDATE THE TIMER VALUE
	MOVF				TIMERVAL, W
	CALL				PRINT_FORMATTED_DIGIT

	;CHECK THE VALUE OF THE TIMERVAL REGISTER
	MOVF				TIMERVAL, F
	BTFSC				STATUS, Z
	GOTO				ENDGAME_MODE2

	;REPOSITION THE CURSOR
	MOVF				TEMP, W
	GOTO				MOVE_CURSOR_AND_RETURN










;*****************************************************************************
;LEFT PUSHBUTTON SUBROUTINES
;*****************************************************************************

BUTTON_LEFT
	;CHECK IF WE ARE IN A GAME MODE
	BTFSS				FLAG, 0

	;RETURN FROM INTERRUPTS
	GOTO				RETURN_FROM_INTERRUPTS

	;OTHERWISE CHECK IF WE ARE ON COLUMN 0
	MOVF				CURSOR, W
	ANDLW				B'00001111'
	BTFSC				STATUS, Z
	GOTO				CURSOR_ERROR

	;OTHERWISE DECREMENT THE CURSOR POSITION
	DECF				CURSOR, W
	GOTO				MOVE_CURSOR_AND_RETURN










;*****************************************************************************
;RIGHT PUSHBUTTON SUBROUTINES
;*****************************************************************************

BUTTON_RIGHT
	;CHECK IF WE ARE ON THE MAIN SCREEN
	BTFSC				FLAG, 0
	GOTO				BUTTON_RIGHT_GAME_MODE










BUTTON_RIGHT_MAIN_SCREEN
	;PRINT CHARACTER WHITESPACE
	CALL				PRINT_CHARACTER_WHITESPACE

	;CHECK THE CURRENT CURSOR POSITION
	BTFSC				MODE, 2
	GOTO				RESET_CURSOR_MAIN_SCREEN

	;INCREMENT THE CURSOR REGISTER
	MOVLW				D'3'
	ADDWF				CURSOR, W
	CALL				MOVE_CURSOR

	;SHIFT THE MODE REGISTER TO THE LEFT
	RLF				MODE, F

PRINT_CURSOR_CHARACTER
	;PRINT CHARACTER *
	MOVLW				B'00101010'
	CALL				PRINT_CHARACTER

	;CANCEL THE AUTOINCREMENT EFFECT
	CALL				CANCEL_AUTOINCREMENT

	;RETURN FROM INTERRUPTS
	GOTO				RETURN_FROM_INTERRUPTS





RESET_CURSOR_MAIN_SCREEN
	;MOVE THE CURSOR TO ROW 0, COLUMN 6
	MOVLW				B'10000110'
	CALL				MOVE_CURSOR

	;RESET THE MODE REGISTER
	CLRF				MODE
	BSF				MODE, 0

	;PRINT THE CURSOR CHARACTER
	GOTO				PRINT_CURSOR_CHARACTER










BUTTON_RIGHT_GAME_MODE
	;CHECK IF WE ARE ON COLUMN 5
	MOVF				CURSOR, W
	ANDLW				B'00001111'
	SUBLW				B'00000101'
	BTFSC				STATUS, Z
	GOTO				CURSOR_ERROR

	;OTHERWISE INCREMENT THE CURSOR POSITION
	INCF				CURSOR, W
	GOTO				MOVE_CURSOR_AND_RETURN










;*****************************************************************************
;UP/DOWN PUSHBUTTON SUBROUTINES
;*****************************************************************************

BUTTON_UPDOWN
	;CHECK IF WE ARE IN A GAME MODE
	BTFSS				FLAG, 0
	GOTO				RETURN_FROM_INTERRUPTS

	;INVERT THE ROW BIT
	MOVF				CURSOR, W
	XORLW				B'01000000'
	GOTO				MOVE_CURSOR_AND_RETURN










;*****************************************************************************
;CONFIRM PUSHBUTTON SUBROUTINES
;*****************************************************************************

BUTTON_CONFIRM
	;CHECK IF WE ARE ON THE MAIN SCREEN
	BTFSC				FLAG, 0
	GOTO				BUTTON_CONFIRM_GAME_MODE










BUTTON_CONFIRM_MAIN_SCREEN
	;SET FLAG[0] TO INDICATE THAT WE ARE IN A GAME MODE
	BSF				FLAG, 0

	;CLEAR THE LCD DISPLAY
	CALL				CLEAR

	;PRINT SIX SQUARE CHARACTERS
	CALL				PRINT_SIX_SQUARES

	;MOVE THE CURSOR TO ROW 1, COLUMN 0
	MOVLW				B'11000000'
	CALL				MOVE_CURSOR

	;PRINT SIX SQUARE CHARACTERS
	CALL				PRINT_SIX_SQUARES

	;MOVE THE CURSOR TO ROW 0, COLUMN 8
	MOVLW				B'10001000'
	CALL				MOVE_CURSOR

	;CHECK WHICH GAME MODE WAS SELECTED
	BTFSC				MODE, 0
	CALL				PRINT_MODE1
	BTFSC				MODE, 1
	CALL				PRINT_MODE2
	BTFSC				MODE, 2
	CALL				PRINT_MODE3

	;MOVE THE CURSOR TO ROW 0, COLUMN 0
	MOVLW				B'10000000'
	GOTO				MOVE_CURSOR_AND_RETURN










PRINT_MODE1
	;PRINT CHARACTER S
	CALL				PRINT_CHARACTER_S

	;PRINT SIX EMPTY CHARACTERS
	MOVLW				D'6'
	MOVWF				TEMP

PRINT_CHARACTER_EMPTY_LOOP
	CALL				PRINT_CHARACTER_EMPTY
	DECFSZ				TEMP, F
	GOTO				PRINT_CHARACTER_EMPTY_LOOP

	;PRINT CHARACTER W
	GOTO				PRINT_CHARACTER_W










PRINT_MODE2
	;ENABLE THE TMR0 INTERRUPT
	BSF				INTCON, T0IE

	;INITIALIZE THE TIMERVAL REGISTER
	MOVLW				D'9'
	MOVWF				TIMERVAL

	;PRINT CHARACTER R
	CALL				PRINT_CHARACTER_R
	;PRINT CHARACTER E
	CALL				PRINT_CHARACTER_E
	;PRINT CHARACTER M
	CALL				PRINT_CHARACTER_M

	;PRINT CHARACTER WHITESPACE
	CALL				PRINT_CHARACTER_WHITESPACE

	;PRINT CHARACTER T
	MOVLW				B'01010100'
	CALL				PRINT_CHARACTER
	;PRINT NUMBER 9
	MOVLW				B'00111001'
	CALL				PRINT_CHARACTER
	;PRINT NUMBER 0
	MOVLW				B'00110000'
	GOTO				PRINT_CHARACTER










PRINT_MODE3
	;MOVE THE CURSOR TO ROW 0, COLUMN 8
	MOVLW				B'10001000'
	CALL				MOVE_CURSOR

	;PRINT CHARACTER MINUS
	MOVLW				B'00101101'
	CALL				PRINT_CHARACTER

	;PRINT THE VALUE INSIDE THE PENALTY REGISTER
	MOVF				PENALTY, W
	CALL				PRINT_NORMALIZED_NUMBER

	;MOVE THE CURSOR TO ROW 0, COLUMN 12
	MOVLW				B'10001100'
	CALL				MOVE_CURSOR

	;PRINT CHARACTER PLUS
	MOVLW				B'00101011'
	CALL				PRINT_CHARACTER

	;PRINT THE VALUE INSIDE THE HITCOUNT REGISTER
	MOVF				HITCOUNT, W
	CALL				PRINT_FORMATTED_DIGIT

	;MOVE THE CURSOR TO ROW 1, COLUMN 8
	MOVLW				B'11001000'
	CALL				MOVE_CURSOR

	;PRINT THE WORD SCORE
	CALL				PRINT_WORD_SCORE

	;CHECK IF THE PENALTY VALUE IS GREATER THAN 13
	MOVF				PENALTY, W
	ADDLW				D'242'
	BTFSC				STATUS, C
	GOTO				ENDGAME

	;OTHERWISE COMPUTE THE GAME SCORE
	MOVF				PENALTY, W
	SUBLW				D'13'
	ADDWF				HITCOUNT, W

	;PRINT THE GAME SCORE
	GOTO				PRINT_NORMALIZED_NUMBER










BUTTON_CONFIRM_GAME_MODE
	;POINT TO THE DATABASE ELEMENT
	CALL				CURSOR_TO_DATABASE

	;CHECK IF THE CARD IS CURRENTLY OPEN
	BTFSC				INDF, 3
	GOTO				CURSOR_ERROR

	;PRINT THE CARD VALUE
	MOVF				INDF, W
	ANDLW				B'01110111'
	CALL				PRINT_CHARACTER

	;CANCEL THE AUTOINCREMENT EFFECT
	CALL				CANCEL_AUTOINCREMENT

	;CHECK IF THE USER OPENED A SECOND CARD
	MOVF				CARDVALUE, F
	BTFSS				STATUS, Z
	GOTO				VALIDATE_PAIR

	;COPY THE CARD ADDRESS
	MOVF				CURSOR, W
	MOVWF				CARDADDRESS

	;COPY THE CARD VALUE
	MOVF				INDF, W
	MOVWF				CARDVALUE

	;SET THE CARD BIT [3]
	BSF				INDF, 3

	;RETURN FROM INTERRUPTS
	GOTO				RETURN_FROM_INTERRUPTS





VALIDATE_PAIR
	;COMPARE THE CARDS
	MOVF				INDF, W
	SUBWF				CARDVALUE, W
	ANDLW				B'01111111'
	BTFSC				STATUS, Z
	GOTO				MATCHING_PAIR





WRONG_PAIR
	;PAUSE LCD DISPLAY FOR 1S
	CALL				DELAY_LONG

	;MARK THE CARD IF WE ARE IN MODE 3
	BTFSC				MODE, 2
	CALL				MARK_CARD

	;HIDE THE CURRENT CARD VALUE
	CALL				PRINT_CHARACTER_SQUARE

	;HIDE THE PREVIOUS CARD VALUE
	MOVF				CARDADDRESS, W
	CALL				MOVE_CURSOR
	CALL				PRINT_CHARACTER_SQUARE

	;RESET THE PREVIOUS CARD DATABASE VALUE
	CALL				CURSOR_TO_DATABASE
	MOVF				CARDVALUE, W
	MOVWF				INDF

	;MARK THE CARD IF WE ARE IN MODE 3
	BTFSC				MODE, 2
	CALL				MARK_CARD

	;CHECK WHICH MODE WAS SELECTED
	BTFSC				MODE, 0
	CALL				UPDATE_PENALTY
	BTFSC				MODE, 2
	CALL				PRINT_MODE3

	;RESET THE POSITION OF THE CURSOR
	GOTO				RESET_CURSOR_GAME_MODE





MARK_CARD
	;CHECK IF THE CARD WAS ALREADY MARKED
	BTFSC				INDF, 7
	INCF				PENALTY, F

	;SET THE CARD BIT [7]
	BSF				INDF, 7

	;RETURN TO THE PREVIOUS FUNCTION CALL
	RETURN





UPDATE_PENALTY
	;INCREMENT THE PENALTY REGISTER
	INCF				PENALTY, F

	;CHECK IF MORE THAN TEN PENALTIES OCCURRED
	MOVF				PENALTY, W
	ADDLW				D'244'
	BTFSC				STATUS, C
	RETURN

	;OTHERWISE CHECK FOR AN ODD PENALTY VALUE
	BTFSS				PENALTY, 0
	RETURN

UPDATE_BAR_METER
	;UPDATE CURSOR POSITION
	RRF				PENALTY, W
	ADDLW				B'10001001'
	CALL				MOVE_CURSOR

	;PRINT CHARACTER FILLED SQUARE
	MOVLW				B'11111111'
	GOTO				PRINT_CHARACTER





MATCHING_PAIR
	;SET THE CARD BIT [3]
	BSF				INDF, 3

	;INCREMENT THE HITCOUNT REGISTER
	INCF				HITCOUNT, F

	;CHECK IF WE ARE IN MODE 3
	BTFSC				MODE, 2
	CALL				PRINT_MODE3

	;CHECK IF WE OPENED ALL CARDS
	MOVLW				D'6'
	SUBWF				HITCOUNT, W
	BTFSC				STATUS, Z
	GOTO				ENDGAME





RESET_CURSOR_GAME_MODE
	;RESET THE CARDADDRESS REGISTER
	CLRF				CARDADDRESS

	;RESET THE CARDVALUE REGISTER
	CLRF				CARDVALUE

	;MOVE THE CURSOR TO ROW 0, COLUMN 0
	MOVLW				B'10000000'
	GOTO				MOVE_CURSOR_AND_RETURN










ENDGAME
	;CHECK WHICH GAME MODE WAS SELECTED
	BTFSC				MODE, 2
	GOTO				RESTART_GAME
	BTFSC				MODE, 1
	GOTO				ENDGAME_MODE2





ENDGAME_MODE1
	;MOVE THE CURSOR TO ROW 1, COLUMN 9
	MOVLW				B'11001001'
	CALL				MOVE_CURSOR

	;CHECK IF 0 TO 4 MISSES OCCURRED
	MOVF				PENALTY, W
	ADDLW				D'251'
	BTFSS				STATUS, C
	GOTO				PRINT_WORD_SUPER

	;CHECK IF 5 TO 8 MISSES OCCURRED
	MOVF				PENALTY, W
	ADDLW				D'247'
	BTFSS				STATUS, C
	GOTO				PRINT_WORD_AVG

	;PRINT CHARACTER W
	CALL				PRINT_CHARACTER_W
	;PRINT CHARACTER E
	CALL				PRINT_CHARACTER_E
	;PRINT CHARACTER A
	CALL				PRINT_CHARACTER_A
	;PRINT CHARACTER K
	MOVLW				B'01001011'
	CALL				PRINT_CHARACTER

RESTART_GAME
	;PAUSE LCD DISPLAY FOR 1S
	CALL				DELAY_LONG

	;GO TO THE MAIN SCREEN DISPLAY
	GOTO				MAIN_SCREEN










ENDGAME_MODE2
	;MOVE THE CURSOR TO ROW 1, COLUMN 8
	MOVLW				B'11001000'
	CALL				MOVE_CURSOR

	;PRINT THE WORD SCORE
	CALL				PRINT_WORD_SCORE

	;COMPUTE THE GAME SCORE
	MOVF				HITCOUNT, W
	ADDWF				TIMERVAL, W

	;PRINT THE GAME SCORE
	CALL				PRINT_NORMALIZED_NUMBER

	;RESTART THE GAME
	GOTO				RESTART_GAME










;*****************************************************************************
;COMMON INTERRUPT SUBROUTINES
;*****************************************************************************

;SUBROUTINE USED TO INDICATE THAT AN ERROR HAS OCCURRED
CURSOR_ERROR
	BSF				PORTB, 0
	CALL				DELAY_SHORT
	BCF				PORTB, 0
	GOTO				RETURN_FROM_INTERRUPTS





;SUBROUTINE USED TO MAP THE CURSOR POSITION TO THE DATABASE REGISTER
CURSOR_TO_DATABASE
	;CHECK WHETHER THE CURSOR IS AT R0 OR R1
	BTFSS				CURSOR, 6
	MOVLW				D'88'
	BTFSC				CURSOR, 6
	MOVLW				D'146'

	;SUBTRACT THE OFFSET FROM THE CURSOR VALUE
	SUBWF				CURSOR, W

	;MOVE THE COMPUTED OFFSET TO THE FSR REGISTER
	MOVWF				FSR

	;RETURN TO THE PREVIOUS FUNCTION CALL
	RETURN





;SUBROUTINE USED TO PRINT A NORMALIZED NUMBER
PRINT_NORMALIZED_NUMBER
	;COPY THE VALUE INSIDE THE TEMP REGISTER
	MOVWF				TEMP

	;CHECK IF THE VALUE IS GREATER THAN 9
	ADDLW				D'246'
	BTFSC				STATUS, C
	GOTO				NORMALIZE_SCORE

	;OTHERWISE PRINT THE VALUE
	MOVF				TEMP, W
	CALL				PRINT_FORMATTED_DIGIT

	;PRINT A WHITESPACE CHARACTER
	GOTO				PRINT_CHARACTER_WHITESPACE

NORMALIZE_SCORE
	;PRINT NUMBER 1
	MOVLW				B'00110001'
	CALL				PRINT_CHARACTER

	;NORMALIZE THE NUMBER
	MOVLW				D'10'
	SUBWF				TEMP, W
	GOTO				PRINT_FORMATTED_DIGIT










;*****************************************************************************
;DELAY SUBROUTINES
;*****************************************************************************

DELAY_SHORT
	MOVLW				D'255'
	MOVWF				C1
	MOVLW				D'40'
	MOVWF				C2
DELAY_SHORT_LOOP
	DECFSZ				C1, F
	GOTO				DELAY_SHORT_LOOP
	DECFSZ				C2, F
	GOTO				DELAY_SHORT_LOOP
	RETURN

DELAY_LONG
	MOVLW				D'255'
	MOVWF				C1
	MOVWF				C2
	MOVLW				D'10'
	MOVWF				C3
DELAY_LONG_LOOP
	DECFSZ				C1,	F
	GOTO				DELAY_LONG_LOOP
	DECFSZ				C2,	F
	GOTO				DELAY_LONG_LOOP
	DECFSZ				C3,	F
	GOTO				DELAY_LONG_LOOP
	RETURN










;*****************************************************************************
;MISCELLANEOUS SUBROUTINES
;*****************************************************************************

ET
	MOVWF				PORTA
	BSF				PORTB, 1
	NOP
	BCF				PORTB, 1

;SUBROUTINE USED TO ACCOUNT FOR THE HARDWARE DEBOUNCE DELAY
DEBOUNCE
	MOVLW				D'182'
	MOVWF				C1
	MOVLW				D'3'
	MOVWF				C2
DEBOUNCE_LOOP
	DECFSZ				C1, F
	GOTO				DEBOUNCE_LOOP
	DECFSZ				C2, F
	GOTO				DEBOUNCE_LOOP
	RETURN










;*****************************************************************************
;LCD SUBROUTINES
;*****************************************************************************

;SUBROUTINE USED TO CLEAR THE LCD DISPLAY
CLEAR
	MOVLW				B'00000'
	CALL				ET
	MOVLW				B'00001'
	GOTO				ET

;SUBROUTINE USED TO CANCEL THE AUTOINCREMENT EFFECT
CANCEL_AUTOINCREMENT
	MOVF				CURSOR, W

;SUBROUTINE USED TO CHANGE THE POSITION OF THE CURSOR ON THE LCD
MOVE_CURSOR
	MOVWF				CURSOR
	SWAPF				CURSOR, W
	ANDLW				B'01111'
	CALL				ET
	MOVF				CURSOR, W
	ANDLW				B'01111'
	GOTO				ET

;SUBROUTINE USED TO CHANGE THE POSITION OF THE CURSOR AND RETURN FROM INTERRUPTS
MOVE_CURSOR_AND_RETURN
	CALL				MOVE_CURSOR
	GOTO				RETURN_FROM_INTERRUPTS

;SUBROUTINE USED TO PRINT A NON-LCD FORMATTED DIGIT
PRINT_FORMATTED_DIGIT
	IORLW				B'00110000'

;SUBROUTINE USED TO PRINT ANY CHARACTER ON THE LCD
PRINT_CHARACTER
	MOVWF				CHARACTER
	SWAPF				CHARACTER, W
	IORLW				B'10000'
	CALL				ET
	MOVF				CHARACTER, W
	IORLW				B'10000'
	GOTO				ET










;*****************************************************************************
;PRINTING SUBROUTINES
;*****************************************************************************

;PRINTING CHARACTERS
PRINT_CHARACTER_WHITESPACE
	MOVLW				B'00100000'
	GOTO				PRINT_CHARACTER

PRINT_CHARACTER_SQUARE
	MOVLW				B'11011011'
	GOTO				PRINT_CHARACTER

PRINT_CHARACTER_EMPTY
	MOVLW				B'10100011'
	GOTO				PRINT_CHARACTER

PRINT_CHARACTER_A
	MOVLW				B'01000001'
	GOTO				PRINT_CHARACTER

PRINT_CHARACTER_E
	MOVLW				B'01000101'
	GOTO				PRINT_CHARACTER

PRINT_CHARACTER_M
	MOVLW				B'01001101'
	GOTO				PRINT_CHARACTER

PRINT_CHARACTER_O
	MOVLW				B'01001111'
	GOTO				PRINT_CHARACTER

PRINT_CHARACTER_R
	MOVLW				B'01010010'
	GOTO				PRINT_CHARACTER

PRINT_CHARACTER_S
	MOVLW				B'01010011'
	GOTO				PRINT_CHARACTER

PRINT_CHARACTER_W
	MOVLW				B'01010111'
	GOTO				PRINT_CHARACTER





;PRINTING WORDS
PRINT_WORD_SCORE
	;PRINT CHARACTER S
	CALL				PRINT_CHARACTER_S
	;PRINT CHARACTER C
	MOVLW				B'01000011'
	CALL				PRINT_CHARACTER
	;PRINT CHARACTER O
	CALL				PRINT_CHARACTER_O
	;PRINT CHARACTER R
	CALL				PRINT_CHARACTER_R
	;PRINT CHARACTER E
	CALL				PRINT_CHARACTER_E

	;PRINT CHARACTER WHITESPACE
	GOTO				PRINT_CHARACTER_WHITESPACE





PRINT_WORD_SUPER
	;PRINT CHARACTER S
	CALL				PRINT_CHARACTER_S
	;PRINT CHARACTER U
	MOVLW				B'01010101'
	CALL				PRINT_CHARACTER
	;PRINT CHARACTER P
	MOVLW				B'01010000'
	CALL				PRINT_CHARACTER
	;PRINT CHARACTER E
	CALL				PRINT_CHARACTER_E
	;PRINT CHARACTER R
	CALL				PRINT_CHARACTER_R

	;RESTART THE GAME
	GOTO				RESTART_GAME

PRINT_WORD_AVG
	;PRINT CHARACTER A
	CALL				PRINT_CHARACTER_A
	;PRINT CHARACTER V
	MOVLW				B'01010110'
	CALL				PRINT_CHARACTER
	;PRINT CHARACTER G
	MOVLW				B'01000111'
	CALL				PRINT_CHARACTER

	;RESTART THE GAME
	GOTO				RESTART_GAME





;SUBROUTINE USED TO PRINT SIX CONSECUTIVE SQUARE CHARACTERS
PRINT_SIX_SQUARES
	CALL				PRINT_CHARACTER_SQUARE
	CALL				PRINT_CHARACTER_SQUARE
	CALL				PRINT_CHARACTER_SQUARE
	CALL				PRINT_CHARACTER_SQUARE
	CALL				PRINT_CHARACTER_SQUARE
	GOTO				PRINT_CHARACTER_SQUARE










;*****************************************************************************
;END OF PROJECT
;*****************************************************************************

	END
