.model small
.stack 100h
.data
    a dw 0
    b dw 0
    c dw 0
    d dw 0
    counter dw 0
    countertotal dw 0
    negative db 0
    msg db 13, 10, 'Bad input$'
    zeroerror db 13,10, 'Zero division$'
.code
readData proc
    
    mov counter,0
    cycle:
    mov AH, 01h
    int 21h
    cmp AL, 13 ;enter
    jz entert
    cmp AL, 08 ;backspace
    jz backspacet
    cmp AL, 45 ;-
    jz minussign
    cmp AL, '9' + 1
    jnc endpr
    cmp AL, '0' - 1
    jc endpr
    push AX
    xor DX,DX
    inc counter
    jmp cycle
    backspacet:
    pop AX
    dec counter
    mov DL, 20h
    call printData
    mov DL, 08
    call printData
    jmp cycle
    entert:
    mov CX, counter
    mov countertotal, CX
    numberloop:
    cmp counter, 0
    JZ final
    mov CX, countertotal
    sub CX, counter
    mov AX, 1
    mov BX, 10
    cmp CX, 0
    jz zerot
    push DX
    power:
    mul BX 
    loop power
    pop DX
    ;countertotal - counter = 0
    zerot:
    
    pop CX
    xor CH, CH
    sub CX, '0'
    push DX
    mul CX
    pop DX
    add DX, AX
    mov AX, DX
    dec counter
    jmp numberloop
    ;(-)handling
    minussign:
    cmp counter, 0
    jnz endpr
    cmp negative, 1
    jz endpr
  
    inc negative
    jmp cycle
    ;error 
    endpr:
    mov DX, offset msg
    mov AH, 09
    int 21h
    mov AH, 76
    int 21h
    final:
   
    cmp negative, 1
    jnz endproc
    
    
    mov negative, 0
    
    mov AX, DX
    
    mov CX, -1
    mul CX
    mov DX, AX
    endproc:
    ret
readData endp
printData proc
    push AX
    mov AH, 02h
    int 21h
    pop AX
    ret
printData endp
printNumber proc
    push AX 
    push DX
    test AX, AX
    jns positiveprint
    mov CX, -1
    mul CX
    push AX
    push DX
    mov AH, 02h
    mov DL, '-'
    int 21h
    pop DX
    pop AX
    positiveprint:
    xor CX, CX
    xor BL, BL
    mov BX, 10
    division:
    xor DX, DX
    div BX
    push DX
    inc CX
    cmp AX, 0
    mov DX, 0
    jnz division
    printing:
    pop DX
    mov AH, DL
    xor DX, DX
    mov DL, AH
    add DL, '0'
    mov AH, 02h
    int 21h
    loop printing
    pop DX
    pop AX
    ret
printNumber endp
main proc
    mov AX, @data
    mov DS, AX
    call readData
    mov a, DX
    call readData
    mov b, DX
    call readData
    mov c, DX
    call readData
    mov d, DX
    mov AX, a
    mov BX, b
    mov CX, c
    mov DX, d
    cmp AX, 0
    jnz notzero1
    mov DX, offset zeroerror
    mov AH, 09
    int 21h
    jmp stop
    notzero1:
    cmp DX, 0
    jnz notzero2
    mov DX, offset zeroerror
    mov AH, 09
    int 21h
    jmp stop
    notzero2:
    cmp AX, BX
    jl false1
   
    sub CX, DX
    add CX, AX
    mov AX, CX
    call printNumber ;print((c - d) + a)
    jmp stop
    false1:
   
    mov AX, a
    mov BX, b
    mov CX, c
    mov DX, d
    
    
    and CX, DX
    mov CX, c
    js ct
    
    or CX,DX
    mov CX, c
    jns ct
    
   
    test CX, CX
    jns ntest2 
    ; CX
    push AX
    push DX
    mov AX, CX
    xor DX,DX
    mov CX, -1
    mul CX
    mov CX, AX
    pop DX
    pop AX
    jmp calcdiv
    ntest2: ;DX
    push AX
    push CX
    mov AX, DX
    mov CX, -1
    mul CX
    mov DX, AX
    pop CX
    pop AX
    calcdiv:; (c / d):
    
    mov AX, CX
    
    mov CX, DX
    xor DX, DX
    div CX
  
    push DX
    mov CX, -1
    mul CX
    pop DX
    push AX
    mov AX, DX
    mul CX
    mov DX, AX
    pop AX
  
    ; -7 / 2 AX=-3 DX = -1
    jmp calc2
    
    ct:
    sub AX, BX
    push AX
    mov AX, CX
    
    mov CX, DX
    xor DX, DX
    div CX
    pop CX
    calc2:
    push AX
    mov CX, a
    mov BX, b
    sub CX, BX
    pop AX
    cmp CX, AX ;still works
    jg false2
    
    cmp CX, AX
    jnz state2
    cmp DX, 0
    jl false2
    
    state2:
    ;
    
    mov CX, a
    mov BX, b
    mov AX, c
   
    xor DX, DX
    div CX
    sub BX, DX
    mov AX, BX 
    
    ;
    
    call printNumber; print(b - (c % a))
    jmp stop
    false2:
    
    mov AX, a
    mov BX, b
    mov CX, c
    mov DX, d
    sub AX, DX
    sub CX, AX
    mov AX, CX
    call printNumber ;print(c - (a - d))
    stop:
    mov AH, 4Ch
    int 21h
main endp
end main
