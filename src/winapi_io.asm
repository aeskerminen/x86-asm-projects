global _main

extern _CreateFileA@28
extern _WriteFile@20
extern _ReadFile@20
extern _CloseHandle@4

section .bss

section .data
    fileName: db "test.txt", 0

section .text
    _createTestFile:
    push ebp
    mov ebp, esp
    
    ; dwFlagsAndAttributes
    mov eax, 0x80
    push eax

    ; dwCreationDisposition
    mov eax, 1
    push eax

    ; lpSecurityAttributes
    mov eax, 0
    push eax

    ; dwShareMode
    mov eax, 0
    push eax

    ; dwDesiredAccess
    mov eax, 0x4
    push eax

    ; lpFileName
    push fileName    

    call _CreateFileA@28

    pop ebp
    ret

    _main:
   
    call _createTestFile

    ; close unused handle to the file
    push eax
    call _CloseHandle@4 ;

    ret