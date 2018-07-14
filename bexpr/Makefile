bexpr:	bexpr.l bexpr.y
		bison -d bexpr.y
		flex --header-file=lex.yy.h bexpr.l
		gcc bexpr.tab.c lex.yy.c -lm -o bexpr
