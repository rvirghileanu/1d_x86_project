.data
	v: .space 4096

	;//siruri de caractere pentru citiri si afisari
	fprint: .asciz "%d: (%d, %d)\n"
	fscan: .asciz "%d "
	printget: .asciz "(%d, %d)\n"
	printdelete: .asciz "%d: "

	;//variabile pentru functii
	start: .space 4
	end: .space 4
	cnt: .long 0
	st: .long 0
	dr: .long 0


	;//variabile pentru meniu
	nrop: .long 0
	op: .long 0
	nrf: .long 0
	id: .long 0
	dim: .long 0

.text

afisare_vector:

	lea v, %esi

	xorl %ecx, %ecx
	movl $0, cnt
	movl $0, id
	xorl %eax, %eax

	loop_afisare:
		movl $1024, %edi
		cmp %edi, %ecx ;//verific sa nu ies din vector
		jge exit_afisare

		xorl %ebx, %ebx
		movl (%esi, %ecx, 4), %ebx
		xorl %eax, %eax
		cmpl %ebx, %eax ;//verific sa exite un fisier stocat pe pozitia curenta
		je cont_afisare

		xorl %ebx, %ebx
		movl (%esi, %ecx, 4), %ebx
		movl id, %eax
		cmpl %eax, %ebx ;//verific sa nu afisez intervalul unui fisier de mai multe ori
		je cont_afisare

		movl %ebx, id
		pushl id
		pushl $printdelete
		call printf

		popl %edx
		popl %edx

		pushl $0
		call fflush
		popl %edx

		call get

		cont_afisare:
		movl cnt, %ecx 
		inc %ecx
		movl %ecx, cnt
		jmp loop_afisare

		exit_afisare:
			xorl %eax, %eax
			ret

add:
	pushl %ebp
	movl %esp, %ebp
	movl id, %edi ;//idul fisierului
	movl dim, %ebx ;//dimensiunea fisierului
	lea v, %esi ;//adresa vectorului e in esi


	verif_dim:
	xorl %edx, %edx
	movl $8, %edx
	cmpl %edx, %ebx ;//verific sa nu am fisiere mai mici de 2
	jle exit_add
	xorl %edx, %edx

	;//testez daca e nevoie de aproximare
	xorl %edx, %edx
	xorl %ecx, %ecx
	movl $8, %ecx
	movl %ebx, %eax
	divl %ecx
	test %edx, %edx
	jnz aprox_sup

	;//daca dimensiunea fisierului e divizibila cu 8
	movl %eax, %ebx
	movl %edi, %eax
	xorl %edx, %edx
	xorl %edi, %edi
	jmp for_loop

	;//daca dimensiunea fisierului nu e divizibila cu 8
	aprox_sup:
    	movl %eax, %ebx
    	inc %ebx
    	movl %edi, %eax
    	xorl %edx, %edx
    	xorl %edi, %edi

	;//acum eax=id fisier si ebx=dimensiune fisier (eventual aproximata)

	;//caut primul 0 si, cand il gasesc, verific daca e urmat de o secventa de zerouri astfel incat sa incapa fisierul curent acolo

	;//indexul pentru forul de cautare a primului 0 este %edx (acum 0), iar pentru cautarea ultimului va fi %ecx (care pleaca de la 0 de fiecare data)

	for_loop: ;// for de la 0 la 1023

    	movl $1024, %edi
    	cmpl %edi, %edx ;//verific sa nu ies din vector
    	jge afisare

    	xorl %ecx, %ecx ;//initializez indexul pentru al doilea for

    	;//verific daca am 0
    	movl (%esi, %edx, 4), %edi ;// pun valoarea pozitiei curente in esi
    	test %edi, %edi
    	jz for_loop2

        	for_loop2: ;//for de la 0 la ebx=dimensiune fisier

            	movl %edx, start

            	cmp %ebx, %ecx
            	jge et_verif

            	xorl %edi, %edi
            	movl %edx, %edi
            	addl %ecx, %edi

            	movl  (%esi, %edi, 4), %edi
            	test %edi, %edi
            	jnz cont_add ;//am gasit prematur spatiu ocupat (fiindca %ecx nu a depasit dimensiunea din %ebx), deci fisierul nu are loc in secventa curenta

            	inc %ecx
            	jmp for_loop2

        	cont_add:
            	inc %edx
            	jmp for_loop

    	et_verif:
        	addl %edx, %ecx
        	dec %ecx
        	movl %ecx, end
        	adaugare:
            	cmpl %ecx, %edx
            	jg afisare
            	lea v, %esi
            	movl %eax, (%esi, %edx, 4)
            	inc %edx
            	jmp adaugare


				afisare:
				pushl id
				pushl $printdelete
				call printf

				popl %eax
				popl %eax

				pushl $0
				call fflush
				popl %eax
				
				call get

			

			exit_add:
				
            	xorl %eax, %eax
            	movl %ebp, %esp
            	popl %ebp
            	ret




get:
	pushl %ebp
	movl %esp, %ebp
	movl id, %eax ;//idul fisierului
	lea v, %esi ;//adresa vectorului e in esi

	movl $0, start
	movl $0, end

	xorl %edx, %edx ;// edx e indexul forului
	xorl %ecx, %ecx ;// in ecx contorizez dimensiunea fisierului

	for_get:

    	movl $1024, %edi
    	cmp %edi, %edx ;//verific sa nu ies din vector
    	jge exit_get

    	xorl %ebx, %ebx
    	movl (%esi, %edx, 4), %ebx
    	cmpl %ebx, %eax ;//verific daca am gasit idul
    	jne cont_get

    	movl %edx, end
    	inc %ecx

    	;//pun urmatoarea pozitie din vector in ebx
    	xorl %ebx, %ebx
    	movl %edx, %ebx
    	inc %ebx
    	movl (%esi, %ebx, 4), %ebx

    	cmpl %ebx, %eax ;//verific cand se termina fisierul ca sa nu mai caut pana la finalul vectorului
    	jne exit_get


    	cont_get:
        	inc %edx
        	jmp for_get

    	exit_get:
        	movl end, %edx
        	xorl %edi, %edi
        	cmpl %edx, %edi
        	je nu_exista

        	;//ecx=dimensiunea fisierului, edx=end
        	subl %ecx, %edx
        	inc %edx
        	movl %edx, start

        	pushl end
        	pushl start
        	pushl $printget
        	call printf

        	popl %ebx
        	popl %ebx
        	popl %ebx

			pushl $0
			call fflush
			popl %ebx

        	xorl %eax, %eax
        	movl %ebp, %esp
        	popl %ebp
        	ret


    	nu_exista:
        	movl $0, start
        	movl $0, end

        	pushl end
        	pushl start
        	pushl $printget
        	call printf

        	popl %ebx
        	popl %ebx
        	popl %ebx

			pushl $0
			call fflush
			popl %ebx

        	xorl %eax, %eax
        	movl %ebp, %esp
        	popl %ebp
        	ret



delete:
	pushl %ebp
	movl %esp, %ebp
	movl id, %eax ;//idul fisierului
	lea v, %esi ;//adresa vectorului e in esi

	xorl %ecx, %ecx

	for_delete:

    	movl $1024, %edi
    	cmp %edi, %ecx ;//verific sa nu ies din vector
    	jge exit_delete

    	movl (%esi, %ecx, 4), %ebx
    	cmp %ebx, %eax
    	jne cont_delete

    	movl $0, (%esi, %ecx, 4)
		;//testez daca am incheiat stergerea, ca sa nu mai parcurg tot vectorul
		xorl %ebx, %ebx
		movl %ecx, %ebx
		inc %ebx
		movl (%esi, %ebx, 4), %ebx
		cmpl %ebx, %eax
		jne exit_delete


    	cont_delete:
        	inc %ecx
        	jmp for_delete


    	exit_delete:
			call afisare_vector
			xorl %eax, %eax
			movl %ebp, %esp
			popl %ebp
			ret


defragmentation:
pushl %ebp
movl %esp, %ebp
lea v, %esi ;//adresa vectorului e in esi

xorl %ecx, %ecx
xorl %ebx, %ebx

for_st:
    movl $1024, %edi
    cmpl %edi, %ecx
    jge exit_defr

    movl (%esi, %ecx, 4), %edx
    xorl %eax, %eax
    cmpl %edx, %eax
    je st_gasit

    inc %ecx
    jmp for_st

st_gasit:
    xorl %ebx, %ebx
    movl %ecx, st
    movl %ecx, %ebx
    inc %ebx
    for_dr:
        movl $1024, %edi
        cmpl %edi, %ebx
        jge exit_defr

        movl (%esi, %ebx, 4), %edx
        xorl %eax, %eax
        cmpl %edx, %eax
        jne dr_gasit

        inc %ebx
        jmp for_dr

dr_gasit:
    movl %ebx, dr
    movl st, %ecx

    movl (%esi, %ebx, 4), %edx
    movl %edx, (%esi, %ecx, 4)
    movl $0, (%esi, %ebx, 4)

    inc %ecx
    jmp for_st

	exit_defr:
		call afisare_vector
		xorl %eax, %eax
		movl %ebp, %esp
		popl %ebp
		ret

.global main

main:
	pushl $nrop
	pushl $fscan
	call scanf

	popl %eax
	popl %eax

	movl nrop, %ecx 
	for_operatii:
		xorl %edx, %edx
		cmpl %ecx, %edx
		jge final

		pushl $op
		pushl $fscan
		call scanf

		popl %eax
		popl %eax

		xorl %ebx, %ebx
		movl op, %ebx

		xorl %eax, %eax
		movl $1, %eax

		cmpl %ebx, %eax
		je call_add

		xorl %eax, %eax
		movl $2, %eax

		cmpl %ebx, %eax
		je call_get

		xorl %eax, %eax
		movl $3, %eax

		cmpl %ebx, %eax
		je call_delete

		xorl %eax, %eax
		movl $4, %eax

		cmpl %ebx, %eax
		je call_defr

		cont_for_operatii:
		movl nrop, %ecx
		dec %ecx
		movl %ecx, nrop
		jmp for_operatii

call_add:
	pushl $nrf
	pushl $fscan
	call scanf

	popl %eax
	popl %eax

	xorl %eax, %eax

for_add:

	movl nrf, %ecx
	xorl %edx, %edx
	cmpl %ecx, %edx
	jae final_for_add

	pushl $id
	pushl $fscan
	call scanf

	popl %eax
	popl %eax

	pushl $dim
	pushl $fscan
	call scanf

	popl %eax
	popl %eax

	call add

	xorl %ecx, %ecx
	xorl %edx, %edx

	movl nrf, %ecx
	dec %ecx
	movl %ecx, nrf
	jmp for_add

final_for_add:
	jmp cont_for_operatii

call_get:
	pushl $id
	pushl $fscan
	call scanf

	popl %eax
	popl %eax

	call get
	jmp cont_for_operatii

call_delete:
	pushl $id
	pushl $fscan
	call scanf

	popl %eax
	popl %eax

	call delete
	jmp cont_for_operatii

call_defr:
	call defragmentation
	jmp cont_for_operatii


final:
	movl $1, %eax
	xorl %ebx, %ebx
	int $0x80

