main:
        push    rbp
        mov     rbp, rsp
        mov     DWORD PTR [rbp-12], 2
        mov     DWORD PTR [rbp-16], 90
        mov     DWORD PTR [rbp-64], 0
        mov     DWORD PTR [rbp-60], 1
        mov     DWORD PTR [rbp-56], 2
        mov     DWORD PTR [rbp-52], 3
        mov     DWORD PTR [rbp-48], 256
        mov     DWORD PTR [rbp-44], 14
        mov     DWORD PTR [rbp-40], 16
        mov     DWORD PTR [rbp-20], 7
        mov     DWORD PTR [rbp-4], 0
        mov     DWORD PTR [rbp-8], -1
        jmp     .L2
.L7:
        add     DWORD PTR [rbp-8], 1
        mov     eax, DWORD PTR [rbp-8]
        cdqe
        mov     eax, DWORD PTR [rbp-64+rax*4]
        mov     DWORD PTR [rbp-24], eax
        mov     eax, DWORD PTR [rbp-24]
        cmp     eax, DWORD PTR [rbp-12]
        jge     .L3
        jmp     .L2
.L3:
        mov     eax, DWORD PTR [rbp-24]
        cmp     eax, DWORD PTR [rbp-16]
        jle     .L4
        jmp     .L2
.L4:
        cmp     DWORD PTR [rbp-24], 0
        jg      .L5
        jmp     .L2
.L5:
        mov     eax, DWORD PTR [rbp-24]
        sub     eax, 1
        mov     DWORD PTR [rbp-28], eax
        mov     eax, DWORD PTR [rbp-24]
        and     eax, DWORD PTR [rbp-28]
        mov     DWORD PTR [rbp-32], eax
        cmp     DWORD PTR [rbp-32], 0
        je      .L6
        jmp     .L2
.L6:
        mov     eax, DWORD PTR [rbp-24]
        add     DWORD PTR [rbp-4], eax
.L2:
        mov     eax, DWORD PTR [rbp-20]
        sub     eax, 1
        cmp     DWORD PTR [rbp-8], eax
        jl      .L7
        mov     eax, 0
        pop     rbp
        ret