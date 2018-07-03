%{
  #define YY_BREAK 	;break;
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  #include "converter.tab.h"
%}

%option noyywrap

%%

\+             { yylval.sign = 1; return SIGN; }
\-             { yylval.sign = -1; return SIGN; }
[0-1]          { yylval.bit = atoi(yytext); return BIT; }
[\t \n]        { return LINE; }
.


%%
