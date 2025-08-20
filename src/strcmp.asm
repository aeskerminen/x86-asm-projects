global _main

section .bss

section .data
    fmtStr: db "The length of: %s is %d", 0xB, 0

section .text
    ; modifies eax, ebx, ecx, esi
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

    mov eax, ecx

    pop ebp
    ret

    _main:
    ; read argv
    mov eax, [esp + 8]
    ; read first and second parameters
    mov ebx, [eax + 1 * 4]
    mov ecx, [eax + 2 * 4]

    push ebx
    push ecx

    ; get lengths of both strings
    push ebx
    call strlen
    add esp, 0x4

    mov edx, eax

    pop ecx
    push ecx
    push ecx
    call strlen
    add esp, 0x4

    pop ecx
    pop ebx

    ; we have both lengths in EAX and EDX
    cmp eax, edx
    jnz end

    ; init index
    mov esi, 0

    end:
    ret

    