.model small
.stack 1000h
.data 
    old_9h dw 0,0

.code 
kb_handler proc
    push DX
    push AX
    mov DL, 'p'
    mov AH, 02h     
    int 21h
    
    pop AX
    pop DX
    
    ret
kb_handler endp
main proc
    mov AX, @data
    mov DS, AX
    mov ax, 3509h
    int 21h
    mov word ptr old_9h, bx
    mov word ptr old_9h[2], es
    mov ax,2509h
    mov dx ,offset kb_handler
    int 21h   
    mov ax, 3509h    
    mov dx, offset old_9h
    int 21h 
main endp
end main