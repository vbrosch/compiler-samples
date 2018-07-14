%{

  #include <math.h>
  #include <ctype.h>
  #include <stdio.h>
  #include <string.h>

  extern int yylex (void);
  void yyerror (char const *);

%}

%union {
  char* string;
}

%token<string> ELEMENT;
%token COMMA;
%token L_BRACKET;
%token R_BRACKET;
%token LINE;

%%

statements:   statements statement
              | statement
              ;

statement:    LINE                                         { printf("[]\n"); }
              | { printf("["); } lists LINE                { printf("]\n"); }
              ;

lists:        L_BRACKET list R_BRACKET
              | ELEMENT                                   { printf("%s", $1); }
              ;

list:         list COMMA  { printf(","); } lists
              | lists
              ;

%%

int main(int argc, char** argv){
  return yyparse();
}

/* Display error messages */
void yyerror(const char *s)
{
	printf("ERROR: %s\n", s);
}
