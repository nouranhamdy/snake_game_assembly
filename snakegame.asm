include irvine32.inc
.DATA
	mapwidth EQU 20
    mapheight EQU 20
	mapsize EQU mapwidth*mapheight
	headxpos DB ?
	headypos DB ?
	NEWX DB ?
	NEWY DB ?
	xMOVE DB ?
	yMOVE DB ?
	direction DB ?
	food DW 3
	running DB 1    ;boolean running = true
	map SWORD 400 DUP(?)
	MSG DB " !!!Game over!,  Your score is: "
	snake DW 'o'
	body DW 'O'
	frame DW 'X'
	

.CODE
MAIN PROC
   
	CALL RUN
	
main ENDP

RUN   PROC   
	  CALL initMap
	  MOV BL, running
WIL:
	  MOV EAX, 2000
      CALL delay
      CALL readkey
      JZ   REST    ;no key pressed
	  MOV direction, AL 
	  CALL changeDirection
REST:
	  CALL UPDATE
	  CALL clrscr
	  CALL printMap
	  MOV EAX, 500
      CALL delay    ;control speed of snake
	  CMP BL, 1
	  JE  WIL
	  MOV EDX, OFFSET MSG
	  CALL writestring
	  MOVZX EAX, food
	  CALL writeint
	  RET
RUN   ENDP

MOVE   PROC   
	   MOV BL, headxpos
	   ADD BL, xMOVE
	   MOV NEWX, BL
	   MOV CL, headypos
	   ADD CL, yMOVE
	   MOV NEWY, CL
	   MOV AL, mapwidth
	   MUL NEWY  ;AX=AL*NEWY
	   MOVZX DX, NEWX
	   ADD AX, DX
	   MOVZX ESI, AX   ;SI is map index
       CMP map[ESI*2], -2
	   JNE FREE
	   ADD food, 1
	   CALL generateFood
	   JMP CHANGE
FREE:  
	   MOVZX ESI, AX
	   CMP map[ESI*2], 0
	   JE CHANGE
	   MOV running, 0
CHANGE:
	   MOV BL, NEWX
	   MOV headxpos, BL
	   MOV CL, NEWY
	   MOV headypos, CL
	   MOV AL, mapwidth
	   MUL headypos  ;AX=AL*headypos
	   ADD AX, DX 
	   MOVZX ESI, AX   
	   ADD food, 1 
	   MOV AX, food
	   MOV map[ESI*2], AX
	   RET
MOVE   ENDP

UPDATE  PROC
		CMP direction, 0
		JNE CASE1
		MOV xMOVE, -1
		MOV yMOVE, 0
		MOVZX AX, xMOVE
		MOVZX BX, yMOVE
		;PUSH AX
		;PUSH BX
		CALL MOVE
		JMP BREAK
CASE1:
		CMP direction, 1
		JNE CASE2
		MOV xMOVE, 0
		MOV yMOVE, 1
		MOVZX AX, xMOVE
		MOVZX BX, yMOVE
		;PUSH AX
		;PUSH BX
		CALL MOVE
		JMP BREAK
CASE2:
		CMP direction, 2
		JNE CASE3
		MOV xMOVE, 1
		MOV yMOVE, 0
		MOVZX AX, xMOVE
		MOVZX BX, yMOVE
		;PUSH AX
		;PUSH BX
		CALL MOVE
		JMP BREAK
CASE3:
		CMP direction, 3
		JNE BREAK
		MOV xMOVE, 0
		MOV yMOVE, -1
		MOVZX AX, xMOVE
		MOVZX BX, yMOVE
		;PUSH AX
		;PUSH BX
		CALL MOVE
BREAK:
		    
		MOV ESI, 0        
UPDATELOOP:
		CMP map[ESI*2], 0
		JLE CONTINUE
		DEC map[ESI*2]
CONTINUE:
		INC ESI
		CMP ESI,400
		JB UPDATELOOP
		RET
UPDATE  ENDP

changeDirection PROC 
		MOV BL,direction
		CMP AL,'w'
		JNE RIGHT
		CMP BL,2
		JE RIGHT
		MOV BL,0
		JMP BREAK
RIGHT:
		CMP AL,'d'
		JNE DOWN
		CMP BL,3
		JE DOWN
		MOV BL,1
		JMP BREAK
DOWN:
		CMP AL,'s'
		JNE LEFT
		CMP BL,4
		JE LEFT
		MOV BL,2
		JMP BREAK
LEFT:
		CMP AL,'a'
		JNE BREAK
		CMP BL,5
		JE BREAK
		MOV BL,3
BREAK:
		MOV DL,AL
		RET 
		MOV direction,BL
changeDirection ENDP

generateFOOD PROC USES EAX EBX EDX ECX
generate:
		MOV EAX,19
		CALL RANDOMRANGE
		MOV ECX,EAX
		
		MOV EAX,19
		CALL RANDOMRANGE
		MOV EDX,EAX

		MOV AL,20
		MUL DL
		ADD BX,AX
		MOVZX EBX,BX
		SHL EBX,1
		CMP MAP[EBX*2],0
		JNE generate
		MOV MAP[EBX*2],-2
		RET
generateFOOD ENDP

initMap   PROC   
	      ;MOV AX, mapwidth
		  ;MOV AH, 2
		  ;DIV AH
		  MOV headxpos, 10
		  ;MOV AX, mapheight
		  ;MOV AH, 2
		  ;DIV AH
		  MOV headypos, 10
		  MOV AL, mapwidth
		  MUL headypos
		  MOVZX BX, headypos
		  ADD AX, BX
		  MOVZX ESI, AX
		  
		  MOV map[ESI*2], 01H
		  MOV SI, 0
		  
TBLOOP:

		
		  MOV map[ESI*2], -2
		  MOV AL, 19
		  
		  MOV BL, 20
		  MUL BL
		  ADD AX,SI
		  MOVZX EDI, AX
		 
		  MOV map[EDI*2], -2   ;THIS DOESN'T ASSIGN 
		  INC SI
		  MOVZX ESI,SI
		  CMP SI,20
		  JB TBLOOP
		  
		  MOV DL, 0   ;DL is map index
LRLOOP:
		  MOV AL, DL
		  MOV DH, mapwidth
		  MUL DH
		  MOVZX ESI, AX
		  MOV map[ESI], -1
		  
		  MOV BX,19
		  ADD BX,AX
		  MOVZX EDI, BX
		  MOV map[EDI], -1
		  INC DL
		 
		  CMP CX,20
		  JB LRLOOP
		  CALL generateFood
	      RET
initMap   ENDP



printMap PROC
		MOV CL,0
		MOV CH,0
innerloop:
		CMP CH,20
		JE  outerloop
		MOV AL,20
		MUL CH
		MOVZX DX,CL
		ADD AX,DX
		MOVZX ESI,AX
		;MOV BX,-2
		MOV BX,map[ESI]
		CALL getmapvalue
		MOVZX EAX,DL
		CALL WRITECHAR
		INC Ch
		JMP innerloop
outerloop:
		CMP CL,20
		JE Exitloop
		CALL CRLF
		INC CL

		JMP innerloop
Exitloop:
		RET
printMap ENDP

getmapvalue PROC
		;CMP BX,0
		;CMOVA DX,snake
		;CMP BX,-1
		;CMOVE DX,frame
		;CMP BX,-2
		;CMOVE DX,body
		;RET

		CMP BX,0
		JLE WALL
		MOV DL,'o'
		RET
	WALL:
		CMP BX,-1
		JNE SETFOOD
		MOV DL,'X'
		RET
	SETFOOD:
		CMP BX,-2
		JNE EXITGETMAP
		MOV DL,'O'
		RET
EXITGETMAP:
		RET
getmapvalue ENDP


; (insert additional procedures here)
END main