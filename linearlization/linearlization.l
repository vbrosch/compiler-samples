%{
  #define YY_BREAK 	;break;
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  #include "linearlization.tab.h"
%}

%option noyywrap

%%

[A-z]          { yylval.string = yytext; return ELEMENT; }
,              { return COMMA; }
\(             { return L_BRACKET; }
\)             { return R_BRACKET; }
[\t \n]        { return LINE; }
.


%%
