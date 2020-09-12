.model small
.stack 100h
.data
    a dw 0
    b dw 0
    c dw 0
    d dw 0
    counter dw 0
    countertotal dw 0
    msg db 13, 10, 'Bad input$'
.code
printData proc
    push AX
    mov AH, 02h
    int 21h
    pop AX
    ret
printData endp
readData proc
    mov counter,0
    cycle:
    mov AH, 01h
    int 21h
    cmp AL, 13
    jz entert
    cmp AL, 08
    jz backspacet
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
    mov BL, 10
    cmp CX, 0
    jz zerot
    power:
    mul BL
    loop power
    zerot:
    pop CX
    sub CL, '0'
    mul CL
    add DX, AX
    dec counter
    jmp numberloop
    endpr:
    mov DX, offset msg
    mov AH, 09
    int 21h
    mov AH, 76
    int 21h
    final:
    ret
readData endp
printNumber proc
    xor CX, CX
    xor BL, BL
    mov BL, 10
    division:
    div BL

    push AX
    inc CX
    cmp AL, 0
    mov AH, 0
    jnz division
    printing:
    pop DX
    mov AH, DH
    xor DX, DX
    mov DL, AH
    add DL, '0'
    mov AH, 02h
    int 21h
    loop printing
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
    ;<readABCD>
    
   
    mov AX, a
    add AX, b
    
    xor AX, c
    cmp AX, d
    jz t1
    mov CX, d
    and CX, c
    mov AX, b
    add AX, CX
    ;<print>
    call printNumber
    jmp f1
    t1:
    mov AX, d
    sub AX, b
    mov DX, a
    sub DX, c
    cmp AX, DX
    JZ t2
    mov AX, b
    add AX, c
    add AX, d
    ;<print>
    call printNumber
    jmp f1
    t2:
    mov AX, a
    add AX, b
    add AX, c
    ;<print>
    call printNumber
    f1:
    mov AH, 4Ch
    int 21h
main endp
end main