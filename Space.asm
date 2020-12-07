.model small 
.stack 100h
; TO-DO
; hit boxes
; fix spawn
; invader movement
; models
; invaders shooting
.data
    InvadersLeft db 18
    ;TotalInvaders db 18
    invaderHeight dw 20
    invaderWidth dw 35
    MaxLasers db 3 
    CurrentLasers db 0
    MovementSpeed dw 5
    PlayerShooting db 0 
    PlayerLaserX dw ?
    PlayerLaserY dw ?
    PlayerPosX dw 160
    PlayerPosY dw 180
    Time db ?
    PlayerHeight dw 8
    PlayerWidth dw 8
    BulletFrames dw 5
    ;InvadersPosX dw 18 dup (0, 50, 100, 150, 200, 250, 0, 50, 100, 150, 200, 250, 0, 50, 100, 150, 200, 250)
    InvadersRowPosX dw 0, 50, 100, 150,200, 250, 0, 50, 100, 150,200, 250, 0, 50, 100, 150,200, 250
    InvadersRowPosY dw 0
    InvaderPosY dw 0
    InvaderPosX dw 0
    InvaderFrames db 0
.code


Shoot proc
    push AX
    push BX
    push CX
    push DX
    
    mov AL, 0Fh
    cmp PlayerShooting, 0
    jne endShooting
    mov PlayerShooting, 1 
    mov CX, PlayerPosX
    mov PlayerLaserX, CX
    mov DX, PlayerPosY
    mov PlayerLaserY, DX
    endShooting:
    pop DX
    pop CX
    pop BX
    pop AX
    ret
Shoot endp

drawBullet proc
    push AX
    push BX
    push CX
    push DX
    cmp PlayerShooting, 0 
    je stopdrawbullet
    cmp BulletFrames, 0 
    je drawandtest
    dec bulletFrames
    jmp stopdrawbullet
    drawandtest:
    mov BulletFrames, 5
    mov CX, PlayerLaserX
    mov DX, PlayerLaserY
    mov AH, 0Ch
    mov AL, 0 
    int 10h ; delete prev bullet
    add DX, 1
    int 10h
    sub DX, 1   
   
    cmp PlayerLaserY, 0
    jne drwb
    mov PlayerShooting, 0
    mov PlayerLaserX, 0
    mov PlayerLaserY, 0
    jmp stopdrawbullet
    drwb:
    
    mov AL, 0Fh
    
    int 10h
    sub DX, 1
    mov AL, 0Fh
    int 10h
    
    int 10h
    mov PlayerLaserY, DX
    add InvaderFrames, 1
    cmp InvaderFrames, 10
    jne stopdrawbullet
    mov invaderFrames, 0
    call StartGame
    
    stopdrawbullet:
    pop DX
    pop CX
    pop BX
    pop AX
    ret
drawBullet endp

drawInvader proc
    push AX
    push BX
    push CX
    push DX
    xor CX, CX
    xor DX, DX
    mov CX, InvaderPosX
    mov DX, InvaderPosY
    add DX, InvaderHeight
    printInvaderLine:
    cmp DX, InvaderPosY
    je stopInvPr
    mov CX, InvaderPosX
    add CX, InvaderWidth
    InvPixelPr:
    cmp CX, invaderPosX
    je stopLinePr
    int 10h 
    sub CX, 1
    jmp InvPixelPr
    stopLinePr:
    dec DX
    jmp printInvaderLine
    stopInvPr:
    pop DX
    pop CX
    pop BX
    pop AX
    ret
drawInvader endp

printPlayer proc
    push AX
    push BX
    push CX
    push DX
    mov CX, PlayerPosX
    mov DX, PlayerPosY
    add DX, PlayerHeight
    printL:
    cmp DX, PlayerPosY
    je stoppr
    int 10h
    add CX, PlayerWidth
    prLine:
    cmp CX, PlayerPosX
    jle pr2
    int 10h
    sub CX, 1
    jmp prLine
    pr2:
     
    sub CX, PlayerWidth
    prLine2:
    cmp CX, PlayerPosX
    je endpr2
    int 10h
    add CX, 1
    jmp prLine2
    endpr2:
    dec DX
    jmp printL
    stoppr:
    pop DX
    pop CX
    pop BX
    pop AX
    ret
printPlayer endp
StartGame proc
    push AX
    push BX
    push CX
    push DX
    mov AH, 0Ch
    
    
    xor CX, CX
    lea SI, InvadersRowPosX
     
    xor BX, BX
    linesLoop:
    cmp BX, 3
    jge stPrLines
    push BX
    mov CL, 6
    prInvader:    
    xor DX, DX
    xor BX, BX
    mov BX,[SI]
    mov InvaderPosX, BX
    mov DX, InvadersRowPosY
    mov InvaderPosY, DX
    call drawInvader
    inc SI
    inc Si
    
    loop prInvader
    pop BX
    add BX, 1
    add InvadersRowPosY, 30
    jmp linesLoop
    stPrLines:
    mov InvadersRowPosY, 0
    pop DX
    pop CX
    pop BX
    pop AX
    ret
StartGame endp
main proc
    mov AX, @data
    mov DS, AX
    mov AH, 2Ch
    int 21h
    mov Time, DL
    mov AH, 00h
    mov AL, 13h
    int 10h
    
    mov AH, 0Bh
    mov BH, 00h
    mov BL, 00h
    int 10h
    mov AL, 0Fh
    call StartGame
    mov AH, 0Ch
    mov DX, PlayerPosY
    mov AL, 0Fh
  
    mov CX, PlayerPosX ; CX = x DX = y A AL = color
    back:
    push AX
    push DX
    push CX
    mov CL, Time
    mov AH, 2Ch
    timer:
    int 21h
    cmp CL, DL ; CLOCK
    je timer
    mov Time, DL
    pop CX
    pop DX
    pop AX
    ;mov CX, PlayerPosX
    call printPlayer
    push AX 
    xor al, al
    mov AH, 1h
    int 16h
    jz ef
    mov ah, 0
    int 16h
    cmp AH, 4Bh ; left
    jne rightch
    mov AH, 0Ch
    mov AL, 0
    call PrintPlayer
    mov AL, 0Fh
    sub PlayerPosX , 5
    jmp ef
    rightch:
    cmp AH, 4Dh
    jne spacecheck ; right
    mov AH, 0Ch
    mov AL, 0
    call PrintPlayer
    mov AL, 0Fh
    add PlayerPosX, 5
    ;mov InvaderPosX, 0
    ;mov InvaderPosY, 0
    ;call drawInvader
    jmp ef
    spacecheck:
    cmp AH, 57 ; Space bar check
    jne escCheck
    call Shoot
    
    jmp ef
    escCheck:
    cmp AH, 01 ; ESC check
    jne ef
    jmp stop
    ef:
    ; Clear screen
    ;mov AL, 13h
    ;mov AH, 00h
    ;int 10h
    pop AX
    call drawBullet
    jmp back
    stop:
    mov AH, 3
    int 10h
    mov AH, 4ch
    int 21h
main endp
end main