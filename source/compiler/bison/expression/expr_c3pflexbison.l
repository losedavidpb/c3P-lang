%{
  /*
    Lexical analyzer for logical expressions

    WARNING
      Since this analyzer was designed to be executed with
      a Bison program, single execution would throw errors.
    
    AUTHOR
      losedavidpb (https://github.com/losedavidpb)
      HectorMartinAlvarez (https://github.com/HectorMartinAlvarez)
  */

  #include "expr_c3pbison.tab.h"

  int l_error = 0;        // Specify if errors were detected
  int num_lines = 1;      // Number of lines processed

  // Show and error message at console
  void showerr(const char *mssg);
%}

%option noyywrap
%option case-sensitive
%option nodefault

digit           [0-9]

%%

"and"                                           { return AND; }
"or"                                            { return OR; }
"not"                                           { return NOT; }

"T"                                             { return T; }
"F"                                             { return F; }

==                                              { return EQUAL; }
!=                                              { return NOTEQUAL; }
>=                                              { return MOREEQUAL; }
"<="                                            { return LESSEQUAL; }

[\>\<]                                          { return yytext[0]; }

[\+\-\*\/\^\%]                                  { return yytext[0]; }

[()]                                            { return yytext[0]; }

\-?{digit}+                                     { yylval.integer_t = atoi(yytext); return INTEGER; }
\-?{digit}*\.{digit}+                           { yylval.double_t = atof(yytext); return DOUBLE; }

\n                                              { num_lines++; return EOL; }
[[:space:]]|[[:space:]]+;                       { /* ignore spaces */ }

.                                               { char s[4]; sprintf(s, "'%c'", yytext[0]); showerr(s); }
<<EOF>>                                         { return 0; }
%%

void showerr(const char *mssg)
{
  l_error = 1;
  printf("lexical error: \"%s\" at line %i\n", mssg, num_lines);
}