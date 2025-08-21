global _main

extern _CreateWindowExA@48
extern _ShowWindow@8
extern _GetModuleHandleA@4
extern _RegisterClassA@4
extern _PostQuitMessage@4
extern _DefWindowProcA@16
extern _UpdateWindow@4
extern _GetMessageA@16
extern _TranslateMessage@4
extern _DispatchMessageA@4
extern _LoadCursorA@8
extern _GetLastError@0

extern _printf

section .bss
    msg resb 28
    hInstance resd 1
    hwndMain resd 1

section .data
    windowName: db "Assembly GUI", 0
    className: db "Assembly window class", 0
    failMsg: db "Program failed", 0
    errMsg: db "Error code: %d", 0xB, 0

    wc:
        dd 0 ; style
        dd WindowProc ; lpfnWndProc
        dd 0 ; cbClsExtra
        dd 0 ; cbWndExtra
        dd 0 ; hInstance
        dd 0 ; hIcon
        dd 0 ; hCursor
        dd 5 ; hbrBackground
        dd 0 ; lpszMenuName
        dd className ; lpszClassName

section .text
    WindowProc:
        cmp dword [esp+8], 2        ; WM_DESTROY == 2
        jne .def
        push 0
        call _PostQuitMessage@4
        xor eax, eax
        ret 16                      ; stdcall: clean 4 args
        .def:
            push dword [esp+20]         ; lParam
            push dword [esp+16]         ; wParam
            push dword [esp+12]         ; Msg
            push dword [esp+4]          ; hwnd
            call _DefWindowProcA@16
            ret 16

    _main:

    push 0
    call _GetModuleHandleA@4 ; hInstance in EAX
    mov [hInstance], eax
    mov [wc + 16], eax ; hInstance into wc

    ; params for registerclass

    push 0
    push 32512
    call _LoadCursorA@8

    mov [wc + 24], eax

    push wc
    call _RegisterClassA@4

    push eax
    push errMsg
    call _printf
    add esp, 0x8

    test eax, eax
    jz _fail

    ; params for createwindowex

    push 0 ; lpParam
    push dword [hInstance] ; hInstance
    push 0 ; hMenu
    push 0 ; hWndParent
    push 500 ; height
    push 500 ; width
    push 0 ; yPos
    push 0 ; xPos
    push 0x00C00000 ; dwStyle
    push windowName ; windowName
    push className ; className
    push 0 ; extended windows style

    call _CreateWindowExA@48 ; handle to window in EAX

    mov [hwndMain], eax ; store handle to window permanently

    test eax, eax
    jz _fail

    ; params for ShowWindow

    push 0x1
    push dword [hwndMain]

    call _ShowWindow@8

    ; update window

    push dword [hwndMain]
    call _UpdateWindow@4

    ; message loop for handling events

    _msg_loop:
        push 0
        push 0
        push 0
        push msg
        call _GetMessageA@16

        test eax, eax
        jz _end

        push msg
        call _TranslateMessage@4

        push msg
        call _DispatchMessageA@4

        jmp _msg_loop
  
    _fail:
    push failMsg
    call _printf
    jmp _end

    _end:
    ret
