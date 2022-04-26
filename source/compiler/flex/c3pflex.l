%{
  /*
    Lexical analyzer for c3P programming language.

    SYNTAX
      ./c3pflex C3P_FILE [...]

    PARAMETERS
      FLEX_FILE    Name of file that will be compilated
      C3P_FILE     Name of file that will be tested (you can add more files)

    AUTHOR
      losedavidpb (https://github.com/losedavidpb)
      HectorMartinAlvarez (https://github.com/HectorMartinAlvarez)
  */

  // Tokens defined with explicit number since Flex
  // will be executed independently

  #define READONLY              257
  #define HIDE                  258

  #define IDENTIFIER            259

  #define INTEGER               260
  #define FLOAT                 261
  #define BOOL                  262
  #define STRING                263
  #define CHAR                  264

  #define INTEGER_TYPE          265
  #define FLOAT_TYPE            266
  #define CHAR_TYPE             267
  #define STR_TYPE              268
  #define BOOL_TYPE             269

  #define NOT                   270

  #define BEGIN_IF              275
  #define END_IF                276
  #define ELSE_IF               277

  #define BEGIN_SWITCH          278
  #define END_SWITCH            279
  #define DEFAULT_SWITCH        280

  #define BEGIN_FOR             281
  #define END_FOR               282
  #define BEGIN_WHILE           283
  #define END_WHILE             284
  #define CONTINUE              285
  #define BREAK                 286

  #define LOGIC_OPERAND         287
  #define ARITMETHIC_OPERAND    288
  #define COMPARE_OPERAND       289

  #define BEGIN_PROCEDURE       291
  #define END_PROCEDURE         292
  #define BEGIN_FUNCTION        293
  #define END_FUNCTION          294
  #define RETURN                295
  #define CALL                  296
  
  #define ADD_LIBRARY           297
  #define PATH_ADD_LIBRARY      298

  int no_errors = 1;      // Specify if errors were detected
  int num_lines = 1;      // Number of lines processed

  // Show and error message at console
  void showerr(const char *mssg, int cod);
%}

letter          [a-zA-Z]
digit           [0-9]
word            {letter}|{digit}|_
identifier      {letter}{word}+|{letter}

integer_type    i8|i16|i32|i64
float_type      f32|f64
char_type       c
str_type        str
bool_type       b

comment         \?.*

%option noyywrap
%option case-sensitive
%option nodefault

%%

readonly                                        { return READONLY; }
hide                                            { return HIDE; }

{integer_type}                                  { return INTEGER_TYPE; }
{float_type}                                    { return FLOAT_TYPE; }
{char_type}                                     { return CHAR_TYPE; }
{str_type}                                      { return STR_TYPE; }
{bool_type}                                     { return BOOL_TYPE; }

if                                              { return BEGIN_IF; }
else                                            { return ELSE_IF; }
endif                                           { return END_IF; } 

switch                                          { return BEGIN_SWITCH; }
def                                             { return DEFAULT_SWITCH; }
endswitch                                       { return END_SWITCH; }

for                                             { return BEGIN_FOR; }
endfor                                          { return END_FOR; }
while                                           { return BEGIN_WHILE; }
endwhile                                        { return END_WHILE; }
continue                                        { return CONTINUE; }
break                                           { return BREAK; }

and|or                                          { return LOGIC_OPERAND; }
not                                             { return NOT; }
[\+\-\*\/\^\%]                                  { return ARITMETHIC_OPERAND; }
==|!=|<=|>=                                     { return COMPARE_OPERAND; }

proc                                            { return BEGIN_PROCEDURE; }
endproc                                         { return END_PROCEDURE; }
func                                            { return BEGIN_FUNCTION; }
endfunc                                         { return END_FUNCTION; }
ret                                             { return RETURN; } 
call                                            { return CALL; }

[():,\[\]{}]                                    { return yytext[0]; }
[\=\>\<]                                        { return yytext[0]; }

#add                                            { return ADD_LIBRARY; }

\".*\"                                          { return STRING; }
\'.?\'                                          { return CHAR; }
\-?{digit}+                                     { return INTEGER; }
\-?{digit}*\.{digit}+                           { return FLOAT; }
T|F                                             { return BOOL; }

{identifier}                                    { return IDENTIFIER; }

{identifier}(\.{identifier})*                   { return PATH_ADD_LIBRARY; }

\n                                              { num_lines++; }
{comment}                                       { /* ignore comments */ }
[[:space:]]|[[:space:]]+;                       { /* ignore spaces */ }

.                                               { char s[4]; sprintf(s, "'%c'", yytext[0]); showerr(s); }
<<EOF>>                                         { return 0; /* default */ }

%%

int main(int argc, char** argv)
{
  printf("c3pflex -- Lexical Analyzer\n");
  printf("===========================\n");

  for (int i = 1; i < argc; i++)
  {
    printf(" >> Analyzing lexic for %s ... ", argv[i]);

    int symbol = 1;
    yyin = fopen(argv[i], "r");

    while (symbol != 0)
      symbol = yylex();

    if (no_errors == 1)
      printf("OK\n");

    fclose(yyin);
  }
  
  return 0;
}

void showerr(const char *mssg)
{
  if (no_errors == 1) printf("BAD\n");
  no_errors = 0;
  printf("error: \"%s\" at line %i\n", mssg, num_lines);
}