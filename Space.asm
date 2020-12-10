.model small 
.stack 100h
.386
; TO-DO
; fix clock (?)
; boundaries (+)
; invader movement (+)
; models (?)
; invaders shooting
;   > random nubmer generator (+)
.data
    Playing db 1 ; game state
    InvadersLeft db 18
    TotalInvaders db 18
    invaderHeight dw 20
    invaderWidth dw 26
    MaxLasers db 3 ; max. number of invader lasers on screen
    CurrentLasers db 0 ; number of ivnader lasers on screen
    MovementSpeed dw 5 ; Player movement speed
    PlayerShooting db 0 ; is laser on screen; 0 - false 1 - true
    PlayerLaserX dw -1
    PlayerLaserY dw -1
    PlayerPosX dw 160
    PlayerPosY dw 180
    Time db ?
    PlayerHeight dw 8 ; half of the player's height
    PlayerWidth dw 8
    BulletFrames dw 5
    InvadersRowPosX dw 0, 50, 100, 150,200, 250, 0, 50, 100, 150,200, 250, 0, 50, 100, 150,200, 250 
    InvaderAlive dw 18 dup(1)
    InvadersRowPosY dw 0, 30, 60
    InvaderLaserPosY dw -1, -1, -1
    InvaderLaserPosX dw -1, -1, -1
    InvaderPosY dw 0
    InvaderPosX dw 0
    InvaderFrames db 0
    InvaderMovementFrames dw  10
    InvaderMovementDirection db 1 ; 1 - right, 0 - left
    ScreenHeight dw 200
    ScreenWidth dw 320
    InvaderVerticalMovementSpeed dw 10
    RandomNumber db 0
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
    ; delete bullet after hit
    ; remove invader 
    push AX
    push BX
    push CX
    push DX
    push SI
    push DI
    xor CX, CX
    xor DX, DX
    mov CX, SI
    sub CX, offset InvadersRowPosX
    mov SI, offset InvaderAlive
    add SI, CX
    cmp byte ptr[SI], 1
    jne stopInvPr
    mov SI, offset InvadersRowPosX
    add SI, CX
    mov BX, CX
    mov DX, [SI]
    cmp PlayerLaserX, DX 
    ; compare x coord
    jl drInv
    mov DX, [SI]
    add DX, InvaderWidth
    cmp PlayerLaserX, DX
    jg drInv
    
    mov DX, InvaderPosY
    cmp PlayerLaserY, DX
    jl drInv
    
    add DX, InvaderHeight
    cmp PlayerLaserY, DX
    jg drInv
    mov SI, offset InvaderAlive
    add SI, BX
    mov byte ptr[SI], 0
    mov PlayerShooting , 0
    mov AL, 00h
    mov CX, PlayerLaserX
    mov DX, PlayerLaserY
    int 10h
    add DX, 1
    int 10h
    mov PlayerLaserX, -1
    mov PlayerLaserY, -1
    dec InvadersLeft
    drInv:
    xor DX, DX
    xor CX, CX
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
    pop DI
    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
    ret
drawInvader endp
checkForWin proc
    push SI
    push CX
    mov SI, offset InvadersRowPosY
    add SI, 6
    mov CX, [SI]
    add CX, InvaderHeight
    cmp CX, PlayerPosY
    jl stopCheck
    mov Playing, 0
    stopCheck:
    pop CX
    pop SI
    ret
checkForWin endp
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
    push SI
    push DI
    mov AH, 0Ch
    
    
    xor CX, CX
    lea SI, InvadersRowPosX
     
    xor BX, BX
    mov DI, offset InvadersRowPosY
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
    
    mov DX, [DI]
    
    mov InvaderPosY, DX
    call drawInvader
    add SI, 2
    
    loop prInvader
    pop BX
    add DI, 2
    add BX, 1
    ;add InvadersRowPosY, 30
    jmp linesLoop
    stPrLines:
  
    ;mov InvadersRowPosY, 0
    pop DI
    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
    ret
StartGame endp
MoveInvaders proc
    push AX
    push BX
    push CX
    push DX
    push SI
    push DI
    mov DI, offset InvadersRowPosY
    cmp InvaderMovementFrames, 0
    je moveInv
    dec InvaderMovementFrames
    jmp stopInvF
    moveInv:
    mov InvaderMovementFrames, 1000
    cmp InvaderMovementDirection, 1
    je moveRightCheck
    mov SI, offset InvadersRowPosX
    cmp [SI], 0
    jg movLeft
    mov InvaderMovementDirection, 1
    mov CX, InvaderVerticalMovementSpeed
    mov AL, 00h
    call StartGame
   
    add [DI], 10
    add DI, 2
    add [DI], 10
    add DI, 2 
    add [DI], 10
    mov AL, 0Fh
    call StartGame
    call checkForWin 
    
    jmp stopInvF
    movLeft:
    ; Move left
    xor CX, CX
    mov CL, TotalInvaders
    mov AL, 00h
    call StartGame
    mov SI, offset InvadersRowPosX
    movInvLeft:
    
    
    sub [SI], 10
    add SI, 2
    loop movInvLeft
    ; /Move left
    mov AL, 0Fh
    call StartGame
    jmp stopInvF
    
    moveRightCheck:
    mov SI, offset InvadersRowPosX
    add SI, 10
    mov CX, ScreenWidth
    sub CX, InvaderWidth
    sub CX, 5
    cmp [SI], CX
    jl moveRight
    mov InvaderMovementDirection, 0
    mov AL, 00h
    call StartGame
    mov CX, InvaderVerticalMovementSpeed
    add [DI], 10
    add DI, 2
    add [DI], 10
    add DI, 2 
    add [DI], 10
    mov AL, 0Fh
    call StartGame
    call checkForWin 
    jmp stopInvF
    moveRight:
    ; Move right
    xor CX, CX
    mov CL, TotalInvaders
    mov AL, 00h
    call StartGame
    mov SI, offset InvadersRowPosX
    movInv:
    
    
    add [SI], 10
    add SI, 2
    loop movInv 
    ; /Move right
    mov AL, 0Fh
    call StartGame
    stopInvF:
    
    
    pop DI
    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
    ret
MoveInvaders endp

randomNumberGenerator proc
    push AX
    push BX
    push CX
    push DX
    mov AH, 2Ch
    int 21h 
    xor AX, AX
    mov AL, DL
    xor CX, CX
    mov CL, TotalInvaders
    add AL, RandomNumber
    div CL
    mov RandomNumber, AH
    pop DX
    pop CX
    pop BX
    pop AX
    ret
randomNumberGenerator endp
invaderLaser proc
    push AX
    push BX
    push CX
    push DX
    push SI
    
    mov SI, offset InvadersRowPosX
    add SI, CX
    add SI, CX  
    xor CX, CX
    mov DI, offset InvaderLaserPosX
    mov CL, MaxLasers
    checkLaserArray: 
    cmp [DI], -1
    je foundLaserPos
    add DI, 2
    loop checkLaserArray
   
    foundLaserPos:
    mov CX, offset InvaderLaserPosX
    push DI
    sub DI, CX
    mov CX, DI
    pop DI
    ;sub CH, CL ; free laser pos in array
    mov AX, [SI]
    mov [DI], AX
    mov DX, offset InvadersRowPosX
    push DI
    sub DI, DX
    mov DX, DI
    pop DI
    mov AX, DX
    xor BX, BX
    mov BL,  6
    div BL
    xor DX, DX
    mov DL, AL
    mov DI, offset InvadersRowPosY
    add DI, DX
    add DI, DX     
    mov SI, offset InvaderLaserPosY
    add SI, CX ; CX - pos in InvaderLaserPosX
    mov AX, [DI]
    mov [SI], AX
    ;mov DI, offset InvaderLaserY
    ;add DI, CH
    ;add DI, CH
    ;mov [DI], [SI]
    pop SI  
    pop DX
    pop CX
    pop BX
    pop AX
    ret
invaderLaser endp
drawInvaderLaser proc
    push AX
    push BX
    push CX
    push DX
    xor CX, CX
    xor DX, DX
    mov AH, 0Ch
    mov AL, 00h
    mov CX, [SI]
    mov DX, [DI]
    int 10h
    
    
    mov CX, InvaderLaserPosY
    cmp CX, ScreenHeight
    jl stDr
    mov [SI], -1
    mov [DI], -1
    dec CurrentLasers
    jmp endF 
    stDr:
    add [DI], 1
    mov AH, 0Ch
    mov AL, 0Fh
    mov CX, [SI]
    mov DX, [DI]
    int 10h
    endF:
    pop DX
    pop CX
    pop BX
    pop AX
    ret
drawInvaderLaser endp
InvaderShoot proc
    push AX
    push BX
    push CX
    push DX
    
    
    checkLasers:
    xor AX, AX
    mov AL, CurrentLasers
    cmp AL, MaxLasers
    je stopInvaderShootF
    mov SI, offset InvaderAlive
    xor CX, CX
    mov CL,RandomNumber
    add SI, CX
    add SI, CX
    cmp [SI], 1
    je addLaser
    call randomNumberGenerator
    jmp checkLasers
    addLaser:
    call InvaderLaser
    inc CurrentLasers ; adds 1 laser to the counter if invader is alive
    
    jmp checkLasers
    
    stopInvaderShootF:
    xor CX, CX
    mov CL, MaxLasers
    mov SI, offset InvaderLaserPosX
    mov DI, offset InvaderLaserPosY
    drInvaders:
   
    cmp [DI], -1
    jne  cntC
    add SI, 2
    add DI, 2
    dec CX
    jmp drInvaders
    cntC:
    call drawInvaderLaser
    add SI, 2
    add DI, 2
    loop drInvaders
    
    pop DX
    pop CX
    pop BX
    pop AX
    ret
invaderShoot endp
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
    cmp PlayerPosX, 10
    jle ef
    sub PlayerPosX , 5
    jmp ef
    rightch:
    cmp AH, 4Dh
    jne spacecheck ; right
    mov AH, 0Ch
    mov AL, 0
    call PrintPlayer
    mov AL, 0Fh
    cmp PlayerPosX, 310
    jge ef
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
   
    pop AX
    call InvaderShoot
    call drawBullet
    call MoveInvaders
    cmp Playing, 0
    je stop
    cmp InvadersLeft, 0
    je stop
    jmp back
    stop:
    mov AH, 3
    int 10h
    mov AH, 4ch
    int 21h
main endp
end main