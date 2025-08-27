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
    failText: db "%d", 0xB, 0
    opcodeText: db "%04X", 0xB, 0

section .text
    ; readSourceFile(char* SOURCE_URL)
    readSourceFile:
        push ebp
        mov ebp, esp

        mov eax, [ebp + 8] ; move SOURCE_URL to EAX

        ; open stream
        push readMode
        push eax
        call _fopen 
        add esp, 0x8
        mov [filePointer], eax

        ; get file size
        push 0x2
        push 0x0
        mov eax, [filePointer]
        push eax
        call _fseek
        add esp, 0xC

        mov eax, [filePointer]
        push eax
        call _ftell
        add esp, 0x4
        mov [fileSize], eax
        
        mov eax, [filePointer]
        push eax
        call _rewind
        add esp, 0x4

        ; allocate space on the heap for buffer
        mov eax, [fileSize]
        inc eax
        push eax
        call _malloc
        add esp, 0x4
        mov [fileBuffer], eax

        ; read source into buffer
        mov eax, [filePointer]
        push eax
        mov eax, [fileSize]
        push eax
        push 1
        mov eax, [fileBuffer]
        push eax
        call _fread
        add esp, 0x10

        ; null terminator
        mov eax, [fileSize]
        add eax, [fileBuffer]
        mov [eax], byte 0x00

        ; close file
        mov eax, [filePointer]
        push eax
        call _fclose
        add esp, 0x4

        mov esp, ebp
        pop ebp

    ret

    _main:
        push ebp
        mov ebp, esp

        ; print entry text
        push entryText
        call _printf
        add esp, 0x4

        ; retrieve arguments
        mov eax, [ebp + 12] ; argv
        mov ebx, [eax + 4] ; 1st argument, which is the source file

        ; read source to buffer
        push ebx
        call readSourceFile
        add esp, 0x4

        ; opcode retrieval loop

        push entryText
        call _printf
        add esp, 0x4

        sub esp, 24 ; space for 6 local variables

        %define opcode ebp - 4
        %define x ebp - 8
        %define y ebp - 12
        %define nnn ebp - 16
        %define nn ebp - 20
        %define n ebp - 24

        ; for loop variables
        mov esi, 0
        mov edi, [fileSize]

        main_loop:
            cmp esi, edi
            jz end

            ; get the array
            mov eax, [fileBuffer]

            ; read two bytes from the array and combine them
            movzx ebx, byte [eax+esi] ; h
            shl ebx, 0x8
            movzx ecx, byte [eax+esi+1] ; l
            or ebx, ecx

            ; store the opcode
            mov [opcode], ebx

            ; print the opcode
            push ebx
            push opcodeText
            call _printf
            add esp, 0x8

            ; X
            mov eax, [opcode]
            and eax, 0x0F00
            shr eax, 8
            mov [x], eax

            ; Y
            mov eax, [opcode]
            and eax, 0x00F0
            shr eax, 4
            mov [y], eax
            
            ; NNN
            mov eax, [opcode]
            and eax, 0x0FFF
            mov [nnn], eax

            ; NN
            mov eax, [opcode]
            and eax, 0x00FF
            mov [nn], eax

            ; N
            mov eax, [opcode]
            and eax, 0x000F
            mov [n], eax

            ; handle different opcodes

            ; compare first byte
            mov eax, opcode
            and eax, 0xF000

            cmp eax, 0x0000
            jnz jump_one

            jump_one:
            cmp eax, 0x1000
            jnz jump_two

            jump_two:
            cmp eax, 0x2000
            jnz jump_three

            jump_three:
            cmp eax, 0x3000
            jnz jump_four

            jump_four:
            cmp eax, 0x4000
            jnz jump_five

            jump_five:
            cmp eax, 0x5000
            jnz jump_six

            jump_six:
            cmp eax, 0x6000
            jnz jump_seven

            jump_seven:
            cmp eax, 0x7000
            jnz jump_eight

            jump_eight:
            cmp eax, 0x8000
            jnz jump_nine

            jump_nine:
            cmp eax, 0x9000


            ; increment ESI and continue
            add esi, 0x2
        jmp main_loop

        end:
        mov esp, ebp
        pop ebp

    ret

