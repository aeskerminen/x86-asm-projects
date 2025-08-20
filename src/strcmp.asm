global _main

extern _printf

section .bss

section .data
    fmtStr: db "The length of: %s is %d", 0xB, 0
    errorStr: db "The strings are not the same", 0xB, 0
    succStr: db "The strings are the same", 0xB, 0
    test: db "%d", 0xB, 0

section .text
    strlen:
        push ebp
        mov ebp, esp

        push ebx
        push ecx
        push edx

        mov ebx, [ebp + 8]

        ; len
        mov ecx, 0
        ; index
        mov esi, 0

        loop:
        ; check for null terminator
        cmp byte [ebx + esi], 0x00
        jz end_strlen

        ; increment index and len
        inc ecx
        inc esi
        
        jmp loop

        end_strlen: ; print length
        mov eax, ecx
        push eax

        push ecx
        push ebx
        push fmtStr
        call _printf
        add esp, 0xC

        pop eax
        pop edx
        pop ecx
        pop ebx
        pop ebp
        ret

    _main:
    ; read argv
    mov eax, [esp + 8]
    ; read first and second parameters to EBX and ECX
    mov ebx, [eax + 1 * 4]
    mov ecx, [eax + 2 * 4]

    ; get length of first string
    push ebx
    call strlen
    add esp, 0x4

    ; move result to EDX
    mov edx, eax

    ; get length of second string
    push ecx
    call strlen
    add esp, 0x4

    ; we have both lengths in EDX and EAX, strings in EBX and ECX
    cmp edx, eax

    ; ESI = 0, EDI = EAX (LENGTH)
    mov esi, 0
    mov edi, eax

    loop_strcmp:
    cmp esi, edi
    jz strcmp_success
    mov al, byte [ebx + esi]
    cmp [ecx + esi], al
    jnz strcmp_error   
    inc esi
    jmp loop_strcmp

    strcmp_error:
    push errorStr
    call _printf
    jmp end

    strcmp_success:
    push succStr
    call _printf
    jmp end

    end:
    ret

    