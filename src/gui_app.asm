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
ANSI_CHARSET         EQU 0                      
BLACKNESS            EQU 42h
CLIP_DEFAULT_PRECIS  EQU 0
CS_BYTEALIGNWINDOW   EQU 2000h
CS_HREDRAW           EQU 2
CS_VREDRAW           EQU 1
DEFAULT_PITCH        EQU 0
ES_AUTOHSCROLL       EQU 80h
ES_CENTER            EQU 1
FALSE                EQU 0
GRAY_BRUSH           EQU 2
IDC_ARROW            EQU 7F00h
IDI_APPLICATION      EQU 7F00h
IDNO                 EQU 7
IMAGE_CURSOR         EQU 2
IMAGE_ICON           EQU 1
LR_SHARED            EQU 8000h
MB_DEFBUTTON2        EQU 100h
MB_YESNO             EQU 4
NULL                 EQU 0
NULL_BRUSH           EQU 5
OPAQUE               EQU 2
PROOF_QUALITY        EQU 2
SM_CXFULLSCREEN      EQU 10h
SM_CYFULLSCREEN      EQU 11h
SS_CENTER            EQU 1
SS_NOTIFY            EQU 100h
SW_SHOWNORMAL        EQU 1
TRUE                 EQU 1
WM_CLOSE             EQU 10h
WM_COMMAND           EQU 111h
WM_CREATE            EQU 1
WM_CTLCOLOREDIT      EQU 133h
WM_CTLCOLORSTATIC    EQU 138h
WM_DESTROY           EQU 2
WM_PAINT             EQU 0Fh
WM_SETFONT           EQU 30h
OUT_DEFAULT_PRECIS   EQU 0
WS_CHILD             EQU 40000000h
WS_EX_COMPOSITED     EQU 2000000h
WS_OVERLAPPEDWINDOW  EQU 0CF0000h
WS_TABSTOP           EQU 10000h
WS_VISIBLE           EQU 10000000h

Static1ID            EQU 100

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
    Static1 resd 1
section .data
    windowName: db "Assembly GUI", 0
    className: db "Asddsembly class", 0
    failMsg: db "Program failed", 0
    errMsg: db "Error code: %d", 0xB, 0
    StaticClass: db "STATIC", 0
    Text1: db "Hello, world!", 0

    wc: ; WndClassEX
        dd 48 ; cbSize
        dd CS_HREDRAW | CS_VREDRAW | CS_BYTEALIGNWINDOW ; style
        dd WindowProc ; lpfnWndProc
        dd NULL; cbClsExtra
        dd NULL; cbWndExtra
        dd 0 ; hInstance
        dd 0 ; hIcon
        dd 0 ; hCursor
        dd COLOR_WINDOW + 1 ; hbrBackground
        dd 0 ; lpszMenuName
        dd className ; lpszClassName
        dd 0 ; hIconSm
       

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

        cmp dword [uMsg], WM_CREATE
        je WMCREATE

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
        jmp _WM_PROCESSED

        WMCREATE:
        ; do stuff
        push  NULL
        push  dword [hInstance]
        push  Static1ID
        push  dword [hWnd]                             ; [EBP + 8]
        push  20                                       ; Height
        push  400                                      ; Width
        push  10                                       ; Y
        push  120                                      ; X
        push  WS_CHILD | WS_VISIBLE | SS_NOTIFY | SS_CENTER
        push  Text1                                    ; Default text
        push  StaticClass
        push  NULL
        call  _CreateWindowExA@48
        mov   dword [Static1], EAX
        jmp _WM_PROCESSED


        _WM_PROCESSED:
        xor   EAX, EAX                                 ; WM_DESTROY has been processed, return 0
        mov   ESP, EBP                                 ; Remove the stack frame
        pop   EBP
        ret   16                                       ; Pop 4 parameters off the stack and return

    _main:

    ; Get hInstance
    push NULL
    call _GetModuleHandleA@4 
    mov [wc + 20], eax

    ; Set up stack frame for storing local variables (32 bytes)
    
    push  EBP                                      
    mov   EBP, ESP
    sub   ESP, 32                                  

    %define msg                EBP - 32             ; MSG structure. 28 bytes
    %define msg.hwnd           EBP - 32             
    %define msg.message        EBP - 28             
    %define msg.wParam         EBP - 24            
    %define msg.lParam         EBP - 20
    %define msg.time           EBP - 16
    %define msg.pt.x           EBP - 12
    %define msg.pt.y           EBP - 8

    %define hWnd               EBP - 4

    ; Application icon to wc
    push  LR_SHARED
    push  NULL
    push  NULL
    push  IMAGE_ICON
    push  IDI_APPLICATION
    push  NULL
    call  _LoadImageA@24                           
    mov   dword [wc + 24], EAX                  

    ; Application cursor to wc
    push  LR_SHARED
    push  NULL
    push  NULL
    push  IMAGE_CURSOR
    push  IDC_ARROW
    push  NULL
    call  _LoadImageA@24                          
    mov   dword [wc + 28], EAX

    ; Application small icon to wc
    push  LR_SHARED
    push  NULL
    push  NULL
    push  IMAGE_ICON
    push  IDI_APPLICATION
    push  NULL
    call  _LoadImageA@24                           
    mov   dword [wc + 44], eax                 

    ; Load wc to eax and push to stack for registerclass
    lea   eax, [wc]                               
    push  eax
    call  _RegisterClassExA@4

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
