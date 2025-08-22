global _main
                                                ; Basic Window, 32 bit. V1.01
COLOR_WINDOW        EQU 5                       ; Constants
CS_BYTEALIGNWINDOW  EQU 2000h
CS_HREDRAW          EQU 2
CS_VREDRAW          EQU 1
CW_USEDEFAULT       EQU 80000000h
IDC_ARROW           EQU 7F00h
IDI_APPLICATION     EQU 7F00h
IMAGE_CURSOR        EQU 2
IMAGE_ICON          EQU 1
LR_SHARED           EQU 8000h
NULL                EQU 0
SW_SHOWNORMAL       EQU 1
WM_DESTROY          EQU 2
WS_EX_COMPOSITED    EQU 2000000h
WS_OVERLAPPEDWINDOW EQU 0CF0000h

extern _CreateWindowExA@48
extern _ShowWindow@8
extern _GetModuleHandleA@4
extern _RegisterClassExA@4
extern _PostQuitMessage@4
extern _DefWindowProcA@16
extern _UpdateWindow@4
extern _GetMessageA@16
extern _TranslateMessage@4
extern _DispatchMessageA@4
extern _LoadCursorA@8
extern _GetLastError@0
extern _LoadIconA@8
extern _LoadImageA@24
extern _IsDialogMessageA@8

extern _printf

section .bss
    hInstance resd 1
section .data
    windowName: db "Assembly GUI", 0
    className: db "Asddsembly class", 0
    failMsg: db "Program failed", 0
    errMsg: db "Error code: %d", 0xB, 0

    wc:
        dd 0 ; style
        dd WindowProc ; lpfnWndProc
        dd 0 ; cbClsExtra
        dd 0 ; cbWndExtra
        dd 0 ; hInstance
        dd 0 ; hIcon
        dd 32512 ; hCursor
        dd 6 ; hbrBackground
        dd 0 ; lpszMenuName
        dd className ; lpszClassName

section .text
    WindowProc:
        push  EBP                                      ; Set up a Stack frame
        mov   EBP, ESP

        %define hWnd    EBP + 8                         ; Location of the 4 passed parameters from
        %define uMsg    EBP + 12                        ; the calling function
        %define wParam  EBP + 16                        ; We can now access these parameters by name
        %define lParam  EBP + 20

        cmp   dword [uMsg], WM_DESTROY                 ; [EBP + 12]
        je    WMDESTROY

        DefaultMessage:
        push  dword [lParam]                           ; [EBP + 20]
        push  dword [wParam]                           ; [EBP + 16]
        push  dword [uMsg]                             ; [EBP + 12]
        push  dword [hWnd]                             ; [EBP + 8]
        call  _DefWindowProcA@16

        mov   ESP, EBP                                 ; Remove the stack frame
        pop   EBP
        ret   16                                       ; Pop 4 parameters off the stack and return

        WMDESTROY:
        push  NULL
        call  _PostQuitMessage@4

        xor   EAX, EAX                                 ; WM_DESTROY has been processed, return 0
        mov   ESP, EBP                                 ; Remove the stack frame
        pop   EBP
        ret   16                                       ; Pop 4 parameters off the stack and return

    _main:

    push NULL
    call _GetModuleHandleA@4 ; hInstance in EAX
    mov [hInstance], eax
    
    ; EXAMPLE CODE

    push  EBP                                      ; Set up a stack frame
    mov   EBP, ESP
    sub   ESP, 80                                  ; Space for 80 bytes of local variables

    %define wc                 EBP - 80             ; WNDCLASSEX structure. 48 bytes
    %define wc.cbSize          EBP - 80
    %define wc.style           EBP - 76
    %define wc.lpfnWndProc     EBP - 72
    %define wc.cbClsExtra      EBP - 68
    %define wc.cbWndExtra      EBP - 64
    %define wc.hInstance       EBP - 60
    %define wc.hIcon           EBP - 56
    %define wc.hCursor         EBP - 52
    %define wc.hbrBackground   EBP - 48
    %define wc.lpszMenuName    EBP - 44
    %define wc.lpszClassName   EBP - 40
    %define wc.hIconSm         EBP - 36

    %define msg                EBP - 32             ; MSG structure. 28 bytes
    %define msg.hwnd           EBP - 32             ; Breaking out each member is not necessary
    %define msg.message        EBP - 28             ; in this case, but it shows where each
    %define msg.wParam         EBP - 24             ; member is on the stack
    %define msg.lParam         EBP - 20
    %define msg.time           EBP - 16
    %define msg.pt.x           EBP - 12
    %define msg.pt.y           EBP - 8

    %define hWnd               EBP - 4

    mov   dword [wc.cbSize], 48                    ; [EBP - 80]
    mov   dword [wc.style], CS_HREDRAW | CS_VREDRAW | CS_BYTEALIGNWINDOW  ; [EBP - 76]
    mov   dword [wc.lpfnWndProc], WindowProc          ; [EBP - 72]
    mov   dword [wc.cbClsExtra], NULL              ; [EBP - 68]
    mov   dword [wc.cbWndExtra], NULL              ; [EBP - 64]
    mov   EAX, dword [hInstance]                   ; Global
    mov   dword [wc.hInstance], EAX                ; [EBP - 60]

    push  LR_SHARED
    push  NULL
    push  NULL
    push  IMAGE_ICON
    push  IDI_APPLICATION
    push  NULL
    call  _LoadImageA@24                           ; Large program icon
    mov   dword [wc.hIcon], EAX                    ; [EBP - 56]

    push  LR_SHARED
    push  NULL
    push  NULL
    push  IMAGE_CURSOR
    push  IDC_ARROW
    push  NULL
    call  _LoadImageA@24                           ; Cursor
    mov   dword [wc.hCursor], EAX                  ; [EBP - 52]

    mov   dword [wc.hbrBackground], COLOR_WINDOW + 1  ; [EBP - 48]
    mov   dword [wc.lpszMenuName], NULL            ; [EBP - 44]
    mov   dword [wc.lpszClassName], className      ; [EBP - 40]

    push  LR_SHARED
    push  NULL
    push  NULL
    push  IMAGE_ICON
    push  IDI_APPLICATION
    push  NULL
    call  _LoadImageA@24                           ; Small program icon
    mov   dword [wc.hIconSm], EAX                  ; [EBP - 36]

    lea   EAX, [wc]                                ; [EBP - 80]
    push  EAX
    call  _RegisterClassExA@4

    ; EXAMPLE CODE

    ; params for createwindowex

    push NULL ; lpParam
    push dword [hInstance] ; hInstance
    push NULL ; hMenu
    push NULL ; hWndParent
    push 500 ; height
    push 500 ; width
    push CW_USEDEFAULT ; yPos
    push CW_USEDEFAULT ; xPos
    push WS_OVERLAPPEDWINDOW ; dwStyle
    push windowName ; windowName
    push className ; className
    push WS_EX_COMPOSITED ; extended windows style

    call _CreateWindowExA@48 ; handle to window in EAX
    mov [hWnd], eax ; store handle to window permanently

    ; params for ShowWindow

    push SW_SHOWNORMAL
    push dword [hWnd]

    call _ShowWindow@8

    ; update window

    push dword [hWnd]
    call _UpdateWindow@4

    ; message loop for handling events

    .MessageLoop:
    lea   EAX, [msg]                               ; [EBP - 32]
    push  NULL
    push  NULL
    push  NULL
    push  EAX
    call  _GetMessageA@16
    cmp   EAX, 0
    je    _end

    lea   EAX, [msg]                               ; [EBP - 32]
    push  EAX
    push  dword [hWnd]                             ; [EBP - 4]
    call  _IsDialogMessageA@8                      ; For keyboard strokes
    cmp   EAX, 0
    jne   .MessageLoop                             ; Skip TranslateMessage and DispatchMessage

    lea   EAX, [msg]                               ; [EBP - 32]
    push  EAX
    call  _TranslateMessage@4

    lea   EAX, [msg]                               ; [EBP - 32]
    push  EAX

    call  _DispatchMessageA@4
    jmp   .MessageLoop


    jmp _end

    _fail:
    push failMsg
    call _printf
    jmp _end

    _end:
    mov ESP, EBP
    pop EBP
    xor eax, eax

    ret
