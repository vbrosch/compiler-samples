calculator:	calculator.y
		bison -d calculator.y
		flex --header-file=lex.yy.h calculator.l
		gcc calculator.tab.c lex.yy.c -lm -o calc
