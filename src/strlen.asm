global _main

extern _printf

section .bss

section .data
    fmtStr: db "The length of: %s is %d", 0xB, 0

section .text
    strlen:
    push ebp
    mov ebp, esp

    mov ebx, [esp + 8]

    ; len
    mov ecx, 0
    ; index
    mov esi, 0

    loop:
    ; check for null terminator
    cmp byte [ebx + esi], 0x00
    jz end

    ; increment index and len
    inc ecx
    inc esi
    
    jmp loop

    end: ; print length
    push ecx
    push ebx
    push fmtStr
    call _printf

    pop ebp
    ret

    _main:

    ; read argv into memory
    mov eax, [esp + 8]
    ; read first argument
    mov ebx, [eax + 1 * 4]

    push ebx
    call strlen
    
    ret