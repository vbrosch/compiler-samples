%{
  #define YY_BREAK 	;break;
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  #include "converter.tab.h"
%}

%option noyywrap

%%

b              { return BINARY_MODE; }
d              { return DECIMAL_MODE; }
\+             { yylval.sign = 1; return SIGN; }
\-             { yylval.sign = -1; return SIGN; }
[0-9]          { yylval.num = atoi(yytext);  return NUM; }
[\t \n]        { return LINE; }
.


%%
