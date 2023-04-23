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

_start:
    xor     rdi, rdi
    call    XOpenDisplay

.exit:
    mov     rax, 60
    xor     rdi, rdi
    syscall

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
    ; rdx holds the message length
    syscall
.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
    display: dq 0h
