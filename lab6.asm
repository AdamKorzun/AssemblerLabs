.model small
.stack 1000h
.186
.data 
    old_9h dd 0


.code 
kb_handler proc far ; new int 9h handler
    pusha
    push ES
    push DS
    push CS
    add word ptr [0:041Ch], 3
    pop DS
    pop DS
    pop ES
    popa
    jmp cs:old_9h
    iret
kb_handler endp
main proc
    mov AX, @data
    mov DS, AX
    xor CX, CX
    
   
    mov AX, 3509h ; save old handler
    int 21h
    mov word ptr old_9h, BX
    mov word ptr old_9h+2, ES
   
    mov AX,2509h ; load new handler
    mov DX, seg kb_handler 
    mov DS, DX
    mov DX, offset kb_handler
    int 21h   
   
    back:
    mov AH, 02h
    mov DL, [0:041Ch]
    int 21h
    jmp back
   
    
  
    mov AH, 4Ch
    int 21h
main endp
end main 