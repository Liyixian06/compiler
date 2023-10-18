.PHONY: calculator, postfix, assign, clean
calculator:
	yacc calculator.y -o calculator.tab.c
	gcc calculator.tab.c -o calculator
	./calculator

postfix:
	yacc postfix.y -o postfix.tab.c
	gcc postfix.tab.c -o postfix
	./postfix

assign:
	yacc assign.y -o assign.tab.c
	gcc assign.tab.c -o assign
	./assign

clean:
	rm *.tab.c calculator postfix assign
