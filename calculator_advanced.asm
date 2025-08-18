global _main

extern _printf
extern _atoi
extern MessageBoxA

section .bss

section .data
    welcomeString: db "Germculator", 0xB, 0
    resultString: db "Result: %d", 0xB, 0
    printString: db "%s %s %s", 0xB, 0
    errorString: db "Bad operator", 0xB, 0

section .text
    add_two:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 12]
    mov ecx, [ebp + 8]

    pop ebp

    add eax, ecx
    ret
    
    sub_two:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 12]
    mov ecx, [ebp + 8]

    pop ebp

    sub eax, ecx
    ret
    
    mul_two:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 12]
    mov ecx, [ebp + 8]

    pop ebp

    mul ecx
    ret
    
    div_two:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 12]
    mov ecx, [ebp + 8]

    pop ebp

    div ecx
    ret

    _main:
    
    ; Print welcome string

    push welcomeString
    call _printf
    add esp, 0x4

    ; Load argv and strings

    mov eax, [esp + 8] ; load argv 
    mov ebx, [eax + 1 * 4] ; 1st arg
    mov esi, [eax + 3 * 4] ; 3rd arg
    mov edi, [eax + 2 * 4] ; 2nd arg

    ; EBX and ESI contain the numbers

    ; print calculation
    
    push esi
    push edi
    push ebx
    push printString
    call _printf
    add esp, 0xC

    ; Convert to int

    push edi ; save EDI to stack (callee-save register)

    push ebx
    call _atoi
    mov ebx, eax
    add esp, 0x4

    push esi
    call _atoi
    mov esi, eax
    add esp, 0x4

    mov edi, [esp] ; get EDI from stack 
    mov al, byte [edi] ; move first byte of the value that edi points to, to al.

    ; check operator

    cmp al, '+'
    jnz sub_cmp
    push eax
    push ebx
    push esi
    call add_two
    add esp, 0x8
    mov ebx, eax
    mov eax, [esp]

    jmp print_res

    sub_cmp:
    cmp al, '-'
    jnz mul_cmp
    push eax
    push ebx
    push esi
    call sub_two
    add esp, 0x8
    mov ebx, eax
    mov eax, [esp]
    jmp print_res

    mul_cmp:
    cmp al, '*'
    jnz div_cmp    
    push eax
    push ebx
    push esi
    call mul_two
    add esp, 0x8
    mov ebx, eax
    mov eax, [esp]
    jmp print_res

    div_cmp:
    cmp al, '/'
    jnz error
    push eax
    push ebx
    push esi
    call div_two
    add esp, 0x8
    mov ebx, eax
    mov eax, [esp]
    jmp print_res

    ; Push error string

    error:
    push errorString
    call _printf

    ret

    print_res:
    ; Print the result

    push ebx
    push resultString
    call _printf
    add esp, 0x8

    ret