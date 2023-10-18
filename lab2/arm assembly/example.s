	.arch armv5t
	@ data section : save initialized global variable
	.data
i:
	.word 2
f:
	.word 1
	.text
	.align 2
	@ rodata section : save constant
	.section .rodata
	.align 2
_str0:
	.ascii "%d"
	.align 2
_str1:
	.ascii "%d\n"
	@ text section : code
	.text
	.align 2
	
	.global factorial
factorial: @ function int factorial(int i, int n, int f)
	str fp, [sp, #-4]! @ pre-index mode, sp = sp - 4, push fp
	mov fp, sp
_cmp:
	cmp r0, r1
	bgt _end @ jump to end if i > n
_while:
	mul r3, r2, r0 @ f = f * i
	mov r2, r3
	@mov r1, r2
	@bl printf
	add r0, r0, #1 @ i = i + 1
	@mov r1, r0
	@bl printf
	b _cmp
_end:
	mov r0, r2
	add sp, fp, #0
	ldr fp, [sp], #4 @ post-index mode, pop fp, sp = sp + 4
	bx lr @ recover sp fp pc
  
	.global main
main:
	push {fp, lr}
	add fp, sp, #4
	sub sp, sp, #8
	add r1, fp, #-8 @ r1 = &n
	ldr r0, _bridge+8 @ *r0 = "%d"
	bl __isoc99_scanf @ scanf("%d", &n)
	ldr r1, [fp, #-8] @ r1 = n
	ldr r3, _bridge @ r3 = &i
	ldr r0, [r3] @ r0 = i
	ldr r3, _bridge+4 @ r3 = &f
	ldr r2, [r3] @ r2 = f
	bl factorial
	mov r1, r0 @ r1 = factorial(i,n,f)
	ldr r0, _bridge+12 @ *r0 = "%d\n"
	bl printf @ printf("%d\n", factorial(i,n,f))
	mov r0, #0
	pop {fp, pc}
	
_bridge:
	.word i
	.word f
	.word _str0
	.word _str1
	
	.section .note.GNU-stack,"",%progbits @ safety use
