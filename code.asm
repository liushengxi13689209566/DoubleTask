DELAY_TIME	EQU	02h	;延时时间参数
MAXBODY		EQU	100
HIGHT		EQU	20
WIDE		EQU	30	;0~WIDE , or  wide+1
WIN_LENTH	EQU	10	;获胜长度
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
triScr_h	EQU 350		;设置屏幕属性，保证图形在近似中央
	
	
DATAS SEGMENT
    ;此处输入数据段代码  
    ;debug
	s	db '12345$'
	stri	db 'tri$'
	ssna	db 'snack$'
    ;debug end
    ;printInt
	printInt_div        DW 10000, 1000, 100, 10, 1
	printInt_res        DB 0,0,0,0,0,"$"        ;存放五位数ASCII码
    ;end
    ;main
    	space	db  '                                $'
    ;end
    ;snake
    	;全局变量
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
    	;局部变量
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
	triP  dw 0 			;以上三个算法需要的变量
					
	triFlag db 0		;第n次调用triHypotenuse
	triEx dw 0			;记录本次画线终点横坐标
	
	triLeftX dw 0		;记录左端点横坐标
	triRightX dw 0		;记录右端点横坐标	
	triHengY dw 0		;记录底边总左边	（以上三个供画横线函数使用）
	
	triLenth dw 0		;记录边长（代码必须要覆盖AX）
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
		int 10h		;设置显示模式
		
		call sInit
		;yield init
		mov ax,offset TStack
		add ax,TRISTACKOFFSET
		mov stack_tri_sp,ax
		
		mov dx,ss
		mov bx,sp	;暂存
		mov ax,STACK_SNAKE
		mov ss,ax
		mov ax,offset SStack
		mov sp,ax 	;由于起点在tri 所以要将snake初始断点设置好
		add sp,SNASTACKOFFSET
		mov ax,snake
		push ax	;先保存snake断点
		mov cx,8	;加上flags一共8个寄存器
		mov ax,0
	mInitYLp:
			push ax
		loop mInitYLp
		
		mov stack_snake_sp,sp
	
		mov sp,bx	;还原
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
		pushf	;先保存一下flags
		cmp ax,0 ;判断是否是esc
		jne yEls1
			mov AH, 4CH	;esc exit
      			int 21h	
	yEls1:
		;是tab，先在它自己的栈里保存寄存器,
		push ax
		push bx
		push cx
		push dx
		push di
		push si
		push bp
		
		;再切换栈，恢复另一组寄存器
		cmp yFunc,0	;当前是tri?
		je yTri

			mov stack_snake_sp,sp
			mov sp,stack_tri_sp		;当前是1:snake，要切换成tri
			mov ax,STACK_RTI
			mov ss,ax		
			mov yFunc,0

			jmp yTriEd
	yTri:
			mov stack_tri_sp,sp
			mov sp,stack_snake_sp		;当前是0:tri，要切换成snake
			mov ax,STACK_SNAKE
			mov ss,ax
			mov yFunc,1
		;恢复寄存器
	yTriEd:

		pop bp
		pop si
		pop di
		pop dx
		pop cx
		pop bx
		pop ax
		popf
		ret	;切换
yield endp

snake proc
	pushf
	push ax
	push bx
	push di
	

	sstart:	;死循环
		call sInit ;贪吃蛇初始化
	sBigLp:	cmp gameover,0		;for循环头部
		je sBigLpBkElse 	;满足循环条件
		jmp sBigLpBk	;转换成远转移
	sBigLpBkElse:
			;循环体
			call sMove
			
			;判断是否撞墙
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
			;判断是否咬到自己
			mov bh,0
			mov bl,1	;i
		sForHd1:			;for(    )
			cmp bl,blength
			jbe sForBk1Else		;满足条件
				jmp sForBk1	;转换成远转移
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
						;end for.循环体结束(    )
			inc bl
			jmp sForHd1
			sForBk1:	;for外部
			cmp gameover,1		;gameover?
			je sBigLp
			
			call kbhit	;if(   kbhit()   )
			jnz nonImput
				mov al,m
				mov ta,al	;备份m
				call getch	;read in
					;判断特殊字符，tab，esc，r（重新开始）
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
			
				;四个判断，不能倒退
				;m==a && ta==d
				cmp al,'a'
				jne sIfElseA
				mov m,al
				cmp ah,'d'
				jne sIfElseA
				jmp sIfY
			sIfElseA:	
				;第二个 
				cmp al,'d'
				jne sIfElseB
				mov m,al
				cmp ah,'a'
				jne sIfElseB
					jmp sIfY
			sIfElseB:
				;第三个 m==w && ta==s
				cmp al,'w'
				jne sIfElseC
				mov m,al
				cmp ah,'s'
				jne sIfElseC
				jmp sIfY
			sIfElseC:
				;第四个
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
				call sFood	;fe==0	食物不存在产生食物
				mov fe,1
		sIfElse5:
			mov al,fy	;y	输出食物
			mov bl,fx	;x	输出食物
			call movCursor
			mov al,FOOD
			call putchar
			;移动光标
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
		
		
		;大 for( ; gameover==0  ;    )结束
		jmp sBigLp
	sBigLpBk:
		cmp win,0
		je sIfElse7
			mov ax,offset loseMSG
			call puts	;win==0，lose
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
	jmp sstart	; 死循环
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
	
		
		
		;food不能在身体或头部
		mov al,fx		;头部
		cmp x,al
		jne sFIfEd
		mov al,fy
		cmp fy,al
		jne sFIfEd
		jmp sFStart
	sFIfEd:
		
		mov bh,0		;身体
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
					;两个条件满足了
			jmp sFStart	;食物在蛇体内，重新生成随机数
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
		mov blength,2 ;如果blength大于4，则需要调整初始化逻辑，否则会有一个bug
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
		
		;局部变量初始化
		mov win,0
		mov de,1
		mov gameover,0
		mov fe,0
		
		;清除底部字
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
		
		;画线
		
		mov DX,3
		mov triBx,280
		mov CX,243	;得到heng坐标
	    mov bx,0

		baseDraw1:	
			mov al,1111b
			mov ah,0ch
			int 10h	
					
			inc DX
			cmp DX,triBx		
		jne baseDraw1	;右竖线
		
		;;;;
		
		mov DX,3
		mov triBx,243
		mov CX,3	;得到heng坐标
	    mov bx,0

		baseDraw2:	
			mov al,1111b
			mov ah,0ch
			int 10h	
					
			inc CX
			cmp CX,triBx		
		jne baseDraw2	;上横线
	
		;;;;
		
		mov DX,3
		mov triBx,280
		mov CX,3	;得到heng坐标
	    mov bx,0

		baseDraw3:	
			mov al,1111b
			mov ah,0ch
			int 10h	
					
			inc DX
			cmp DX,triBx		
		jne baseDraw3	;左竖线
		
		;;;;
		
		mov DX,280
		mov triBx,243
		mov CX,3	;得到heng坐标
	    mov bx,0

		baseDraw4:	
			mov al,1111b
			mov ah,0ch
			int 10h	
					
			inc CX
			cmp CX,triBx		
		jne baseDraw4	;下横线		
		
			
			
			
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
		;擦除身体最后一节
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
		ja sMElse1	;手动取余
			mov al,blength
			mov sbody_move,al
	sMElse1:
			;不需要擦除头部
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
		mov al,y	;重新绘制头部
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
		;移动光标
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
;		cmp al,1	;如果al为奇数，则加一
;		jne evenEnd
;		inc bx
;	evenEnd:mov ax,bx
;		pop bx
;		popf
;		ret
;sEven endp
rand proc near
 ; 利用时钟的低位反转除ax的余数作为随机数 
              ; 随机数在ax中带回 
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
          ;div 除法： 被除数: 如果除数是8位则被除数为16位, 默认放在AX中, 如果除数是16位, 则被除数为32位, 默认高位放在DX, 低位放在AX
	 		;	    结果: 如果除数是8位, 那么执行div后, 余数存放在ah, 商存放在AL中; 如果除数是16位, 那么AX保存商, DX保存余数 
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
		jz  setzero	;无键入时将zf=1改为zf=0
		jnz setone	;有键入将zf=0改为zf=1	
	setOne:	
		sub AX,AX	;将zf置1
		ret	
	setZero:	
		add AX,0	;将zf置0
		ret  
kbHit endp	
getch proc near
   		mov AL, 0
    		mov AH, 0
    		int 16h		;从键盘读取数据,键入的ASCII存在AL中 
    		ret
getch endp
getchar proc near
    		mov AH, 1
    		int 21h		;从键盘读取数据,键入的ASCII存在AL中 
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
        div     word ptr [si]   ;除法指令的被除数是隐含操作数，此处为dx:ax，商ax,余数dx
        add     al,30h           ;商加上48即可得到相应数字的ASCII码
        mov     byte ptr [di],al        
        inc     di                                
        add     si,2                           
        mov     ax,dx                        
        loop    sly_aa
        mov     cx,4    
        mov     di, offset printInt_res 
    lsy_bb:
        cmp     byte ptr [di],'0'   ;不输出前面的0字符    
        jne     sly_print
        inc     di                           
        loop    lsy_bb
    sly_print:
        mov     dx,di                       
        mov     ah,9
        int     21h   ;调用DOS功能，该功能为显示DS：DX地址处的字符 
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
	push bx	;后期改的，还是保持一下参数比较好用
        mov ah,02h  		
	mov DH,AL	;设定光标到第y行x列 ;DH＝行(Y坐标)DL＝列(X坐标)
	mov DL,BL
	pop bx
	int 10h	
	pop ax
	pop dx
	popf
	ret
movCursor endp


getInt  PROC  near    
	;普通输入数字返回输入的数字ax(zf=1),,,特殊情况（esc键和tab键zf=0）esc键返回ax=0(zf=0)，tab返回ax=1(zf=0)
	;可以用jz判断是否发生了特殊情况。用ax区分发生了esc还是tab

        push BX  ;保护现场
        push DX 
        push CX 
       ;此处不能pushf，因为flags是返回值
        mov AX,0 ;初始化 
        mov BX,0
        mov CX,0
        mov DX,0
getInt_XUNHUAN:
    mov AH ,01H
    int 21H ; 输入一个字符，一定存储在　AL 中
    cmp  AL,0DH ; 判断回车符　
    jz  getInt_RESULT ;  zf=0

    cmp  AL,08H ;判断退格符 
    je   getInt_SUB_TO_AX  

    cmp  AL,1BH ;判断esc符 
    je   getInt_DO_ESC     

    cmp  AL,09H ;判断tab符 
    je   getInt_DO_TAB        

    cmp  AL,30H
    jb   getInt_OTHER_ERROR ; < 0
    cmp  AL,39H ;<= 9 && > 0
    jbe  getInt_SUM_TO_AX   

    jmp  getInt_XUNHUAN ;继续循环　

getInt_SUM_TO_AX: 
        mov AH,0 ;清除 AX 高位
        push AX  ;保存 AX

        mov AX,CX  ;将原先的值乘以　10 ,实质上乘起来的值放在了 CX 中 
        mov BX,10
        ;如果参数是字节,将把 AL 做乘数, 结果放在 AX
        ;如果参数是字 , 将把 AX 做乘数, 结果放在 DX:AX
        mul BX 
        mov DX,0
        mov CX,AX 
        pop AX
        sub AL,30H
        add CX,AX 
        jmp  getInt_XUNHUAN    
            
getInt_SUB_TO_AX:
        mov AX,CX 
    ; 被除数默认存放在 AX 中 
    ; 除数是8位， 则被除数为 AX，    AL 存储商，AH 储存余数; 
    ; 除数是16位，则被除数为 DX:AX ，AX 储存商，DX 储存余数
        mov DX,0
        mov BX,10
        div BX 
        mov CX,AX

        mov DL,20H ;输出空格
        mov AH,02H
        int 21H

        mov AL,08H 
        mov DL,AL
        mov AH,02H
        int 21H

        jmp  getInt_XUNHUAN     

getInt_DO_TAB:;tab置zf为1 ax=1
        add AX,0 ;zf=0
        mov CX,1
        jmp getInt_RESULT 
getInt_DO_ESC: ;esc置zf为0
        add AX,0 ;
        mov CX,0	;
        jmp getInt_RESULT
    ;如果要处理其他错误的话，就在这里处理 
getInt_OTHER_ERROR:  
        jmp  getInt_XUNHUAN   
getInt_RESULT:
 	mov ax,10
        ;call putchar
        mov AX,CX
        
        pop BX  ;恢复现场
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
	    mov triFlag,0		;调用画等边三角形的函数
	    jmp triLoop
	    
    pop DX
	pop CX
	pop BX
	pop AX
	popf 
   	ret
tri endp
   
clear proc near			;清除三角形
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
			int 10h      	;画黑色
			
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
	
	mov triLenth,AX	;记录AX输入的边长
	

	
	call triHypotenuse	;第一次call画左边
    call triHypotenuse 	;第二次call画右边
    call triBase    	;画横线
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
		mov CX,AX			;得到边长并除以二
		
		cmp triFlag,0
		je hypCalLeftX
		jne hypCalRightX
			
		hypCalLeftX:		;第一次计算得到左端点横坐标放入triEx、leftx
			
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
			mov triRightX,AX	;第二次计算得到左端点横坐标放入triEx、rightx
		
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
			mov DX,AX		;保证位置在近似中央
										
			mov AX,triYd
			add AX,AX
			mov BX,triXd
			sub AX,BX
			mov triP,AX		;初始化triP变量，算法需要
			
		hypDraw:
			mov al,1111b
			mov ah,0ch
			int 10h      	;设置白色
			
			cmp triP,0		
			jge hypDown	
			jl hypLorr		;判断此次向下画像素还是向左右画
			
			hypLorr:
				cmp triFlag,0
				je hypDrawLeft
				jne hypDrawRight	;判断向左画还是向右画
				
				hypDrawLeft:		;向左画一个像素（第一次调用xiexian时）
					dec CX
					jmp hypUpt
				hypDrawRight:		;向右画一个像素（第二次调用xiexian时）
					inc CX
					jmp hypUpt
				
				hypUpt:		
				mov AX,triP
				mov BX,triYd
				add BX,BX
				add AX,BX
				mov triP,AX	;更新triP值，算法需要
				jmp hypFin		
				
			hypDown: 		;向下画一个像素
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
			jne hypDraw		;判断本条线是否画完

		mov triFlag,1		;记录左边画完
		mov triHengY,DX		;记录底边纵坐标
		ret			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
triBase:
	;mov CX,triLeftX
	;mov AX,triRightX
	;mov Bx,AX	;得到左右端点横坐标
	;mov triBx,AX
	;mov DX,triHengY		;得到纵坐标

	mov CX,triLeftX
	mov AX,triRightX
	mov triBx,AX	;得到左右端点横坐标
	mov DX,triHengY	;得到纵坐标
	mov bx,0
	;inc CX
	baseDraw:	
		mov al,1111b
		mov ah,0ch
		int 10h			
		inc CX
		cmp CX,triBx		
	jne baseDraw	;循环画点		
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

triangle endp	

code ends
	end main





