%{

  #include <math.h>
  #include <ctype.h>
  #include <stdio.h>
  #include <string.h>

  extern int yylex (void);
  void yyerror (char const *);

%}

%union {
  int num;
}

%token TRUE_T;
%token FALSE_T;
%token NOT;
%token AND;
%token OR;
%token L_BRACKET;
%token R_BRACKET;
%token LINE;
%token SPACE;

%type<num> expr term factor

%%

statements:   statements statement
              | statement
              ;

statement:    LINE                                        { printf("Empty input. \n"); }
              | expr LINE                                 { printf("Truthy: %s\n", ($1 == 1 ? "true" : "false")); }
              ;

expr:         expr space OR space term                    { $$ = ($1 == 1) ? $1 : $5; }
              | term                                      { $$ = $1; }
              ;

term:         term space AND space factor                 { $$ = (($1 + $5) == 2) ? 1 : 0; }
              | factor                                    { $$ = $1; }
              ;

factor:       NOT space factor                            { $$ = ($3 == 1) ? 0 : 1; }
              | L_BRACKET space expr space R_BRACKET      { $$ = $3;  }
              | TRUE_T                                    { $$ = 1; }
              | FALSE_T                                   { $$ = 0; }
              ;

space:        SPACE
              | %empty;

%%

int main(int argc, char** argv){
  return yyparse();
}

char* getBin(int num)
{
  char* buff = (char*) malloc(sizeof(char) * 128);

  if(num <= 0){
    buff[0] = '0';
  }

  int bit_index = 0;

  while(num > 0){
    int bit = num % 2;
    int quotient = num / 2;

    buff[bit_index] = bit + '0';
    num = quotient;
    bit_index++;
  }

  int length = strlen(buff);
  char* s = (char*) malloc(sizeof(char) * length);
  int j = 0;

  for(int i = length - 1; i >= 0; i--){
    s[j++] = buff[i];
  }

  return s;
}

/* Display error messages */
void yyerror(const char *s)
{
	printf("ERROR: %s\n", s);
}
