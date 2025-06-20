;
; Semaforo.asm

	rjmp Start
	.ORG 0x0002
	rjmp RSI_0
	.ORG 0x0004
	rjmp RSI_1

Start:
	sei					;Habilita interrupciones globales

	ldi	r16, 0xFF
	out DDRB,  r16		;Configurar puerto B como salida

	ldi	r17, 0xFF
	out PORTD,  r17		;Configurar resistencias pull-up

	ldi r18, 0xFF
	out SPL, r18		;SPL: Stack Pointer Low byte
	ldi r19, 0X08
	out SPH, r19		;SPH: Stack Pointer High byte.

	ldi	r20, 0x03
	out	EIMSK, r20		;Habilita INT0

	ldi	r21, 0x0F
	sts	EICRA, r21		;Configura flanco de subida

;***********************************************************************
inicio: 

	sbi PORTB, 3		;Enciende LED rojo peatonal (PB3)
	cbi PORTB, 0		;Desactiva el rojo  en el pin0 del puerto B

	sbi PORTB, 2		;Activa el led verde en el pin2 del puerto B

	RCALL tseg
	cbi PORTB, 2		;Desactiva el led verde en el pin2 del puerto B
	RCALL blink			;parpadeo del foco led 1 segundo
	RCALL blink			;parpadeo del foco led 1 segundo
	RCALL blink			;parpadeo del foco led 1 segundo

	sbi PORTB, 1		;Activa el led amarillo en el pin1 del puerto B
	RCALL tseg
	cbi PORTB, 1		;Desactiva el amarillo  en el pin1 del puerto B

	sbi PORTB, 0		;Activa el led rojo en el pin0 del puerto B
	RCALL tseg
	RCALL tseg
	;cbi PORTB, 0		;Desactiva el rojo  en el pin0 del puerto B

	RCALL peatonal		;reactivar semáforo peatonal

RJMP inicio				;RJMP es un salto Relative Jump (Salto Relativo)

;*******************************************************************
;* Subrutina para parpadear semaforo							   *
;*******************************************************************
Blink: 
	sbi PORTB, 2
	RCALL tseg
	cbi PORTB, 2
	RCALL tseg
ret

;*******************************************************************
;* Subrutina de retaedo de tiempo								   *
;*******************************************************************
tseg:
	ldi r18, 4;16
	ldi r19, 12;57
	ldi r20, 3;12
	l2: dec r20
	brne l2
	dec r19
	brne l2
	dec r18
	brne l2
	nop
ret

;*******************************************************************
;* Subrutina Semaforo peatonal      							   *
;*******************************************************************
peatonal:
	sbi PORTB, 4     ; Enciende LED verde peatonal (PB4)

	cbi PORTB, 3     ; Apaga LED rojo peatonal (PB3)

	RCALL tseg_1       ; Espera 1 segundo
	RCALL tseg_1      ; Espera 1 segundo

	RCALL parpadeo_peatonal


	cbi PORTB, 4     ; Apaga LED verde peatonal

	sbi PORTB, 3     ; Enciende LED rojo peatonal
ret

;*******************************************************************
;* Subrutina para parpadear peatonal							   *
;*******************************************************************
parpadeo_peatonal:
	sbi PORTB, 4
	RCALL tseg_1
	cbi PORTB, 4
	RCALL tseg_1

	sbi PORTB, 4
	RCALL tseg_1
	cbi PORTB, 4
	RCALL tseg_1
ret

;*******************************************************************
;* Subrutina de retaedo de tiempo								   *
;*******************************************************************
tseg_1:
	ldi r21, 4;16
	ldi r22, 12;57
	ldi r23, 3;12
	l3: dec r23
	brne l3
	dec r22
	brne l3
	dec r21
	brne l3
	nop
ret

;*******************************************************************
;* Subrutina interrupcion INT0      							   *
;*******************************************************************
RSI_0:

	cbi PORTB, 2		;Desactiva el led verde en el pin2 del puerto B
	sbi PORTB, 1		;Activa el led amarillo en el pin1 del puerto B

	RCALL tseg
	cbi PORTB, 1		;Desactiva el amarillo  en el pin1 del puerto B

	sbi PORTB, 0		;Activa el led rojo en el pin0 del puerto B
	RCALL tseg_1
	RCALL tseg_1
	;cbi PORTB, 0		;Desactiva el rojo  en el pin0 del puerto B

	RCALL peatonal		;reactivar semáforo peatonal
reti


RSI_1:
reti