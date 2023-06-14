%define WINDOW_WIDTH 800
%define WINDOW_HEIGHT 800
%define KEY_RELEASE 3h

section .text
    global create_window
    global clear_window
    global flush_buffer
    global draw_rectangle
    global get_window_event
    global check_key_release

    extern print_string

    extern XOpenDisplay
    extern XDefaultScreen
    extern XBlackPixel
    extern XWhitePixel
    extern XDefaultRootWindow
    extern XCreateSimpleWindow
    extern XMapWindow
    extern XNextEvent
    extern XSelectInput
    extern XCheckWindowEvent
    extern XLookupKeysym
    extern XSetForeground
    extern XCreateGC
    extern XFillRectangle
    extern XClearWindow
    extern XFlush

;-------------------------------------------------------------
; create a window using xlib
;-------------------------------------------------------------
create_window:
    push    rbp
    mov     rbp, rsp

    xor     rdi, rdi
    call    XOpenDisplay
    test    rax, rax
    jz      .open_display_failed
    mov     [display], rax

    mov     rdi, [display]
    call    XDefaultScreen
    mov     [screen_number], rax

    mov     rdi, [display]
    mov     rsi, [screen_number]
    call    XBlackPixel
    mov     [black_color], rax

    mov     rdi, [display]
    mov     rsi, [screen_number]
    call    XWhitePixel
    mov     [white_color], rax

    mov     rdi, [display]
    call    XDefaultRootWindow
    mov     [root_window], rax

    mov     rdi, [display]
    mov     rsi, [root_window]
    xor     rdx, rdx
    xor     rcx, rcx
    mov     r8, WINDOW_WIDTH
    mov     r9, WINDOW_HEIGHT
    mov     rax, [black_color]
    push    rax
    mov     rax, [white_color]
    push    rax
    push    0
    call    XCreateSimpleWindow
    mov     [window], rax
    add     rsp, 24

    mov     rdi, [display]
    mov     rsi, [window]
    xor     rdx, rdx
    xor     rcx, rcx
    call    XCreateGC
    mov     [gc], rax

    mov     rdi, [display]
    mov     rsi, [window]
    mov     rdx, 20003h ; KeyPressMask | KeyReleaseMask | ButtonMotionMask
    call    XSelectInput

    mov     rdi, [display]
    mov     rsi, [window]
    call    XMapWindow

    jmp     .exit

.open_display_failed:
    lea     rdi, [msg_open_display_failed]
    call    print_string
    
.exit:
    leave
    ret

;-------------------------------------------------------------
; clear everything before you want to draw something
;-------------------------------------------------------------
clear_window:
    sub     rsp, 8
    mov     rdi, [display]
    mov     rsi, [window]
    call    XClearWindow
    add     rsp, 8
    ret

;-------------------------------------------------------------
; make sure everything is drawn
;-------------------------------------------------------------
flush_buffer:
    sub     rsp, 8
    mov     rdi, [display]
    call    XFlush
    add     rsp, 8
    ret

;-------------------------------------------------------------
; draw a white rectangle
;
; @param edi
;   x
;
; @param esi
;   y
;
; @param edx
;   width
;
; @param ecx
;   height
;-------------------------------------------------------------
draw_rectangle:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16

    mov     dword [rbp - 4], edi
    mov     dword [rbp - 8], esi
    mov     dword [rbp - 12], edx
    mov     dword [rbp - 16], ecx

    mov     rdi, [display]
    mov     rsi, [gc]
    mov     rdx, [white_color]
    call    XSetForeground

    mov     rdi, [display]
    mov     rsi, [window]
    mov     rdx, [gc]
    mov     ecx, dword [rbp - 4]
    mov     r8d, dword [rbp - 8]
    mov     r9d, dword [rbp - 12]
    mov     eax, dword [rbp - 16]
    push    rax
    call    XFillRectangle

    add     rsp, 24
    pop     rbp
    ret

;-------------------------------------------------------------
; get window event
;
; @param event
;-------------------------------------------------------------
get_window_event:
    push    rbp

    lea     rcx, [rdi]
    mov     rdi, [display]
    mov     rsi, [window]
    mov     rdx, 3h ; KeyReleaseMask | KeyPressMask
    call    XCheckWindowEvent

    pop     rbp
    ret

check_key_release:
    push    rbp

    mov     rbp, [rdi]
    cmp     rbp, KEY_RELEASE
    jne     .failed

    mov     rbp, rsi

    xor     rsi, rsi
    call    XLookupKeysym
    cmp     rax, rbp
    jne     .failed

    mov     rax, 1
    jmp     .exit

.failed:
    xor     rax, rax

.exit:
    pop     rbp
    ret

section .rodata
    msg_open_display_failed: db "failed to open a display", 0ah, 0h

section .data
    display:        dq 0h
    screen_number:  dd 0h
    black_color:    dq 0h
    white_color:    dq 0h
    root_window:    dq 0h
    window:         dq 0h
    gc:             dq 0h

section .bss
    event: resb 0xc0
