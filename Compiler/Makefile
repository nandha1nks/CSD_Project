minicc : y.tab.c lex.yy.c
	g++ -g -o minicc lex.yy.c y.tab.c -ll -ly

lex.yy.c : lexAn.l y.tab.c
	lex lexAn.l

y.tab.c : synAn.y
	yacc -v -d synAn.y

clean:
	rm -rf lex.yy.c y.tab.h y.tab.c y.output minicc