        ;; NASM 64-bit
%define EOF     -1
%define stdout	1
	
section .data

zero_double	dq 0.0
minus_four 	dw -4
title   	db "Program obliczający pierwiastki równania kwadratowego.", 0
msg1    	db "Dla równania kwadratowego o współczynnikach:", 0ah, " a = %.2f, b = %.2f i c = %.2f", 0ah, 0
msg2    	db "Obliczone pierwiastki to:", 0ah, " x1 = %.2f, x2 = %.2f", 0ah, 0
msg3    	db "Równanie nie posiada rozwiązań", 0
msg4    	db "Równanie ma jedno rozwiązanie:", 0ah, " x = %.2f", 0ah, 0
msg5		db "To nie jest równanie kwadratowe!", 0
line		db "========================================", 0
format  	db "%lf %lf %lf", 0
file_open_err   db "Nie udało się otworzyć pliku!", 0
file_name	db "cw06-04.txt", 0
file_mode	db "r", 0
	
section .bss

a       	resq 1
b       	resq 1
c       	resq 1
delta_sqrt      resq 1
one_over_2a     resq 1
x1              resq 1
x2              resq 1
fp		resq 1		; FILE *fp
        
section .text
        global main
        extern exit
        extern puts
        extern printf
	extern fscanf
	extern fopen
	extern fclose

main:                           ; program start
        push rbp		; set up stack frame, must be alligned
	mov rbp, rsp

	mov rdi, title		; puts(title)
	call puts

	mov rdi, file_name	; fopen
	mov rsi, file_mode
	call fopen
	mov qword [fp], rax
	cmp rax, 0
	jne file_ok
	mov rdi, file_open_err
	call puts
	jmp main_return
file_ok:	
while:	
	mov rdi, qword [fp]	; scanf
	mov rsi, format
	mov rdx, a
	mov rcx, b
	mov r8, c
	call fscanf

	cmp rax, 3
	jne main_end
	
while_body:
	mov rdi, line
	call puts

	movq xmm0, qword [a]
	movq xmm1, qword [zero_double]
	ucomisd xmm0, xmm1
	jnz a_not_zero
	mov rdi, msg5
	call puts
	jmp while
	
a_not_zero:		
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
        
        jmp while

main_one_solution:
        mov rdi, msg4
        movq xmm0, qword [x1]
        mov rax, 1
        call printf
        
        jmp while
        
main_no_solutions:
        mov rdi, msg3
        call puts
	jmp while
        
main_end:
	mov rdi, qword[fp]
	call fclose
        xor rax, rax            ; return 0

main_return:	
	mov rsp, rbp
        pop rbp
        
        ret

