DATA_S SEGMENT
    MSG1 DB 0DH, 0AH, "ENTER FIRST STROKE :$"
    MSG2 DB 0DH, 0AH, "ENTER SECOND STROKE :$"
    MSG_FIRST DB 0DH, 0AH, "FIRST STROKE CONTAINS SECOND STROKE$"
    MSG_SECOND DB 0DH, 0AH, "SECOND STROKE CONTAINS FIRST STROKE$"
    MSG_NO DB 0DH, 0AH, "NO ENTRANCES$"
    STR1 DB 80, ?, 80 DUP(?)
    STR2 DB 80, ?, 80 DUP(?)
    COUNT DB ?
DATA_S ENDS
CODE_S SEGMENT
    ASSUME CS:CODE_S, DS:DATA_S
    WRITENUM PROC
        PUSHA
        MOV AL, COUNT
        MOV CX, 10
        MOV BX, 0
        ADDITION_LOOP:
            XOR DX, DX
            DIV CX
            ADD DL, '0'
            PUSH DX
            INC BX
            CMP AL, 0
            JNE ADDITION_LOOP
        PRINT_LOOP:
            POP DX
            MOV AH, 02H
            INT 21H
            DEC BX
            CMP BX, 0
            JNE PRINT_LOOP
        POPA
        RET
    WRITENUM ENDP

    STR_OUTPUT PROC
        PUSHA
        MOV AH, 09H
        INT 21H
        POPA
        RET
    STR_OUTPUT ENDP

    STR_INPUT PROC
        PUSHA
        MOV AH, 0AH
        INT 21H
        POPA
        RET
    STR_INPUT ENDP

    DELSUB PROC
		PUSH BP
		MOV	BP, SP
		PUSHA
		MOV	AX, DS
		MOV	ES, AX
		MOV	DI, [BP+4]		; HEAD ADDR
		ADD DI, [BP+6]		; DELPOS ADDR + 1
		DEC	DI			    ; DELPOS ADDR
		MOV	SI, DI
		ADD	SI, [BP+8]		; TAIL ADDR
		MOV	CX, [BP+4]		; HEAD ADDR
		ADD	CX, [BP+10]		; TAIL ADDR + "$"
		SUB	CX, SI			; DEL CHARS COUNT - 1
		INC	CX			; DEL CHARS COUNT
		CLD				; CLEAR D FLAG
		REP	MOVSB		; MOV (CX) CHARS
		POP	BP
 		POPA
		RET 8			; RETURN WITH CLEAR STACK
    DELSUB ENDP
    COUNT_ENTRANCES PROC
        PUSHA
        LEA SI, [STR1+2]   ; FIRST STROKE
        LEA DI, [STR2+2]   ; SECOND STROKE
        MOV DH, [STR1+1]   ; LENGTH STR1
        MOV DL, [STR2+1]   ; LENGTH STR2
        MOV CX, 0        ; ENTRANCE COUNTER
        MOV BX, 0        ; INDEX OF START
        
        CMP DH, DL
        JNB CMP_LOOP
        SWAP:   ; SWAPPING STR1 AND STR2
        XCHG SI, DI
        XCHG DH, DL
        CMP_LOOP:
        PUSH DL ; PUSH STR1, THEN STR2
        PUSH DH
        PUSH DI
        LEA SI, [SI + BX] ; ADDR OF STR = PREV ADDR + START
        PUSH SI
        CALL FIND_SUBSTR
        POP AX      ; INDEX OF ENTRANCE
        CMP AX, -1  ; NO MORE ENTRANCES
        JE EXIT 
        INC CX
        ADD BX, AX + DL ; INDEX OF START = INDEX OF ENTRANCE + SUBSTR LENGTH
        CMP BX, DH - DL ; INDEX OF START < LENGTH OF STR - SUBSTR
        JA EXIT
        JMP CMP_LOOP
        EXIT:
        MOV COUNT, CX
        POPA
        RET
    COUNT_ENTRANCES ENDP
    FIND_SUBSTR PROC
        PUSHA
        PUSH BP
        MOV BP, SP
        MOV SI, [BP+2]    ; STROKE
        MOV DI, [BP+4]  ; SUBSTROKE
        MOV CL, [BP+6]  ; LENGTH STROKE
        MOV CH, [BP+8]  ; LENGTH SUBSTROKE
        CMP CL, CH        ; LEN(STR) >= LEN(SUB)
        JB EXIT
        MOV DH, 0           ; INDEX OF CURRENT CHAR
        MOV DL, 0           ; INDEX OF FIRST ENTRANCE
        MOV BL, 0           ; NUMBER OF CHARACTERS FOUND IN A ROW
        NEXT_VAL:
            INC DH          ; INCREASE CHAR INDEX
            MOV AL, [SI]
            MOV AH, [DI + BX]
            INC SI          ; INCREASE CHAR ADDRESS
            CMP AL, AH      ; COMPARING CURRENT STRING CHAR
                            ; WITH INDEXED SUBSTRING CHAR
            JE EQUAL
            JMP NO
        NOT_EQUAL:
            MOV BL, 0       ; RESET COUNTER
            MOV DL, 0       ; RESET ENTRANCE INDEX
            MOV AH, [DI]
            CMP AL, AH
            JE EQUAL
            LOOP NEXT_VAL
            JMP NOT_FOUND          ; WASNT FOUND
        EQUAL:
            CMP DL, 0
            JNE SKIP_INDEX  ; IF CHAR IS NOT ENTRANCE
                MOV DL, DH
            SKIP_INDEX:
            INC BL          ; INCREASE SUBSTRING COUNTER
            CMP BL, CH      ; SUBSTR COUNTER == LENGTH OF SUBSTRING?
            JZ EXIT
            LOOP NEXT_VAL
        NOT_FOUND:
            MOV DL, -1
        RETURN:
            POP BP
            POPA
            PUSH DL
            RET
    FIND_SUBSTR ENDP
    START:
        MOV AX, DATA_S
        MOV DS, AX
        ; STR1
        LEA DX, MSG1
        CALL STR_OUTPUT
        LEA DX, STR1
        CALL STR_INPUT
        ; STR2
        LEA DX, MSG2
        CALL STR_OUTPUT
        LEA DX, STR2
        CALL STR_INPUT
        ; ARGS - STR1, STR2
        CALL COUNT_ENTRANCES
        POP AX          ; ISCONTAINS: -1 - NO, 0 - SECOND IN FIRST, 1 - FIRST IN SECOND
        CMP AX, 0
        JB NO
        JE SECOND
        FIRST:
        LEA DX, MSG_FIRST
        CALL WRITENUM
        JMP COUNT_OUTPUT
        SECOND:
        LEA DX, MSG_SECOND
        CALL WRITENUM
        JMP COUNT_OUTPUT
        NO:
        LEA DX, MSG_NO
        COUNT_OUTPUT:
        CALL STR_OUTPUT
        CALL WRITENUM
    QUIT:
        MOV AX, 4C00H
        INT 21H
CODE_S ENDS
END START