%{
  /*
    Lexical analyzer for c3P programming language
    to be executed with Bison implementation.

    WARNING
      Since this analyzer was designed to be executed with
      a Bison program, single execution would throw errors.

    AUTHOR
      losedavidpb (https://github.com/losedavidpb)
      HectorMartinAlvarez (https://github.com/HectorMartinAlvarez)
  */

  #include "c3pbison.tab.h"

  int l_error = 0;        // Specify if errors were detected
  int num_lines = 1;      // Number of lines processed

  // Show and error message at console
  void showerr(const char *mssg, int cod);
%}

letter          [a-zA-Z]
digit           [0-9]
word            {letter}|{digit}|_
identifier      {letter}{word}+|{letter}

integer_type    i8|i16|i32|i64
double_type     f32|f64
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
{double_type}                                   { return DOUBLE_TYPE; }
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

"and"                                           { return AND; }
"or"                                            { return OR; }
"not"                                           { return NOT; }
[\+\-\*\/\^\%]                                  { return yytext[0]; }

==                                              { return EQUAL; }
!=                                              { return NOTEQUAL; }
>=                                              { return MOREEQUAL; }
"<="                                            { return LESSEQUAL; }

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
\-?{digit}*\.{digit}+                           { return DOUBLE; }
"T"                                             { yylval.bool_t = 1; return T; }
"F"                                             { yylval.bool_t = 0; return F; }

{identifier}                                    { return IDENTIFIER; }

\<{identifier}(\.{identifier})*\>               { return PATH_ADD_LIBRARY; }

\n                                              { num_lines++; return EOL; }
{comment}                                       { /* ignore comments */ }
[[:space:]]|[[:space:]]+;                       { /* ignore spaces */ }

.                                               { char s[4]; sprintf(s, "'%c'", yytext[0]); showerr(s, 23); }
<<EOF>>                                         { return EOF; }
%%

void showerr(const char *mssg, int cod)
{
  l_error = 1;

  if (mssg == NULL || cod == -1)
    printf("lexical error: \"UNKOWN\" at line %i\n", num_lines);
  else
    printf("lexical error: \"%s\" at line %i (%i)\n", mssg, num_lines, cod);
}
