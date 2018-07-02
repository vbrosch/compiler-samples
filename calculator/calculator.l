%{
  #define YY_BREAK 	;break;
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  #include "calculator.tab.h"
%}

%option noyywrap

%%

[0-9]+\.[0-9]+ { yylval.number = atof(yytext); return NUM; }
[0-9]+         { yylval.number = atof(yytext); return NUM; }
\+             { return ADD; }
\-             { return SUB; }
\*             { return MULT; }
\/             { return DIV; }
\(             { return L_BRACKET; }
\)             { return R_BRACKET; }
[\t \n]        { return LINE; }
.

%%
