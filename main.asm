;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text

    global _start

    ;-------------------------------------------------------------
    ; open a connection to the X server that controls a display
    ; 
    ; @param rdi
    ;   specifies the hardware display name.
    ;   if it is NULL, the DISPLAY environment variable will be used
    ; 
    ; @return rax
    ;   return the pointer of Display structure.
    ;   if it does not succeed, it return NULL
    ;-------------------------------------------------------------
    extern XOpenDisplay

    ;-------------------------------------------------------------
    ; get the default screen number referenced by the display
    ; 
    ; @param rdi
    ;   the display, which is returned by XOpenDisplay()
    ;
    ; @return eax
    ;   the default screen number
    ;-------------------------------------------------------------
    extern XDefaultScreen

    ;-------------------------------------------------------------
    ; get the black pixel value of the specified screen
    ;
    ; @param rdi
    ;   the display pointer
    ;
    ; @param esi
    ;   the screen number
    ;
    ; @return rax
    ;   return the black pixel of the specified screen
    ;-------------------------------------------------------------
    extern XBlackPixel

    ;-------------------------------------------------------------
    ; get the white pixel value of the specified screen
    ;
    ; @param rdi
    ;   the display pointer
    ;
    ; @param esi
    ;   the screen number
    ;
    ; @return rax
    ;   return the white pixel of the specified screen
    ;-------------------------------------------------------------
    extern XWhitePixel

    ;-------------------------------------------------------------
    ; get the root window for the default screen
    ;
    ; @param rdi
    ;   the display pointer
    ;
    ; @retun rax
    ;   return the root window
    ;-------------------------------------------------------------
    extern XDefaultRootWindow

    ;-------------------------------------------------------------
    ; create a window that inherits its attributes
    ; from its parent window
    ;
    ; @param rdi 
    ;   the display pointer
    ;
    ; @param rsi
    ;   the window parent
    ;
    ; @param edx
    ;   x
    ;
    ; @param ecx
    ;   y
    ;
    ; @param r8d
    ;   width
    ;
    ; @param r9d
    ;   height
    ;
    ; @param [rsp + 8]
    ;   border width
    ; 
    ; @param [rsp + 12]
    ;   border color
    ;
    ; @param [rsp + 20]
    ;   blackground color
    ;
    ; @return rax
    ;   return the window
    ;-------------------------------------------------------------
    extern XCreateSimpleWindow

    ;-------------------------------------------------------------
    ; map the window and then make it viewable
    ;
    ; @param rdi
    ;   the display pointer
    ;
    ; @param rsi
    ;   the window
    ;-------------------------------------------------------------
    extern XMapWindow

    ;-------------------------------------------------------------
    ; @param rdi
    ;   the display pointer
    ;
    ; @param rsi
    ;   the pointer of event_return
    ;-------------------------------------------------------------
    extern XNextEvent

    ;-------------------------------------------------------------
    ; request that X server report the events
    ;
    ; @param rdi
    ;   the display pointer
    ;
    ; @param rsi
    ;   the window
    ;
    ; @param rdx
    ;   event_mask
    ;-------------------------------------------------------------
    extern XSelectInput

_start:
    call create_window

.game_loop:
    mov     rdi, msg_game_loop
    call    print_string
    jmp     .game_loop

.exit:
    mov     rax, 60
    xor     rdi, rdi
    syscall

;-------------------------------------------------------------
; create a window using xlib
;-------------------------------------------------------------
create_window:
    push    rbp
    mov     rbp, rsp

    xor     rdi, rdi
    call    XOpenDisplay
    cmp     rax, 0h
    jne     .open_display_success

    mov     rdi, msg_open_display_failed
    call    print_string
    jmp     .exit

.open_display_success:
    mov     [display], rax

    mov     rdi, rax ; rax is holding display pointer
    call    XDefaultScreen
    mov     [screen_number], eax

    mov     rdi, [display]
    mov     esi, eax ; eax is holding screen number
    call    XBlackPixel
    mov     [black_color], rax

    mov     rdi, [display]
    mov     esi, [screen_number]
    call    XWhitePixel
    mov     [white_color], rax

    mov     rdi, [display]
    call    XDefaultRootWindow
    mov     [root_window], rax

    mov     rdi, [display]
    mov     rsi, [root_window]
    mov     edx, 0h
    mov     ecx, 0h
    mov     r8d, 800
    mov     r9d, 800
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
    mov     rdx, 20003h
    call    XSelectInput

    mov     rdi, [display]
    mov     rsi, [window]
    call    XMapWindow

.wait_visible:
    mov     rdi, [display]
    lea     rsi, [event]
    call    XNextEvent

    mov     eax, [event]
    cmp     eax, 13h
    jne     .wait_visible

.exit:
    pop     rbp
    ret

;-------------------------------------------------------------
; print a null-terminated string
;
; @param rdi
;   a null-terminated string
;-------------------------------------------------------------
print_string:
    cmp     byte [rdi], 0h
    je      .done

    xor     rdx, rdx
.strlen:
    inc     rdx
    cmp     byte [rdi + rdx], 0h
    jne     .strlen

    mov     rax, 1
    mov     rsi, rdi
    mov     rdi, 1
    ; rdx is holding the message length
    syscall
.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
    display: dq 0h
    screen_number: dd 0h
    black_color: dq 0h
    white_color: dq 0h
    root_window: dq 0h
    window: dq 0h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss
    event: resb 0xc0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .rodata
    msg_open_display_failed: db "failed to open a connection to X server", 0ah, 0h
    msg_game_loop: db "game loop", 0ah, 0h
