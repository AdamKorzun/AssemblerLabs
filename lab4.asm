.model small
.stack 1000h
.data
    max db 101
    count db 0                    
    buffer db 100 dup (?)          
.code
main proc
    mov AX, @data                         
    mov DS, AX
    mov DX, offset max
    mov AH, 10
    int 21h
    mov SI, offset buffer                   
    xor BX, BX
    mov BL, count
    mov byte ptr [SI + BX], '$'
    firstl:
    dec BX
    jz stop
    mov CX, BX
    mov SI, offset buffer
    xor DL, DL; DL = swap(0 - false, 1 - trie)
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
    mov DX, offset buffer
    mov AH, 9
    int 21h
    mov AH, 4Ch
    int 21h
main endp
end main