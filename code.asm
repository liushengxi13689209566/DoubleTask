DELAY_TIME	EQU	02h	;��ʱʱ�����
MAXBODY		EQU	100
HIGHT		EQU	20
WIDE		EQU	30	;0~WIDE , or  wide+1
WIN_LENTH	EQU	10	;��ʤ����
;HEAD_CHAR	EQU	'#'
BODY_CHAR	EQU	'*'
SNASTACKOFFSET	EQU	127
TRISTACKOFFSET	EQU	127
kEsc		EQU	27
kTab		EQU	9
FOOD		EQU	'+'
SCx			EQU 0
SCy			EQU HIGHT+1

;tri
triScr_x	EQU 320
triScr_w	EQU 320
triScr_h	EQU 350		;������Ļ���ԣ���֤ͼ���ڽ�������
	
	
DATAS SEGMENT
    ;�˴��������ݶδ���  
    ;debug
	s	db '12345$'
	stri	db 'tri$'
	ssna	db 'snack$'
    ;debug end
    ;printInt
	printInt_div        DW 10000, 1000, 100, 10, 1
	printInt_res        DB 0,0,0,0,0,"$"        ;�����λ��ASCII��
    ;end
    ;main
    	space	db  '                                $'
    ;end
    ;snake
    	;ȫ�ֱ���
    	    HEAD_CHAR	db '#'
	    m		db 0
	    x		db 0
	    y		db 0
	    fx		db 0
	    fy		db 0
	    ta		db 0
	    blength	db 2
	    sbody_move	db 0
	    sbody	db MAXBODY dup(0)
	    pause	db 'press r to reload$'
    	;�ֲ�����
	    win		db 0
	    de		db 0
	    gameover	db 0
	    fe		db 0
	    winMSG	db 'Gameover...$'
	    loseMSG	db 'You are winner!$'
    ;end
    ;tri
    
    tribx	dw 0
    triYd dw 173
	triXd dw 100
	triP  dw 0 			;���������㷨��Ҫ�ı���
					
	triFlag db 0		;��n�ε���triHypotenuse
	triEx dw 0			;��¼���λ����յ������
	
	triLeftX dw 0		;��¼��˵������
	triRightX dw 0		;��¼�Ҷ˵������	
	triHengY dw 0		;��¼�ױ������	�����������������ߺ���ʹ�ã�
	
	triLenth dw 0		;��¼�߳����������Ҫ����AX��
	note	db '>=2 and <=320:$'
    ;end
    ;yield
    	    yFunc		db 0	;0 is tri
    	    stack_tri_sp	dw 0
    	    stack_snake_sp	dw 0
    ;end
    ;rand
    	    rseed	dw ?
    	    rcnt	dw ?
    ;end
DATAS ENDS
STACK_SNAKE segment
	SStack db 128 dup(0)
STACK_SNAKE ENDS
STACK_RTI segment
	TStack db 128 dup(0)
STACK_RTI ends
CODE SEGMENT
main proc 
	assume cs:code,ds:datas
	mov AX,DATAS
	mov DS,AX
	
		
		;main_init
		mov al,10h
		mov ah,0	  		
		int 10h		;������ʾģʽ
		
		call sInit
		;yield init
		mov ax,offset TStack
		add ax,TRISTACKOFFSET
		mov stack_tri_sp,ax
		
		mov dx,ss
		mov bx,sp	;�ݴ�
		mov ax,STACK_SNAKE
		mov ss,ax
		mov ax,offset SStack
		mov sp,ax 	;���������tri ����Ҫ��snake��ʼ�ϵ����ú�
		add sp,SNASTACKOFFSET
		mov ax,snake
		push ax	;�ȱ���snake�ϵ�
		mov cx,8	;����flagsһ��8���Ĵ���
		mov ax,0
	mInitYLp:
			push ax
		loop mInitYLp
		
		mov stack_snake_sp,sp
	
		mov sp,bx	;��ԭ
		mov ss,dx
	
		;
		
		mov ax,STACK_RTI
		mov ss,ax
		mov sp,stack_tri_sp
		call tri
		
		
	mov AH,4ch
	int 21h	
main endp

yield proc
		pushf	;�ȱ���һ��flags
		cmp ax,0 ;�ж��Ƿ���esc
		jne yEls1
			mov AH, 4CH	;esc exit
      			int 21h	
	yEls1:
		;��tab���������Լ���ջ�ﱣ��Ĵ���,
		push ax
		push bx
		push cx
		push dx
		push di
		push si
		push bp
		
		;���л�ջ���ָ���һ��Ĵ���
		cmp yFunc,0	;��ǰ��tri?
		je yTri

			mov stack_snake_sp,sp
			mov sp,stack_tri_sp		;��ǰ��1:snake��Ҫ�л���tri
			mov ax,STACK_RTI
			mov ss,ax		
			mov yFunc,0

			jmp yTriEd
	yTri:
			mov stack_tri_sp,sp
			mov sp,stack_snake_sp		;��ǰ��0:tri��Ҫ�л���snake
			mov ax,STACK_SNAKE
			mov ss,ax
			mov yFunc,1
		;�ָ��Ĵ���
	yTriEd:

		pop bp
		pop si
		pop di
		pop dx
		pop cx
		pop bx
		pop ax
		popf
		ret	;�л�
yield endp

snake proc
	pushf
	push ax
	push bx
	push di
	

	sstart:	;��ѭ��
		call sInit ;̰���߳�ʼ��
	sBigLp:	cmp gameover,0		;forѭ��ͷ��
		je sBigLpBkElse 	;����ѭ������
		jmp sBigLpBk	;ת����Զת��
	sBigLpBkElse:
			;ѭ����
			call sMove
			
			;�ж��Ƿ�ײǽ
			cmp x,WIDE		
			jae sIfThen
			cmp x,1
			jb sIfThen
			cmp y,HIGHT
			jae sIfThen
			cmp y,1
			jb sIfThen
			jmp sIfElse
		sIfThen:
			jmp sBigLpBk		;break big loop
		sIfElse:
			;�ж��Ƿ�ҧ���Լ�
			mov bh,0
			mov bl,1	;i
		sForHd1:			;for(    )
			cmp bl,blength
			jbe sForBk1Else		;��������
				jmp sForBk1	;ת����Զת��
			sForBk1Else:
				
				mov al,x	;if
				mov di,bx
				shl di,1
				cmp sbody[di],al;sbody[bx*2+0]
				jne sIfElse2
				mov al,y
				inc di
				cmp sbody[di],al;sbody[bx*2+1]
				jne sIfElse2
				mov gameover,1
				jmp sForBk1
			sIfElse2:
						;end for.ѭ�������(    )
			inc bl
			jmp sForHd1
			sForBk1:	;for�ⲿ
			cmp gameover,1		;gameover?
			je sBigLp
			
			call kbhit	;if(   kbhit()   )
			jnz nonImput
				mov al,m
				mov ta,al	;����m
				call getch	;read in
					;�ж������ַ���tab��esc��r�����¿�ʼ��
				cmp al,kEsc
				jne nKEsc
					mov ax,0	;kEsc
					call yield
					;exit
			nKesc:
				cmp al,kTab
				jne nKTab
					mov ax,1	;kTab
					call yield
					jmp nonImput
			nKTab:
				cmp al,'r'
				jnz sNR
					jmp sstart	;reload
			sNR:
				
				mov ah,ta
			
				;�ĸ��жϣ����ܵ���
				;m==a && ta==d
				cmp al,'a'
				jne sIfElseA
				mov m,al
				cmp ah,'d'
				jne sIfElseA
				jmp sIfY
			sIfElseA:	
				;�ڶ��� 
				cmp al,'d'
				jne sIfElseB
				mov m,al
				cmp ah,'a'
				jne sIfElseB
					jmp sIfY
			sIfElseB:
				;������ m==w && ta==s
				cmp al,'w'
				jne sIfElseC
				mov m,al
				cmp ah,'s'
				jne sIfElseC
				jmp sIfY
			sIfElseC:
				;���ĸ�
				cmp al,'s'
				jne sIfElseD
				mov m,al
				cmp ah,'w'
				jne sIfElseD
				jmp sIfY
			sIfElseD:
				jmp sIfN
			sIfY:
				mov m,ah	;m=ta
			sIfN:
		nonImput:	;end kbhit end if (    )
		
			;if(x==fx && y==fy)
			mov al,x
			mov ah,y
			cmp al,fx
			jne sIfElse3
			cmp ah,fy
			jne sIfElse3
				inc blength	;x==fx && y==fy
				mov bx,offset sbody
				mov ah,0
				mov al,blength
				shl ax,1
				add bx,ax
				mov al,-1
				mov [bx],al
				
				mov fe,0
		sIfElse3:
			cmp blength,WIN_LENTH
			jb sIfElse4
				mov win,1		;blength>=20 
				jmp sBigLpBk
		sIfElse4:
			;call sMap
			cmp fe,0
			jne sIfElse5
				call sFood	;fe==0	ʳ�ﲻ���ڲ���ʳ��
				mov fe,1
		sIfElse5:
			mov al,fy	;y	���ʳ��
			mov bl,fx	;x	���ʳ��
			call movCursor
			mov al,FOOD
			call putchar
			;�ƶ����
			mov al,SCY
			mov bl,0
			call movCursor
			cmp de,1
			jne sIfElse6
				mov ax,DELAY_TIME	;de==1
				call sDelay	
				jmp sIfEnd6
		sIfElse6:
				mov de,1
		sIfEnd6:
		
		
		;�� for( ; gameover==0  ;    )����
		jmp sBigLp
	sBigLpBk:
		cmp win,0
		je sIfElse7
			mov ax,offset loseMSG
			call puts	;win==0��lose
			jmp sIfEnd7
	sIfElse7:
			mov ax,offset winMSG
			call puts
	sIfEnd7:
		mov ax,offset pause
		call puts
	spauseLp:
		call getch
		cmp al,'r'
		je spauseLpBk
		cmp al,kEsc
		jne sifEls7
			mov ax,0
			call yield;exit
	sifEls7:	
		cmp al,kTab
		jne sifEls8
			;tab
			mov ax,1
			call yield
	sifEls8:
		jmp spauseLp
	spauseLpBk:
	jmp sstart	; ��ѭ��
	pop di
	pop bx
	pop ax
	popf
	ret
snake endp

sFood proc
	pushf
	push ax
	push bx
	sFStart:
		mov ax,WIDE-2	;x
		call rand
		mov fx,al
		
		mov ax,HIGHT-2	;y
		call rand
		mov fy,al
	
		
		
		;food�����������ͷ��
		mov al,fx		;ͷ��
		cmp x,al
		jne sFIfEd
		mov al,fy
		cmp fy,al
		jne sFIfEd
		jmp sFStart
	sFIfEd:
		
		mov bh,0		;����
		mov bl,blength		
	sFLp:			
			mov al,fx
			mov di,bx
			shl di,1
			cmp sbody[di],al	;if(sbody[bx].x==fx && .y==fy)
			jne sFEnd
			mov al,fy
			inc di
			cmp sbody[di],al
			jne sFEnd
					;��������������
			jmp sFStart	;ʳ���������ڣ��������������
			dec bx
		sFEnd:	
		
	pop bx
	pop ax
	popf
	ret
sFood endp
sInit proc
	pushf
	push ax
	push bx
		mov blength,2 ;���blength����4������Ҫ������ʼ���߼����������һ��bug
		mov m,'d'
		mov x,10
		mov y,10
		mov bx,1
		shl bx,1
		mov ch,0
		mov cl,blength
	sInitLp0:
		
		
		
		mov sbody[bx],10	;mov sbody[bx*2+0],8
		inc bx
		mov sbody[bx],10;mov sbody[bx*2+1],10
		inc bx
		loop sInitLp0
		mov bl,blength
		mov sbody_move,bl
		
		;�ֲ�������ʼ��
		mov win,0
		mov de,1
		mov gameover,0
		mov fe,0
		
		;����ײ���
		mov al,SCY
		mov bl,0
		call movCursor
		mov ax,offset space
		call puts
		
		;clear
		mov al,0
		
	sinitLp1:
			mov bl,0
		sinitLp2:
			call movCursor
			push ax
			mov al,' '
			call putchar
			pop ax
			
			inc bl
			cmp bl,WIDE
			jbe sinitLp2		
		inc al
		cmp al,HIGHT
		jbe sinitLp1
		
		;����
		
		mov DX,3
		mov triBx,280
		mov CX,243	;�õ�heng����
	    mov bx,0

		baseDraw1:	
			mov al,1111b
			mov ah,0ch
			int 10h	
					
			inc DX
			cmp DX,triBx		
		jne baseDraw1	;������
		
		;;;;
		
		mov DX,3
		mov triBx,243
		mov CX,3	;�õ�heng����
	    mov bx,0

		baseDraw2:	
			mov al,1111b
			mov ah,0ch
			int 10h	
					
			inc CX
			cmp CX,triBx		
		jne baseDraw2	;�Ϻ���
	
		;;;;
		
		mov DX,3
		mov triBx,280
		mov CX,3	;�õ�heng����
	    mov bx,0

		baseDraw3:	
			mov al,1111b
			mov ah,0ch
			int 10h	
					
			inc DX
			cmp DX,triBx		
		jne baseDraw3	;������
		
		;;;;
		
		mov DX,280
		mov triBx,243
		mov CX,3	;�õ�heng����
	    mov bx,0

		baseDraw4:	
			mov al,1111b
			mov ah,0ch
			int 10h	
					
			inc CX
			cmp CX,triBx		
		jne baseDraw4	;�º���		
		
			
			
			
	pop bx
	pop ax
	popf
	ret
sInit endp

sMove proc
	pushf
	push ax
	push bx
	push di
		
		mov ah,0
		mov al,sbody_move
		mov di,ax
		;�����������һ��
		shl di,1
		mov bl,sbody[di]	;x  di*2+0
		inc di
		mov al,sbody[di]	;y
		call movCursor
		
		cmp bl,-1
		jz SMEls0
		mov al,' '
		call putchar
	SMEls0:
		mov ah,0
		mov al,sbody_move
		mov bx,ax
		mov al,x
		mov di,bx
		shl di,1
		mov sbody[di],al
		mov al,y
		inc di
		mov sbody[di],al
		dec sbody_move
		cmp sbody_move,0
		ja sMElse1	;�ֶ�ȡ��
			mov al,blength
			mov sbody_move,al
	sMElse1:
			;����Ҫ����ͷ��
		;switch(m)
			cmp m,'s'
			je sMCs1
			cmp m,'a'
			je sMCs2
			cmp m,'d'
			je sMCs3
			cmp m,'w'
			je sMCs4
		;case
		sMCs1:	inc y
			jmp SCsEd1
		sMCs2:	dec x
			jmp SCsEd1
		sMCs3:	inc x
			jmp SCsEd1
		sMCs4:	dec y
			jmp SCsEd1
	SCsEd1:	;end of switch-case
		mov al,y	;���»���ͷ��
		mov bl,x
		call movCursor
		mov al,HEAD_CHAR
		call putchar
		cmp HEAD_CHAR,'#'
		jne sMElse2
			mov HEAD_CHAR,'*'
			jmp sMIfEd2
	sMElse2:
			mov HEAD_CHAR,'#'
	sMIfEd2:
		;�ƶ����
		mov bl,0
		mov al,SCY
		call movCursor
	pop di
	pop bx
	pop ax
	popf
	ret
sMove endp




;sEven proc
;		pushf
;		push bx
;		mov bx,ax
;		and al,1
;		cmp al,1	;���alΪ���������һ
;		jne evenEnd
;		inc bx
;	evenEnd:mov ax,bx
;		pop bx
;		popf
;		ret
;sEven endp
rand proc near
 ; ����ʱ�ӵĵ�λ��ת��ax��������Ϊ����� 
              ; �������ax�д��� 
              push di
      
              PUSH      BX
              PUSH      CX
              PUSH      DX
              PUSHF
              mov di,ax
              MOV       AH,0
              INT       1AH
              ; MOV       AX,CX
              
              xor ax,rseed
              add ax,rcnt
              inc rcnt
              mov dx,1
              div di
              mov ax,dx
          ;div ������ ������: ���������8λ�򱻳���Ϊ16λ, Ĭ�Ϸ���AX��, ���������16λ, �򱻳���Ϊ32λ, Ĭ�ϸ�λ����DX, ��λ����AX
	 		;	    ���: ���������8λ, ��ôִ��div��, ���������ah, �̴����AL��; ���������16λ, ��ôAX������, DX�������� 
              inc ax
              mov rseed,ax
              POPF
              POP       DX
              POP       CX
              POP       BX
              pop di
              
              RET
rand endp
sDelay proc near
		pushf
		push cx
		mov cx,ax
	mDLp1:	
		push cx
		mov cx,0ffffH
		mDLp2:
			push ax
			pop ax
			loop mDLp2
		pop cx
		loop mDLp1
	
		pop cx
		popf
		ret
sDelay endp	
puts proc near
	push dx
	mov dx,ax
	mov ah,09h
	int 21h
	pop dx
	ret
puts endp
putchar proc near
	push DX
	mov DX,AX
	mov AH,02H
	int 21h
	pop DX
	ret
putchar endp
kbHit proc near
	kbstart:
		mov AH,1
		int 16h;
		jz  setzero	;�޼���ʱ��zf=1��Ϊzf=0
		jnz setone	;�м��뽫zf=0��Ϊzf=1	
	setOne:	
		sub AX,AX	;��zf��1
		ret	
	setZero:	
		add AX,0	;��zf��0
		ret  
kbHit endp	
getch proc near
   		mov AL, 0
    		mov AH, 0
    		int 16h		;�Ӽ��̶�ȡ����,�����ASCII����AL�� 
    		ret
getch endp
getchar proc near
    		mov AH, 1
    		int 21h		;�Ӽ��̶�ȡ����,�����ASCII����AL�� 
    		ret
getchar endp
putInt PROC NEAR
	pushf
	push ax
	push bx
	push cx
	push dx
	push di
	push si
    	mov     si, offset printInt_div
    	mov     di, offset printInt_res                     
    	mov     cx,5  
    sly_aa:
        mov     dx,0            
        div     word ptr [si]   ;����ָ��ı��������������������˴�Ϊdx:ax����ax,����dx
        add     al,30h           ;�̼���48���ɵõ���Ӧ���ֵ�ASCII��
        mov     byte ptr [di],al        
        inc     di                                
        add     si,2                           
        mov     ax,dx                        
        loop    sly_aa
        mov     cx,4    
        mov     di, offset printInt_res 
    lsy_bb:
        cmp     byte ptr [di],'0'   ;�����ǰ���0�ַ�    
        jne     sly_print
        inc     di                           
        loop    lsy_bb
    sly_print:
        mov     dx,di                       
        mov     ah,9
        int     21h   ;����DOS���ܣ��ù���Ϊ��ʾDS��DX��ַ�����ַ� 
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        popf     
    	RET
putInt ENDP
movCursor proc near    ;al=y,bl=x;
	pushf
	push dx
	push ax
	push bx	;���ڸĵģ����Ǳ���һ�²����ȽϺ���
        mov ah,02h  		
	mov DH,AL	;�趨��굽��y��x�� ;DH����(Y����)DL����(X����)
	mov DL,BL
	pop bx
	int 10h	
	pop ax
	pop dx
	popf
	ret
movCursor endp


getInt  PROC  near    
	;��ͨ�������ַ������������ax(zf=1),,,���������esc����tab��zf=0��esc������ax=0(zf=0)��tab����ax=1(zf=0)
	;������jz�ж��Ƿ����������������ax���ַ�����esc����tab

        push BX  ;�����ֳ�
        push DX 
        push CX 
       ;�˴�����pushf����Ϊflags�Ƿ���ֵ
        mov AX,0 ;��ʼ�� 
        mov BX,0
        mov CX,0
        mov DX,0
getInt_XUNHUAN:
    mov AH ,01H
    int 21H ; ����һ���ַ���һ���洢�ڡ�AL ��
    cmp  AL,0DH ; �жϻس�����
    jz  getInt_RESULT ;  zf=0

    cmp  AL,08H ;�ж��˸�� 
    je   getInt_SUB_TO_AX  

    cmp  AL,1BH ;�ж�esc�� 
    je   getInt_DO_ESC     

    cmp  AL,09H ;�ж�tab�� 
    je   getInt_DO_TAB        

    cmp  AL,30H
    jb   getInt_OTHER_ERROR ; < 0
    cmp  AL,39H ;<= 9 && > 0
    jbe  getInt_SUM_TO_AX   

    jmp  getInt_XUNHUAN ;����ѭ����

getInt_SUM_TO_AX: 
        mov AH,0 ;��� AX ��λ
        push AX  ;���� AX

        mov AX,CX  ;��ԭ�ȵ�ֵ���ԡ�10 ,ʵ���ϳ�������ֵ������ CX �� 
        mov BX,10
        ;����������ֽ�,���� AL ������, ������� AX
        ;����������� , ���� AX ������, ������� DX:AX
        mul BX 
        mov DX,0
        mov CX,AX 
        pop AX
        sub AL,30H
        add CX,AX 
        jmp  getInt_XUNHUAN    
            
getInt_SUB_TO_AX:
        mov AX,CX 
    ; ������Ĭ�ϴ���� AX �� 
    ; ������8λ�� �򱻳���Ϊ AX��    AL �洢�̣�AH ��������; 
    ; ������16λ���򱻳���Ϊ DX:AX ��AX �����̣�DX ��������
        mov DX,0
        mov BX,10
        div BX 
        mov CX,AX

        mov DL,20H ;����ո�
        mov AH,02H
        int 21H

        mov AL,08H 
        mov DL,AL
        mov AH,02H
        int 21H

        jmp  getInt_XUNHUAN     

getInt_DO_TAB:;tab��zfΪ1 ax=1
        add AX,0 ;zf=0
        mov CX,1
        jmp getInt_RESULT 
getInt_DO_ESC: ;esc��zfΪ0
        add AX,0 ;
        mov CX,0	;
        jmp getInt_RESULT
    ;���Ҫ������������Ļ����������ﴦ�� 
getInt_OTHER_ERROR:  
        jmp  getInt_XUNHUAN   
getInt_RESULT:
 	mov ax,10
        ;call putchar
        mov AX,CX
        
        pop BX  ;�ָ��ֳ�
        pop DX 
        pop CX
        ret  
getInt ENDP 
tri proc near
	pushf
	push AX
	push BX
	push CX
	push DX
	triLoop:
		mov al,0
		mov bl,35
		call movCursor
		
		mov AX,offset note
		call puts
		
		mov al,0
		mov bl,50
		call movCursor
		
		mov CX,10
		spaceLoop:
		mov al,' '
		call putchar
		loop spaceLoop
				
		mov al,0
		mov bl,50
		call movCursor
		
		call getInt
		jz triEls1
		call yield		
		jmp triLoop

		triEls1:
		cmp AX,triScr_w
		jg triLoop	
		cmp AX,2
		jl triLoop
		
		
		call clear
	    call triangle
	    mov triFlag,0		;���û��ȱ������εĺ���
	    jmp triLoop
	    
    pop DX
	pop CX
	pop BX
	pop AX
	popf 
   	ret
tri endp
   
clear proc near			;���������
	pushf
	push AX
	push BX
	push CX
	push DX
	
	mov CX,triScr_x
	add CX,triScr_w	
	mov DX,triScr_h
	
	clrLoopOut:
		mov DX,triScr_h	
		clrLoopIn:				
			mov al,0000b
			mov ah,0ch
			int 10h      	;����ɫ
			
			dec DX
			cmp DX,0
			jne clrLoopIn
		dec CX
		cmp CX,319
		jne clrLoopOut
		 
	pop DX
	pop CX
	pop BX
	pop AX
	popf 
   	ret
clear endp
 	
triangle proc near
	pushf
	push AX
	push BX
	push CX
	push DX
	
	mov triLenth,AX	;��¼AX����ı߳�
	

	
	call triHypotenuse	;��һ��call�����
    call triHypotenuse 	;�ڶ���call���ұ�
    call triBase    	;������
	pop DX
	pop CX
	pop BX
	pop AX
	popf 
	ret    
	
	
triHypotenuse:
	
		mov AX,triLenth			
		;mov BL,2
		;div BL
		;mov AH,0
		shr AX,1
		mov CX,AX			;�õ��߳������Զ�
		
		cmp triFlag,0
		je hypCalLeftX
		jne hypCalRightX
			
		hypCalLeftX:		;��һ�μ���õ���˵���������triEx��leftx
			
			mov AX,triScr_w	
			shr AX,1		
			;mov BL,2
			;div BL
			;mov AH,0
			add AX,triScr_x
			mov BX,AX
			sub BX,CX
			mov triEx,BX
			mov triLeftX,BX
			jmp hypIni
					
		hypCalRightX:
		
			mov AX,triScr_w			
			;mov BL,2
			;div BL
			;mov AH,0
			shr AX,1
			add AX,triScr_x
			add AX,CX
			mov triEx,AX
			mov triRightX,AX	;�ڶ��μ���õ���˵���������triEx��rightx
		
		hypIni:
			
			mov AX,triScr_w			
			;mov BL,2
			;div BL
			;mov AH,0
			shr AX,1
			add AX,triScr_x
			mov CX,AX			
			
			mov AX,triScr_h
			sub AX,triLenth
			;mov BL,2
			;div BL
			;mov AH,0
			shr AX,1	
			mov DX,AX		;��֤λ���ڽ�������
										
			mov AX,triYd
			add AX,AX
			mov BX,triXd
			sub AX,BX
			mov triP,AX		;��ʼ��triP�������㷨��Ҫ
			
		hypDraw:
			mov al,1111b
			mov ah,0ch
			int 10h      	;���ð�ɫ
			
			cmp triP,0		
			jge hypDown	
			jl hypLorr		;�жϴ˴����»����ػ��������һ�
			
			hypLorr:
				cmp triFlag,0
				je hypDrawLeft
				jne hypDrawRight	;�ж����󻭻������һ�
				
				hypDrawLeft:		;����һ�����أ���һ�ε���xiexianʱ��
					dec CX
					jmp hypUpt
				hypDrawRight:		;���һ�һ�����أ��ڶ��ε���xiexianʱ��
					inc CX
					jmp hypUpt
				
				hypUpt:		
				mov AX,triP
				mov BX,triYd
				add BX,BX
				add AX,BX
				mov triP,AX	;����triPֵ���㷨��Ҫ
				jmp hypFin		
				
			hypDown: 		;���»�һ������
				inc DX				
				mov AX,triP
				mov BX,triXd
				add BX,BX
				sub AX,BX
				mov triP,AX
				jmp hypFin	
		
		hypFin:
			mov AX,triEx		
			cmp CX,AX
			jne hypDraw		;�жϱ������Ƿ���

		mov triFlag,1		;��¼��߻���
		mov triHengY,DX		;��¼�ױ�������
		ret			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
triBase:
	;mov CX,triLeftX
	;mov AX,triRightX
	;mov Bx,AX	;�õ����Ҷ˵������
	;mov triBx,AX
	;mov DX,triHengY		;�õ�������

	mov CX,triLeftX
	mov AX,triRightX
	mov triBx,AX	;�õ����Ҷ˵������
	mov DX,triHengY	;�õ�������
	mov bx,0
	;inc CX
	baseDraw:	
		mov al,1111b
		mov ah,0ch
		int 10h			
		inc CX
		cmp CX,triBx		
	jne baseDraw	;ѭ������		
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

triangle endp	

code ends
	end main





