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
printData proc
    push AX
    mov AH, 02h
    int 21h
    pop AX
    ret
printData endp
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
    mov AX, a
    mov BX, b
    mov CX, c
    mov DX, d
    and BX, AX
    and DX, CX
    cmp BX, DX
    jz true1
    mov AX, a
    mov BX, b
    mov CX, c
    mov DX, d
    xor AX, BX
    or CX, DX
    cmp AX, CX
    jz true2
    mov AX, a
    mov BX, b
    mov CX, c
    mov DX, d
    and AX, DX
    xor BX, CX
    or AX, BX
    call printNumber
    jmp endprogram
    ;print (a & d) | (b ^ c)
    true2:
    mov AX, a
    mov BX, b
    mov CX, c
    mov DX, d
    xor BX, AX
    add CX, DX
    and BX, CX
    mov AX, BX
    call printNumber
    ;print (b ^ a) & (c + d)
    jmp endprogram
    true1:
    mov AX, a
    mov BX, b
    mov CX, c
    mov DX, d
    or AX, BX
    or CX, DX
    and AX, CX
    call printNumber
    ;print (a | b) & (c | d)
    endprogram:
    mov AH, 4Ch
    int 21h
main endp
end main
