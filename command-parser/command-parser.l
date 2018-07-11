/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */
#include <math.h>
#include <string.h>

char* cmd = "";

%}

IDENTIFIER    [A-Za-z0-9]*

%x line_command_id
%x line_command
%x inline_command
%x wrapped_command

%%

^\\   { BEGIN(line_command_id); }
\\    { BEGIN(inline_command); }
{IDENTIFIER}    { printf("[WORD, %s]", yytext); }

<line_command_id>{IDENTIFIER}     { cmd = strdup(yytext); printf("[COMMAND START, %s]", cmd); BEGIN(line_command); }
<line_command>{IDENTIFIER}        { printf("[WORD, %s]", yytext); }
<line_command>\n                  { printf("[COMMAND END, %s]\n", cmd); BEGIN(INITIAL); }

<inline_command>{IDENTIFIER}      { cmd = strdup(yytext); printf("[COMMAND, %s]", cmd); BEGIN(INITIAL); }
<inline_command>{IDENTIFIER}/_\{  { cmd = strdup(yytext); printf("[COMMAND START, %s]", cmd); BEGIN(wrapped_command); }

<wrapped_command>_\{
<wrapped_command>{IDENTIFIER}     { printf("[WORD, %s]", yytext); }
<wrapped_command>\}               { printf("[COMMAND END, %s]", cmd); BEGIN(INITIAL); }

.

%%

/*char* strdup(char* str){
  char* new_str;

  for(int i=0; strlen(str); i++){
    new_str[i] = str[i];
  }

  return new_str;
}*/

int main(int argc, char** argv){
    yyin = stdin;
    yylex();
}
