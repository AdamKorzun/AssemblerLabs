.model small
.stack 1000h
.data
    counter dw 0
    countertotal dw 0
    matrix_size dw 0
    negative db 0
    msg db 13, 10, 'Bad input$'
    buffer db 101 dup (?)
    
.code

printData proc
    push AX
    mov AH, 02h
    int 21h
    pop AX
    ret
printData endp

readData proc
    push BX
    push DX
    push CX
    mov counter,0
    cycle:
    mov AH, 01h
    int 21h
    cmp AL, 13 ;enter
    jz entert
    cmp AL, 10 ;enter
    jz entert
    cmp AL, 32 ;space
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
    pop CX
    pop DX
    pop BX
    ret
readData endp
readMatrix proc
    push BX
    push CX
    push AX
    xor BX, BX
    mov BX, matrix_size
    dec BX
    inc_col:
    mov CX, matrix_size
    jc end_matrix
    enter_row:
    call readData
    mov [SI], AL
    xor AX, AX
    
    inc SI
    loop enter_row
    sub BX, 1
    jmp inc_col
    end_matrix:
    pop AX
    pop CX
    pop BX
    ret
readMatrix endp
printNumber proc
    push AX 
    push DX
    push CX
    push BX
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
    pop BX
    pop CX
    pop DX
    pop AX
    ret
printNumber endp
printMatrix proc
    push AX
    push CX
    push BX
    push DX
    xor BX, BX
    prMatrix:
    cmp BX, matrix_size
    jge stop_printing
    mov CX, matrix_size
    prRow:
    mov AX, [SI]
    xor AH, AH
    call printNumber    
    inc SI
    mov DL, ' '
    mov AH, 02h
    int 21h
    loop prRow
    inc BX
    mov DL, 10
    mov AH, 02h
    int 21h
    jmp prMatrix
    stop_printing:
    pop DX
    pop BX
    pop CX
    pop AX
    ret
printMatrix endp
FloydWarshallAlgo proc
    push AX
    push BX
    push CX
    push DX
    xor AX, AX
    xor CX, CX
    xor BX, BX
    xor DX, DX
    floop: ; first cycle
    cmp DX, matrix_size ; DX == k
    jge stop_algo
    xor BX, BX
    sloop: ; second cycle
    cmp BX, matrix_size ; BX == i
    jge floopk
    xor CX, CX
    tloop: ; third cycle
    cmp CX, matrix_size ; CX == j
    jge sloopi
    ; start third cycle iteration
    push DX
    push CX
    xor AX, AX
    mov AL, BL
    mul byte ptr[matrix_size]
    add AL, CL ; AX = [BX][CX] index ([i][j])
    xor AH, AH
    
    add SI, AX
    push SI
    ;xor DX, DX
    push [SI] ; push buffer[BX][CX] == buffer[i][j]
    
    xor AX, AX
    mov AL, BL
    mul byte ptr[matrix_size]
    add AL, DL ; AX = [BX][DX] index ([i][k])
    mov SI, offset buffer
    xor AH, AH
    add SI, AX
    push [SI] ; push buffer[BX][DX] == buffer[i][k]
    
    xor AX, AX
    mov AL, DL
    mul byte ptr[matrix_size]
    add AL, CL ; AX = [DX][CX] index ([k][j])
    mov SI, offset buffer
    xor AH, AH
    add SI, AX
    xor AX, AX
    mov AL, [SI]; AL = buffer[DX][CX] == buffer[k][j]
    
    xor DX, DX
    pop DX
    add AL, DL ; AL = buffer[k][j] + buffer[i][k]
    xor DX, DX
    pop DX
    pop SI
    cmp DL, AL
    jnle cmp_g
    ;mov [SI], DL  
    jmp cmp_l
    cmp_g:
    mov [SI], AL
    cmp_l:
    pop CX
    pop DX
    mov SI, offset buffer
    
    ; stop third cycle iteration
    inc CX
    jmp tloop
    sloopi:
    inc BX
    jmp sloop
    floopk:
    inc DX
    jmp floop
    stop_algo:
    pop DX
    pop CX
    pop BX
    pop AX
    ret
FloydWarshallAlgo endp
main proc
    mov AX, @data
    mov DS, AX
    mov SI, offset buffer   
    call readData
    mov matrix_size, AX
    call readMatrix
    mov SI, offset buffer
    call FloydWarshallAlgo
    mov SI, offset buffer
    call printMatrix
    mov AH, 4Ch
    int 21h
main endp
end main