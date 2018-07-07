%{

  #include <math.h>
  #include <ctype.h>
  #include <stdio.h>
  #include <string.h>

  #define MAX_DEPTH 8192
  #define STORE_SIZE 1024
  #define ACCESS_TYPE_VALUE 0
  #define ACCESS_TYPE_POINTER 1
  #define ACCESS_TYPE_ADDRESS 2

  extern void yy_scan_string(char* string);
  extern int yydebug;
  extern int yylex (void);
  void yyerror (char const *);

  struct var_const_t {
      int index;
      int is_const;
      char* name;
      int sdepth;
      int offset;
      size_t size;
      int value;
      int align;
  };

  struct func_tab_t {
      int index;
      char* name;
      int sdepth;
      int offset;
      int size;
  };

  typedef struct var_const_t var_const_t;
  typedef struct func_tab_t func_tab_t;

  // lifecycle functions
  void inc_pc();

  // VarConstTab functions
  int adr(int i);
  int offset(int i);
  int sdepth(int i);

  // call functions
  void call(int i);
  void refparam(int i);
  void valparam(int i);
  void f_return(int i);
  void get_result(int i);

  // operators
  int binary_operator(char* op, int op1, int op2);

  var_const_t* var_const_tab;
  func_tab_t* func_tab;

  int pc;
  int* display;
  int depth;
  int newframe;
  int param;
  int heap;
  int* store;
  char** code_store;
%}

%code requires {
    struct var_reference_t {
        int index;
        int access_type;
    };
    struct array_reference_t {
        int var_index;
        int access_type;
        int array_index;
    };
    struct variable_reference_t {
        int adr;
        int is_address;
    };
}

%union {
    int number;
    char* string;
    struct var_reference_t var_reference;
    struct variable_reference_t variable_reference;
    struct array_reference_t array_reference;
}

%token OP_CALL
%token OP_REFPARAM
%token OP_VALPARAM
%token OP_GETRESULT
%token OP_RETURN
%token OP_FRETURN
%token OP_ASSIGNMENT
%token OP_GOTO
%token OP_NOOP
%token OP_NOT
%token COP_GR
%token COP_GEQ
%token COP_EQ
%token COP_LEQ
%token COP_LE
%token BEGIN_IF
%token ARRAY_INDICES
%token<string> CHAR_ADD
%token<string> CHAR_DIVIDE
%token<string> CHAR_MINUS
%token<string> CHAR_STAR
%token CHAR_LOGICAL_AND
%token CHAR_LOGICAL_OR
%token CHAR_AND
%token CHAR_INCREMENT
%token CHAR_DECREMENT
%token CHAR_SQUARE_BRACKET_LEFT
%token CHAR_SQUARE_BRACKET_RIGHT
%token<number> LITERAL_NUMBER
%token<string> LITERAL_NAME
%token LINE
%token WHITESPACE

%type<variable_reference> var_reference variable_reference value_assignment
%type<number> binary_assignment
%type<string> binary_operator
%%

statement:            assignment
                      | if_jump
                      | noop { inc_pc(); }
                      | call
                      | refparam
                      | valparam
                      | return
                      | freturn
                      | get_result
                      ;

assignment:           variable_reference space OP_ASSIGNMENT space binary_assignment  { store[$1.adr] = $5; inc_pc(); }
                      | variable_reference space OP_ASSIGNMENT space value_assignment { store[$1.adr] = ($5.is_address) ? $5.adr : store[$5.adr]; inc_pc(); }
                      ;

value_assignment:     variable_reference  { $$ = $1; }
                      ;

binary_assignment:    variable_reference space binary_operator space variable_reference { $$ = binary_operator($3, $1.adr, $5.adr); }
                      ;

binary_operator:      CHAR_ADD        { $$ = $1; }
                      | CHAR_STAR     { $$ = $1; }
                      | CHAR_DIVIDE   { $$ = $1; }
                      | CHAR_MINUS    { $$ = $1; }
                      ;

if_jump:              BEGIN_IF space variable_reference
                      space compare_operator space variable_reference
                      space OP_GOTO space label
                      ;

compare_operator:     COP_GR
                      | COP_LE
                      | COP_EQ
                      | COP_GEQ
                      | COP_LEQ
                      ;

variable_reference:   var_reference                 { $$ = $1; }
                      ;

var_reference:        LITERAL_NUMBER                { $$.adr = adr($1); }
                      | CHAR_STAR LITERAL_NUMBER    { $$.adr = store[adr($2)]; }
                      | CHAR_AND LITERAL_NUMBER     { $$.adr = adr($2); $$.is_address = 1; }
                      ;

//array_reference:      var_reference CHAR_SQUARE_BRACKET_LEFT var_reference CHAR_SQUARE_BRACKET_RIGHT
//                      ;

label:                LITERAL_NAME
                      ;

noop:                 OP_NOOP
                      ;

call:                 OP_CALL WHITESPACE LITERAL_NUMBER { call($3); }
                      ;

refparam:             OP_REFPARAM WHITESPACE LITERAL_NUMBER { refparam($3); }
                      ;

valparam:             OP_VALPARAM WHITESPACE LITERAL_NUMBER { valparam($3); }
                      ;

return:               OP_RETURN { f_return(-1); }
                      ;

freturn:              OP_FRETURN WHITESPACE LITERAL_NUMBER  { f_return($3); }
                      ;

get_result:           OP_GETRESULT WHITESPACE LITERAL_NUMBER { get_result($3); }
                      ;

space:                WHITESPACE
                      | ;

%%

void inc_pc(){
  pc++;
}

int align(int x, int alignment){
  return x + (x % alignment);
}

// var const tab functions

int adr(int i) {
  return offset(i) + display[sdepth(i)];
}

int sdepth(int i){
  return var_const_tab[i].sdepth;
}

int offset(int i){
  return var_const_tab[i].offset;
}

int size(int i){
  return var_const_tab[i].size;
}

int alignment(int i){
  return var_const_tab[i].align;
}

// func tab functions
int sdepth_func(int i){
  return func_tab[i].sdepth;
}

int size_func(int i){
  return func_tab[i].size;
}

int start(int i){
  return func_tab[i].offset;
}

// function call operations

void call(int i){
  inc_pc();

  store[newframe+4] = pc;
  store[newframe+8] = depth;

  depth = sdepth_func(i);
  store[newframe+12] = display[depth];

  display[depth] = newframe;
  newframe = newframe + size_func(i);

  param = newframe + 16;

  pc = start(i);
}

void refparam(int i){
  param = align(param, sizeof(int));
  store[param] = adr(i);
  param += 4;
  inc_pc();
}

void valparam(int i){
  param = align(param, alignment(i));

  for(int j = 0; i < size(i); i++){
    store[param+j] = store[adr(i) + j];
  }

  param += size(i);
  inc_pc();
}

void f_return(int i){
  newframe = display[depth];

  if(i >= 0){
    store[newframe] = store[adr(i)];
  }

  param = newframe + 16;

  display[depth] = store[newframe + 12];
  depth = store[newframe + 8];
  pc = store[newframe + 4];
}

void get_result(int i){
  store[adr(i)] = newframe;
  inc_pc();
}

// operators

int binary_operator(char * op, int adr1, int adr2){
  printf("binary op!");
  switch(op[0]){
    case '+':
      return store[adr1] + store[adr2];
    case '-':
      return store[adr1] - store[adr2];
    case '*':
      return store[adr1] * store[adr2];
    case '/':
      return store[adr1] / store[adr2];
    default:
      return 0;
  }
}

void init_machine(){
  pc = 0;
  depth = 0;
  display = (int*) malloc(sizeof(int) * MAX_DEPTH);
  newframe = 0;
  param = newframe + 16;
  heap = STORE_SIZE;
  store = (void*) malloc(sizeof(int) * STORE_SIZE);
}

void destroy_machine(){
  free(display);
  free(store);
}

char** read_lines(char* filename){
  FILE * fp;
  char *source_str;
  size_t source_size, program_size;

  fp = fopen (filename, "r");

  if (!fp) {
      printf("Failed to load %s\n", filename);
      return NULL;
  }

  fseek(fp, 0, SEEK_END);
  program_size = ftell(fp);
  rewind(fp);
  source_str = (char*)malloc(program_size + 1);
  source_str[program_size] = '\0';
  fread(source_str, sizeof(char), program_size, fp);
  fclose(fp);

  char** dest_string = (char**) malloc(sizeof(char) * STORE_SIZE);

  // split string by lines
  char delimiter[] = "\n";
  char *ptr;

  ptr = strtok(source_str, delimiter);

  int index = 0;
  while(ptr != NULL) {
    dest_string[index] = ptr;
    index++;
   	ptr = strtok(NULL, delimiter);
  }

  return dest_string;
}

void init_stack(int n){
  newframe = display[0];
  param = newframe + 16;
}

int main(int argc, char** argv){
  init_machine();
  code_store = read_lines("program.3ac");

  var_const_tab = (var_const_t*) malloc(sizeof(var_const_t) * 16);
  var_const_t tab0 = {0, 0, "a", 0, 16, 4, 0, 4};
  var_const_t tab1 = {1, 0, "b", 0, 20, 4, 0, 4};
  var_const_t tab2 = {2, 0, "c", 0, 24, 4, 0, 4};

  var_const_tab[0] = tab0;
  var_const_tab[1] = tab1;
  var_const_tab[2] = tab2;

  store[tab0.offset] = 10;
  store[tab1.offset] = 20;

  func_tab = (func_tab_t*) malloc(sizeof(func_tab_t) * 16);

  char* current_statement = code_store[pc];
  while(current_statement != NULL){
    printf("Interpretation of: %s\n", current_statement);
    yy_scan_string(current_statement);
    yyparse();
    current_statement = code_store[pc];
  }

  //printf("Storage of c: %d\n", store[tab2.offset]);

  destroy_machine();

  free(var_const_tab);
  free(func_tab);
  free(code_store);
}

/* Display error messages */
void yyerror(const char *s)
{
	printf("ERROR: %s\n", s);
}
