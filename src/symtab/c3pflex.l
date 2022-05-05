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

  #include "../../include/arrcopy.h"
  #include "../../include/symt.h"
  #include "../../include/symt_cons.h"
  #include "../../include/symt_var.h"
  #include "../../include/symt_rout.h"
  #include "../../include/symt_node.h"

  #include <stdio.h>
  #include <stdlib.h>
  #include <ctype.h>

  int l_error = 0;        // Specify if errors were detected
  int num_lines = 1;      // Number of lines processed

  // Show and error message at console
  void showerr(const char *mssg, int cod);
  double get_double(const char *str);
  int get_int(const char *str);
%}

letter          [a-zA-Z]
digit           [0-9]
word            {letter}|{digit}|_
char_id 		{letter}|_
identifier      {char_id}{word}+|{letter}
word_path		{word}|\.
path			{word_path}+(\/{word_path}+)*

char_type       c
str_type        str
bool_type       b

comment         \?.*

%option noyywrap
%option case-sensitive
%option nodefault

%%

hide                                            { return HIDE; }

i8                  	                		{ return I8_TYPE; }
i16                                  			{ return I16_TYPE; }
i32                                				{ return I32_TYPE; }
i64                                				{ return I64_TYPE; }
f32												{ return F32_TYPE; }
f64												{ return F64_TYPE; }
{char_type}                                     { return CHAR_TYPE; }
{str_type}                                      { return STR_TYPE; }
{bool_type}                                     { return BOOL_TYPE; }

if                                              { return BEGIN_IF; }
else                                            { return ELSE_IF; }
endif                                           { return END_IF; }

while                                           { return BEGIN_WHILE; }
endwhile                                        { return END_WHILE; }
for												{ return BEGIN_FOR; }
endfor											{ return END_FOR; }
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

\".*\"                                          { yylval.string_t = strcopy(yytext); return STRING; }
\'.?\'                                          { yylval.char_t = yytext[1]; return CHAR; }
\-?{digit}+                                     { yylval.integer_t = get_int(strcopy(yytext)); return INTEGER; }
\-?{digit}*\.{digit}+                           { yylval.double_t =  get_double(strcopy(yytext)); return DOUBLE; }
"T"                                             { yylval.bool_t = 1; return T; }
"F"                                             { yylval.bool_t = 0; return F; }

{identifier}                                    { yylval.name_t = strcopy(yytext); return IDENTIFIER; }

\<{path}\>               						{yylval.name_t = strcopy(yytext); return PATH_ADD_LIBRARY; }

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

double get_double(const char *str)
{
    while (*str && !(isdigit(*str) || ((*str == '-' || *str == '+') && isdigit(*(str + 1))))) str++;
    return strtod(str, NULL);
}

int get_int(const char *str)
{
    while (*str && !(isdigit(*str) || ((*str == '-' || *str == '+') && isdigit(*(str + 1))))) str++;
    return (int)strtod(str, NULL);
}
