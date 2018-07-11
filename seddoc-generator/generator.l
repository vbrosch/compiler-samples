/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */
#include <math.h>
#include <string.h>

%}

IDENTIFIER    [A-Za-z0-9\;&#<>]*

%x sed_search_arg
%x sed_replacement

%%

s\/ { BEGIN(sed_search_arg); }

<sed_search_arg>{IDENTIFIER}/\/\\   { printf("%s -> ", yytext); BEGIN(sed_replacement); }
<sed_replacement>\/\\
<sed_replacement>\/g
<sed_replacement>{IDENTIFIER}\\/g   { printf("%s", yytext); BEGIN(INITIAL); }
.

%%

int main(int argc, char** argv){
  ++argv, --argc;  /* skip over program name */
  if ( argc > 0 )
          yyin = fopen( argv[0], "r" );
  else
          yyin = stdin;

  yylex();
}
