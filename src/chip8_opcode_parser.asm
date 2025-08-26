global _main

extern _printf
extern _malloc

extern _fopen
extern _ftell
extern _fseek
extern _rewind
extern _fread
extern _fclose

section .bss
    filePointer: resd 1
    fileSize: resd 1
    fileBuffer: resd 1
section .data
    entryText: db "Chip-8 parser written in x86 assembly.", 0xB, 0
    readMode: db "rb", 0
    failText: db "failed", 0xB, 0

section .text
    ; readSourceFile(char* SOURCE_URL)
    readSourceFile:
    push ebp
    mov ebp, esp

    ; save registers
    push eax
    push ecx
    push edx

    mov eax, [ebp + 8] ; move SOURCE_URL to EAX

    ; open stream
    push readMode
    push eax
    call _fopen 
    add esp, 0x8
    mov [filePointer], eax

    test eax, eax
    jnz next

    push failText
    call _printf
    add esp, 0x4


    next:
    ; get file size
    push 2
    push 0
    push filePointer
    add esp, 0xC
    call _fseek

    push filePointer
    call _ftell
    add esp, 0x4
    mov [fileSize], eax

    push filePointer
    call _rewind
    add esp, 0x4

    ; allocate space on the heap for buffer
    push fileSize
    call _malloc
    add esp, 0x4
    mov [fileBuffer], eax

    ; read source into buffer
    push filePointer
    push fileSize
    push 1
    push fileBuffer
    call _fread
    add esp, 0x10

    ; close file
    push filePointer
    call _fclose
    add esp, 0x4

    mov esp, ebp

    pop edx
    pop ecx
    pop eax
    pop ebp

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
    push ebx
    call readSourceFile
    add esp, 0x4

    ; print the buffer
    push fileBuffer
    call _printf
    add esp, 0x4

    ret

