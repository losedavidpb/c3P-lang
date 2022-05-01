%{
  /*
    Syntax analyzer for variable expressions

    DESCRIPTION
      This analyzer allows variable declaration and assignation
      Each statement is declared at a single line, so if you want to
      specify multiple statements, it is necessary to include EOL.

    SYNTAX
      ./c3pbison C3P_FILE [...]

    AUTHOR
      losedavidpb (https://github.com/losedavidpb)
      HectorMartinAlvarez (https://github.com/HectorMartinAlvarez)
  */

  #include <stdio.h>
  #include <stdlib.h>
  #include <math.h>
  #include <string.h>
  #include <stdbool.h>

  extern int l_error;        // Specify if lexical errors were detected
  extern int num_lines;      // Number of lines processed

  extern FILE *yyin;         // Bison file to be checked
  
  int yydebug = 1;           // Enable this to active debug mode
  int s_error = 0;           // Specify if syntax errors were detected

  // This functions have to be declared in order to
  // avoid warnings related to implicit declaration
  int yylex(void);
  void yyerror(char *s);
%}

// __________ Data __________

%union {
    char * name_t;
    int integer_t;
    double double_t;
    char char_t;
    char * string_t;
    int bool_t;
    int type_t;
}

%token READONLY HIDE

%token <name_t> IDENTIFIER

%token <integer_t> INTEGER
%token <double_t> DOUBLE
%token <char_t> CHAR
%token <string_t> STRING
%token <integer_t> T
%token <integer_t> F

%token <type_t> INTEGER_TYPE
%token <type_t> DOUBLE_TYPE
%token <type_t> CHAR_TYPE
%token <type_t> STRING_TYPE
%token <type_t> BOOL_TYPE

%token AND OR NOT

%token EQUAL "=="
%token NOTEQUAL "!="
%token LESSEQUAL "<="
%token MOREEQUAL ">="
%token EOL

%type <double_t> expr_num
%type <bool_t> expr_bool
%type <char_t> expr_char;
%type <string_t> expr_string;
%type <integer_t> int_expr;

%left '+' '-'
%left '*' '/' '%'
%right '^'

%left '<' '>'
%left EQUAL NOTEQUAL
%left LESSEQUAL MOREEQUAL

%left AND OR
%right NOT

%left '(' ')' ':' ',' '[' ']' '{' '}'

%right '='

%start line

%%

line            : | EOL line | var line
                | error EOL { printf(" at expression\n"); } line
                ;

data_type       : INTEGER_TYPE | DOUBLE_TYPE
                | CHAR_TYPE | STRING_TYPE | BOOL_TYPE
                ;

arr_data_type   : INTEGER_TYPE '[' int_expr ']'
                | DOUBLE_TYPE '[' int_expr ']'
                | CHAR_TYPE '[' int_expr ']'
                | STRING_TYPE '[' int_expr ']'
                | BOOL_TYPE '[' int_expr ']'
                ;
                
list_expr       : expr_var
                | expr_var ',' list_expr
                ;

var            : IDENTIFIER ':' data_type                                           
               | IDENTIFIER ':' arr_data_type                                       
               | READONLY IDENTIFIER ':' data_type                                  
               | READONLY IDENTIFIER ':' arr_data_type                              
               | IDENTIFIER '=' expr_var
               | IDENTIFIER '[' int_expr ']' '=' expr_var
               | IDENTIFIER ':' data_type '=' expr_var                              
               | IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'
               | READONLY IDENTIFIER ':' data_type '=' expr_var
               | READONLY IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'
               | HIDE IDENTIFIER ':' data_type
               | HIDE IDENTIFIER ':' arr_data_type
               | HIDE IDENTIFIER ':' data_type '=' expr_var
               | HIDE IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'
               | HIDE READONLY IDENTIFIER ':' data_type
               | READONLY HIDE IDENTIFIER ':' data_type
               | HIDE READONLY IDENTIFIER ':' data_type '=' expr_var
               | HIDE READONLY IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'
               | READONLY HIDE IDENTIFIER ':' data_type '=' expr_var
               | READONLY HIDE IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'
               ;

expr_var       : expr_num
               | expr_bool
               | expr_char
               | expr_string
               ;

int_expr       : int_expr '+' int_expr                 { $$ = $1 + $3; }
               | int_expr '-' int_expr                 { $$ = $1 - $3; }
               | int_expr '*' int_expr                 { $$ = $1 * $3; }
               | int_expr '/' int_expr                 { $$ = $1 / $3; }
               | int_expr '%' int_expr                 { $$ = (int)fmod((double)$1, (double)$3); }
               | int_expr '^' int_expr                 { $$ = (int)pow((double)$1, (double)$3); }
               | '(' int_expr ')'                      { $$ = $2; }
               | INTEGER                               { $$ = $1; }
               ;

expr_num       : expr_num '+' expr_num                 { $$ = $1 + $3; }
               | expr_num '-' expr_num                 { $$ = $1 - $3; }
               | expr_num '*' expr_num                 { $$ = $1 * $3; }
               | expr_num '/' expr_num                 { $$ = $1 / $3; }
               | expr_num '%' expr_num                 { $$ = fmod($1, $3); }
               | expr_num '^' expr_num                 { $$ = pow($1, $3); }
               | expr_num '<' expr_num                 { $$ = $1 < $3; }
               | expr_num '>' expr_num                 { $$ = $1 > $3; }
               | expr_num EQUAL expr_num               { $$ = $1 == $3; }
               | expr_num NOTEQUAL expr_num            { $$ = $1 != $3; }
               | expr_num LESSEQUAL expr_num           { $$ = $1 <= $3; }
               | expr_num MOREEQUAL expr_num           { $$ = $1 >= $3; }
               | expr_num AND expr_num                 { $$ = $1 && $3; }
               | expr_num OR expr_num                  { $$ = $1 || $3; }
               | NOT expr_num                          { $$ = !$2; }
               | '(' expr_num ')'                      { $$ = $2; }
               | DOUBLE                                { $$ = $1; }
               | INTEGER                               { $$ = $1; }
               ;

expr_bool      : expr_bool EQUAL expr_bool             { $$ = $1 == $3; }
               | expr_bool NOTEQUAL expr_bool          { $$ = $1 != $3; }
               | expr_bool AND expr_bool               { $$ = $1 && $3; }
               | expr_bool OR expr_bool                { $$ = $1 || $3; }
               | NOT expr_bool                         { $$ = !$2; }
               | '(' expr_bool ')'                     { $$ = $2; }
               | T                                     { $$ = 1; }
               | F                                     { $$ = 0; }
               ;

expr_char      : expr_char '<' expr_char               { $$ = $1 < $3; }
               | expr_char '>' expr_char               { $$ = $1 > $3; }
               | expr_char EQUAL expr_char             { $$ = $1 == $3; }
               | expr_char NOTEQUAL expr_char          { $$ = $1 != $3; }
               | expr_char LESSEQUAL expr_char         { $$ = $1 <= $3; }
               | expr_char MOREEQUAL expr_char         { $$ = $1 >= $3; }
               | '(' expr_char ')'                     { $$ = $2; }
               | CHAR                                  { $$ = $1; }
               ;

expr_string    : expr_string '+' expr_string           { int len_result = strlen($1) + strlen($3);
                                                         char * res = (char*)(malloc(sizeof(char) * len_result));
                                                         if (res == NULL) yyerror("Not enought memory for malloc");
                                                         strcpy(res, $1); strcat(res, $3); $$ = res;
                                                       }
               | STRING                                { $$ = $1; }
               ;

%%

int main(int argc, char** argv)
{
  printf("var_c3pbison -- Syntax Analyzer\n");
  printf("======================================\n");

  for (int i = 1; i < argc; i++)
  {
    num_lines = 1;
    s_error = 0;
    l_error = 0;

    printf(" >> Analyzing syntax for %s ... ", argv[i]);
    yyin = fopen(argv[i], "r");
    yyparse();

    fclose(yyin);

    if (s_error == 0 && l_error == 0) printf("OK\n");
  }

  return 0;
}

void yyerror(char * mssg)
{
  s_error = 1;
  printf("%s at line %i\n", mssg, num_lines);
  exit(1);
}