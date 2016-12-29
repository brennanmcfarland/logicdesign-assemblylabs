
	list      p=16F84A            ; list directive to define processor
	#include <p16F84A.inc>        ; processor specific variable definitions

	__CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _RC_OSC

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.

;***** VARIABLE DEFINITIONS
w_temp        EQU     0x0C        ; variable used for context saving
status_temp   EQU     0x0D        ; variable used for context saving
COUNT         EQU     0x0E
DVAR          EQU     0x0F
DVAR2         EQU     0x10
octr          EQU     0x11	; outer-loop counter for delays
ictr          EQU     0x12	; inner-loop counter for delays
G1            EQU     RA0
G2            EQU     RA1
G3            EQU     RA2
G4            EQU     RA3
L1            EQU     RB0
L2            EQU     RB1
L3            EQU     RB2
L4            EQU     RB3
ERR           EQU     RB7

;**********************************************************************
		ORG     0x000             ; processor reset vector
  		goto    Main              ; go to beginning of program


		ORG     0x004             ; interrupt vector location
		movwf   w_temp            ; save off current W register contents
		movf	STATUS,w          ; move status register into W register
		movwf	status_temp       ; save off contents of STATUS register


; isr code can go here or be located as a call subroutine elsewhere


		movf    status_temp,w     ; retrieve copy of STATUS register
		movwf	STATUS            ; restore pre-isr STATUS register contents
		swapf   w_temp,f
		swapf   w_temp,w          ; restore pre-isr W register contents
		retfie                    ; return from interrupt


; program code goes here
Main
    clrw
    movwf PORTB     ; clear PORTB
    bsf STATUS, RP0 ; switch to register bank 1
    movwf TRISB     ; configure PORTB as all outputs
    bcf STATUS, RP0 ; switch to register bank 0

S1 ;S1 state
    ;turn on only L1
    movlw 0x71 ;binary 01110001
    andwf PORTB, 1 ;bitmask PORTB storing result in registers to clear lights
    bsf PORTB, L1 ;turn on L1
    delaysec
    ;if only G1 is active, go to SOK
    movlw 0x0F ;binary 00001111
    andwf PORTA, 0 ;bitmask PORTA storing result in wd
    xorlw 0x01 ;xor with 00000001 to see if only G1 active
    btfsc STATUS, Z ;if they are equal, to to SOK
        goto SOK
    ;otherwise, if no input active, go to S2
    movlw 0x0F ;binary 00001111
    andwf PORTA, 0 ;bitmask PORTA storing result in wd
    xorlw 0x00 ;xor with 00000000 to see if no inputs active
    btfsc STATUS, Z ;if they are equal, go to SOK
        goto SOK
    ;otherwise go to SERR
    goto SERR

S2 ;S2 state
    ;turn on only L2
    movlw 0x72 ;binary 01110010
    andwf PORTB, 1 ;bitmask PORTB storing result in registers to clear lights
    bsf PORTB, L2 ;turn on L2
    delaysec
    ;if only G2 is active, go to SOK
    movlw 0x0F ;binary 00001111
    andwf PORTA, 0 ;bitmask PORTA storing result in wd
    xorlw 0x02 ;xor with 00000010 to see if only G2 active
    btfsc STATUS, Z ;if they are equal, go to SOK
        goto SOK
    ;otherwise, if no input is active, go to S3
    movlw 0x0F ;binary 00001111
    andwf PORTA, 0 ;bitmask PORTA storing result in wd
    xorlw 0x00 ;xor with 0000 to see if no inputs active
    btfsc STATUS, Z ;if they are equal, go to S3
        goto S3
    ;otherwise go to SERR
    goto SERR
S3 ;S3 state
    ;turn on only L3
    movlw 0x74 ;binary 01110100
    andwf PORTB, 1 ;bitmask PORTB storing result in registers to clear lights
    bsf PORTB, L3 ;turn on L3
    delaysec
    ;if only G3 is active, go to SOK
    movlw 0x0F ;binary 00001111
    andwf PORTA, 0 ;bitmask PORTA storing result in wd
    xorlw 0x04 ;xor with 00000100 to see if only G3 active
    btfsc STATUS, Z ;if they are equal, go to SOK
        goto SOK
    ;otherwise, if no input is active, go to S4
    movlw 0x0F ;binary 00001111
    andwf PORTA, 0 ;bitmask PORTA storing result in wd
    xorlw 0x00 ;xor with 0000 to see if no inputs active
    btfsc STATUS, Z ;if they are equal, go to S4
        goto S4
    ;otherwise go to SERR
    goto SERR

S4 ;S4 state
    ;turn on only L4
    movlw 0x78 ;binary 01111000
    andwf PORTB, 1 ;bitmask PORTB storing result in registers to clear lights
    bsf PORTB, L4 ;turn on L4
    delaysec
    ;if only G4 is active, go to SOK
    movlw 0x0F ;binary 00001111
    andwf PORTA, 0 ;bitmask PORTA storing result in wd
    xorlw 0x08 ;xor with 00001000 to see if only G4 active
    btfsc STATUS, Z ;if they are equal, go to SOK
        goto SOK
    ;otherwise, if no input is active, go to S1
    movlw 0x0F ;binary 00001111
    andwf PORTA, 0 ;bitmask PORTA storing result in wd
    xorlw 0x00 ;xor with 00000000 to see if no inputs active
    btfsc STATUS, Z ;if they are equal, go to S1
        goto S1
    ;otherwise, go to SERR
    goto SERR
SOK ;SOK state
    ;turn all the lights off
    movlw 0x70 ;binary 01110000
    andwf PORTB, 1 ;bitmask PORTB storing result in registers to clear all lights
    delaysec
    ; if any of the inputs is active, stay in SOK, otherwise go to S1
    movlw 0x0F ;binary 00001111
    andwf PORTA, 0 ;bitmask PORTA storing result in wd
    xorlw 0x00 ;xor with 00000000 to see if any inputs active
    btfsc STATUS, Z ;if all inputs are off, go to S1 state
        goto S1
    ;otherwise stay in SOK state
    goto SOK

SERR ;SERR state
    ;set the ERR light on and all other lights off
    movlw 0xF0 ;binary 11110000
    andwf PORTB, 1 ;bitmask PORTB storing result in registers to clear L1-L4
    bsf PORTB, ERR ;and turn on the ERR light
    delaysec
    ; if any of the inputs is active, stay in SERR, otherwise go to S1
    movlw 0x0F ;binary 00001111
    andwf PORTA, 0 ;bitmask PORTA storing result in wd
    xorlw 0x00 ;xor with 00000000 to see if any inputs active
    btfsc STATUS, Z ;if all inputs are off, go to S1 state
        goto S1
    ;otherwise stay in SERR state
    goto SERR

delaysec macro ;delay for 1 second
    delay
    delay
    return

delay macro ; create a delay of about 0.5 seconds
	movlf d'16',octr ; initialize outer loop counter to 16
d1 macro
    clrf	ictr	; initialize inner loop counter to 256
    return
d2 macro
    decfsz	ictr,F	; if (--ictr != 0) loop to d2
	goto 	d2
	decfsz	octr,F	; if (--octr != 0) loop to d1
	goto	d1
    return

Init
    clrf COUNT
IncCount
    incf COUNT
    movf COUNT,W
    movwf PORTB; display COUNT on PORTB

    call Delay
    goto IncCount; infinite loop

END ; directive 'end of program'