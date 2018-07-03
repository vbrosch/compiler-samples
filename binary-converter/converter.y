%{

  #include <math.h>
  #include <ctype.h>
  #include <stdio.h>
  #include <string.h>

  extern int yylex (void);
  void yyerror (char const *);
  char* getBin(int num);

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
    int num;
    char* binary;
    struct bit val;
}

%token <num>  NUM;
%token DECIMAL_MODE
%token BINARY_MODE
%token <sign> SIGN
%token <bit> BIT
%token LINE

%type<val> bits expr expr_decimal nums

%%

statements:   statements statement
              | statement
              ;

statement:    LINE                    { printf("Empty input. \n"); }
              | expr LINE             { printf("to dec=%d, length=%d\n", $1.sum, $1.depth+1); }
              | BINARY_MODE expr LINE { printf("to dec=%d, length=%d\n", $2.sum, $2.depth+1); }
              | DECIMAL_MODE expr_decimal LINE { int dec = $2.sum; char* bin = getBin(dec);
                                      printf("to bin=%s\n", bin); free(bin); }
              ;

expr:         bits                  { $$.depth = $1.depth; $$.sum = $1.sum; }
              | SIGN bits           { $$.depth = $2.depth; $$.sum = $1 * $2.sum; }
              ;

bits:         NUM bits              { $$.depth = $2.depth + 1; $$.sum = $2.sum; if($1 == 1){ $$.sum += (int) pow(2, $$.depth); } }
              | NUM                 { $$.depth = 0; $$.sum = ($1 == 1) ? (int) pow(2, $$.depth) : 0; }
              ;

expr_decimal: nums                  { $$.depth = $1.depth; $$.sum = $1.sum; }
              ;

nums:         NUM nums              { $$.depth = $2.depth + 1; $$.sum = $2.sum; $$.sum += (int) $1 * pow(10, $$.depth); }
              | NUM                 { $$.depth = 0; $$.sum = (int) $1 * pow(10, $$.depth);  }
              ;

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
