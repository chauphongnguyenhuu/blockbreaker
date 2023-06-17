%define SYS_EXIT 60
%define KEY_ESC 0xff1b
%define KEY_LEFT 0xff53
%define KEY_RIGHT 0xff51

section .text

    global _start

    extern create_window
    extern get_window_event
    extern check_key_release
    extern check_key_press
    extern draw_rectangle
    extern clear_window
    extern flush_buffer
    extern get_time
    extern sleep_ms

_start:
    call create_window

.game_loop:
    call    get_time
    mov     [frame_time], rax

.process_events:
    mov     rdi, event
    call    get_window_event
    test    rax, rax
    jz      .check_move_left

    mov     rdi, event
    mov     rsi, KEY_ESC
    call    check_key_release
    test    rax, rax
    jnz     .exit

.check_left:
    mov     rdi, event
    mov     rsi, KEY_LEFT
    call    check_key_press
    test    rax, rax
    jz      .check_right
    mov     byte [move_left], 1
    jmp     .process_events

.check_right:
    mov     rdi, event
    mov     rsi, KEY_RIGHT
    call    check_key_press
    test    rax, rax
    jz      .process_events
    mov     byte [move_right], 1

    jmp     .process_events

.check_move_left:
    cmp     byte [move_left], 1
    jne     .check_move_right
    mov     rax, [paddle_x]
    add     rax, [paddle_speed]
    mov     [paddle_x], rax
    mov     byte [move_left], 0

.check_move_right:
    cmp     byte [move_right], 1
    jne     .render
    mov     rax, [paddle_x]
    sub     rax, [paddle_speed]
    mov     [paddle_x], rax
    mov     byte [move_right], 0

.render:
    call    clear_window

    mov     rdi, [paddle_x]
    mov     rsi, [paddle_y]
    mov     rdx, [paddle_width]
    mov     rcx, [paddle_height]
    call    draw_rectangle

    call    flush_buffer

    call    get_time
    mov     rcx, [frame_time]
    sub     rax, rcx
    cmp     rax, 30
    jg      .game_loop

    mov     rdi, 30
    sub     rdi, rax
    call    sleep_ms

    jmp     .game_loop

.exit:
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

section .data

    paddle_x:       dq 300
    paddle_y:       dq 750
    paddle_width:   dq 200
    paddle_height:  dq 30
    paddle_speed:   dq 10

    move_left:      db 0h
    move_right:     db 0h

    frame_time:     dq 0h

section .bss

    event: resq 24
