.PHONY: regex2NFA, clean
regex2NFA:
	yacc regex2NFA.y -o regex2NFA.tab.cpp
	g++ regex2NFA.tab.cpp -o regex2NFA
	./regex2NFA
clean:
	rm *.tab.cpp regex2NFA