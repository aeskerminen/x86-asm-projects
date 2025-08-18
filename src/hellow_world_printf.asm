global _main

extern _printf ; add printf from stdlib

section .data
    message: db 'hello, world',0xA,0 ; allocate bytes for string

section .bss
section .text
        _main:

        push message ; push message string to stack as parameter
        call _printf ; call printf from stdlib

        add esp, 0x4 ; clear stack

        ret ; return

        