[org 0x0100]
jmp start

;================================================
;==================Memory Labels ================
;================================================
Name: dw 'Name:        '
namecounter: dw 0
NameLength: dw 12
InitialScore: dw "Score: 0  "
ScoreVal: dw 0

instructions : db  'Please Enter your choice!', 0
press_1 : db 'Press 1 for level 1', 0
press_2 : db 'Press 2 for level 2', 0
press_3 : db 'Press 3 for level 3', 0
invalid_msg  db 'Invalid input.', 0

level_1 : db 'Level 1', 0
level_2 : db 'Level 2', 0
level_3 : db 'Level 3', 0

developers: db 'Game Developers!', 0
dev_F: db 'Faiza Ali(23F-0739)', 0
dev_T: db 'Muhammad Talha(23F-0615)', 0
dev_A: db 'Ali Hamza(23F-0635)', 0
msg5: db 'Press any key to continue...', 0
message: db 'Candy Crush'
length: dw 11
game_instructions: db 'Game Instructions:',0

TotalMoves: dw "Total Moves:15"
RemainingMoves: dw "Remaining:   "
RemainingMovesCount: db 15

level_flag: dw 0

bombflag: db 0

WelcomeMessage1: db 'Welcome to Letter Crush (Assembly Edition)',0; 
WelcomeMessage2: db 'You will get 15 turns to score the maximum score possible',0 
WelcomeMessage3: db 'Make pattern of 3   numbers to pop them and gain score',0 
WelcomeMessage4: db 'Make a pattern of three or more characters to form a bomb X',0 
WelcomeMessage5: db 'Swap the bomb with a character to delete all instances of that character',0 
PressAnyKey: db 'Press any key to continue',0 

ConclusionMessage1: db 'Game Over',0
ConclusionMessage2: db 'Press Any Key To Exit',0

InitialScoreLength: dw 10
InitialCharacters_1: db 'ABCDEFGHA'
InitialCharacters_2: db 'ABCDEFGH '
InitialCharacters_3: db 'ABCDEF   '
InitialColours: db 0x02,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0x01
randomNum: dw 0
rows: db 6
columns: db 6
getName_: db ' Enter name: '


; ==========================================
; ========Print Null-Terminated String======
; ==========================================
print_string:
    mov ah, 0x03 
.print_loop:
    lodsb
    cmp al, 0
    je .done
    stosw
    jmp .print_loop
.done:
    ret

; ==========================================
; ============Draw Border===================
; ==========================================
draw_border:
    mov ax, 0xB800
    mov es, ax

    ; Top border
    mov cx, 80
    mov di, 0
top_row:
    mov word [es:di], 0x6020
    add di, 2
    loop top_row

    ; Bottom border
    mov cx, 80
    mov di, 3840
bottom_row:
    mov word [es:di], 0x6020
    add di, 2
    loop bottom_row

    ; Left and right border
    mov cx, 25
    mov si, 0
sides:
    mov di, si
    mov word [es:di], 0x6020
    mov di, si
    add di, 158
    mov word [es:di], 0x6020
    add si, 160
    loop sides

    ; Mid border
    mov di, 960
    mov cx, 80
mids:
    mov word [es:di], 0x6020
    add di, 2
    loop mids

    ; Write candy crush title
    mov ax, message
    push ax
    push word [length]

    push bp
    mov bp, sp
    mov ax, 0xb800
    mov es, ax
    mov si, [bp + 4]
    mov cx, [bp + 2]
    mov ah, 0x03
    mov di, 230
    cld
nextchar:
    lodsb
    stosw
    loop nextchar
    pop bp
    add sp, 4

    ; Underline
    mov di, 390
    mov cx, 11
print_underline:
    mov word [es:di], 0x035F
    add di, 2
    loop print_underline
    ret


; ==========================================
; ==========Print Names=====================
; ==========================================
print_names:
    mov ax, 0xB800
    mov es, ax

    mov si, developers
    mov di, 1284
    call print_string

    mov si, dev_F
    mov di, 1444
    call print_string

    mov si, dev_T
    mov di, 1604
    call print_string

    mov si, dev_A
    mov di, 1764
    call print_string

    mov si, msg5
    mov di, 1924
    call print_string

    ret
; ==========================================
; ======Wait For Any Key Press==============
; ==========================================
    wait_for_keys:
    mov ah, 01h
    int 16h
    jz wait_for_keys
    mov ah, 00h
    int 16h
    ret

; =========================================
; =========clear Screen====================
; ========================================
clrscr:

		push bp
		mov bp,sp
		
		push es
		push ax
		push di
		push cx
		
		mov ax, 0xb800
		mov es, ax
		xor di, di
		mov ax, 0x0720
		mov cx, 2000
		
		cld
		rep stosw
		
		pop cx
		pop di
		pop ax
		pop es

		pop bp
		ret

; ==================================================
; =================Print String ====================
; ==================================================
printstr: 
	push bp
	mov bp, sp
	push es
	push ax
	push cx
	push si
	push di
	mov ax, 0xb800
	mov es, ax 
	mov al, 80 
	mul byte [bp+10] 
	add ax, [bp+12] ; add x position
	shl ax, 1 ; turn into byte offset
	mov di,ax ; point di to required location

	mov si, [bp+6] ; point si to string
	mov cx, [bp+4] ; load length of string in cx
	mov ah, [bp+8] ; load attribute in ah

	cld ; auto increment mode
nextchars: 
	lodsb ; load next char in al
	stosw ; print char/attribute pair
	loop nextchars ; repeat for the whole string
	pop di
	pop si
	pop cx
	pop ax
	pop es
	pop bp
	ret 10

; ====================================================
; =============Random Number Generate ================
; ====================================================
randomNumber: ; generate a random number using the system time
	push cx
	push dx
	push ax
	rdtsc ;getting a random number in ax dx
	xor dx,dx ;making dx 0
	mov cx, 8
	div cx ;dividing by 8 to get numbers from 0-7
	mov [randomNum], dl ;moving the random number in variable
	pop ax
	pop dx
	pop cx
	ret

; =============================================
; ======================Get Name===============
; =============================================
getname: 
	mov ah, 0 ; service 0 – get keystroke
	int 0x16 ; call BIOS keyboard service
	cmp al, '0'
	je end

	;mov dl, al

	mov bx, Name
	mov si, [namecounter]
	mov ah, 0x07
	mov [bx+si+5], al
	add si, 1
	mov [namecounter], si

	end:
	ret

; =====================================================
; ===============Print Board ==========================
; =====================================================

prtboard:
		
		push bp
		mov bp, sp
		
		push es
		push ax
		push di
		
		call clrscr
		
		call topstrip ; print top row strip
		
		mov ax, 0xb800
		mov es, ax
		mov di, 320 ; leave first row as already covered by topstrip sub routine
		
		mov al, 0x20 ; space character
		mov ah, 0x1F

next_:
		
		mov [es:di], ax
		add di, 2
		cmp di, 4000
		jne next_
		
		pop di
		pop ax
		pop es

		pop bp
		ret
; =====================================================
; ================Top strip ===========================
; =====================================================
topstrip:

		push bp
		mov bp, sp
		
		push es
		push ax
		push di
		
		mov ax, 0xb800
		mov es, ax
		mov di, 0
		
		mov al, 0x20 ; space character
		mov ah, 0x4F ; red color

next_first: ; half red
		
		mov [es:di], ax
		add di, 2
		cmp di, 80
		jne next_first

		mov di, 160
second_row:

		mov [es:di], ax
		add di, 2
		cmp di, 240
		jne second_row

		mov ah, 0x2F ; green color

		mov di, 80

next_second:
		
		mov [es:di], ax
		add di, 2
		cmp di, 160
		jne next_second

		mov di, 240
next_secondrow: ; half green
		
		mov [es:di], ax
		add di, 2
		cmp di, 320
		jne next_secondrow
		
		pop di
		pop ax
		pop es

		pop bp
		ret		
;====================================================
;===============Horizontal Print ====================
;====================================================

hzl:
		push bp
		mov bp, sp
		
		push es
		push ax
		push di
		push cx
		
		mov ax, 0xb800
		mov es, ax
		mov di, 480 ; first two row already left empty and two more rows left as each block will be 2 units wide
		
		mov al, '-'
		mov ah, 0x4F ; blue color
		mov dl, [rows]

hzlloop:		
		mov cx, 0
		
next_hzl: ; print a line of _ character
		
		mov [es:di], ax
		add di, 2
		add cx, 2
		cmp cx, 160
		jne next_hzl
		
		add di, 160 ; skip a row to make blocks 2 wide
		dec dl
		cmp dl, 0
		jne hzlloop
		
		pop cx
		pop di
		pop ax
		pop es

		pop bp
		ret
;====================================================
;=================Vertical Print ====================
;====================================================
vtl:
		push bp
		mov bp, sp
		
		push es
		push ax
		push di
		push cx
		
		mov ax, 0xb800
		mov es, ax
		mov di, 320 ; leave fisrt row
		
		mov al, '|' ; | character
		mov ah, 0x4F ; cyan color
		
		mov bx, 2 ; used for multiplication
		mov dx, 0
		
vtlloop:		
		
		mov cl, 0
		add di, 0 ; leave space on left side for proper symmetry and allignment
		
next_vtl: ; run a loop and print | character 13 times
		
		mov [es:di], ax
		add di, 12
		inc cl
		cmp cl, [columns]
		jbe next_vtl
		
		push ax ; store value of ax
		
		; multiplication used to move onto next line of grid 
		mov ax, 160
		mul bx
		mov di, ax
		inc bx
		
		pop ax ; restore value of ax
		
		cmp di, 4000
		jbe vtlloop
		
		pop cx
		pop di
		pop ax
		pop es

		pop bp
		ret
; ===================================================
; ===================Print Details ==================
; ===================================================
prtdetails:

		push bp
		mov bp, sp
		
		push es
		push ax
		push di
                push si
		push cx
		
                mov cx, [NameLength]
		mov ax, 0xb800
		mov es, ax
		mov di, 24
		mov si, Name                 ; space character
		mov ah, 0x03 ; non red color

prtname: ; half red
		mov al, [si]
		mov [es:di], ax
		add di, 2
                add si, 1
		loop prtname

		mov cx, [InitialScoreLength]
		mov di, 110
		mov si, InitialScore
		mov ah, 0x03

prtscore: ; half red
		mov al, [si]
		mov [es:di], ax
		add di, 2
                add si, 1
		loop prtscore

		mov cx, 14
		mov ax, 0xb800
		mov es, ax
		mov di, 184
		mov si, TotalMoves               
		mov ah, 0x03 

prtMoves:
		mov al, [si]
		mov [es:di], ax
		add di, 2
                add si, 1
		loop prtMoves
        
		pop cx
                pop si
                pop di
                pop ax
                pop es
                pop bp
                ret
set_si_1:
                mov si, InitialCharacters_1
                jmp move_ah
set_si_2:
                mov si, InitialCharacters_2
                jmp move_ah

oldinitialiseboard:
		push bp
		mov bp, sp
		
		push es
		push ax
		push di
                push si
		push cx
		
		mov di, 320 ; place of first element
                mov cx, 144
		mov ax, 0xb800
		mov es, ax
                cmp word[level_flag],1
                je set_si_1
                cmp word[level_flag],2
                je set_si_2
                mov si, InitialCharacters_3
move_ah:
		mov ah, 00010000b ; blue color

		mov al, [si]
		mov [es:172], ax
		mov al, [si+1]
		mov [es:1144], ax
		mov al, [si+2]
		mov [es:304], ax
		mov al, [si+3]
		mov [es:2212], ax
		mov al, [si+4]
		mov [es:552], ax
		mov al, [si+5]
		mov [es:1228], ax

        pop cx
        pop si
        pop di
        pop ax
        pop es
        pop bp
        ret

randomNumberBlocker: ; generate a random number using the system time
	push cx
	push dx
	push ax
	rdtsc ;getting a random number in ax dx
	xor dx,dx ;making dx 0
	mov cx, 9
	div cx ;dividing by 9 to get numbers from 0-8
	mov [randomNum], dl ;moving the random number in variable
	pop ax
	pop dx
	pop cx
	ret

initialiseboard:
	;random number initalisation here
	
	mov al, [columns]
	xor ah, ah
	mov dl, 0x00
	sub dl, 3
	
l2:
call randomNumberBlocker
	push ax
	
	add dl, 0x06
	
	mov cl, [rows]
	xor ch, ch

	
l1:
	call randomNumberBlocker
	push cx
	mov ah, 0x13 ; service 13 - print string
	mov al, 0 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	
	mov si, [randomNum]
	call randomNumber
	mov bl, [InitialColours + si]
	
	;mov dx, 0x0A03 ; row 10 column 3
	
	mov dh, cl
	add dh, cl
	
	
	mov cx, 1 ; length of string
	push cs
	pop es ; segment of string
        cmp word[level_flag],1
        je set_bp_1
        cmp word[level_flag],2
        je set_bp_2

	mov bp, InitialCharacters_3; offset of string
move_bp:
	add bp, si

	int 0x10
	
	pop cx
	dec cx
	cmp cx, 0
	jne l1
	
	pop ax
	dec ax
	cmp ax, 0
	jne l2
	
	ret
set_bp_1:
    mov bp, InitialCharacters_1
    jmp move_bp
set_bp_2:
    mov bp, InitialCharacters_2
    jmp move_bp

; ==================================================
; ===================Setup ==========================
; ===================================================
setup:

welcomescreen:
	call clrscr
        call draw_border
	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 0x03 ; normal attrib
	mov dx, 0x0802 
	mov cx, 42 ; length of string
	push cs
	pop es ; segment of string
	mov bp, WelcomeMessage1 ; offset of string
	int 0x10

	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 0x03 ; normal attrib
	mov dx, 0x0A02 
	mov cx, 56 ; length of string
	push cs
	pop es ; segment of string
	mov bp, WelcomeMessage2 ; offset of string
	int 0x10

	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 0x03 ; normal attrib
	mov dx, 0x0B02 
	mov cx, 54 ; length of string
	push cs
	pop es ; segment of string
	mov bp, WelcomeMessage3 ; offset of string
	int 0x10

	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 0x03 ; normal attrib
	mov dx, 0x0C02 
	mov cx, 59 ; length of string
	push cs
	pop es ; segment of string
	mov bp, WelcomeMessage4 ; offset of string
	int 0x10

	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 0x03 ; normal attrib
	mov dx, 0x0D02 
	mov cx, 72 ; length of string
	push cs
	pop es ; segment of string
	mov bp, WelcomeMessage5 ; offset of string
	int 0x10

	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 0x03 ; normal attrib
	mov dx, 0x0E02 
	mov cx, 25 ; length of string
	push cs
	pop es ; segment of string
	mov bp, PressAnyKey ; offset of string
	int 0x10


	mov ah, 0
	int 0x16 ;await input

	call clrscr
        call draw_border
	
getnamefun:
	push cs
	pop  es
	mov bp, getName_
	mov cx, 13

	mov ah, 0x13
	mov al, 1
	mov bh, 0
	mov bl, 0x03
	mov dh, 0x08
	mov dl, 0x02
	int 0x10 ; print

	; Loop to get name, change initial cx for name length of max 6
	mov cx, 6	
loopgetname:
	call getname
	dec cx
	cmp cx, 0
	jne loopgetname
	;gets number of rows needed

	ClearScreen:

	;clears the screen
	mov ah, 00
	mov al, 03h
	
	int 10h ; print
	ret

	;to check is mouse clicked?
noMouseClick:
    push bp
	mov bp, sp
	push ax
	push bx
	push cx;
	push di
	push dx

	xor ax, ax; subservice to reset mouse
	int 33h
waitForMouseClick:
	mov ax, 0001h ;to show mouse
	int 33h
	mov ax,0003h
	int 33h
	or bx,bx
	jz short waitForMouseClick
	mov ax, 0002h ;hide mouse after clicking
	int 33h
	shr cx, 3
	shr dx, 3

	mov ax, 0xb800
	mov es, ax
	mov ax, 80
	mov bx, dx
	mul bl
	add ax, cx
	shl ax, 1
    mov di, ax
	mov ax, [es:di]
	mov [bp+4], di  ;return coordinate of click
	
	pop dx
	pop di
	pop cx
	pop bx
	pop ax
	pop bp
	ret
	
rg:
	push bp
	mov bp,sp
	push ax
	push es
	push si
	push di
	push dx
	push bx

	jmp startfun

	endfun1:
	pop bx
	pop dx
	pop di
	pop si
	pop es
	pop ax
	pop bp
	ret 2

	startfun:
	
	mov ax, 0xb800
	mov es, ax
	mov di, [bp+4]
	jmp mainrg

	looprandom:
	cmp di, 480
	jb endfun1

	sub di, 320
	mov bx, [es:di]

	mov [es:di+320], bx
	cmp di, 480
	ja looprandom

	call randomNumber
	mov si, [randomNum]
	mov ah, [InitialColours+si]
        cmp word[level_flag],1
        je set_al_1
        cmp word[level_flag],2
        je set_al_2
        mov al, [InitialCharacters_3+si] 
move_1:
	mov [es:di], ax
	jmp endfun

set_al_1:
	mov al, [InitialCharacters_1+si]
       jmp move_1
set_al_2:
	mov al, [InitialCharacters_2+si]
       jmp move_1
set_al_3:
	mov al, [InitialCharacters_1+si]
       jmp move_2
set_al_4:
	mov al, [InitialCharacters_2+si]
       jmp move_2


mainrg:
	call randomNumber
	mov si, [randomNum]
	mov ah, [InitialColours+si]
        cmp word[level_flag],1
        je set_al_3
        cmp word[level_flag],2
        je set_al_4
       mov al, [InitialCharacters_3+si]  
move_2:
	mov [es:di], ax

	;Obstacles checking and removing
	mov di, [bp+4]
	add di, 320
	mov dx, [es:di]
	cmp dl, '~'
	je looprandom

	mov di, [bp+4]
	sub di, 320
	mov dx, [es:di]
	cmp dl, '~'
	je looprandom

	mov di, [bp+4]
	sub di, 12
	mov dx, [es:di]
	cmp dl, '~'
	je looprandom

	mov di, [bp+4]
	add di, 12
	mov dx, [es:di]
	cmp dl, '~'
	je looprandom

	mov di, [bp+4]
	add di, 320
	sub di, 12
	mov dx, [es:di]
	cmp dl, '~'
	je looprandom

	mov di, [bp+4]
	sub di, 320
	sub di, 12
	mov dx, [es:di]
	cmp dl, '~'
	je looprandom

	mov di, [bp+4]
	sub di, 320
	add di, 12
	mov dx, [es:di]
	cmp dl, '~'
	je looprandom

	mov di, [bp+4]
	add di, 320
	add di, 12
	mov dx, [es:di]
	cmp dl, '~'
	je looprandom

	endfun:
	pop bx
	pop dx
	pop di
	pop si
	pop es
	pop ax
	pop bp
	ret 2
; ===================================================
; =====================Print Number==================
; ===================================================
printnum: 
		push bp
		mov bp, sp
		push es
		push ax
		push bx
		push cx
		push dx
		push di
		
		mov ax, 0xb800
		mov es, ax ; point es to video base
		mov ax, [bp+4] ; load number in ax
		mov bx, 10 ; use base 10 for division
		mov cx, 0 ; initialize count of digits

nextdigit: 
		mov dx, 0 ; zero upper half of dividend
		div bx ; divide by 10
		add dl, 0x30 ; convert digit into ascii value
		push dx ; save ascii value on stack
		inc cx ; increment count of values
		cmp ax, 0 ; is the quotient zero
		jnz nextdigit ; if no divide it again
		
		mov di, 124 ; point di
		
nextpos:
		pop dx ; remove a digit from the stack
		mov dh, 0x03 ; use normal attribute
		mov [es:di], dx ; print char on screen
		add di, 2 ; move to next screen location
		loop nextpos ; repeat for all digits on stack
		
		pop di
		pop dx
		pop cx
		pop bx
		pop ax
		pop es
		pop bp
		ret 2
; ====================================================
; ========================set flag====================
; ====================================================
setflag:
	push bp
	mov bp, sp
	push ax
	push dx
	mov dx, [bp+4]

	cmp dx, 1
	ja resetflag

	mov al, 1
	mov [bombflag], al
	jmp endsetflag

	resetflag:
	mov al, 0
	mov [bombflag], al

	endsetflag:
	pop dx
	pop ax
	pop bp
	ret 2
; ================================================
; ===================update Score ================
; ================================================
updateScore:
	push bp
	mov bp,sp
	push ax
	push dx
	mov dx, [bp+4]
	xor dh, dh
	mov ax, [ScoreVal]
	add ax, dx
	mov [ScoreVal], ax

	xor ah, ah
	push ax
	call printnum
	pop dx
	pop ax
	pop bp
	ret 2
	
bombsub:

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push es
	push si
	push di
	mov si, 0
	
	mov ax, 0xb800
	mov es, ax
	
	mov di, [bp+6]
	mov cx, [es:di]
	
	mov di, [bp+4] ;bomb always here
	mov dx, [es:di]
	
	push di
	call rg
	
	mov di, 320 ; leave first row as already covered by topstrip sub routine

bombnext_:
		
		mov ax, [es:di]
		cmp al, cl
		je remove_
		
continue_next_:		
		
		add di, 2
		cmp di, 4000
		jne bombnext_
		jmp fun_eend
		
remove_:
		inc si
remov_:		
		push di
		call rg
		mov ax, [es:di]
		cmp al, cl
		je remov_
		jmp continue_next_	
	
	fun_eend:
	push si
	call updateScore
	pop di
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	
	ret 4

; ================================================
; ======================Pattern===================
; ================================================
pattern:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push es
    push si
    push di
    
    mov ax, 0xb800
    mov es, ax
    
    mov di, [bp+6]
    mov bx, [es:di]
    
    mov di, [bp+4]
    mov dx, [es:di]
    
    cmp dl, 'X'
    jne bombl
    
    cmp bl, 'X'
    je fun_ter
    jmp bomb11
    
    fun_ter:
    pop di
    pop si
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4
    
bomb11:    
    mov di, [bp+6]
    push di
    mov di, [bp+4]
    push di
    call bombsub
    jmp fun_ter
    
bombl:
    cmp bl, 'X'
    jne topleft
    
    cmp dl, 'X'
    je fun_ter
    
    mov di, [bp+4]
    push di
    mov di, [bp+6]
    push di
    call bombsub
    jmp fun_ter

topleft:
    mov si, 0
    mov di, [bp+4]
    sub di, 320
    sub di, 12
    mov cx, [es:di]
    cmp dx, cx
    jne topright  

    continuetopleft:
    inc si
    cmp si, 1       ; Require at least 2 matches (3 candies)
    jl skip_pop_topleft
    
    cmp si, 2       ; Create bomb if 3 matches (4 candies)
    jl normal_pop_topleft
    
    ; Create bomb
    mov al, 'X'
    mov ah, 0x05
    mov [es:di+320+12], ax ; Middle position
    jmp topright
    
    normal_pop_topleft:
    push di
    call rg
    
    skip_pop_topleft:
    sub di, 320
    sub di, 12
    mov cx, [es:di]
    cmp dx,cx
    je continuetopleft

topright:
    mov si, 0
    mov di, [bp+4]
    sub di, 320
    add di, 12
    mov cx, [es:di]
    cmp dx, cx
    jne bottomleft

    continuetopright:
    inc si
    cmp si, 1       ; Require at least 2 matches (3 candies)
    jl skip_pop_topright
    
    cmp si, 2       ; Create bomb if 3 matches (4 candies)
    jl normal_pop_topright
    
    ; Create bomb
    mov al, 'X'
    mov ah, 0x05
    mov [es:di+320-12], ax ; Middle position
    jmp bottomleft
    
    normal_pop_topright:
    push di
    call rg
    
    skip_pop_topright:
    sub di, 320
    add di, 12
    mov cx, [es:di]
    cmp dx,cx
    je continuetopright

bottomleft:
    mov si, 0
    mov di, [bp+4]
    add di, 320
    sub di, 12
    mov cx, [es:di]
    cmp dx, cx
    jne bottomright  

    continuebottomleft:
    inc si
    cmp si, 1       ; Require at least 2 matches (3 candies)
    jl skip_pop_bottomleft
    
    cmp si, 2       ; Create bomb if 3 matches (4 candies)
    jl normal_pop_bottomleft
    
    ; Create bomb
    mov al, 'X'
    mov ah, 0x05
    mov [es:di-320+12], ax ; Middle position
    jmp bottomright
    
    normal_pop_bottomleft:
    push di
    call rg
    
    skip_pop_bottomleft:
    add di, 320
    sub di, 12
    mov cx, [es:di]
    cmp dx,cx
    je continuebottomleft

bottomright:
    mov si, 0
    mov di, [bp+4]
    add di, 320
    add di, 12
    mov cx, [es:di]
    cmp dx, cx
    jne down

    continuebottomright:
    inc si
    cmp si, 1       ; Require at least 2 matches (3 candies)
    jl skip_pop_bottomright
    
    cmp si, 2       ; Create bomb if 3 matches (4 candies)
    jl normal_pop_bottomright
    
    ; Create bomb
    mov al, 'X'
    mov ah, 0x05
    mov [es:di-320-12], ax ; Middle position
    jmp down
    
    normal_pop_bottomright:
    push di
    call rg
    
    skip_pop_bottomright:
    add di, 320
    add di, 12
    mov cx, [es:di]
    cmp dx,cx
    je continuebottomright
        
down:
    mov si, 0
    mov di, [bp+4]
    add di, 320
    mov cx, [es:di]
    cmp dx, cx
    jne up  

    continuedown:
    inc si
    cmp si, 1       ; Require at least 2 matches (3 candies)
    jl skip_down
    
    cmp si, 2       ; Create bomb if 3 matches (4 candies)
    jl normal_down
    
    ; Create bomb
    mov al, 'X'
    mov ah, 0x05
    mov [es:di-320], ax ; Middle position
    jmp up
    
    normal_down:
    push di
    call rg
    
    skip_down:
    add di, 320
    mov cx, [es:di]
    cmp dx,cx
    je continuedown

up:
    mov si, 0
    mov di, [bp+4]
    sub di, 320
    mov cx, [es:di]
    cmp dx, cx
    jne right  

    continueup:
    inc si
    cmp si, 1       ; Require at least 2 matches (3 candies)
    jl skip_up
    
    cmp si, 2       ; Create bomb if 3 matches (4 candies)
    jl normal_up
    
    ; Create bomb
    mov al, 'X'
    mov ah, 0x05
    mov [es:di+320], ax ; Middle position
    jmp right
    
    normal_up:
    push di
    call rg
    
    skip_up:
    sub di, 320
    mov cx, [es:di]
    cmp dx,cx
    je continueup
    
right:
    mov si, 0
    mov di, [bp+4]
    add di, 12
    mov cx, [es:di]
    cmp dx, cx
    jne left
    
    continueright:
    inc si
    cmp si, 1       ; Require at least 2 matches (3 candies)
    jl skip_right
    
    cmp si, 2       ; Create bomb if 3 matches (4 candies)
    jl normal_right
    
    ; Create bomb
    mov al, 'X'
    mov ah, 0x05
    mov [es:di-12], ax ; Middle position
    jmp left
    
    normal_right:
    push di
    call rg
    
    skip_right:
    add di, 12
    mov cx, [es:di]
    cmp dx,cx
    je continueright

left:
    mov si, 0
    mov di, [bp+4]
    sub di, 12
    mov cx, [es:di]
    cmp dx, cx
    jne pass
    
    continueleft:
    inc si
    cmp si, 1       ; Require at least 2 matches (3 candies)
    jl skip_left
    
    cmp si, 2       ; Create bomb if 3 matches (4 candies)
    jl normal_left
    
    ; Create bomb
    mov al, 'X'
    mov ah, 0x05
    mov [es:di+12], ax ; Middle position
    jmp pass
    
    normal_left:
    push di
    call rg
    
    skip_left:
    sub di, 12
    mov cx, [es:di]
    cmp dx,cx
    je continueleft

pass:
    push si
    call setflag
    mov di, [bp+4]

    cmp byte[bombflag], 0
    jne updateoriginal
    cmp si, 1       ; Only update score if we have 3+ candies
    jl topleft2
    
    mov di, [bp+4]
    push si
    call updateScore

    mov al, 'X'
    mov ah, 0x05
    mov [es:di], ax
    jmp topleft2

updateoriginal:
    cmp si, 1       ; Only update if we have 3+ candies
    jl topleft2 
    push di
    call rg
    push si
    call updateScore
topleft2:
	mov si, 0
	mov di, [bp+6]
	sub di, 320
	sub di, 12
	mov cx, [es:di]
	cmp bx, cx
	jne bottomright2

	continuetopleft2:
	inc si
	push di
	call rg
	sub di, 320
	sub di, 12
	mov cx, [es:di]
	cmp bx,cx
	je continuetopleft2

	bottomright2:
	mov di, [bp+6]
	add di, 320
	add di, 12
	mov cx, [es:di]
	cmp bx, cx
	jne topright2

	continuebottomright2:
	inc si
	push di
	call rg
	add di, 320
	add di, 12
	mov cx, [es:di]
	cmp bx,cx
	je continuebottomright2

	topright2:
	mov di, [bp+6]
	sub di, 320
	add di, 12
	mov cx, [es:di]
	cmp bx, cx
	jne bottomleft2

	continuetopright2:
	inc si
	push di
	call rg
	sub di, 320
	add di, 12
	mov cx, [es:di]
	cmp bx,cx
	je continuetopright2

	bottomleft2:
	mov di, [bp+6]
	add di, 320
	sub di, 12
	mov cx, [es:di]
	cmp bx, cx
	jne down2

	continuebottomleft2:
	inc si
	push di
	call rg
	add di, 320
	sub di, 12
	mov cx, [es:di]
	cmp bx,cx
	je continuebottomleft2
	
	down2:
	mov di, [bp+6]
	add di, 320
	mov cx, [es:di]
	cmp bx, cx
	jne up2

	continuedown2:
	inc si
	push di
	call rg
	add di, 320
	mov cx, [es:di]
	cmp bx,cx
	je continuedown2

	up2:
	mov di, [bp+6]
	sub di, 320
	mov cx, [es:di]
	cmp bx, cx
	jne right2

	continueup2:
	inc si
	push di
	call rg
	sub di, 320
	mov cx, [es:di]
	cmp bx,cx
	je continueup2
	
	right2:
	mov di, [bp+6]
	add di, 12
	mov cx, [es:di]
	cmp bx, cx
	jne left2
	
	continueright2:
	inc si
	push di
	call rg
	add di, 12
	mov cx, [es:di]
	cmp bx,cx
	je continueright2

	left2:
	mov di, [bp+6]
	sub di, 12
	mov cx, [es:di]
	cmp bx, cx
	jne pass2
	
	continueleft2:
	inc si
	push di
	call rg
	sub di, 12
	mov cx, [es:di]
	cmp bx,cx
	je continueleft2

	pass2:

	push si
	call setflag
	mov di, [bp+6]


	cmp byte[bombflag], 0
	jne updateoriginal2
	mov di, [bp+6]
	inc si
	push si
	call updateScore

	push ax
	push di
	call rg
	mov al, 'X'
	mov ah, 0x05
	mov [es:di], ax
	pop ax
	jmp fun_end

	updateoriginal2:
	
	cmp si, 0
	je fun_end 
	push di
	call rg
	inc si
	push si
	call updateScore
fun_end:
    pop di
    pop si
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4
swapchars:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	mov si, [bp+4]
	mov ax, [bp+6]

	add ax, 320
	cmp ax, si
	je swap
	
	mov ax, [bp+6]
	sub ax, 320
	cmp ax, si
	je swap
	
	mov ax, [bp+6]
	add ax, 12
	cmp ax, si
	je swap
	
	mov ax, [bp+6]
	sub ax, 12
	cmp ax, si
	je swap
	                                                                              
	jmp returnfun

swap:
	
	mov ax, 0xb800
	mov es, ax
	
	
	mov ax, [bp+6]
	mov di, ax
	
	mov dx, [es:di] ; 1st ; bp+6
	
	mov di, si
	mov si, 0 ; count of pattern
                                                                                                                          
	mov bx, [es:di] ; 2nd ; bp+4

	cmp dl, '~'
	je returnfun

	cmp bl, '~'
	je returnfun
	
	
	;interchange
	mov di, [bp+6]
	mov [es:di], bx
	
	mov di, [bp+4]
	mov [es:di], dx
		
	;now ;1st ; bp+4 ;2nd; bp+6
	
	; pattern [bp+6]

	p:
	
	mov di, [bp+6]
	push di
	mov di, [bp+4]
	push di
	call pattern

count:
	;moves count and show
       	        mov cx, 13
		mov ax, 0xb800
		mov es, ax
		mov di, 270
		mov si, RemainingMoves               
		mov ah, 0x03 

prtRemMoves: ; half red
		mov al, [si]
		mov [es:di], ax
		add di, 2
                add si, 1
		loop prtRemMoves

	mov si, RemainingMovesCount
	mov di, 290
	mov cx, 1
	
	prtRemMovesC:
	mov al, [si]
	add al, 0x30
	sub al, 1
	mov [es:di], ax
	add di, 2
	add si, 1
	sub al, 0x30
	mov [RemainingMovesCount], al
	loop prtRemMovesC
	
	returnfun:
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4

changec:
	
	push bp
	mov bp, sp
	push es
	push di 
	push ax
	
	mov ax, 0xb800
	mov es, ax
	mov di, [bp+4]
	
	mov al, ' '
	mov ah, 00010000b
	
	mov [es:di-4], ax 
	mov [es:di-2], ax
	mov [es:di+2], ax
	mov [es:di+4], ax
	
	pop ax
	pop di
	pop es
	pop bp
	ret 2
	
revertc:

	push bp
	mov bp, sp
	push es
	push di 
	push ax
	
	mov ax, 0xb800
	mov es, ax
	mov di, [bp+4]
	
	mov al, ' '
	mov ah, 00010000b
	
	mov [es:di-4], ax 
	mov [es:di-2], ax
	mov [es:di+2], ax
	mov [es:di+4], ax
	
	pop ax
	pop di
	pop es
	pop bp
	ret 2

	concludingscreen:

	mov si, 4
	mov dx, 0x0A18

	prtrectangle:
	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 0x77 ; normal attrib
	mov cx, 27 ; length of string
	push cs
	pop es ; segment of string
	mov bp, PressAnyKey ; offset of string
	int 0x10
	inc dh
	dec si
	cmp si, 0
	jne prtrectangle

	mov ah, 0x13 
	mov al, 1 
	mov bh, 0 
	mov bl, 0x70 
	mov dx, 0x0B21
	mov cx, 9 
	push cs
	pop es 
	mov bp, ConclusionMessage1 
	int 0x10

	mov ah, 0x13 ; 
	mov al, 1 ; 
	mov bh, 0 ; 
	mov bl, 0x70 ; 
	mov dx, 0x0C1B
	mov cx, 21 ; 
	push cs
	pop es ; 
	mov bp, ConclusionMessage2 
	int 0x10

	mov ah, 0
	int 16h

	mov ax, 0xb800
	mov es, ax
	xor di, di
	mov ax, 0x0720
	mov cx, 2000
		
	cld
	rep stosw

	ret

; ===========================================
; =================Level_1 ==================
; ===========================================
show_level_1:
mov ax, 0xB800
mov es, ax

mov si, level_1
mov di, 80
call print_string
jmp gettwochars

; ============================================
; =================Level_2====================
; ============================================
show_level_2:
mov ax, 0xB800
mov es, ax

mov si, level_2
mov di, 80
call print_string
jmp gettwochars

; ==============================================
; ================ Level_3 =====================
; ==============================================
show_level_3:
mov ax, 0xB800
mov es, ax

mov si, level_3
mov di, 80
call print_string
jmp gettwochars


start:
        call clrscr
        call draw_border
        call print_names
        call wait_for_keys
	call setup
        call clrscr
        call draw_border
        call get_level_input
        call wait_for_keys
        here:
	call prtboard ; fill background colors
	call hzl ; draw horizontal lines
	call vtl ; draw vertical lines
        call prtdetails ; print player name and score
	;call oldinitialiseboard
	call initialiseboard
        cmp word[level_flag],1
        je show_level_1
        cmp word[level_flag],2
        je show_level_2
        cmp word[level_flag],3
        je show_level_3
        
	gettwochars:
	sub sp, 2
	call noMouseClick
	pop di
	
	push di
	; 1st change color
	call changec

	mov cx, 0xFFFF
	delay:
	sub cx, 1
	cmp cx,0
	jne delay

	mov cx, 0xFFFF
	delay1:
	sub cx, 1
	cmp cx,0
	jne delay1

	mov cx, 0xFFFF
	delay2:
	sub cx, 1
	cmp cx,0
	jne delay2

	sub sp, 2
	call noMouseClick
	pop si
	
	; 1st revert color
	push di
	call revertc

	push di
	push si
	call swapchars

	mov al, [RemainingMovesCount]
	cmp al, 0
	je terminate
	
	mov cx, 0xFFFF
	first_delay:
	sub cx, 1
	cmp cx,0
	jne first_delay

	mov cx, 0xFFFF
	second_delay:
	sub cx, 1
	cmp cx,0
	jne second_delay

	mov cx, 0xFFFF
	third_delay:
	sub cx, 1
	cmp cx,0
	jne third_delay

	jmp gettwochars

terminate:
	call concludingscreen
	mov ax, 0x4c00
	int 21h

; ==============================================
; ================Get level Input===============
; ==============================================
get_level_input:
; Print instructions at row 5, col 25
mov si, instructions
mov di, 1284; row 5 * 80 + col 5 = 5 * 80 + 5 = 405
call print_string

mov si, press_1
mov di, 1444
call print_string

mov si, press_2
mov di, 1604
call print_string

mov si, press_3
mov di, 1764
call print_string

wait_input :
; Wait for user key press
mov ah, 0
int 16h; BIOS keyboard input → AL = ASCII

cmp al, '1'
je set_level_1

cmp al, '2'
je set_level_2

cmp al, '3'
je set_level_3

; Invalid input
mov si, invalid_msg
mov di, 1924

call clrscr
call draw_border
call print_string
jmp get_level_input

ret
; ================================================
; =============set level 1 =======================
; ================================================
set_level_1:
mov word[level_flag],0x01
mov byte[rows],0x07
mov byte[columns],0x07
jmp here


; ===============================================
; =============set level 2 ======================
; ===============================================
set_level_2:
mov word[level_flag],0x02
mov byte[rows],0x07
mov byte[columns],0x07
jmp here


; ================================================
; =============set level 3 =======================
; ================================================
set_level_3:
mov word[level_flag],0x03
mov byte[rows],0x07
mov byte[columns],0x07
jmp here