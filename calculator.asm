global _main

extern _printf
extern _atoi

section .bss

section .data
    welcomeString: db "Germculator", 0xB, 0
    resultString: db "Result: %d", 0xB, 0
    printString: db "%s %s %s", 0xB, 0
    errorString: db "Bad operator", 0xB, 0

section .text
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
    jz add_branch
    cmp al, '-'
    jz sub_branch
    cmp al, '*'
    jz mul_branch
    cmp al, '/'
    jz div_branch

    ; Push error string

    push errorString
    call _printf

    ret

    ; Branches for the actual operation

    add_branch:
    add ebx, esi
    jmp print_res

    sub_branch:
    sub ebx, esi
    jmp print_res

    mul_branch:
    mov eax, ebx
    mul esi
    mov ebx, eax
    jmp print_res

    div_branch:
    mov edx, 0x0
    mov eax, ebx
    div esi
    mov ebx, eax
    jmp print_res

    print_res:
    ; Print the result

    push ebx
    push resultString
    call _printf
    add esp, 0x8

    ret