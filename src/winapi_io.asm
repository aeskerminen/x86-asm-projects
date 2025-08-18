global _main

extern _CreateFileA@28
extern _WriteFile@20
extern _ReadFile@20
extern _CloseHandle@4

section .bss

section .data
    fileName: db "test.txt", 0
    fileContent: db "I hacked your pc!! PWND!!", 0
    fileContentLen: equ $ - fileContent
    bytesWritten: dd 0

section .text
    _createTestFile:
    push ebp
    mov ebp, esp
    
    ; hTemplateFile
    push 0

    ; dwFlagsAndAttributes
    mov eax, 0x80
    push eax

    ; dwCreationDisposition
    mov eax, 2
    push eax

    ; lpSecurityAttributes
    mov eax, 0
    push eax

    ; dwShareMode
    mov eax, 0
    push eax

    ; dwDesiredAccess
    mov eax, 0x40000000
    push eax

    ; lpFileName
    push fileName    

    call _CreateFileA@28

    pop ebp
    ret

    _writeToTestFile:
    push ebp
    mov ebp, esp

    ; store the handle in ebx and push to stack
    mov ebx, [esp + 8]

    ; lpOverlapped
    push 0

    ; lpNumberOfBytesWritten
    push bytesWritten

    ; nNumberOfBytesToWrite
    push fileContentLen

    ; LpBuffer
    push fileContent

    ; hFile
    push ebx

    call _WriteFile@20

    pop ebp
    ret
    
    _main:
   
    ; create file test.txt
    call _createTestFile

    ; write to file test.txt
    push eax ; handle
    call _writeToTestFile
    add esp, 0x4

    ; restore handle to file
    mov eax, ebx

    ; close unused handle to the file
    push eax
    call _CloseHandle@4

    add esp, 0x4

    ret