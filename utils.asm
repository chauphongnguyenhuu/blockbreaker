section .text

    global print_string
    global get_time
    global sleep_ms

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

get_time:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16

    mov    rax, 60h
    lea     rdi, [rbp - 16]
    mov     rsi, 0h
    syscall

    mov     rax, [rbp - 16]
    mov     rbx, [rbp - 8]

    imul    rax, rax, 1000000 ; convert seconds to microseconds
    add     rax, rbx
    mov     rdx, 0h
    mov     rbx, 1000
    div     rbx ; convert to milliseconds

    leave
    ret

sleep_ms:
    imul    rdi, rdi, 1000000 ; convert supplied ms to ns
    xor     rax, rax
    push    rdi ; tv_nsec
    push    rax

    mov     rax, 23h
    mov     rdi, rsp
    mov     rsi, 0h
    syscall

    add     rsp, 16
    ret

