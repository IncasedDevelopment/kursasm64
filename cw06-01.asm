        ;; NASM 64-bit
section .data

msg1    db "Dla równania kwadratowego o współczynnikach:", 0ah, " a = %.2f, b = %.2f i c = %.2f", 0ah, 0
msg2    db "Obliczone pierwiastki to:", 0ah, " x1 = %.2f, x2 = %.2f", 0ah, 0
msg3    db "Równanie nie posiada rozwiązań", 0
msg4    db "Równanie ma jedno rozwiązanie:", 0ah, " x = %.2f", 0ah, 0
a       dq 2.0
b       dq 1.0
c       dq -2.0
minus_four dw -4
        
section .bss

delta_sqrt      resq 1
one_over_2a     resq 1
x1              resq 1
x2              resq 1
        
section .text
        global main
        extern exit
        extern puts
        extern printf
main:                           ; program start
        push rbp		; set up stack frame, must be alligned

        mov rdi, msg1
        movq xmm0, qword [a]
        movq xmm1, qword [b]
        movq xmm2, qword [c]
        mov rax, 3              ; 3 xmm registers used
        call printf

        fild word [minus_four]
        fld qword [a]
        fld qword [c]
        fmulp                   ; fstack: ac, -4
        fmulp                   ; fstack: -4ac

        fld qword [b]
        fld qword [b]
        fmulp                   ; fstack: b*b, -4ac
        faddp                   ; fstack: delta

        ftst                    ; test delta with 0 (for jumps)
        fstsw ax                ; copy coprocessor flags to ax
        sahf                    ; ah to FLAGS
       
        fsqrt                   ; fstack: sqrt(delta)
        fstp qword [delta_sqrt] ; pop sqrt(delta)

        jb main_no_solutions    ; if (delta<0)
        
        fld1                    ; fstack: 1.0
        fld qword [a]           ; fstack: a, 1.0
        fscale                  ; fstack: a*2^(1.0), 1.0 = 2a, 1.0
        fdivp                   ; fstack: 1/(2a)
        fst qword [one_over_2a]
        fld qword [b]           ; fstack: b, 1/(2a)
        fld qword [delta_sqrt]  ; fstack: sqrt(delta), b, 1/(2a)
        fsubrp                  ; fstack: sqrt(delta) - b, 1/(2a)
        fmulp                   ; fstack: (-b + sqrt(delta))/2a
        fstp qword [x1]         ; pop result to x1       

        jz main_one_solution    ; if (delta==0)

        ;; else (delta>0)
        fld qword [b]           ; fstack: b
        fld qword [delta_sqrt]  ; fstack: sqrt(delta), b
        fchs                    ; fstack: -sqrt(delta), b
        fsubrp                  ; fstack: -sqrt(delta)-b
        fmul qword [one_over_2a]
        fstp qword [x2]         ; pop result to x2
        ;; print
        mov rdi, msg2
        movq xmm0, qword [x1]
        movq xmm1, qword [x2]
        mov rax, 2
        call printf       
        
        jmp main_end

main_one_solution:
        mov rdi, msg4
        movq xmm0, qword [x1]
        mov rax, 1
        call printf
        
        jmp main_end
        
main_no_solutions:
        mov rdi, msg3
        call puts
        
main_end:
        pop rbp
        
        xor rax, rax            ; return 0
        ret

