.PHONY: pre, lexer, ast-gcc, ast-llvm, cfg, ir-gcc, ir-llvm, ll-bc, pass, asm, obj, exe, antiobj, antiexe

pre:
	gcc main.c -E -o main.i

lexer:
	clang -E -Xclang -dump-tokens main.c > tokens.txt 2>&1

ast-gcc:
	gcc -fdump-tree-original-raw main.c

ast-llvm:
	clang -E -Xclang -ast-dump main.c > ast-llvm.txt 2>&1

cfg:
	gcc -O0 -fdump-tree-all-graph main.c

ir-gcc:
	gcc -O0 -fdump-rtl-all-graph main.c

ir-llvm:
	clang -S -emit-llvm main.c

ll-bc:
	llvm-as main.ll -o main.bc

pass:
	llc -print-before-all -print-after-all main.ll > pass.log 2>&1

asm:
	gcc -O0 -o main.S -S -masm=att main.i

obj:
	gcc -O0 -c -o main.o main.S

antiobj:
	objdump -d main.o > main-anti-obj.S
	nm main.o > main-nm-obj.txt

exe:
	gcc -O0 -o main main.o

antiexe:
	objdump -d main > main-anti-exe.S
	nm main > main-nm-exe.txt

clean:
	rm -rf *.c.*

clean-all:
	rm -rf *.c.* *.o *.S *.dot *.out *.txt *.ll *.bc *.s *.log *.i main
