;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text

    global _start

    extern print_string
    extern create_window
    extern clear_window
    extern flush_buffer
    extern draw_rectangle
    extern get_event

    extern XCheckWindowEvent
    extern XLookupKeysym

_start:
    call create_window

.game_loop:
    ; get time at start of frame
    call    get_time
    mov     [frame_time], rax
    mov     qword [move_left], 0
    mov     qword [move_right], 0

.process_events:
    lea     rdi, [event]
    call    get_event
    cmp     al, 0h
    je      .update

.check_key_release_event:
    mov     eax, [event]
    cmp     eax, 3h
    jne     .check_key_press_event

    lea     rdi, [event]
    xor     rsi, rsi
    call    XLookupKeysym

    cmp     rax, 0xff1b ; ESC key
    je      .end_game_loop

.check_key_press_event:
    cmp     eax, 2h
    jne     .process_events

    lea     rdi, [event]
    xor     rsi, rsi
    call    XLookupKeysym

.check_left_arrow_key:
    cmp     rax, 0xff51 ; Left Arrow Key
    jne     .check_right_arrow_key

    mov     qword [move_left], 1
    jmp     .process_events

.check_right_arrow_key:
    cmp     rax, 0xff53 ; Right Arrow Key
    jne     .process_events

    mov     qword [move_right], 1
    jmp     .process_events

.update:
.check_move_left:
    cmp     qword [move_left], 1
    jne     .check_move_right

    mov     rax, qword [paddle_x]
    sub     rax, 10
    mov     qword [paddle_x], rax

.check_move_right:
    cmp     qword [move_right], 1
    jne     .render

    mov     rax, qword [paddle_x]
    add     rax, 10
    mov     qword [paddle_x], rax

.render:
    call    clear_window

    ; draw paddle
    mov     edi, [paddle_x]
    mov     esi, [paddle_y]
    mov     edx, [paddle_width]
    mov     ecx, [paddle_height]
    call    draw_rectangle

    call    flush_buffer

    ; get time at end of frame
    call    get_time
    mov     rbx, [frame_time]
    sub     rax, rbx
    cmp     rax, 30 ; see if we have spent less than 30ms in this frame
    jg      .game_loop

    ; sleep for remainder of 30ms
    mov     rdi, 30
    sub     rdi, rax
    call    sleep_ms

    jmp     .game_loop

.end_game_loop:

.exit:
    mov     rax, 60
    xor     rdi, rdi
    syscall

;-------------------------------------------------------------
; get the time since epoch in milliseconds
;
; @return rax
;   milliseconds since epoch
;-------------------------------------------------------------
get_time:
    push    rbp
    mov     rbp, rsp

    ; reserves space for timeval struct
    ; +---------+
    ; | tv_usec | = 8 bytes
    ; +---------+
    ; | tv_sec  | = 8 bytes
    ; +---------+
    sub     rsp, 16

    mov     rax, 96 ; sys_gettimeofday
    lea     rdi, [rbp - 16]
    xor     rsi, rsi
    syscall

    push    rbx

    mov     rax, qword [rbp - 16]   ; seconds
    mov     rbx, qword [rbp - 8]    ; microseconds

    imul    rax, rax, 1000000       ; convert seconds to microseconds
    add     rax, rbx                ; add microseconds
    xor     rdx, rdx
    mov     rbx, 1000
    div     rbx                     ; convert microseconds to milliseconds

    pop     rbx

    add     rsp, 16
    pop     rbp
    ret

;-------------------------------------------------------------
; sleep for some milliseconds
;
; @param rdi
;   milliseconds that u want to sleep
;-------------------------------------------------------------
sleep_ms:
    push    rbp
    mov     rbp, rsp

    ; reserves space for timeval struct
    ; +---------+
    ; | tv_usec | = 8 bytes
    ; +---------+
    ; | tv_sec  | = 8 bytes
    ; +---------+
    sub     rsp, 16

    imul    rdi, rdi, 1000000       ; convert supplied ms to ns
    mov     qword [rbp - 8], rdi    ; store tv_usec
    mov     qword [rbp - 16], 0h    ; tv_sec = 0

    mov     rax, 35 ; sys_nanosleep
    lea     rdi, [rbp - 16]
    xor     rsi, rsi
    syscall

    add     rsp, 16
    pop     rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
    frame_time:     dq 0h

    paddle_x:       dq 300
    paddle_y:       dq 770
    paddle_width:   dq 200
    paddle_height:  dq 20

    move_left:      dq 0h
    move_right:     dq 0h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss
    event: resb 0xc0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .rodata
    msg_open_display_failed: db "failed to open a connection to X server", 0ah, 0h
