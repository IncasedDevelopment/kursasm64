        ;; wersja NASM na system 64-bitowy
section .text                   ; początek sekcji kodu
        global _start           ; ld chce mieć ten symbol globalny

_start:                         ; punkt startu programu
        mov rax, 1              ; # funkcji sys_write - zapisz do pliku
        mov rdi, 1              ; # pliku - 1 = standardowe wyjście
        mov rsi, msg            ; RSI = adres tekstu
        mov rdx, msg_len        ; RDX = długość tekstu
        syscall                 ; wywołanie funkcji sys_write
        mov rax, 60             ; # funkcji sys_exit - wyjdz z programu
        syscall                 ;

section .data
msg     db      "Hello World!", 0ah      ; nasz napis
msg_len equ     $ - msg                  ; dlugosc napisu
        
