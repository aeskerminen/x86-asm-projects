global _main

extern _printf

section .bss

section .data
    fmtStr: db "Fibonacci number: %d", 0xB, 0

section .text
    fibonacci:
    
    ; save the stack pointers
    push ebp
    mov ebp, esp

    ; save EBX and ECX due to being modified in recursive calls
    push ebx
    push ecx


    mov eax, [ebp + 8] ; n, the nth fibonacci number (0-based)

    ; recursive conditions and their respective outcomes
    cmp eax, 0
    je fib_0
    cmp eax, 1
    je fib_1


    ; save the original index of the wanted fib
    mov ecx, eax

    ; case fib(n - 1)
    mov eax, ecx
    dec eax
    push eax
    call fibonacci
    add esp, 0x4
    mov ebx, eax

    ; case fib(n - 2)
    mov eax, ecx
    sub eax, 2
    push eax
    call fibonacci
    add esp, 0x4

    ; add them
    add eax, ebx    

    ; final return case
    jmp done

    fib_0:
    mov eax, 0
    jmp done
    
    fib_1:
    mov eax, 1
    jmp done

    done:
    ; restore the registers and stack
    pop ecx
    pop ebx
    pop ebp
    ; return
    ret

    _main:

    ; call fibonacci with n = 6
    mov eax, 6
    push eax
    call fibonacci
    add esp, 0x4

    ; print out the fibonacci number
    push eax
    push fmtStr
    call _printf
    add esp, 0x8

    ret