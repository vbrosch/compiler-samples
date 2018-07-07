simulator:	simulator.y simulator.l
		bison -d simulator.y
		flex --header-file=lex.yy.h simulator.l
		gcc simulator.tab.c lex.yy.c -lm -o simulator
