bexpr:	linearlization.l linearlization.y
		bison -d linearlization.y
		flex --header-file=lex.yy.h linearlization.l
		gcc linearlization.tab.c lex.yy.c -lm -o linearlization
