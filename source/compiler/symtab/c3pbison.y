%{
	/*
		Syntax analyzer for c3P programming language
		using an external symbol table

		SYNTAX
	  		./c3pbison C3P_FILE [...]

		AUTHOR
	  		losedavidpb (https://github.com/losedavidpb)
	  		HectorMartinAlvarez (https://github.com/HectorMartinAlvarez)
  	*/

	#include <math.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#include "lib/assertb.h"
	#include "lib/copy.h"
	#include "lib/memlib.h"
	#include "symt.h"

	extern int l_error;	  // Specify if lexical errors were detected
	extern int num_lines; // Number of lines processed

	extern FILE *yyin; // Bison file to be checked

	int yydebug = 1; // Enable this to active debug mode
	int s_error = 0; // Specify if syntax errors were detected

	symt_tab *tab; // Table of symbol

	int array_length = 0;  // Array length for current token
	int array_type = 0;	   // Array data type for current token
	int variable_type = 0; // Variable data type for curren token
	void *value_list_expr; // Array value for current token

	// Return integer which is the equivalent token
	// at current symbol table
	int bison2symt_enum(int);

	// This functions have to be declared in order to
	// avoid warnings related to implicit declaration
	int yylex(void);
	void yyerror(const char *s);
%}

// __________ Data __________

%union
{
	char *name_t;
	int integer_t;
	double double_t;
	int bool_t;
	char *string_t;
	char char_t;
	int type_t;
	struct symt_node *node_t;
}

// __________ Tokens __________

%token READONLY HIDE

%token<name_t> IDENTIFIER

%token<integer_t> INTEGER
%token<double_t> DOUBLE
%token<char_t> CHAR
%token<string_t> STRING
%token<integer_t> T
%token<integer_t> F

%token<type_t> INTEGER_TYPE
%token<type_t> DOUBLE_TYPE
%token<type_t> CHAR_TYPE
%token<type_t> STR_TYPE
%token<type_t> BOOL_TYPE

%token BEGIN_IF END_IF ELSE_IF
%token BEGIN_SWITCH END_SWITCH DEFAULT_SWITCH

%token BEGIN_FOR END_FOR BEGIN_WHILE END_WHILE
%token CONTINUE BREAK

%token BEGIN_PROCEDURE END_PROCEDURE
%token BEGIN_FUNCTION END_FUNCTION
%token RETURN CALL

%token ADD_LIBRARY PATH_ADD_LIBRARY

%token AND OR NOT

%token EQUAL "=="
%token NOTEQUAL "!="
%token LESSEQUAL "<="
%token MOREEQUAL ">="

%token EOL

%type<double_t> expr_num;
%type<char_t> expr_char;
%type<string_t> expr_string;
%type<double_t> int_expr;

%type<node_t> statement;
%type<node_t> expr;
%type<node_t> in_var;
%type<node_t> var_assign;
%type<node_t> switch_case

// __________ Precedence __________

%left '+' '-'
%left '*' '/' '%'
%right '^'

%left '<' '>'
%left EQUAL NOTEQUAL
%left LESSEQUAL MOREEQUAL

%left AND OR
%right NOT

%right '='

%left '(' ')' ':' ',' '[' ']' '{' '}'

// __________ Config __________

%start init

%define parse.error verbose

%%

// __________ Expression __________

expr 			: expr_num		/*{
									double *value = doublecopy($1);
									symt_node* result = symt_new();
									result = symt_insert_const(result, " ", DOUBLE, value);
									$$ = result;
						  		}*/
				| expr_char		/*{
									char *value = strcopy($1);
						  			symt_node* result = symt_new();
						  			result = symt_insert_const(result, " ", CHAR, value);
						  			$$ = result;
								}*/
				| expr_string	/*{

								}*/;

int_expr 		: int_expr '+' int_expr 		{ $$ = $1 + $3; }
				| int_expr '-' int_expr 		{ $$ = $1 - $3; }
				| int_expr '*' int_expr 		{ $$ = $1 * $3; }
				| int_expr '/' int_expr 		{ $$ = $1 / $3; }
				| int_expr '%' int_expr 		{ $$ = (int)fmod((double)$1, (double)$3); }
				| int_expr '^' int_expr 		{ $$ = (int)pow((double)$1, (double)$3); }
				| '(' expr_num ')' 				{ $$ = $2; }
				| DOUBLE 						{ $$ = $1; }
				| INTEGER 						{ $$ = $1; }
				;

expr_num 		: expr_num '<' expr_num 		{ $$ = $1 < $3; }
				| expr_num '>' expr_num 		{ $$ = $1 > $3; }
				| expr_num EQUAL expr_num 		{ $$ = $1 == $3; }
				| expr_num NOTEQUAL expr_num 	{ $$ = $1 != $3; }
				| expr_num LESSEQUAL expr_num 	{ $$ = $1 <= $3; }
				| expr_num MOREEQUAL expr_num 	{ $$ = $1 >= $3; }
				| expr_num AND expr_num 		{ $$ = $1 && $3; }
				| expr_num OR expr_num 			{ $$ = $1 || $3; }
				| NOT expr_num 					{ $$ = !$2; }
				| int_expr | T 					{ $$ = 1; }
				| F 							{ $$ = 0; }
				;

expr_char 		: expr_char '+' expr_char 		{ $$ = $1 + $3; }
				| expr_char '-' expr_char 		{ $$ = $1 - $3; }
				| expr_char '*' expr_char 		{ $$ = $1 * $3; }
				| expr_char '/' expr_char 		{ $$ = $1 / $3; }
				| expr_char '%' expr_char 		{ $$ = (int)fmod((double)$1, (double)$3); }
				| expr_char '^' expr_char 		{ $$ = (int)pow((double)$1, (double)$3); }
				| expr_char '<' expr_char 		{ $$ = $1 < $3; }
				| expr_char '>' expr_char 		{ $$ = $1 > $3; }
				| expr_char EQUAL expr_char 	{ $$ = $1 == $3; }
				| expr_char NOTEQUAL expr_char 	{ $$ = $1 != $3; }
				| expr_char LESSEQUAL expr_char { $$ = $1 <= $3; }
				| expr_char MOREEQUAL expr_char { $$ = $1 >= $3; }
				| CHAR 							{ $$ = $1; }
				;

expr_string 	: expr_string '+' expr_string	{
													int len_result = strlen($1) + strlen($3);
													char *res = (char *)(malloc(sizeof(char) * len_result));
													if (res == NULL) yyerror("Not enought memory for malloc");
													strcpy(res, $1); strcat(res, $3); $$ = res;
												}
				| STRING		 				{ $$ = $1; }
				;

// __________ Constants and Data type __________

data_type 		: INTEGER_TYPE 					{ variable_type = bison2symt_enum($1); }
				| DOUBLE_TYPE 					{ variable_type = bison2symt_enum($1); }
				| CHAR_TYPE 					{ variable_type = bison2symt_enum($1); }
				| STR_TYPE 						{ variable_type = bison2symt_enum($1); }
				| BOOL_TYPE 					{ variable_type = bison2symt_enum($1); }
				;

arr_data_type 	: INTEGER_TYPE '[' int_expr ']' { array_length = $3; array_type = bison2symt_enum($1); }
				| DOUBLE_TYPE '[' int_expr ']'	{ array_length = $3; array_type = bison2symt_enum($1); }
				| CHAR_TYPE '[' int_expr ']'	{ array_length = $3; array_type = bison2symt_enum($1); }
				| STR_TYPE '[' int_expr ']'		{ array_length = $3; array_type = bison2symt_enum($1); }
				| BOOL_TYPE '[' int_expr ']'	{ array_length = $3; array_type = bison2symt_enum($1); }
				;

// __________ Declaration for variables __________

param_declr 	: IDENTIFIER ':' data_type
				| IDENTIFIER ':' INTEGER_TYPE '[' ']'
				| IDENTIFIER ':' DOUBLE_TYPE '[' ']'
				| IDENTIFIER ':' CHAR_TYPE '[' ']'
				| IDENTIFIER ':' STR_TYPE '[' ']'
				| IDENTIFIER ':' BOOL_TYPE '[' ']'
				| IDENTIFIER ':' INTEGER_TYPE '[' int_expr ']'
				| IDENTIFIER ':' DOUBLE_TYPE '[' int_expr ']'
				| IDENTIFIER ':' CHAR_TYPE '[' int_expr ']'
				| IDENTIFIER ':' STR_TYPE '[' int_expr ']'
				| IDENTIFIER ':' BOOL_TYPE '[' int_expr ']'
				;

// __________ Assignation for variables __________

var_assign 		: IDENTIFIER '=' expr
				| IDENTIFIER '[' int_expr ']' '=' expr
				;

// __________ Declaration and Assignation for variables __________

list_expr 		: expr
				| expr ',' list_expr
				;

ext_var 		: in_var
				| HIDE IDENTIFIER ':' data_type
				| HIDE IDENTIFIER ':' arr_data_type
				| HIDE IDENTIFIER ':' data_type '=' expr
				| HIDE IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'
				| HIDE READONLY IDENTIFIER ':' data_type
				| READONLY HIDE IDENTIFIER ':' data_type
				| HIDE READONLY IDENTIFIER ':' data_type '=' expr
				| HIDE READONLY IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'
				| READONLY HIDE IDENTIFIER ':' data_type '=' expr
				| READONLY HIDE IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'
				;

in_var 			: IDENTIFIER ':' data_type 											{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, LOCAL_VAR, $1, variable_type, 0, 0, NULL, 0, 0);
																					}
				| IDENTIFIER ':' arr_data_type										{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, LOCAL_VAR, $1, array_type, 1, array_length, NULL, 0, 0);
																					}
				| READONLY IDENTIFIER ':' arr_data_type								{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, LOCAL_VAR, $1, array_type, 1, array_length, NULL, 0, 1);
																					}
				| IDENTIFIER '=' expr												{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						assertp(var != NULL, "variable does not exist");
																						var->var->value = $3;
																					}
				| IDENTIFIER '[' expr ']' '=' expr									{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						assertp(var != NULL, "variable does not exist");
																						symt_node *expresion = (symt_node *)$3;
																						symt_node *new_value = (symt_node *)$6;
																						void *valor = symt_get_value_from_node(expresion);
																						void *new_valor = symt_get_value_from_node(new_value);
																						int *value_int;
																						double *value_double;
																						if (expresion->cons->type == INTEGER_)
																						{
																							value_int = (int *)valor;
																							assertp(value_int >= 0 && value_int < expresion->cons->array_length, "array index out of bounds");
																							assertp(new_value->var->type == INTEGER_, "type does not match");
																							int *array_int = (int *)var->var->value;
																							if (new_value->id == CALL_)
																							{
																								symt_call *value_call = (symt_call *)new_valor;
																								//*(array_int+value_int) = value_call;
																							}
																							else
																							{
																								int *new_array_int_valor = (int *)new_valor;
																								*(array_int + value_int) = new_array_int_valor;
																							}
																						}
																						else
																						{
																							value_double = (double *)valor;
																							assertp(value_double >= 0 && value_double < expresion->cons->array_length, "array index out of bounds");
																							assertp(new_value->var->type == DOUBLE_, "type does not match");
																							double *array_double = (double *)var->var->value;
																							if (new_value->id == CALL_)
																							{
																								symt_call *value_call = (symt_call *)new_valor;
																								//*(array_int+value_int) = value_call;
																							}
																							else
																							{
																								double *new_array_double_valor = (double *)new_valor;
																								*(array_double + value_double) = new_array_valor;
																							}
																						}
																						/*
																						switch(expresion->id){
																						  case CONSTANT:
																							  assertp(expresion->cons->type == INTEGER_ || expresion->cons->type == DOUBLE_, "invalid type");
																							  assertp(expresion->cons->type == var->var->type, "constant type does not match array type");
																							  int* value_int;
																							  double* value_double;
																							  if(expresion->cons->type == INTEGER_){
																								  value_int = (int*)expresion->cons->value;
																								  assertp(value_int >= 0 && value_int < expresion->cons->array_length, "array index out of bounds");
																								  int* array_int = (int*)var->var->value;
																								  *(array_int+value_int) =
																							  }else {
																								  value_double = (double*)expresion->cons->value;
																								  assertp(value_double >= 0 && value_double < expresion->cons->array_length, "array index out of bounds");
																								  double* array_double = (double*)var->var->value;
																							  }
																							  break;
																						  case LOCAL_VAR:
																						  case GLOBAL_VAR:

																							  break;
																						  case CALL_:

																							  break;
																						}*/
																					}
				| IDENTIFIER ':' data_type '=' expr									{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, LOCAL_VAR, $1, variable_type, 0, 0, $5, 0, 0);
																					}
				| READONLY IDENTIFIER ':' data_type									{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, LOCAL_VAR, $1, variable_type, 0, 0, NULL, 0, 1);
																					}
				| IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'				{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, LOCAL_VAR, $1, array_type, 1, array_length, NULL, 0, 0);
																						var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						assertp(var != NULL, "variable does not exist");
																						assertp(var->var->type == array_type, "type does not match");
																						var->var->value = value_list_expr;
																					}
				| READONLY IDENTIFIER ':' data_type '=' expr
																					{
																						symt_node *var;
																						var = symt_search_by_name(tab, $2, LOCAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, LOCAL_VAR, $2, variable_type, 0, 0, $6, 0, 1);
																					}
				| READONLY IDENTIFIER ':' data_type									{
																						symt_node *var;
																						var = symt_search_by_name(tab, $2, LOCAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, LOCAL_VAR, $2, variable_type, 0, 0, NULL, 0, 1);
																					}
				| READONLY IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'		{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, LOCAL_VAR, $1, array_type, 1, array_length, NULL, 0, 1);
																						var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						assertp(var != NULL, "variable does not exist");
																						assertp(var->var->type == array_type, "type does not match");
																						var->var->value = value_list_expr;
																					}
				;

// __________ Procedures and functions __________

func_declr 		: BEGIN_FUNCTION IDENTIFIER ':' data_type '(' declr_params ')' EOL statement END_FUNCTION
				| HIDE BEGIN_FUNCTION IDENTIFIER ':' data_type '(' declr_params ')' EOL statement END_FUNCTION
				;

proc_declr 		: BEGIN_PROCEDURE IDENTIFIER '(' declr_params ')' EOL statement END_PROCEDURE
				| HIDE BEGIN_PROCEDURE IDENTIFIER '(' declr_params ')' EOL statement END_PROCEDURE
				;

// __________ Parameters __________

declr_params 	: | param_declr ',' declr_params
				| param_declr
				;

// __________ Call a function __________

call_func 		: CALL IDENTIFIER
				| CALL IDENTIFIER list_expr
				;

// __________ Add libraries __________

add_libraries 	: ADD_LIBRARY PATH_ADD_LIBRARY EOL add_libraries
				| ADD_LIBRARY PATH_ADD_LIBRARY EOL;

// __________ Switch case __________

switch_case 	: EOL switch_case
				| expr ':' EOL statement BREAK EOL switch_case
				| DEFAULT_SWITCH ':' EOL statement BREAK EOL more_EOL
				;

more_EOL 		: | EOL more_EOL;

// __________ Statement __________

statement 		: | in_var EOL statement
				| BEGIN_IF '(' expr ')' EOL statement break_rule more_else END_IF EOL statement
				| BEGIN_WHILE '(' expr ')' EOL statement break_rule END_WHILE EOL statement
				| BEGIN_FOR '(' in_var ',' expr ',' var_assign ')' EOL statement break_rule				{
																											symt_node *cond = (symt_node *)(ml_malloc(sizeof(symt_node)));
																											cond = (symt_node *)$5;
																											symt_node *statement = (symt_node *)(ml_malloc(sizeof(symt_node)));
																											statement = (symt_node *)$10;
																											symt_node *iter_var = (symt_node *)(ml_malloc(sizeof(symt_node)));
																											iter_var = (symt_node *)$3;
																											symt_node *iter_op = (symt_node *)(ml_malloc(sizeof(symt_node)));
																											iter_op = (symt_node *)$7;
																											tab = symt_insert_for(tab, cond, statement, iter_var, iter_op);
																										} END_FOR { symt_end_block(tab, FOR); } EOL statement
				| BEGIN_SWITCH '(' IDENTIFIER ')' EOL switch_case										{
																											symt_node *var;
																											var = symt_search_by_name(tab, $3, GLOBAL_VAR);
																											if (var == NULL) var = symt_search_by_name(tab, $3, LOCAL_VAR);
																											assertp(var != NULL, "variable does not exist");
																											symt_node *casos = (symt_node *)(ml_malloc(sizeof(symt_node)));
																											casos = (symt_node *)$6;
																											tab = symt_insert_switch(tab, var, casos, 0);
																										} END_SWITCH { symt_end_block(tab, SWITCH); } EOL statement
				| call_func EOL statement
				| RETURN expr EOL statement
				| CONTINUE EOL statement
				| EOL statement
				| error EOL { printf(" at expression\n"); } statement
				;

more_else 		: | ELSE_IF EOL statement break_rule
				| ELSE_IF BEGIN_IF '(' expr ')' EOL statement break_rule more_else
				;

break_rule 		: | BREAK EOL statement
				;

// __________ Main program __________

init 			: program
				| add_libraries program
				;

program 		: | ext_var program
				| func_declr program
				| proc_declr program
				| EOL program
				;

%%

int main(int argc, char **argv)
{
	printf("c3psymt -- Better Syntax Analyzer\n");
	printf("=================================\n");

	for (int i = 1; i < argc; i++)
	{
		tab = symt_new();
		num_lines = 1;
		s_error = 0;
		l_error = 0;

		printf(" >> Analyzing syntax for %s ... ", argv[i]);
		yyin = fopen(argv[i], "r");
		yyparse();

		fclose(yyin);

		if (s_error == 0 && l_error == 0)
			printf("OK\n");
		symt_delete(tab);
	}

	return 0;
}

void yyerror(const char *mssg)
{
	s_error = 1;
	printf("%s at line %i\n", mssg, num_lines);
	exit(1);
}

int bison2symt_enum(int value)
{
	switch (value)
	{
		case INTEGER: return INTEGER_; 	break;
		case DOUBLE: return DOUBLE_; 	break;
		case CHAR: return CHAR_; 		break;
		case CALL: return CALL_; 		break;
		default: return -1; 			break;
	}
}
