.PHONY:lcc,clean
lcc:
	flex sysycc.l
	g++ lex.yy.c -o lcc.out
	./lcc.out testin testout
clean:
	rm *.out
