.model small
.stack 1000h
.data
    max db 101
    count db 0                    
    buffer db 100 dup (?)
    
.code
readString proc 
    push AX
    mov SI, offset buffer
    read:
    mov AH, 01
    int 21h
    cmp AL, 10
    je enter1
    cmp AL, 13
    je enter1
    cmp AL, ' '
    je enter1
    add count, 1
    
    mov [SI], AL
    inc SI
    jmp read
    enter1:
    
    mov byte ptr [SI + 1], '$'
    pop AX
    ret
readString endp
printString proc
    push AX
    push DX
    xor DX, DX
    mov SI, offset buffer
    readc: 
    cmp [SI], '$'
    je stopf
    mov DL, [SI]
    mov AH, 2
    int 21h
    inc SI
    jmp readc
    stopf:
    pop DX
    pop AX
    ret
printString endp
main proc
    mov AX, @data                         
    mov DS, AX
    call readString
    mov SI, offset buffer                   
    xor BX, BX
    mov BL, count
    firstl:     
    dec BX
    jz stop
    mov CX, BX
    mov SI, offset buffer
    xor DL, DL; DL = swap(0 - false, 1 - true)  
    secondl:
    mov AX, [SI] ; AL = first 8 bits, AH - second 8 bits
    cmp AL, AH                              
    jbe S1                                  
    mov DL, 1                               
    xchg AL, AH
    mov [SI], AX
    S1:
    inc SI
    loop secondl
    cmp DL, 0
    jnz firstl
    stop:
    lea DX, buffer
    mov AH, 9
    int 21h
    ;call printString
    mov AH, 4Ch
    int 21h
main endp
end main
