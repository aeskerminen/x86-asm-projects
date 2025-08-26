global _main

extern _printf

section .bss

section .data
    entryText: db "Chip-8 parser written in x86 assembly.", 0xB, 0

section .text
    readSourceFile:

    ret

    _main:

    ; print entry text
    push entryText
    call _printf
    add esp, 0x4

    ; retrieve arguments
    mov eax, [esp + 8] ; argv
    mov ebx, [eax + 4] ; 1st argument, which is the source file

    ; read source to buffer
    

    ret

