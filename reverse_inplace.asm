global _main

extern _printf

section .bss

section .data
    string: db "test", 0
    stringLen: equ $ - string

section .text
    _main:

    mov esi, 0 ; init ESI to zero
    mov edi, stringLen
    dec edi ; init EDI to upper limit

    loop: ; string loop

    cmp esi, edi ; check if index is met
    jz end ; break loop

    mov [string + esi], byte 'a' ; move 'a' to index in string
    
    inc esi ; inc index

    jmp loop ; loop again

    end:
    push string ; push new string to stack
    call _printf ; print string
    
    add esp, 0x4 ; fix stack
    
    ret
