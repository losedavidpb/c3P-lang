%{
  /*
    Lexical analyzer for variable expressions

    WARNING
      Since this analyzer was designed to be executed with
      a Bison program, single execution would throw errors.
    
    AUTHOR
      losedavidpb (https://github.com/losedavidpb)
      HectorMartinAlvarez (https://github.com/HectorMartinAlvarez)
  */

  #include "var_c3pbison.tab.h"

  int l_error = 0;        // Specify if errors were detected
  int num_lines = 1;      // Number of lines processed

  // Show and error message at console
  void showerr(const char *mssg);
%}

%option noyywrap
%option case-sensitive
%option nodefault

letter          [a-zA-Z]
digit           [0-9]
word            {letter}|{digit}|_
identifier      {letter}{word}+|{letter}

integer_type    i8|i16|i32|i64
double_type     f32|f64
bool_type       b
char_type       c
string_type     str

comment         \?.*

%%

readonly                                        { return READONLY; }
hide                                            { return HIDE; }

{integer_type}                                  { return INTEGER_TYPE; }
{double_type}                                   { return DOUBLE_TYPE; }
{bool_type}                                     { return BOOL_TYPE; }
{char_type}                                     { return CHAR_TYPE; }
{string_type}                                   { return STRING_TYPE; }

==                                              { return EQUAL; }
!=                                              { return NOTEQUAL; }
>=                                              { return MOREEQUAL; }
"<="                                            { return LESSEQUAL; }

[\=\>\<]                                        { return yytext[0]; }

[\+\-\*\/\^\%]                                  { return yytext[0]; }

[():,\[\]\{\}]                                  { return yytext[0]; }

\".*\"                                          { yylval.string_t = yytext; return STRING; }
\'.?\'                                          { yylval.char_t = yytext[0]; return CHAR; }
\-?{digit}+                                     { yylval.integer_t = atoi(yytext); return INTEGER; }
\-?{digit}*\.{digit}+                           { yylval.double_t = atof(yytext); return DOUBLE; }
"T"                                             { yylval.bool_t = 1; return T; }
"F"                                             { yylval.bool_t = 0; return F; }

{identifier}                                    { yylval.string_t = yytext; return IDENTIFIER; }

\n                                              { num_lines++; return EOL; }
{comment}                                       { /* ignore comments */ }
[[:space:]]|[[:space:]]+;                       { /* ignore spaces */ }

.                                               { char s[4]; sprintf(s, "'%c'", yytext[0]); showerr(s); }
<<EOF>>                                         { return 0; }
%%

void showerr(const char *mssg)
{
  l_error = 1;
  printf("lexical error: \"%s\" at line %i\n", mssg, num_lines);
}