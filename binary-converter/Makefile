converter:	converter.y
		bison -d converter.y
		flex --header-file=lex.yy.h converter.l
		gcc converter.tab.c lex.yy.c -lm -o converter
