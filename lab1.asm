.model small
.stack 100h
.data
    a dw 0
    b dw 0
    c dw 0
    d dw 0
.code
main proc 
    ;<readABCD>
    mov a,10
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
    jmp f1
    t1:
    xor AX,AX
    cmp AX,1
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
    jmp f1
    t2:
    mov AX, a
    add AX, b
    add AX, c
    ;<print>
   
    f1:
   
main endp
end main
    
