%{
  // scanner.l
  //
  // This file is part of the c3P language compiler. This project
  // is free software; you can redistribute it and/or modify it under
  // the terms of the GNU General Public License
  //
  // This project is distributed in the hope that it will be useful,
  // but WITHOUT ANY WARRANTY; without even the implied warranty of
  // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  // GNU General Public License for more details.
  //
  // You should have received a copy of the GNU General Public License
  // If not, see <http://www.gnu.org/licenses/>.
  //

  /*
  *	Lexical analyzer for c3p language
  */

  #include "parser.tab.h"

  #include <ctype.h>
  #include "include/arrcopy.h"
  #include "include/assertb.h"
  #include "include/f_reader.h"

  // Uncomment this to enable development mode
  //#ifndef DEV_MODE
  //#define DEV_MODE
  //#endif

  // Get double value for passed string
  double get_double(const char *str);

  // Get integer value for passed string
  int get_int(const char *str);
%}

letter          [a-zA-Z]
digit           [0-9]
word            {letter}|{digit}|_
char_id 		{letter}|_
identifier      {char_id}{word}+|{letter}

char_type       c
bool_type       b

comment         \?.*

%option noyywrap
%option case-sensitive
%option nodefault

%%

i8                  	                		{ return I8_TYPE; }
i16                                  			{ return I16_TYPE; }
i32                                				{ return I32_TYPE; }
i64                                				{ return I64_TYPE; }
f32												{ return F32_TYPE; }
f64												{ return F64_TYPE; }
{char_type}                                     { return CHAR_TYPE; }
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

arrlen											{ return ARRLENGTH; }
proc                                            { return BEGIN_PROCEDURE; }
endproc                                         { return END_PROCEDURE; }
func                                            { return BEGIN_FUNCTION; }
endfunc                                         { return END_FUNCTION; }
ret                                             { return RETURN; }
call                                            { return CALL; }
show                                            { return SHOW; }
showln                                          { return SHOWLN; }

[():,\[\]{}]                                    { return yytext[0]; }
[\=\>\<]                                        { return yytext[0]; }

\'.?\'                                          { yylval.char_t = yytext[1]; return CHAR; }
\-?{digit}+                                     { yylval.integer_t = get_int(strcopy(yytext)); return INTEGER; }
\-?{digit}*\.{digit}+                           { yylval.double_t =  get_double(strcopy(yytext)); return DOUBLE; }
"T"                                             { yylval.integer_t = 1; return T; }
"F"                                             { yylval.integer_t = 0; return F; }

{identifier}                                    { yylval.string_t = strcopy(yytext); return IDENTIFIER; }

\n                                              { fr_next_line(); return EOL; }
{comment}                                       { /* ignore comments */ }
[[:space:]]|[[:space:]]+;                       { /* ignore spaces */ }

.                                               {
													#ifndef DEV_MODE
														show_errorf("lexical error: '%c'", yytext[0]);
													#endif
												}
<<EOF>>                                         { return EOF; }
%%

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
