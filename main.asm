;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text

    global _start

_start:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, hello
    mov     rdx, 14
    syscall
    
    mov     rax, 60     ; exit program
    xor     rdi, rdi
    syscall

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
    hello: db "hello, world", 0ah, 0h
