%define SYS_EXIT 60
%define KEY_ESC 0xff1b

section .text

    global _start

    extern create_window
    extern get_window_event
    extern check_key_release
    extern draw_rectangle

_start:
    call create_window

.process_events:
    mov     rdi, event
    call    get_window_event
    test    rax, rax
    jz      .render

    mov     rdi, event
    mov     rsi, KEY_ESC
    call    check_key_release
    test    rax, rax
    jnz     .exit

    jmp     .process_events

.render:
    mov     rdi, [paddle_x]
    mov     rsi, [paddle_y]
    mov     rdx, [paddle_width]
    mov     rcx, [paddle_height]
    call    draw_rectangle

    jmp     .process_events

.exit:
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

section .data
    paddle_x:       dq 300
    paddle_y:       dq 750
    paddle_width:   dq 200
    paddle_height:  dq 30

section .bss
    event: resq 24
