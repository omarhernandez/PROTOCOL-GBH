;----------------------
;COMMON I/O            
;----------------------

STATUS	EQU	00H	; BIT0: R/W,  Zero.
			; BIT1: R/W,  Carry.
			; BIT2:
			; BIT3:

IOC_PA	EQU	02H	; R/W, PORT A IO CONTROL, '0'=INPUT, '1'=OUTPUT, PA3 input only.
DATA_PA	EQU	03H	; R/W, PORT A DATA READ/WRITE

PC_CTRL	EQU	04H	; BIT0: R/W, PORT C0 DATA READ/WRITE.
			; BIT1: R/W, PORT C0 IO CONTROL, '0'=INPUT, '1'=OUTPUT.
			; BIT2: R/W, PC0 wake up selection '0'= disable, '1'= enable.
			; BIT3: R/W, PC0 Pull up resistor '0'= disable, '1'= enable.

IOC_PB	EQU	05H	; R/W, PORT B IO CONTROL, '0'=INPUT, '1'=OUTPUT
DATA_PB	EQU	06H	; R/W, PORT B DATA READ/WRITE

USER1	EQU	07H	; R/W, General purpose user register1

IOC_PD	EQU	0CH	; R/W, PORT D IO CONTROL, '0'=INPUT, '1'=OUTPUT
DATA_PD	EQU	0DH	; R/W, PORT D DATA READ/WRITE

SCALER1	EQU	0EH	; R/W, SCALER is the pre-scaler of TIMER1
			; BIT1, BIT0
			;   0 ,  0: MCLK/8192
			;   1 ,  1: MCLK/4096
			;   1 ,  0: MCLK/2048
			;   1 ,  1: MCLK/1024
			; BIT2: Timer1 flge. 
			; BIT3: Timer1 control.
			;     0: Disable, timer1 counter clear 00H.
			;     1: Enabled.

USER2	EQU	0FH	; R/W, General purpose user register2

TIM1_L	EQU	11H	; R, Timer1 low nibble counter, first read
TIM1_H	EQU	12H	; R, Timer1 high nibble counter

IR_DIV	EQU	13H	; R/W, 
			; BIT2~BIT0  Divider     Duty      IR frequency
			;  0, 0, 0 :    x          x        PC1 signal
			;  0, 0, 1 : FIR/105  52/105(1/2)    38.09kHz
			;  0, 1, 0 : FIR/105     (1/3)       38.09kHz
			;  0, 1, 1 : FIR/70      (1/2)       57.14KHz
			;  1, 0, 0 : FIR/71   23/71(1/3)     56.33kHz
			;  1, 0, 1 : FIR/95   31/95(1/3)     42.10kHz
			;  1, 1, 0 : FIR/100  33/100(1/3)    40.00kHz
			;  1, 1, 1 : FIR/111     (1/3)       36.03kHZ
			; BIT3: R/W, PORT C1 DATA READ/WRITE(IR OUT).

DMA0	EQU	18H	; R/W,DATA ROM ADDRESS LOWEST POINTER
DMA1	EQU	19H	; R/W,2ND ADDRESS
DMA2	EQU	1AH	; R/W,3RD

DMDL	EQU	1CH	; R, Read rom data,LOW NIBBLE
DMDM	EQU	1DH	; R, Read rom data,Middle NIBBLE 
WDT	EQU	1DH	; W, WATCH DOG TIMER, WRITE 05H TO THIS REGISTER----CLEAR WDT
DMDH	EQU	1EH	; R, Read rom data,HIGH NIBBLE

;------------------------
;EXTENSION I/O 		
;------------------------
EXIOSTART.
PAPU		EQU	00H	; W, PORT A pull up control
PBPU		EQU	02H	; W, PORT B pull up control
PDPU		EQU	04H	; W, PORT D pull up control
PAWK		EQU	06H	; W, PORT A wake up control 
PBWK		EQU	07H	; W, PORT B wake up control 
PDWK		EQU	08H	; W, PORT D wake up control 
EXIOEND.