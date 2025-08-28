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
    add esp, 0x4
%endmacro

section .bss
    filePointer: resd 1
    fileSize: resd 1
    fileBuffer: resd 1
section .data
    entryText: db "Chip-8 parser written in x86 assembly.", 0xA, 0
    readMode: db "rb", 0
    failText: db "%d", 0xA, 0
    opcodeText: db "%#04x", 0xA, 0
    undefinedOpcode: db "Undefined opcode", 0xA, 0

    clearStr: db "cls", 0xA, 0
    retStr: db "ret", 0xA, 0
    gotoStr: db "jmp %#04x", 0xA, 0
    callStr: db "call %#04x", 0xA, 0
    seStr: db "se V%d, %#04x", 0xA, 0
    sneStr: db "sne V%d, %#04x", 0xA, 0
    sevStr: db "sev V%d, %#04x", 0xA, 0
    ldiStr: db "ldi V%d, %#04x", 0xA, 0
    addStr: db "add V%d, %#04x", 0xA, 0
    movStr: db "mov V%d, V%d", 0xA, 0
    orStr: db "or V%d, V%d", 0xA, 0
    andStr: db "and V%d, V%d", 0xA, 0
    xorStr: db "xor V%d, V%d", 0xA, 0
    addvStr: db "addv V%d, V%d", 0xA, 0
    subvStr: db "subv V%d, V%d", 0xA, 0
    shrStr: db "shr V%d, 1", 0xA, 0
    shlStr: db "shl V%d, 1", 0xA, 0
    subnStr: db "subn V%d, V%d", 0xA, 0
    snevStr: db "snev V%d, V%d", 0xA, 0
    ldi16Str: db "ldi16 %#04x", 0xA, 0
    jpv0Str: db "jpv0 %#04x", 0xA, 0
    rndStr: db "rnd V%d", 0xA, 0
    drwStr: db "drw V%d V%d %#04x", 0xA, 0
    skpStr: db "skp V%d", 0xA, 0
    sknpStr: db "sknp V%d", 0xA, 0
    lddtStr: db "lddt V%d", 0xA, 0
    ldvtStr: db "ldv V%d", 0xA, 0
    ldkStr: db "ldk V%d", 0xA, 0
    ldstStr: db "ldst V%d", 0xA, 0
    addiStr: db "addi V%d", 0xA, 0
    ldfStr: db "ldf V%d", 0xA, 0
    bcdStr: db "bcd V%d", 0xA, 0
    storStr: db "stor", 0xA, 0
    loadStr: db "load", 0xA, 0
    rawStr: db "raw: %#04x", 0xA, 0

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

                ; clear instruction
                print clearStr
                jmp jump_switch_end

                jump_one_one:
                cmp ebx, 0x000E
                jnz jump_one_default

                ; ret instruction
                print retStr
                jmp jump_switch_end

                jump_one_default:
                mov ecx, [opcode]
                push ecx
                push rawStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

            jump_one:
            cmp eax, 0x1000
            jnz jump_two

            ; goto instruction
            mov ecx, [nnn]
            push ecx
            push gotoStr
            call _printf
            add esp, 0x8
            jmp jump_switch_end

            jump_two:
            cmp eax, 0x2000
            jnz jump_three

            ; call instruction
            mov ecx, [nnn]
            push ecx
            push callStr
            call _printf
            add esp, 0x8
            jmp jump_switch_end

            jump_three:
            cmp eax, 0x3000
            jnz jump_four

            ; se instruction
            mov ecx, [nn]
            push ecx
            mov ecx, [x]
            push ecx
            push seStr
            call _printf
            add esp, 0xC
            jmp jump_switch_end

            jump_four:
            cmp eax, 0x4000
            jnz jump_five

            ; sne instruction
            mov ecx, [nn]
            push ecx
            mov ecx, [x]
            push ecx
            push sneStr
            call _printf
            add esp, 0xC
            jmp jump_switch_end

            jump_five:
            cmp eax, 0x5000
            jnz jump_six
            
            ; sev instruction
            mov ecx, [nn]
            push ecx
            mov ecx, [x]
            push ecx
            push sevStr
            call _printf
            add esp, 0xC
            jmp jump_switch_end

            jump_six:
            cmp eax, 0x6000
            jnz jump_seven

            ; ldi instruction
            mov ecx, [nn]
            push ecx
            mov ecx, [x]
            push ecx
            push ldiStr
            call _printf
            add esp, 0xC
            jmp jump_switch_end

            jump_seven:
            cmp eax, 0x7000
            jnz jump_eight

            ; add instruction
            mov ecx, [nn]
            push ecx
            mov ecx, [x]
            push ecx
            push addStr
            call _printf
            add esp, 0xC
            jmp jump_switch_end

            jump_eight:
            cmp eax, 0x8000
            jnz jump_nine

                ; compare last byte
                mov ebx, [opcode]
                and ebx, 0x000F

                cmp ebx, 0x0000
                jnz jump_eight_one

                ; mov instruction
                mov ecx, [y]
                push ecx
                mov ecx, [x]
                push ecx
                push movStr
                call _printf
                add esp, 0xC
                jmp jump_switch_end

                jump_eight_one:
                cmp ebx, 0x0001
                jnz jump_eight_two

                ; or instruction
                mov ecx, [y]
                push ecx
                mov ecx, [x]
                push ecx
                push orStr
                call _printf
                add esp, 0xC
                jmp jump_switch_end

                jump_eight_two:
                cmp ebx, 0x0002
                jnz jump_eight_three

                ; and instruction
                mov ecx, [y]
                push ecx
                mov ecx, [x]
                push ecx
                push andStr
                call _printf
                add esp, 0xC
                jmp jump_switch_end

                jump_eight_three:

                cmp ebx, 0x0003
                jnz jump_eight_four

                ; xor instruction
                mov ecx, [y]
                push ecx
                mov ecx, [x]
                push ecx
                push xorStr
                call _printf
                add esp, 0xC
                jmp jump_switch_end

                jump_eight_four:

                cmp ebx, 0x0004
                jnz jump_eight_five

                ; addv instruction
                mov ecx, [y]
                push ecx
                mov ecx, [x]
                push ecx
                push addvStr
                call _printf
                add esp, 0xC
                jmp jump_switch_end

                jump_eight_five:

                cmp ebx, 0x0005
                jnz jump_eight_six

                ; subv instruction
                mov ecx, [y]
                push ecx
                mov ecx, [x]
                push ecx
                push subvStr
                call _printf
                add esp, 0xC
                jmp jump_switch_end

                jump_eight_six:

                cmp ebx, 0x0006
                jnz jump_eight_seven

                ; shr instruction
                mov ecx, [x]
                push ecx
                push shrStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

                jump_eight_seven:

                cmp ebx, 0x0007
                jnz jump_eight_e

                ; subn instruction
                mov ecx, [x]
                push ecx
                mov ecx, [y]
                push ecx
                push subnStr
                call _printf
                add esp, 0xC
                jmp jump_switch_end

                jump_eight_e:
                cmp ebx, 0x000E
                jnz jump_eight_default

                ; shl instruction
                mov ecx, [x]
                push ecx
                push shlStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

                jump_eight_default:
                mov ecx, [opcode]
                push ecx
                push rawStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end
            
            jump_nine:
            cmp eax, 0x9000
            jnz jump_a
            
            ; snev instruction
            mov ecx, [y]
            push ecx
            mov ecx, [x]
            push ecx
            push snevStr
            call _printf
            add esp, 0xC
            jmp jump_switch_end

            jump_a:
            cmp eax, 0xA000
            jnz jump_b

            ; ldi16 instruction
            mov ecx, [nnn]
            push ecx
            push ldi16Str
            call _printf
            add esp, 0x8
            jmp jump_switch_end

            jump_b:
            cmp eax, 0xB000
            jnz jump_c

            ; jpv0 instruction
            mov ecx, [nnn]
            push ecx
            push jpv0Str
            call _printf
            add esp, 0x8
            jmp jump_switch_end

            jump_c:
            cmp eax, 0xC000
            jnz jump_d

            ; rnd instruction
            mov ecx, [x]
            push ecx
            push rndStr
            call _printf
            add esp, 0x8
            jmp jump_switch_end

            jump_d:
            cmp eax, 0xD000
            jnz jump_e

            ; drw instruction
            mov ecx, [n]
            push ecx
            mov ecx, [y]
            push ecx
            mov ecx, [x]
            push ecx
            push drwStr
            call _printf
            add esp, 0x10
            jmp jump_switch_end

            jump_e:
            cmp eax, 0xE000
            jnz jump_f

                ; compare nn
                mov ebx, [nn]

                cmp ebx, 0x009E
                jnz jump_e_one

                ; skp instruction
                mov ecx, [x]
                push ecx
                push skpStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

                jump_e_one:
                cmp ebx, 0x00A1
                jnz jump_e_default

                ; sknp instruction
                mov ecx, [x]
                push ecx
                push sknpStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

                jump_e_default:
                mov ecx, [opcode]
                push ecx
                push rawStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

            jump_f:
            cmp eax, 0xF000
            jnz jump_switch_end

                ; compare nn
                mov ebx, [nn]

                cmp ebx, 0x0007
                jnz jump_f_one

                ;  ldv
                mov ecx, [x]
                push ecx
                push ldvtStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

                jump_f_one:
                cmp ebx, 0x000A
                jnz jump_f_two

                ; ldk insturction
                mov ecx, [x]
                push ecx
                push ldkStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

                jump_f_two:
                cmp ebx, 0x0015
                jnz jump_f_three

                ; lddt instruction
                mov ecx, [x]
                push ecx
                push lddtStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

                jump_f_three:

                cmp ebx, 0x0018
                jnz jump_f_four

                ; ldst instruction
                mov ecx, [x]
                push ecx
                push ldstStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

                jump_f_four:

                cmp ebx, 0x001E
                jnz jump_f_five

                ; addi instruction
                mov ecx, [x]
                push ecx
                push addiStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

                jump_f_five:

                cmp ebx, 0x0029
                jnz jump_f_six

                ; ldf instruction
                mov ecx, [x]
                push ecx
                push ldfStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

                jump_f_six:

                cmp ebx, 0x0033
                jnz jump_f_seven

                ; bcd instruction
                mov ecx, [x]
                push ecx
                push bcdStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

                jump_f_seven:

                cmp ebx, 0x0055
                jnz jump_f_e

                ; stor instruction
                print storStr
                jmp jump_switch_end

                jump_f_e:
                cmp ebx, 0x0065
                jnz jump_f_default

                ; load instruction
                print loadStr
                jmp jump_switch_end

                jump_f_default:
                mov ecx, [opcode]
                push ecx
                push rawStr
                call _printf
                add esp, 0x8
                jmp jump_switch_end

            jump_switch_end:
            ; increment ESI and continue
            add esi, 0x2
        jmp main_loop

        end:
        mov esp, ebp
        pop ebp

    ret