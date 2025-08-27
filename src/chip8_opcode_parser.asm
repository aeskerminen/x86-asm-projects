global _main

extern _printf
extern _malloc

extern _fopen
extern _ftell
extern _fseek
extern _rewind
extern _fread
extern _fclose

%macro print 1
    push dword %1
    call _printf
    add esp, 04X
%endmacro

section .bss
    filePointer: resd 1
    fileSize: resd 1
    fileBuffer: resd 1
section .data
    entryText: db "Chip-8 parser written in x86 assembly.", 0xB, 0
    readMode: db "rb", 0
    failText: db "%d", 0xB, 0
    opcodeText: db "%04X", 0xB, 0
    undefinedOpcode: db "Undefined opcode", 0xB, 0

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
        print entryText

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
            mov eax, [opcode]
            and eax, 0xF000

            cmp eax, 0x0000
            jnz jump_one

                ; compare last byte
                mov ebx, [opcode]
                and ebx, 0x000F

                cmp ebx, 0x0000
                jnz jump_one_one

                jump_one_one:
                cmp ebx, 0x000E
                jnz jump_one_default

                jump_one_default:
                print undefinedOpcode
                jmp jump_switch_end

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

                ; compare last byte
                mov ebx, [opcode]
                and ebx, 0x000F

                cmp ebx, 0x0000
                jnz jump_eight_one

                jump_eight_one:
                cmp ebx, 0x0001
                jnz jump_eight_two

                jump_eight_two:
                cmp ebx, 0x0002
                jnz jump_eight_three

                jump_eight_three:

                cmp ebx, 0x0003
                jnz jump_eight_four

                jump_eight_four:

                cmp ebx, 0x0004
                jnz jump_eight_five

                jump_eight_five:

                cmp ebx, 0x0005
                jnz jump_eight_six

                jump_eight_six:

                cmp ebx, 0x0006
                jnz jump_eight_seven

                jump_eight_seven:

                cmp ebx, 0x0007
                jnz jump_eight_e

                jump_eight_e:
                cmp ebx, 0x000E
                jnz jump_eight_default

                jump_eight_default:
                print undefinedOpcode
                jmp jump_switch_end
            
            jump_nine:
            cmp eax, 0x9000
            jnz jump_a

            jump_a:
            cmp eax, 0xA000
            jnz jump_b

            jump_b:
            cmp eax, 0xB000
            jnz jump_c

            jump_c:
            cmp eax, 0xC000
            jnz jump_d

            jump_d:
            cmp eax, 0xD000
            jnz jump_e

            jump_e:
            cmp eax, 0xE000
            jnz jump_f

                ; compare nn
                mov ebx, [nn]

                cmp ebx, 0x009E
                jnz jump_e_one

                jump_e_one:
                cmp ebx, 0x00A1
                jnz jump_e_default

                jump_e_default:
                print undefinedOpcode
                jmp jump_switch_end

            jump_f:
            cmp eax, 0xF000
            jnz jump_switch_end

                ; compare nn
                mov ebx, [nn]

                cmp ebx, 0x0007
                jnz jump_f_one

                jump_f_one:
                cmp ebx, 0x000A
                jnz jump_f_two

                jump_f_two:
                cmp ebx, 0x0015
                jnz jump_f_three

                jump_f_three:

                cmp ebx, 0x0018
                jnz jump_f_four

                jump_f_four:

                cmp ebx, 0x001E
                jnz jump_f_five

                jump_f_five:

                cmp ebx, 0x0029
                jnz jump_f_six

                jump_f_six:

                cmp ebx, 0x0033
                jnz jump_f_seven

                jump_f_seven:

                cmp ebx, 0x0055
                jnz jump_f_e

                jump_f_e:
                cmp ebx, 0x0065
                jnz jump_f_default

                jump_f_default:
                print undefinedOpcode
                jmp jump_switch_end

            jump_switch_end:
            ; increment ESI and continue
            add esi, 0x2
        jmp main_loop

        end:
        mov esp, ebp
        pop ebp

    ret