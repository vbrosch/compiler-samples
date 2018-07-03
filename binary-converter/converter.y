%{

  #include <math.h>
  #include <ctype.h>
  #include <stdio.h>

  extern int yylex (void);
  void yyerror (char const *);

%}

%code requires {
    struct bit {
        int depth;
        int sum;
    };
}

%union {
    int bit;
    int sign;
    struct bit val;
}

%token <sign> SIGN
%token <bit> BIT
%token LINE

%type<val> bits expr

%%

statements:   statements statement
              | statement
              ;

statement:    LINE                  { printf("Empty input.\n"); }
              | expr LINE           { printf("=%d, length=%d\n", $1.sum, $1.depth+1); }
              ;

expr:         bits                  { $$.depth = $1.depth; $$.sum = $1.sum; }
              | SIGN bits           { $$.depth = $2.depth; $$.sum = $1 * $2.sum; }
              ;

bits:         BIT bits              { $$.depth = $2.depth + 1; $$.sum = $2.sum; if($1 == 1){ $$.sum += (int) pow(2, $$.depth); } }
              | BIT                 { $$.depth = 0; $$.sum = ($1 == 1) ? (int) pow(2, $$.depth) : 0; }
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
