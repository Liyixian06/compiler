	.text
	.file	"main.c"
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4               # -- Begin function main
.LCPI0_0:
	.long	2                       # 0x2
	.long	3                       # 0x3
	.long	4                       # 0x4
	.long	5                       # 0x5
.LCPI0_1:
	.long	1                       # 0x1
	.long	1                       # 0x1
	.long	1                       # 0x1
	.long	1                       # 0x1
.LCPI0_2:
	.long	4                       # 0x4
	.long	4                       # 0x4
	.long	4                       # 0x4
	.long	4                       # 0x4
.LCPI0_3:
	.long	8                       # 0x8
	.long	8                       # 0x8
	.long	8                       # 0x8
	.long	8                       # 0x8
.LCPI0_4:
	.long	12                      # 0xc
	.long	12                      # 0xc
	.long	12                      # 0xc
	.long	12                      # 0xc
.LCPI0_5:
	.long	16                      # 0x10
	.long	16                      # 0x10
	.long	16                      # 0x10
	.long	16                      # 0x10
.LCPI0_6:
	.long	20                      # 0x14
	.long	20                      # 0x14
	.long	20                      # 0x14
	.long	20                      # 0x14
.LCPI0_7:
	.long	24                      # 0x18
	.long	24                      # 0x18
	.long	24                      # 0x18
	.long	24                      # 0x18
.LCPI0_8:
	.long	28                      # 0x1c
	.long	28                      # 0x1c
	.long	28                      # 0x1c
	.long	28                      # 0x1c
.LCPI0_9:
	.long	32                      # 0x20
	.long	32                      # 0x20
	.long	32                      # 0x20
	.long	32                      # 0x20
	.text
	.globl	main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	4(%rsp), %rsi
	movl	$.L.str, %edi
	xorl	%eax, %eax
	callq	__isoc99_scanf
	movl	4(%rsp), %eax
	movl	$1, %esi
	cmpl	$2, %eax
	jl	.LBB0_13
# %bb.1:
	leal	-1(%rax), %r8d
	cmpl	$8, %r8d
	jae	.LBB0_3
# %bb.2:
	movl	$2, %ecx
	movl	$1, %esi
	jmp	.LBB0_12
.LBB0_3:
	movl	%r8d, %ecx
	andl	$-8, %ecx
	leal	-8(%rcx), %edi
	movl	%edi, %edx
	shrl	$3, %edx
	addl	$1, %edx
	movl	%edx, %esi
	andl	$3, %esi
	cmpl	$24, %edi
	jae	.LBB0_5
# %bb.4:
	movdqa	.LCPI0_0(%rip), %xmm0   # xmm0 = [2,3,4,5]
	movdqa	.LCPI0_1(%rip), %xmm1   # xmm1 = [1,1,1,1]
	movdqa	%xmm1, %xmm2
	jmp	.LBB0_7
.LBB0_5:
	movl	%esi, %edi
	subl	%edx, %edi
	movdqa	.LCPI0_0(%rip), %xmm0   # xmm0 = [2,3,4,5]
	movdqa	.LCPI0_1(%rip), %xmm1   # xmm1 = [1,1,1,1]
	movdqa	.LCPI0_3(%rip), %xmm9   # xmm9 = [8,8,8,8]
	movdqa	.LCPI0_4(%rip), %xmm10  # xmm10 = [12,12,12,12]
	movdqa	.LCPI0_5(%rip), %xmm11  # xmm11 = [16,16,16,16]
	movdqa	.LCPI0_6(%rip), %xmm12  # xmm12 = [20,20,20,20]
	movdqa	.LCPI0_7(%rip), %xmm13  # xmm13 = [24,24,24,24]
	movdqa	.LCPI0_8(%rip), %xmm14  # xmm14 = [28,28,28,28]
	movdqa	.LCPI0_9(%rip), %xmm15  # xmm15 = [32,32,32,32]
	movdqa	%xmm1, %xmm2
	.p2align	4, 0x90
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	movdqa	%xmm0, %xmm6
	paddd	.LCPI0_2(%rip), %xmm6
	pshufd	$245, %xmm0, %xmm7      # xmm7 = xmm0[1,1,3,3]
	pshufd	$245, %xmm1, %xmm3      # xmm3 = xmm1[1,1,3,3]
	pmuludq	%xmm7, %xmm3
	pmuludq	%xmm0, %xmm1
	pshufd	$245, %xmm2, %xmm7      # xmm7 = xmm2[1,1,3,3]
	pshufd	$245, %xmm6, %xmm4      # xmm4 = xmm6[1,1,3,3]
	pmuludq	%xmm7, %xmm4
	pmuludq	%xmm2, %xmm6
	movdqa	%xmm0, %xmm2
	paddd	%xmm9, %xmm2
	movdqa	%xmm0, %xmm7
	paddd	%xmm10, %xmm7
	pmuludq	%xmm2, %xmm1
	pshufd	$245, %xmm2, %xmm2      # xmm2 = xmm2[1,1,3,3]
	pmuludq	%xmm3, %xmm2
	pmuludq	%xmm7, %xmm6
	pshufd	$245, %xmm7, %xmm3      # xmm3 = xmm7[1,1,3,3]
	pmuludq	%xmm4, %xmm3
	movdqa	%xmm0, %xmm4
	paddd	%xmm11, %xmm4
	movdqa	%xmm0, %xmm7
	paddd	%xmm12, %xmm7
	pshufd	$245, %xmm4, %xmm5      # xmm5 = xmm4[1,1,3,3]
	pmuludq	%xmm2, %xmm5
	pmuludq	%xmm1, %xmm4
	pshufd	$245, %xmm7, %xmm8      # xmm8 = xmm7[1,1,3,3]
	pmuludq	%xmm3, %xmm8
	pmuludq	%xmm6, %xmm7
	movdqa	%xmm0, %xmm2
	paddd	%xmm13, %xmm2
	movdqa	%xmm0, %xmm3
	paddd	%xmm14, %xmm3
	pmuludq	%xmm2, %xmm4
	pshufd	$232, %xmm4, %xmm1      # xmm1 = xmm4[0,2,2,3]
	pshufd	$245, %xmm2, %xmm2      # xmm2 = xmm2[1,1,3,3]
	pmuludq	%xmm5, %xmm2
	pshufd	$232, %xmm2, %xmm2      # xmm2 = xmm2[0,2,2,3]
	punpckldq	%xmm2, %xmm1    # xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
	pmuludq	%xmm3, %xmm7
	pshufd	$232, %xmm7, %xmm2      # xmm2 = xmm7[0,2,2,3]
	pshufd	$245, %xmm3, %xmm3      # xmm3 = xmm3[1,1,3,3]
	pmuludq	%xmm8, %xmm3
	pshufd	$232, %xmm3, %xmm3      # xmm3 = xmm3[0,2,2,3]
	punpckldq	%xmm3, %xmm2    # xmm2 = xmm2[0],xmm3[0],xmm2[1],xmm3[1]
	paddd	%xmm15, %xmm0
	addl	$4, %edi
	jne	.LBB0_6
.LBB0_7:
	testl	%esi, %esi
	je	.LBB0_10
# %bb.8:                                # %.preheader
	negl	%esi
	movdqa	.LCPI0_2(%rip), %xmm3   # xmm3 = [4,4,4,4]
	movdqa	.LCPI0_3(%rip), %xmm4   # xmm4 = [8,8,8,8]
	.p2align	4, 0x90
.LBB0_9:                                # =>This Inner Loop Header: Depth=1
	movdqa	%xmm0, %xmm5
	paddd	%xmm3, %xmm5
	pshufd	$245, %xmm1, %xmm6      # xmm6 = xmm1[1,1,3,3]
	pmuludq	%xmm0, %xmm1
	pshufd	$232, %xmm1, %xmm1      # xmm1 = xmm1[0,2,2,3]
	pshufd	$245, %xmm0, %xmm7      # xmm7 = xmm0[1,1,3,3]
	pmuludq	%xmm6, %xmm7
	pshufd	$232, %xmm7, %xmm6      # xmm6 = xmm7[0,2,2,3]
	punpckldq	%xmm6, %xmm1    # xmm1 = xmm1[0],xmm6[0],xmm1[1],xmm6[1]
	pshufd	$245, %xmm2, %xmm6      # xmm6 = xmm2[1,1,3,3]
	pmuludq	%xmm5, %xmm2
	pshufd	$232, %xmm2, %xmm2      # xmm2 = xmm2[0,2,2,3]
	pshufd	$245, %xmm5, %xmm5      # xmm5 = xmm5[1,1,3,3]
	pmuludq	%xmm6, %xmm5
	pshufd	$232, %xmm5, %xmm5      # xmm5 = xmm5[0,2,2,3]
	punpckldq	%xmm5, %xmm2    # xmm2 = xmm2[0],xmm5[0],xmm2[1],xmm5[1]
	paddd	%xmm4, %xmm0
	incl	%esi
	jne	.LBB0_9
.LBB0_10:
	pshufd	$245, %xmm1, %xmm0      # xmm0 = xmm1[1,1,3,3]
	pshufd	$245, %xmm2, %xmm3      # xmm3 = xmm2[1,1,3,3]
	pmuludq	%xmm0, %xmm3
	pmuludq	%xmm1, %xmm2
	pshufd	$78, %xmm2, %xmm0       # xmm0 = xmm2[2,3,0,1]
	pmuludq	%xmm2, %xmm0
	pshufd	$10, %xmm3, %xmm1       # xmm1 = xmm3[2,2,0,0]
	pmuludq	%xmm3, %xmm1
	pmuludq	%xmm0, %xmm1
	movd	%xmm1, %esi
	cmpl	%ecx, %r8d
	je	.LBB0_13
# %bb.11:
	orl	$2, %ecx
	.p2align	4, 0x90
.LBB0_12:                               # =>This Inner Loop Header: Depth=1
	imull	%ecx, %esi
	leal	1(%rcx), %edx
	cmpl	%eax, %ecx
	movl	%edx, %ecx
	jl	.LBB0_12
.LBB0_13:
	movl	$.L.str.1, %edi
	xorl	%eax, %eax
	callq	printf
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"%d"
	.size	.L.str, 3

	.type	.L.str.1,@object        # @.str.1
.L.str.1:
	.asciz	"%d\n"
	.size	.L.str.1, 4

	.ident	"clang version 10.0.0-4ubuntu1 "
	.section	".note.GNU-stack","",@progbits
