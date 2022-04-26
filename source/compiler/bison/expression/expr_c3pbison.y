%{
  /*
    Syntax analyzer for expressions

    DESCRIPTION
      This analyzer allows all types of expressions.
      Each expression is declared at a single line, so if you want to
      specify multiple expressions, it is necessary to include EOL.

    SYNTAX
      ./c3pbison C3P_FILE [...]

    AUTHOR
      losedavidpb (https://github.com/losedavidpb)
      HectorMartinAlvarez (https://github.com/HectorMartinAlvarez)
  */

  #include <stdio.h>
  #include <stdlib.h>
  #include <math.h>

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

%union { int integer_t; double double_t; }

%token <integer_t> INTEGER
%token <double_t> DOUBLE

%token AND OR NOT
%token T F

%token EQUAL "=="
%token NOTEQUAL "!="
%token LESSEQUAL "<="
%token MOREEQUAL ">="
%token EOL

%type <double_t> expr

%left '+' '-'
%left '*' '/' '%'
%right '^'
%left '(' ')'

%left '<' '>'
%left EQUAL NOTEQUAL
%left LESSEQUAL MOREEQUAL

%left AND OR
%right NOT

%start line

%%

line            : | EOL line | expr { printf("= %f ; ", $1); } line
                | error EOL { printf(" at expression\n"); } line
                ;

expr            : expr '+' expr                 { printf("+ "); $$ = $1 + $3; }
                | expr '-' expr                 { printf("- "); $$ = $1 - $3; }
                | expr '*' expr                 { printf("* "); $$ = $1 * $3; }
                | expr '/' expr                 { printf("/ "); $$ = $1 / $3; }
                | expr '%' expr                 { printf("%c ", '%'); $$ = fmod($1, $3); }
                | expr '^' expr                 { printf("^ "); $$ = pow($1, $3); }
                | expr '<' expr                 { printf("< "); $$ = $1 < $3; }
                | expr '>' expr                 { printf("> "); $$ = $1 > $3; }
                | expr EQUAL expr               { printf("== "); $$ = $1 == $3; }
                | expr NOTEQUAL expr            { printf("!= "); $$ = $1 != $3; }
                | expr LESSEQUAL expr           { printf("<= "); $$ = $1 <= $3; }
                | expr MOREEQUAL expr           { printf(">= "); $$ = $1 >= $3; }
                | expr AND expr                 { printf("and "); $$ = $1 && $3; }
                | expr OR expr                  { printf("or "); $$ = $1 || $3; }
                | NOT expr                      { printf("not "); $$ = !$2; }
                | '(' expr ')'                  { $$ = $2; }
                | T                             { printf("T "); $$ = 1; }
                | F                             { printf("F "); $$ = 0; }
                | DOUBLE                        { printf("%f ", $1); $$ = $1; }
                | INTEGER                       { printf("%d ", $1); $$ = $1; }    
                ;

%%

int main(int argc, char** argv)
{
  printf("expr_c3pbison -- Syntax Analyzer\n");
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
