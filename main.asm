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
    xor     rdi, rdi        ; use DISPLAY environment variable
    call    XOpenDisplay

    mov     rax, 60         ; exit program
    xor     rdi, rdi
    syscall

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
    display: dq 0h


