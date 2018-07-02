%{

  #include <math.h>
  #include <ctype.h>
  #include <stdio.h>

  extern int yylex (void);
  void yyerror (char const *);
%}

%union {
    double number;
}

%token L_BRACKET
%token R_BRACKET
%token <number> NUM
%token ADD
%token MULT
%token SUB
%token DIV
%token LINE

%type<number> fakt expr prod sub div

%%

calculations: calculation
              | calculations calculation
              ;

calculation:  LINE                      { printf("Empty input – got nothing todo! :)"); }
              | expr LINE               { printf("=%0.2f\n", $1); }
              ;

expr:         expr ADD prod             { $$ = $1 + $3; }
              | prod                    { $$ = $1; }
              ;

prod:         prod MULT sub             { $$ = $1 * $3; }
              | sub                     { $$ = $1; }
              ;

sub:          sub SUB div               { $$ = $1 - $3; }
              | div                     { $$ = $1; }
              ;

div:          div DIV fakt              { $$ = $1 / $3; }
              | fakt                    { $$ = $1; }
              ;

fakt:         L_BRACKET expr R_BRACKET  { $$ = $2; }
              | NUM                     { $$ = $1; }
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
