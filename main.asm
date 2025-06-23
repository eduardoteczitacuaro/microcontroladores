;
; SemaforoPeatonal2.asm
;
; Created: 22/06/2025 07:00:54 p. m.
; Author : luis_
;

; Asignacion de terminales
;			SEMAFORO VEHICULAR:
;	Verde		PORTD PD0
;	Amarillo	PORTD PD1
;	ROJO		PORTD PD2
;	
;			SEMAFORO PEATONAL
;	Verde	PORTD PD3
;	Rojo	PORTD PD4
;
;			BOTON PEATONAL
;	Pulsador	PINB PB0
;

.ORG 0x0000
RJMP main

.ORG 0x0020
main:
	
; INICIALIZACION Y CONFIGURACION DE ENTRADA Y SALIDAS:

		.EQU delay1 = 250			; retardo de referencia
		.EQU delayflash = 50		; retardo para intermitencia 
		.DEF temp =	R16
		.DEF counter = R17
		.DEF flag_boton = R18

		LDI temp, 0b00011111		; se configuran de PD0 a PD4 como salida
		OUT DDRD, temp
		LDI temp, 0b00000000
		OUT DDRB, temp				; definicion de PB0 como entrada
		LDI temp, 0b00000001
		OUT PORTB, temp				; se activa pull-up en PB0

		CLR temp
		OUT PORTD, temp				; se limpian los datos del puerto D.
		CLR flag_boton				; se inicializa una bandera

loop:
		RCALL revisar_boton
		SBI PORTD, 0				; prende luz verde semaforo vehicular
		RCALL delay_5s
		CBI PORTD, 0				; apaga luz verde semaforo vehicular
		LDI counter, 6				; destellar 6 veces luz verde 

destello_verde:
		SBI PORTD, 0
		RCALL delay_250ms
		CBI PORTD, 0
		RCALL delay_250ms
		DEC counter
		BRNE destello_verde

		SBI PORTD, 1				; prende luz amarilla 3 segundos
		RCALL delay_3s
		CBI PORTD, 1

		SBI PORTD, 2				; prende luz roja 8 segundos
		RCALL delay_8s

		TST flag_boton 
		BREQ revisar_peaton			; revisar si se solicita cruce peatonal

		RCALL cruce_peaton			; se realiza cruce peatonal

revisar_peaton:
		CBI PORTD, 2				; se apaga la luz roja
		CLR flag_boton
		RJMP loop
		

;-------------------subrutinas--------------------------

revisar_boton:
		SBIS PINB, 0				; verificar si se presiona el boton
		RJMP antirrebote
		RET

antirrebote: 
		RCALL delay_50ms
		SBIS PINB, 0				; verifica si sigue presionado el boton
		RJMP set_flag
		RET

set_flag:
		LDI flag_boton, 1
		RET

cruce_peaton:
		SBI PORTD, 3				; luz roja vehicular encencida y luz verde peatonal encendida
		RCALL delay_4s 
		CBI PORTD, 3
		LDI counter, 4				; 4 destellos de luz verde peatonal
		RET

destello_peaton:
		SBI PORTD, 3
		RCALL delay_250ms
		DEC counter
		BRNE destello_peaton
		SBI PORTD, 4
		RET

delay_loop:
		PUSH R19				; colocar en el Stack
		RET

delay_loop2:
		LDI R19, 250
		RET

dl_inner:
		NOP
		NOP
		DEC R19
		BRNE dl_inner
		DEC counter
		BRNE delay_loop2
		POP R19					; recuperar dato del Stack
		RET

delay_250ms:
		LDI counter, 62
		RET

d250_loop:
		RCALL delay_4ms
		DEC counter
		BRNE d250_loop
		RET

delay_50ms:
		LDI counter, 13
		RCALL delay_loop
		RET

delay_4ms:
		LDI counter, 250
		RET

d4ms_loop:
		NOP
		NOP
		DEC counter
		BRNE d4ms_loop
		RET

delay_1s:
		LDI counter, delay1
		RCALL delay_loop
		RET

delay_3s:
		RCALL delay_1s
		RCALL delay_1s
		RCALL delay_1s
		RET

delay_4s:
		RCALL delay_1s
		RCALL delay_1s
		RCALL delay_1s
		RCALL delay_1s
		RET

delay_5s:
		RCALL delay_1s
		RCALL delay_4s
		RET

delay_8s:
		RCALL delay_4s
		RCALL delay_4s
		RET



		



		




