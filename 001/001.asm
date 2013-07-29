;51个键，T型键盘，6124/6124D7C13格式，40K载波
;Include Block
;;------------------------------------------------------------------------------
			#include "Custom.inc"
			#include "001.INC"
;;------------------------------------------------------------------------------
;R_Flag
F_KEYNOP		EQU	Bit0
F_KEYPRO		EQU	Bit1
F_SERIALKEY		EQU	Bit2
;R_CtrlFlag
D_LEDCtrl		EQU	Bit0				;LED 识别位。  0: 不带LED   1: 带LED
D_XtalCtrl		EQU	Bit1
;;------------------------------------------------------------------------------
D_KeyDebunceH		EQU	01H
D_KeyDebunceL		EQU	09H
FrameCycTimeH		EQU	02H		;45
FrameCycTimeL		EQU	0BH
;;------------------------------------------------------------------------------
;User Sram
;;------------------------------------------------------------------------------
;;MAH = 0
R_KeyCount		EQU	20H				;可共用
R_KeyDebunceL		EQU	21H
R_KeyBufL		EQU	22H
R_KeyBufH		EQU	23H
R_XorKeyValH		EQU	24H
R_XorKeyValL		EQU	25H
R_KeyValH		EQU	26H				;键值H
R_KeyValL		EQU	27H				;键值L
R_IrData0H		EQU	28H
R_IrData0L		EQU	29H
R_IrData1H		EQU	2AH
R_IrData1L		EQU	2BH
R_ShiftBufH		EQU	2CH
R_ShiftBufL		EQU	2DH
R_MainTimeH		EQU	2EH
R_MainTimeL		EQU	2FH
R_KeyNumH		EQU	30H
R_KeyNumL		EQU	31H
R_Flag			EQU	32H
R_Temp1			EQU	33H
R_Temp2			EQU	34H
R_Temp3			EQU	35H
R_KeyValL_C		EQU	36H
R_KeyValH_C		EQU	37H
R_KeyCnt		EQU	38H
R_CtrlFlag		EQU	39H
R_KeyDebunceH		EQU	3AH
R_Head			EQU	3BH
R_IrData0M		EQU	3CH

;-------------------------------------------------------------------------
MACRO	%CLRWDT
		LD	A,#05H
		LD	(WDT),A					; Clear Watch Dog Timer
		ENDM
;-------------------------------------------------------------------------
MACRO	%LED_ON
		LD	A,(R_CtrlFlag)
		AND	A,#D_LEDCtrl
		LDPCH	No_LED
		JZ	No_LED
LED_ON:
		LD	A,#2
		LD	(PC_CTRL),A				;setting pc0 output,Low
No_LED:
		ENDM
;-------------------------------------------------------------------------
MACRO	%LED_OFF
		LD	A,(R_CtrlFlag)
		AND	A,#D_LEDCtrl
		LDPCH	No_LED
		JZ	No_LED
LED_OFF:
		LD	A,#3
		LD	(PC_CTRL),A				;setting pc0 output,High
No_LED:
		ENDM
;-------------------------------------------------------------------------
MACRO	%Get_Option_SET
		LD	A,#T_LED_Xtal_Ctrl.n2
		LD	(DMA2),A
		LD	A,#T_LED_Xtal_Ctrl.n1
		LD	(DMA1),A
		LD	A,#T_LED_Xtal_Ctrl.n0				; PROM Address
		LD	(DMA0),A

		LD	A,(DMDL)
		LD	(R_CtrlFlag),A

		ENDM
;-------------------------------------------------------------------------
MACRO	%IO_OPTION_SET
;===============Option Process Start=====================================

		LD	A,(R_CtrlFlag)
		AND	A,#D_LEDCtrl
		LDPCH	LED_Not
		JZ	LED_Not
LED_Yes:
;PC0 As LED Ctrl
		LD	A,#3
		LD	(PC_CTRL),A				;setting pc0 output,High
		LDPCH	LED_Set_Over
		JMP	LED_Set_Over
LED_Not:
;PC0 As I/O For KeyScan
		LD	A,#0DH					;Bit1 Ctrl In/Out
		LD	(PC_CTRL),A				;setting pc0 Input,Pull High
LED_Set_Over:
;----------------
		LD	A,(R_CtrlFlag)
		AND	A,#D_XtalCtrl
		LDPCH	Xtal_In
		JZ	Xtal_In
Xtal_Out:
;PB0,PB1 As X'tal Pin  (X'tal Out)
		LD	A,#0CH					;PB0.PB1 As X'tal
		LD	EXIO(PBPU),A
		LD	EXIO(PBWK),A
		LDPCH	Xtal_Set_Over
		JMP	Xtal_Set_Over
Xtal_In:
;PB0,PB1 As I/O   (X'tal In)
		LD	A,#0FH					;PB0.PB1 As I/O
		LD	EXIO(PBPU),A
		LD	EXIO(PBWK),A
Xtal_Set_Over:
;===============Option Process End=======================================
;Inital Other I/O
;   	    	'0'=INPUT, '1'=OUTPUT
		LD	A,#0
		LD	(IOC_PA),A
		LD	(IOC_PB),A
		LD	(IOC_PD),A				;All as Input

;   	    	"0": Pull Up Disable  "1": Pull Up Enable
		LD	A,#0FH
		LD	EXIO(PAPU),A
		LD	EXIO(PDPU),A

;   	    	"0": Wake Up Disable  "1": Wake Up Enable
		LD	A,#0FH
		LD	EXIO(PAWK),A				;PA2 is LED , Don't Wakeup
		LD	EXIO(PDWK),A
		ENDM
;-------------------------------------------------------------------------
MACRO %NOP_20
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP

		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
ENDM
MACRO %NOP_10
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
ENDM
;-------------------
;PROGRAM START
;-------------------
		ORG	0
		LDPCH	RESET
		JMP	RESET
		NOP
		NOP
		LDPCH	Wakeup
		JMP	Wakeup
		nop
		nop
INT:
		NOP
		RETI
;-------------------
;MAIN PROGRAM
;-------------------
;		ORG	100H
RESET:
;Power ON, IR Output High
		LD	A,#08H
		LD	(IR_DIV),A				;PC1 output High
		LD	A,#3
		LD	(PC_CTRL),A				;setting pc0 output,High

		%Get_Option_SET
Wakeup:
;		%IO_OPTION_SET

		LD	A,#09H
		LD	(SCALER1),A				; enable timer MCLK/4096
;		LD	A,#0BH
;		LD	(SCALER1),A				; enable timer MCLK/1024
ClrRam:
		LD	A,#00H
		LD	(R_KeyCount),A
		LD	(R_KeyDebunceL),A
		LD	(R_KeyDebunceH),A
		LD	(R_KeyBufL),A
		LD	(R_KeyBufH),A
		LD	(R_XorKeyValH),A
		LD	(R_XorKeyValL),A
		LD	(R_KeyValH),A
		LD	(R_KeyValL),A
		LD	(R_IrData0H),A
		LD	(R_IrData0L),A
		LD	(R_IrData1H),A
		LD	(R_IrData1L),A
		LD	(R_ShiftBufH),A
		LD	(R_ShiftBufL),A
		LD	(R_MainTimeH),A
		LD	(R_MainTimeL),A
		LD	(R_KeyNumH),A
		LD	(R_KeyNumL),A
		LD	(R_Flag),A
		LD	(R_KeyCnt),A
		LD	(R_Head),A
		LD	(R_IrData0M),A

;*************************************************************************************
;		Main
;*************************************************************************************
MAIN_LOOP:
		%CLRWDT
		LD	A,(TIM1_L)
		CMP	A,(R_MainTimeL)
		LDPCH	MAIN_LOOP_S
		JNZ	MAIN_LOOP_S
		LD	A,(TIM1_H)
		CMP	A,(R_MainTimeH)
		LDPCH	MAIN_LOOP
		JZ	MAIN_LOOP
MAIN_LOOP_S:
		LDPCH	KeyScan
		JMP	KeyScan
KeyScanOver:
		LDPCH	SendControl
		JMP	SendControl
SendControlBack:
		LDPCH	SleepControl
		CALL	SleepControl

		LD	A,(TIM1_L)
		LD	(R_MainTimeL),A
		LD	A,(TIM1_H)
		LD	(R_MainTimeH),A
		LDPCH	MAIN_LOOP
		JMP	MAIN_LOOP

;*************************************************************************************
;	Key	Scan
;*************************************************************************************
KeyScan:
;*********************************** Scan POTRC
		%IO_OPTION_SET
		LD	A,#0
		LD	(R_KeyCnt),A
		LD	(R_KeyBufL),A
		LD	(R_KeyBufH),A
;================Scan VSS============================================
L_Check_VSS:
		LDPCH	Delay_Xus
		CALL	Delay_Xus

		LD	A,(R_CtrlFlag)
		AND	A,#D_LEDCtrl
		LDPCH	L_Vss_Ck_PC0
		JZ	L_Vss_Ck_PC0				;No LED

		INC	(R_KeyBufL)
		ADR	(R_KeyBufH)				;Has LED

		LDPCH	L_Vss_Ck_PD
		JMP	L_Vss_Ck_PD
L_Vss_Ck_PC0:
		;---------------------- Check PC.0
		LD	A,(PC_CTRL)
		AND	A,#01H
		LD	(R_Temp2),A

		CLR	C
		RLC	(R_Temp2)
		RLC	(R_Temp2)
		RLC	(R_Temp2)
		LD	A,#08H
		LD	(R_Temp1),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine
L_Vss_Ck_PD:
		;---------------------- Check PD
		LD	A,#01H
		LD	(R_Temp1),A
		LD	A,(DATA_PD)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine

;扫描PB口前，检测振荡类型
		LD	A,(R_CtrlFlag)
		AND	A,#D_XtalCtrl
		LDPCH	L_Vss_Ck_PB0_3
		JZ	L_Vss_Ck_PB0_3
;=1 外部振荡，扫描PB2..3
L_Vss_Ck_PB2_3:
;加键值
		CLR	C
		LD	A,#2
		ADC	A,(R_KeyBufL)
		LD	(R_KeyBufL),A
		ADR	(R_KeyBufH)
;从PB2开始扫。
		LD	A,#04H
		LD	(R_Temp1),A
		LD	A,(DATA_PB)
		AND	A,#0CH
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine

		LDPCH	L_Vss_Ck_PA
		JMP	L_Vss_Ck_PA
;=0 内部振荡，扫描PB0..3
L_Vss_Ck_PB0_3:
		;---------------------- Check PB
		LD	A,#01H
		LD	(R_Temp1),A
		LD	A,(DATA_PB)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine
L_Vss_Ck_PA:
		;---------------------- Check PA
		LD	A,#01H
		LD	(R_Temp1),A
		LD	A,(DATA_PA)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine

		LD	A,(R_KeyCnt)				;地线有键按下，不再扫其他键
		LDPCH	Check_Port_Over
		JNZ	Check_Port_Over

;		LD	A,(R_KeyCnt)
;		LDPCH	Check_PC0
;		JZ	Check_PC0
;		LDPCH	Delay_Xus
;		CALL	Delay_Xus
;		LDPCH	Delay_Xus
;		CALL	Delay_Xus
;		LDPCH	Delay_Xus
;		CALL	Delay_Xus

;=================Scan PC0====================================
Check_PC0:
		LD	A,(R_CtrlFlag)
		AND	A,#D_LEDCtrl
		LDPCH	L_Check_PC0
		JZ	L_Check_PC0				;No LED

		CLR	C
		LD	A,#12
		ADC	A,(R_KeyBufL)
		LD	(R_KeyBufL),A
		ADR	(R_KeyBufH)
		LDPCH	Check_PD
		JMP	Check_PD				;Has LED
;============================================================
L_Check_PC0:
		LD	A,#2
		LD	(PC_CTRL),A				;setting pc0 Output Low

		LDPCH	Delay_Xus
		CALL	Delay_Xus

		;---------------------- Check PD
		LD	A,#01H
		LD	(R_Temp1),A
		LD	A,(DATA_PD)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine

;扫描PB口前，检测振荡类型
		LD	A,(R_CtrlFlag)
		AND	A,#D_XtalCtrl
		LDPCH	L_PC0_Ck_PB0_3
		JZ	L_PC0_Ck_PB0_3
;=1 外部振荡，扫描PB2..3
L_PC0_Ck_PB2_3:
;加键值
		CLR	C
		LD	A,#2
		ADC	A,(R_KeyBufL)
		LD	(R_KeyBufL),A
		ADR	(R_KeyBufH)
;从PB2开始扫。
		LD	A,#04H
		LD	(R_Temp1),A
		LD	A,(DATA_PB)
		AND	A,#0CH
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine

		LDPCH	L_PC0_Ck_PA
		JMP	L_PC0_Ck_PA
;=0 内部振荡，扫描PB0..3
L_PC0_Ck_PB0_3:
		;---------------------- Check PB
		LD	A,#01H
		LD	(R_Temp1),A
		LD	A,(DATA_PB)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine
L_PC0_Ck_PA:
		;---------------------- Check PA
		LD	A,#01H
		LD	(R_Temp1),A
		LD	A,(DATA_PA)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine

		LD	A,#0DH
		LD	(PC_CTRL),A		;setting pc0 Intput High
;===============Scan PD0-3=============================================
Check_PD:

 		LD	A,#1
		LD	(IOC_PD),A				; setting inntal PD output LOW
		LD	A,#0
		LD	(DATA_PD),A
		LD	A,#4
		LD	(R_KeyCount),A

		LD	A,#01H
		LD	(R_Temp1),A
		LD	(R_Temp3),A
;============================================================
Check_PD_LOOP:
		CLR	C
		RLC	(R_Temp3)
		LD	A,(R_Temp3)
		LD	(R_Temp1),A

		LDPCH	Delay_Xus
		CALL	Delay_Xus
		;---------------------- Check PD
		LD	A,(DATA_PD)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine

Check_PD3:
;扫描PB口前，检测振荡类型
		LD	A,(R_CtrlFlag)
		AND	A,#D_XtalCtrl
		LDPCH	L_PD_Ck_PB0_3
		JZ	L_PD_Ck_PB0_3

;=1 外部振荡，扫描PB2..3
L_PD_Ck_PB2_3:
;加键值
		CLR	C
		LD	A,#2
		ADC	A,(R_KeyBufL)
		LD	(R_KeyBufL),A
		ADR	(R_KeyBufH)
;从PB2开始扫。
		LD	A,#04H
		LD	(R_Temp1),A
		LD	A,(DATA_PB)
		AND	A,#0CH
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine

		LDPCH	L_PD_Ck_PA
		JMP	L_PD_Ck_PA
;=0 内部振荡，扫描PB0..3
L_PD_Ck_PB0_3:
		;---------------------- Check PB
		LD	A,#01H
		LD	(R_Temp1),A

		LD	A,(DATA_PB)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine
L_PD_Ck_PA:
		;---------------------- Check PA
		LD	A,#01H
		LD	(R_Temp1),A
		LD	A,(DATA_PA)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine

		CLR	C
		RLC	(IOC_PD)
		LD	A,#0
		LD	(DATA_PD),A
		DEC	(R_KeyCount)				;可用R_Temp3做判断

		LD	A,(R_KeyCount)
		LDPCH	Check_PB
		JZ	Check_PB				;扫描退出
		CMP	A,#01H
		LDPCH	Check_PD_LOOP
		JNZ	Check_PD_LOOP

		LDPCH	Delay_Xus
		CALL	Delay_Xus
		LDPCH	Check_PD3
		JMP	Check_PD3				;PD3 Only Check PB,PA口

;===============Scan PB0-3=============================================
Check_PB:
;扫描PB口前，检测振荡类型
		LD	A,(R_CtrlFlag)
		AND	A,#D_XtalCtrl
		LDPCH	L_PB_Ck_PB0_3
		JZ	L_PB_Ck_PB0_3
;=1 外部振荡，扫描PB2..3
L_PB_Ck_PB2_3:
;加偏移键值
		CLR	C
		LD	A,#13					;7+6  PB0 7个键，PB1 6个键
		ADC	A,(R_KeyBufL)
		LD	(R_KeyBufL),A
		ADR	(R_KeyBufH)

 		LD	A,#Bit2					;PB2 开始扫描
		LD	(IOC_PB),A				; setting inntal PD output LOW
		LD	A,#0
		LD	(DATA_PB),A
		LD	A,#2
		LD	(R_KeyCount),A				;扫两根线

		LDPCH	Delay_Xus
		CALL	Delay_Xus

		LD	A,#04H	;Bit2
		LD	(R_Temp1),A
		LD	(R_Temp3),A

		LDPCH	Check_PB_LOOP
		JMP	Check_PB_LOOP

;=0 内部振荡，扫描PB0..3
L_PB_Ck_PB0_3:
 		LD	A,#1
		LD	(IOC_PB),A				; setting inntal PD output LOW
		LD	A,#0
		LD	(DATA_PB),A
		LD	A,#4
		LD	(R_KeyCount),A	     			;扫四根线

		LD	A,#01H
		LD	(R_Temp1),A
		LD	(R_Temp3),A
;============================================================
Check_PB_LOOP:
		CLR	C
		RLC	(R_Temp3)
		LD	A,(R_Temp3)
		LD	(R_Temp1),A

		LDPCH	Delay_Xus
		CALL	Delay_Xus

		;---------------------- Check PB
		LD	A,(DATA_PB)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine
Check_PB3:
		;---------------------- Check PA
		LD	A,#01H
		LD	(R_Temp1),A
		LD	A,(DATA_PA)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine

		CLR	C
		RLC	(IOC_PB)
		LD	A,#0
		LD	(DATA_PB),A
		DEC	(R_KeyCount)

		LD	A,(R_KeyCount)
		LDPCH	Check_PA
		JZ	Check_PA				;扫描PA口
		CMP	A,#01H
		LDPCH	Check_PB_LOOP
		JNZ	Check_PB_LOOP

		LDPCH	Delay_Xus
		CALL	Delay_Xus
		LDPCH	Check_PB3
		JMP	Check_PB3				;PB3 Only Check PA口

;===============Scan PA0-3=============================================
Check_PA:
		LD	A,#1
		LD	(IOC_PA),A				;setting inntal PA output LOW
		LD	A,#0
		LD	(DATA_PA),A
		LD	A,#4
		LD	(R_KeyCount),A

		LD	A,#01H
		LD	(R_Temp1),A
		LD	(R_Temp3),A
;============================================================
Check_PA_LOOP:
		CLR	C
		RLC	(R_Temp3)
		LD	A,(R_Temp3)
		LD	(R_Temp1),A

		LDPCH	Delay_Xus
		CALL	Delay_Xus

		;---------------------- Check PA
		LD	A,(DATA_PA)
		LD	(R_Temp2),A
		LDPCH	F_ReadKeyLine
		CALL	F_ReadKeyLine

		CLR	C
		RLC	(IOC_PA)
		LD	A,#0
		LD	(DATA_PA),A
		DEC	(R_KeyCount)

		LD	A,(R_KeyCount)
		LDPCH	Check_Port_Over
		JZ	Check_Port_Over				;扫描Port结束
		CMP	A,#01H
		LDPCH	Check_PA_LOOP
		JNZ	Check_PA_LOOP

;============================================================
Check_Port_Over:
		LD	A,(R_KeyCnt)
		CMP	A,#1
		LDPCH	Check_Port_Over_SingleKey
		JZ	Check_Port_Over_SingleKey
Check_Port_Over_NoOrMultiKey:			;无按键或双键都认为是无按键
		LD	A,#0
		LD	(R_KeyValL_C),A
		LD	(R_KeyValH_C),A
		;LD	(R_KeyCnt),A
Check_Port_Over_SingleKey:		;判断按键状态与之前状态是否有变化
		LD	A,(R_KeyValL)
		CMP	A,(R_KeyValL_C)
		LDPCH	Check_Port_Over_UnSameKey
		JNZ	Check_Port_Over_UnSameKey
		LD	A,(R_KeyValH)
		CMP	A,(R_KeyValH_C)
		LDPCH	Check_Port_Over_SameKey
		JZ	Check_Port_Over_SameKey
Check_Port_Over_UnSameKey:			;有变化，则R_KeyDebunce=0
		LD	A,#0
		LD	(R_KeyDebunceL),A
		LD	(R_KeyDebunceH),A
		LD	A,(R_KeyValL_C)
		LD	(R_KeyValL),A
		LD	A,(R_KeyValH_C)
		LD	(R_KeyValH),A
Check_Port_Over_SameKey:
		CLR	C
		LD	A,(R_KeyDebunceH)
		CMP	A,#D_KeyDebunceH
		LDPCH	_Debunce_Inc
		JC	_Debunce_Inc
		LD	A,(R_KeyDebunceL)
		CMP	A,#D_KeyDebunceL		
		LDPCH	KeyControl
		JNC	KeyControl
_Debunce_Inc:		
		CLR	C
		LD	A,(R_KeyDebunceL)
		ADC	A,#1
		LD	(R_KeyDebunceL),A
		LD	A,(R_KeyDebunceH)
		ADC	A,#0
		LD	(R_KeyDebunceH),A	
		LDPCH	SCAN_KEY_EXIT
		JMP	SCAN_KEY_EXIT
KeyControl:
		LD	A,(R_KeyCnt)
		CMP	A,#01H
		LDPCH	HaveKeyDn
		JZ	HaveKeyDn
NotKeyDn:								;No Key Down
		LD	A,(R_Flag)
		OR	A,#F_KEYNOP
		AND	A,#09H					;F_KEYPRO+F_SERIALKEY\
		LD	(R_Flag),A
		
		LDPCH	SCAN_KEY_EXIT
		JMP	SCAN_KEY_EXIT
HaveKeyDn:	;Key Down
		LD	A,(R_Flag)
		OR	A,#F_KEYPRO
		AND	A,#0EH					;F_KEYNOP\
		LD	(R_Flag),A
SCAN_KEY_EXIT:
		LDPCH	KeyScanOver
		JMP	KeyScanOver
;===============================================================
F_ReadKeyLine:
L_ReadKeyLine_LP:
		INC	(R_KeyBufL)
		ADR	(R_KeyBufH)

		LD	A,(R_Temp2)
		AND	A,(R_Temp1)
		LDPCH	KEY_DOWN_PRO
		JZ	KEY_DOWN_PRO
READ_KEY_LINE_1:
		CLR	C
		RLC	(R_Temp1)
		LDPCH	L_ReadKeyLine_LP
		JNC	L_ReadKeyLine_LP
		LDPCH	READ_KEY_LINE_NEXT
		JMP	READ_KEY_LINE_NEXT
KEY_DOWN_PRO:
		INC	(R_KeyCnt)
		LD	A,(R_KeyBufL)
		LD	(R_KeyValL_C),A
		LD	A,(R_KeyBufH)
		LD	(R_KeyValH_C),A
		LDPCH	READ_KEY_LINE_1
		JMP	READ_KEY_LINE_1
READ_KEY_LINE_NEXT:
		RETS
;*******************************************************************
;	      发码程序
;    Head_H:9MS+Head_L:4.5MS+C0-8+C0-8\+D0-8+D0-8\
;*******************************************************************
SendControl:
		LD	A,(R_Flag)
		AND	A,#F_KEYPRO
		LDPCH	SendCode
		JNZ	SendCode
		LDPCH	SendControlBack
		JMP	SendControlBack
SendCode:
		LD	A,(R_Flag)
		AND	A,#0DH	;F_KEYPRO\
		LD	(R_Flag),A

		LD	A,#T_KeyValueTable.n2
		LD	(DMA2),A
		LD	A,#T_KeyValueTable.n1
		LD	(DMA1),A
		LD	A,#T_KeyValueTable.n0			; PROM Address
		LD	(DMA0),A

		CLR	C
		LD	A,(R_KeyValL)
		SBC	A,#1
		LD	(R_Temp1),A
		LD	A,(R_KeyValH)
		SBC	A,#0
		LD	(R_Temp2),A

		CLR	C
		LD	A,(DMA0)
		ADC	A,(R_Temp1)
		LD	(DMA0),A
		LD	A,(DMA1)
		ADC	A,(R_Temp2)
		LD	(DMA1),A
		LD	A,(DMA2)
		ADC	A,#0
		LD	(DMA2),A
;
		;Get KeyValue
		LD	A,(DMDM)
		CMP	A,#0FH
		LDPCH	L_Valid_Key
		JNZ	L_Valid_Key
		LD	A,(DMDL)
		CMP	A,#0FH
		LDPCH	L_Valid_Key
		JNZ	L_Valid_Key

		LD	A,(R_Flag)
		AND	A,#0DH	;F_KEYPRO\
		LD	(R_Flag),A

		LDPCH	SendControlBack
		JMP	SendControlBack

L_Valid_Key:
		LD	A,(DMDH)
		LD	(R_Head),A
		LD	A,(DMDM)
		LD	(R_KeyNumH),A
		LD	A,(DMDL)
		LD	(R_KeyNumL),A

		LD	A,#T_CustomerTable.n2
		LD	(DMA2),A
		LD	A,#T_CustomerTable.n1
		LD	(DMA1),A
		LD	A,#T_CustomerTable.n0
		LD	(DMA0),A

		CLR	C
		LD	A,(DMA0)
		ADC	A,(R_Head)
		LD	(DMA0),A
		ADR	(DMA1)
		ADR	(DMA2)

		;Get Customer
		LD	A,(DMDH)
		LD	(R_IrData0H),A
		LD	A,(DMDM)
		LD	(R_IrData0M),A
		LD	A,(DMDL)
		LD	(R_IrData0L),A

		LDPCH	Ready_Key_Customer
		CALL	Ready_Key_Customer
SendHeadCode:
		LD	A,(R_Flag)
		AND	A,#F_SERIALKEY
		LDPCH	SendRepeatCode
		JNZ	SendRepeatCode
		LD	A,(R_Flag)
		OR	A,#F_SERIALKEY
		LD	(R_Flag),A
		LDPCH	StartSendCode
		JMP	StartSendCode
SendRepeatCode:
		%CLRWDT
		CLR	C
		LD	A,(TIM1_L)
		SBC	A,#FrameCycTimeL
		LD	A,(TIM1_H)
		SBC	A,#FrameCycTimeH
		LDPCH	SendControlBack
		JC	SendControlBack
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;---------------------------- START PROTOCOL ---------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------

StartSendCode:
		CLR	#3,(SCALER1)
		SET	#3,(SCALER1)

		LDPCH	DelayHeadH
		CALL	DelayHeadH
		LDPCH	DelayHeadL
		CALL	DelayHeadL
SendCodeBitLoop:
		RRC	(R_IrData0H)
		RRC	(R_IrData0M)
		RRC	(R_IrData0L)
		RRC	(R_KeyNumH)
		RRC	(R_KeyNumL)
		LDPCH	SendCodeBit0
		JNC	SendCodeBit0
SendCodeBit1:
		LDPCH	DelayBit1H
		CALL	DelayBit1H
		LDPCH	DelayBitL
		CALL	DelayBitL
		LDPCH	SendCodeBitJump
		JMP	SendCodeBitJump
SendCodeBit0:
		LDPCH	DelayBit0H
		CALL	DelayBit0H
		LDPCH	DelayBitL
		CALL	DelayBitL
		NOP
		NOP
SendCodeBitJump:
		CLR	C
		LD	A,(R_ShiftBufL)
		SBC	A,#1
		LD	(R_ShiftBufL),A
		LD	A,(R_ShiftBufH)
		SBC	A,#0
		LD	(R_ShiftBufH),A
		LD	A,(R_ShiftBufL)
		LDPCH	SendCodeBitLoop
		JNZ	SendCodeBitLoop
		LD	A,(R_ShiftBufH)
		LDPCH	SendCodeBitLoop
		JNZ	SendCodeBitLoop

		LDPCH	SendControlBack
		JMP	SendControlBack

;***********************************************************************************
;		Sleep Control
;***********************************************************************************
SleepControl:
		LD	A,(R_KeyCnt)
		LDPCH	SleepControlExit
		JNZ	SleepControlExit

		LD	A,(R_Flag)
		AND	A,#F_KEYNOP
		LDPCH	SleepControlExit
		JZ	SleepControlExit

		LD	A,#08H
		LD	(IR_DIV),A

		%IO_OPTION_SET

HaltDelay:
		LD	A,#15
		LD	(DMA0),A
HaltDelayA:
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		DEC	(DMA0)
		LDPCH	HaltDelayA
		JNZ	HaltDelayA

		HALT
		NOP
		NOP
		NOP
SleepControlExit:
		RETS
;----------------------------------------------
Delay_Xus:
		LD	A,#15
		LD	(DMA0),A
Delay_XusA:
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		DEC	(DMA0)
		LDPCH	Delay_XusA
		JNZ	Delay_XusA
		RETS

;----------------------------------------------
Ready_Key_Customer:
		LD	A,(R_Head)
		LDPCH	Ready_6124_C5
		JZ	Ready_6124_C5
Ready_6124_C13_CODE:
		CLR	C
		RLC	(R_KeyNumL)
		RLC	(R_KeyNumH)

		CLR	C
		RRC	(R_IrData0H)
		RRC	(R_IrData0M)
		RRC	(R_IrData0L)
		RRC	(R_KeyNumH)
		RRC	(R_KeyNumL)

		LD	A,#01H
		LD	(R_ShiftBufH),A
		LD	A,#04H
		LD	(R_ShiftBufL),A
		RETS
Ready_6124_C5:
		CLR	C
		RLC	(R_KeyNumL)
		RLC	(R_KeyNumH)


		CLR	C
		RRC	(R_IrData0M)
		RRC	(R_IrData0L)
		RRC	(R_KeyNumH)
		RRC	(R_KeyNumL)

		LD	A,#00H
		LD	(R_ShiftBufH),A
		LD	A,#0CH
		LD	(R_ShiftBufL),A
		RETS
;----------------------------------------------
DelayHeadH:		;2400
		LD	A,#00H
		LD	(R_Temp1),A
		LD	A,#06H
		LD	(R_Temp2),A
		LD	A,#00H
		LD	(R_Temp3),A
		LDPCH	L40KH_CW_OUTA
		JMP	L40KH_CW_OUTA
;----------------------------------------------
DelayBit1H:		;1200
		LD	A,#00H
		LD	(R_Temp1),A
		LD	A,#03H
		LD	(R_Temp2),A
		LD	A,#00H
		LD	(R_Temp3),A
		LDPCH	L40KH_CW_OUTA
		JMP	L40KH_CW_OUTA
;----------------------------------------------
DelayBit0H:		;600
		LD	A,#08H
		LD	(R_Temp1),A
		LD	A,#01H
		LD	(R_Temp2),A
		LD	A,#00H
		LD	(R_Temp3),A
;----------------------------------------------
L40KH_CW_OUTA:	;34/66					;25us
		LD	A,#00H
		LD	(IR_DIV),A
;---32NOP
		LD	A,#7
		LD	(DMA0),A
		NOP
		NOP
Delay40KHH:
		NOP
		DEC	(DMA0)
		LDPCH	Delay40KHH
		JNZ	Delay40KHH

		LD	A,#08H
		LD	(IR_DIV),A			;34
;---45NOP
		LD	A,#14
		LD	(DMA0),A
		NOP
Delay40KHL:
		DEC	(DMA0)
		LDPCH	Delay40KHL
		JNZ	Delay40KHL


		CLR	C
		LD	A,(R_Temp1)			;
		SBC	A,#1
		LD	(R_Temp1),A
		LD	A,(R_Temp2)
		SBC	A,#0
		LD	(R_Temp2),A
		LD	A,(R_Temp3)
		SBC	A,#0
		LD	(R_Temp3),A
		LD	A,(R_Temp1)
		LDPCH	L40KH_CW_OUTL1
		JNZ	L40KH_CW_OUTL1			;19
		LD	A,(R_Temp2)
		LDPCH	L40KH_CW_OUTL2
		JNZ	L40KH_CW_OUTL2			;19
		LD	A,(R_Temp3)
		LDPCH	L40KH_CW_OUTA
		JNZ	L40KH_CW_OUTA			;19

		RETS
L40KH_CW_OUTL1:
		NOP
		NOP
		NOP
L40KH_CW_OUTL2:
		NOP
		LDPCH	L40KH_CW_OUTA
		JMP	L40KH_CW_OUTA
;----------------------------------------------
DelayHeadL:		;600
		LD	A,#06H
		LD	(R_Temp1),A
		LD	A,#07H
		LD	(R_Temp2),A
		LD	A,#00H
		LD	(R_Temp3),A
		LDPCH	DelayBitLLoop
		JMP	DelayBitLLoop
;----------------------------------------------
DelayBitL:		;600
		LD	A,#05H
		LD	(R_Temp1),A
		LD	A,#07H
		LD	(R_Temp2),A
		LD	A,#00H
		LD	(R_Temp3),A
;----------------------------------------------
DelayBitLLoop:			;5us
		LD	A,(R_Temp1)
		LDPCH	DelayBitLA1
		JNZ	DelayBitLA1
		LD	A,(R_Temp2)
		LDPCH	DelayBitLA2
		JNZ	DelayBitLA2
		LD	A,(R_Temp3)
		LDPCH	DelayBitLA
		JNZ	DelayBitLA
		RETS
DelayBitLA1:
		NOP
		NOP
		NOP
DelayBitLA2:
		NOP
		NOP
		NOP
DelayBitLA:
		NOP
		CLR	C
		DEC	(R_Temp1)
		LD	A,(R_Temp2)
		SBC	A,#0
		LD	(R_Temp2),A
		LD	A,(R_Temp3)
		SBC	A,#0
		LD	(R_Temp3),A
		LDPCH	DelayBitLLoop
		JMP	DelayBitLLoop
;-------------------------------------------------------------------------------
;		ORG	540H
;-------------------------------------------------------------------------------
T_LED_Xtal_Ctrl:
		PDW	00H
;		PDW	00H		;Bit1:Xtal In  Bit0:LED No,
;		PDW	01H		;Bit1:Xtal In  Bit0:LED YES,
;		PDW	02H		;Bit1:Xtal Out Bit0:LED No,
;		PDW	03H		;Bit1:Xtal Out Bit0:LED YES,
;-------------------------------------------------------------------------------
T_CustomerTable: 	;低------------------------------->高
	;Customer	 1    2    3    4    5    6    7    8
		PDW	001H,93AH,C5AH,0FFH,0FFH,0FFH,0FFH,0FFH
;-------------------------------------------------------------------------------
T_KeyValueTable:	;键值:低+高

	PDW	014H	;S01
	PDW	070H	;S02
	PDW	039H	;S03
	PDW	04FH	;S04
	PDW	00FH	;S05
	PDW	040H	;S06
	PDW	052H	;S07
	PDW	020H	;S08
	PDW	054H	;S09
	PDW	06BH	;S10
	PDW	074H	;S11
	PDW	050H	;S12
	PDW	060H	;S13
	PDW	010H	;S14
	PDW	04AH	;S15
	PDW	030H	;S16
	PDW	038H	;S17
	PDW	017H	;S18
	PDW	057H	;S19
	PDW	003H	;S20
	PDW	053H	;S21
	PDW	048H	;S22
	PDW	024H	;S23
	PDW	02EH	;S24
	PDW	000H	;S25
	PDW	004H	;S26
	PDW	06EH	;S27
	PDW	044H	;S28
	PDW	064H	;S29
	PDW	068H	;S30
	PDW	07FH	;S31
	PDW	034H	;S32
	PDW	016H	;S33
	PDW	07FH	;S34
	PDW	07FH	;S35
	PDW	063H	;S36
	PDW	066H	;S37
	PDW	036H	;S38
	PDW	008H	;S39
	PDW	016H	;S40
	PDW	0FFH	;S41
	PDW	0FFH	;S42
	PDW	0FFH	;S43
	PDW	0FFH	;S44
	PDW	0FFH	;S45
	PDW	0FFH	;S46
	PDW	0FFH	;S47
	PDW	0FFH	;S48
	PDW	0FFH	;S49
	PDW	0FFH	;S50
	PDW	0FFH	;S51
	PDW	0FFH	;S52
	PDW	0FFH	;S53
	PDW	0FFH	;S54
	PDW	0FFH	;S55
	PDW	0FFH	;S56
	PDW	0FFH	;S57
	PDW	0FFH	;S58
	PDW	0FFH	;S59
	PDW	0FFH	;S60
	PDW	0FFH	;S61
	PDW	0FFH	;S62
	PDW	0FFH	;S63
	PDW	0FFH	;S64
	PDW	0FFH	;S65
	PDW	0FFH	;S66
	PDW	0FFH	;S67
	PDW	0FFH	;S68
	PDW	0FFH	;S69
	PDW	0FFH	;S70
	PDW	0FFH	;S71
	PDW	0FFH	;S72
	PDW	0FFH	;S73
	PDW	0FFH	;S74
	PDW	0FFH	;S75
	PDW	0FFH	;S76
	PDW	0FFH	;S77
	PDW	0FFH	;S78
	PDW	0FFH	;S79
	PDW	0FFH	;S80
	PDW	0FFH	;S81
	PDW	0FFH	;S82
	PDW	0FFH	;S83
	PDW	0FFH	;S84
	PDW	0FFH	;S85
	PDW	0FFH	;S86
	PDW	0FFH	;S87
	PDW	0FFH	;S88
	PDW	0FFH	;S89
	PDW	0FFH	;S90
	PDW	0FFH	;S91