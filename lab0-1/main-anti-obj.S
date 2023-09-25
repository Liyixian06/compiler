
main.o：     文件格式 elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
   0:	f3 0f 1e fa          	endbr64 
   4:	55                   	push   %rbp
   5:	48 89 e5             	mov    %rsp,%rbp
   8:	48 83 ec 20          	sub    $0x20,%rsp
   c:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
  13:	00 00 
  15:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  19:	31 c0                	xor    %eax,%eax
  1b:	48 8d 45 ec          	lea    -0x14(%rbp),%rax
  1f:	48 89 c6             	mov    %rax,%rsi
  22:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 29 <main+0x29>
  29:	b8 00 00 00 00       	mov    $0x0,%eax
  2e:	e8 00 00 00 00       	callq  33 <main+0x33>
  33:	c7 45 f0 02 00 00 00 	movl   $0x2,-0x10(%rbp)
  3a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%rbp)
  41:	eb 0e                	jmp    51 <main+0x51>
  43:	8b 45 f4             	mov    -0xc(%rbp),%eax
  46:	0f af 45 f0          	imul   -0x10(%rbp),%eax
  4a:	89 45 f4             	mov    %eax,-0xc(%rbp)
  4d:	83 45 f0 01          	addl   $0x1,-0x10(%rbp)
  51:	8b 45 ec             	mov    -0x14(%rbp),%eax
  54:	39 45 f0             	cmp    %eax,-0x10(%rbp)
  57:	7e ea                	jle    43 <main+0x43>
  59:	8b 45 f4             	mov    -0xc(%rbp),%eax
  5c:	89 c6                	mov    %eax,%esi
  5e:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 65 <main+0x65>
  65:	b8 00 00 00 00       	mov    $0x0,%eax
  6a:	e8 00 00 00 00       	callq  6f <main+0x6f>
  6f:	b8 00 00 00 00       	mov    $0x0,%eax
  74:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  78:	64 48 33 14 25 28 00 	xor    %fs:0x28,%rdx
  7f:	00 00 
  81:	74 05                	je     88 <main+0x88>
  83:	e8 00 00 00 00       	callq  88 <main+0x88>
  88:	c9                   	leaveq 
  89:	c3                   	retq   
