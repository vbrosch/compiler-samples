%{
  #define YY_BREAK 	;break;
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  #include "simulator.tab.h"
%}

%option noyywrap

%%

\               { return WHITESPACE; }
call            { return OP_CALL; }
refparam        { return OP_REFPARAM; }
valparam        { return OP_VALPARAM; }
getresult       { return OP_GETRESULT; }
return          { return OP_RETURN; }
freturn         { return OP_FRETURN; }
\:\=            { return OP_ASSIGNMENT; }
\+              { return CHAR_ADD; }
\-              { return CHAR_MINUS; }
\*              { return CHAR_STAR; }
\/              { return CHAR_DIVIDE; }
\+\+            { return CHAR_INCREMENT; }
\-\-            { return CHAR_DECREMENT; }
\&&             { return CHAR_LOGICAL_AND; }
\|\|            { return CHAR_LOGICAL_OR; }
\&              { return CHAR_AND; }
\<              { return COP_LE; }
\>              { return COP_GR; }
\<\=            { return COP_LEQ; }
\>\=            { return COP_GEQ; }
goto            { return OP_GOTO; }
if              { return BEGIN_IF; }
\[              { return CHAR_SQUARE_BRACKET_LEFT; }
\]              { return CHAR_SQUARE_BRACKET_RIGHT; }
noop            { return OP_NOOP; }
not             { return OP_NOT; }
%[a-z]+          { yylval.string = yytext; return LITERAL_NAME; }

[0-9]+          { printf("\n"); yylval.number = atoi(yytext); return LITERAL_NUMBER; }
[\t \n]         { return LINE; }
%%
