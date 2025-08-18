global _main

extern _printf

section .bss

section .data
    string: db "testt", 0
    stringLen: equ $ - string
    fmtStr: db "%s", 0xB, 0

section .text
    _main:

    mov esi, 0 ; init ESI to zero
    mov edi, stringLen - 2

    loop: ; string loop

    cmp esi, edi ; check if index is met
    jge end ; break if esi >= edi

    ; swap first and last

    mov al, byte [string + esi]
    mov ah, byte [string + edi]

    mov [string + esi], byte ah
    mov [string + edi], byte al

    inc esi ; inc s_index
    dec edi ; dec e_index

    jmp loop ; loop again

    end:
    push string ; push new string to stack
    push fmtStr ; push format
    call _printf ; print string
    
    add esp, 0x8 ; fix stack
    
    ret
