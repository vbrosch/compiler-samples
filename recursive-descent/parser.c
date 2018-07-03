#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
  Perform a recursive descent parse over a LL(1)-grammar
  describing arithmetic expressions.

  The grammar is given as:                  LOOKAHEAD             ATTR

  1. expr = prod, expr2;                    0, 1, 2, ..., 9 (     expr.left = 0;  prod.left = expr.left;  expr2.left = prod.left + 1;
  2. expr2 = ε;                             $, )
  3. expr2 = '+', prod, expr2;              +                     prod.left = expr2.left; expr2.left = prod.left + 1;
  4. prod = fakt, prod2;                    0, 1, 2, ..., 9 (     fakt.left = prod.left;  prod2.left = prod.left + 1;
  5. prod2 = ε;                             +, $, )
  6. prod2 = '*', fakt, prod2;              *                     fakt.left = prod2.left; prod2.left = fakt.left + 1;
  7. fakt = '(', expr, ')';                 (                     expr.left = fakt.left;
  8. fakt = '0' | '1' | '2' | ... | '9';    0, 1, 2, ..., 9

  1. Calculation of FIRST and FOLLOW sets (for the sake of simplicity, we only consider
  the terminal range 0-2 instead of the full range 0-9 as specified in the grammar):

  FIRST_1:
    FIRST_1(expr) = FIRST_1(prod) = {'0', '1', '2', '('};
    FIRST_1(expr_2) = {ε, '+'};
    FIRST_1(prod) = FIRST_1(fakt) = {'0', '1', '2', '('};
    FIRST_1(prod2) = {ε, '*'};
    FIRST_1(fakt) = {'0', '1', '2', '('};

  FOLLOW_1:
    FOLLOW_1(expr) = {$, ')'};
    FOLLOW_1(expr_2) = {$, ')', ε};
    FOLLOW_1(prod) = {$, ')', '+', ε};
    FOLLOW_1(prod_2) = {$, ')', '+', ε};
    FOLLOW_1(fakt) = {'*', ')', '+', ε};

  2. Build lookahead set D for each rule of the grammar:
    1. D(expr -> prod, expr2) = FIRST(prod) = {'0', '1', '2', '('};
    2. D(expr2 -> ε) = FIRST(ε) ∩ FOLLOW(expr2) = {$, ')'};
    3. D(expr2 -> '+', prod, expr2) = FIRST('+') = {'+'};
    4. D(prod -> fakt, prod2) = FIRST(fakt) = {'0', '1', '2', '('};
    5. D(prod2 -> ε) = FIRST(ε) ∩ FOLLOW(prod2) = {$, ')', '+'};
    6. D(prod2 -> '*', fakt, prod2) = FIRST('*') = {'*'};
    7. D(fakt -> '(', expr, ')') = FIRST('(') = {'('};
    8. D(fakt -> '0' | '1' | '2') = FIRST('0') ∩ FIRST('1') ∩ FIRST('2') = {'0', '1', '2'};

  As all lookahead sets of a common nonterminal are pairwise disjoint, the grammar is a
  suitable for LL(1) parsing with a recursive descent parser.

**/

int expr();
int expr2();
int prod();
int prod2();
int fakt();
void pop(char character);
int error(char* message);

char *input;
char lookahead;
int cur_pos;

int expr(int* left) {
  switch (lookahead) {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
    case '(':
      printf("-R1-\n");
      return prod(left) + expr2(left);
    default:
      return error(NULL);
  }
}

int expr2(int* left){
  switch (lookahead) {
    case '$':
    case ')':
      printf("-R2-");
      return 0;
    case '+':
      printf("-R3-\n", left);
      pop(lookahead);
      (*left)++;
      return prod(left) + expr2(left);
    default:
      return error(NULL);
  }
}

int prod(int* left) {
  switch (lookahead) {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
    case '(':
      printf("-R4-\n", left);
      return fakt(left) * prod2(left);
    default:
      return error(NULL);
  }
}

int prod2(int* left){
  switch (lookahead) {
    case '+':
    case '$':
    case ')':
      printf("-R5-\n");
      return 1;
    case '*':
      printf("-R6-\n");
      pop('*');
      (*left)++;
      return fakt(left) * prod2(left);
    default:
      return error(NULL);
  }
}

int fakt(int* left){
  int ret;

  switch (lookahead) {
    case '(':
      printf("-R7-\n");
      pop('(');
      ret = expr(left);
      pop(')');
      return ret;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      printf("-R8-\n");
      printf("Left of %c is %d\n", lookahead, *left);
      ret = lookahead - '0';
      pop(lookahead);
      return ret;
    default:
      return error(NULL);
  }
}

void pop(char character){
    if(character != lookahead){
      error("Char does not match lookahead");
    }

    cur_pos++;
    lookahead = input[cur_pos];

    printf("Moved lookahead one step forward to %c\n", lookahead);
}

int parse_error(char* msg){
  printf("ERR! Error while parsing the input string: %s.\n", msg);
  exit(-1);

  return -1;
}

char* read_input_from_stdin(){
  printf("Please input an expression: ");

  char* buffer;
  size_t bufsize = 32;

  buffer = (char *)malloc(bufsize * sizeof(char));
  if( buffer == NULL)
  {
      perror("Unable to allocate buffer");
      exit(1);
  }

  getline(&buffer,&bufsize,stdin);

  return buffer;
}

char* append_char(char* source, char character){
  size_t str_len = strlen(source);
  char* s = (char*) malloc(str_len + sizeof(char));
  strcpy(s, source);

  s[str_len-1] = character;

  printf("new: %s", s);

  return s;
}

int main(int argc, char** argv){
  while(1){
    char* buffer = read_input_from_stdin();
    input = append_char(buffer, '$');

    cur_pos = 0;
    lookahead = input[cur_pos];

    printf("Appended end flag $ to input string %s.\n", input);

    printf("Will perform recursive descent of %s. The start lookahead is %c\n",
      input, lookahead);

    int left = 0;
    int result = expr(&left);
    printf("\n---\n\nRecursive descent has result: %d\n\n---\n", result);

    free(buffer);
    free(input);
  }
}
