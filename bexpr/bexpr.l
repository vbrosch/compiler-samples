%{
  #define YY_BREAK 	;break;
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  #include "bexpr.tab.h"
%}

%option noyywrap

%%

\              { return SPACE; }
and            { return AND; }
or             { return OR; }
not            { return NOT; }
false          { return FALSE_T; }
true           { return TRUE_T; }
\(             { return L_BRACKET; }
\)             { return R_BRACKET; }
[\t \n]        { return LINE; }
.


%%
