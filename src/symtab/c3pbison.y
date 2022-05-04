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

	#include "../../include/symt.h"
	#include "../../include/symt_cons.h"
	#include "../../include/symt_var.h"
  	#include "../../include/symt_rout.h"
  	#include "../../include/symt_node.h"
	#include "../../include/assertb.h"
	#include "../../include/arrcopy.h"
	#include "../../include/memlib.h"

	extern int l_error;	  			// Specify if lexical errors were detected
	extern int num_lines; 			// Number of lines processed

	extern FILE *yyin; 				// Bison file to be checked

	int yydebug = 1; 				// Enable this to active debug mode
	int s_error = 0; 				// Specify if syntax errors were detected

	symt_level_t level = 0;			// Current level of symbol table
	symt_tab *tab; 					// Symbol table

	symt_cons_t type;				// Type of a value
	int array_length = 0;  			// Array length for current token
	void *value_list_expr; 			// Array value for current token
	symt_cons_t value_list_expr_t;	// Constant for a part of a list expression

	symt_name_t rout_name;

	// Structure of a stack of void values
	typedef struct Stack {
		char *name;
		void* value;
		symt_var_t type;
		struct Stack *next_value;
	} Stack;

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
	struct Stack *stack;
}

// __________ Tokens __________

%token HIDE

%token<name_t> IDENTIFIER

%token<integer_t> INTEGER
%token<double_t> DOUBLE
%token<char_t> CHAR
%token<string_t> STRING
%token<integer_t> T F

%token<type_t> I8_TYPE I16_TYPE I32_TYPE I64_TYPE
%token<type_t> F32_TYPE F64_TYPE
%token<type_t> CHAR_TYPE STR_TYPE
%token<type_t> BOOL_TYPE

%token BEGIN_IF END_IF ELSE_IF
%token BEGIN_SWITCH END_SWITCH DEFAULT_SWITCH
%token BEGIN_FOR END_FOR BEGIN_WHILE END_WHILE CONTINUE BREAK
%token BEGIN_PROCEDURE END_PROCEDURE BEGIN_FUNCTION END_FUNCTION RETURN CALL
%token ADD_LIBRARY PATH_ADD_LIBRARY
%token AND OR NOT

%token EQUAL "=="
%token NOTEQUAL "!="
%token LESSEQUAL "<="
%token MOREEQUAL ">="

%token EOL

%type<integer_t> data_type arr_data_type;
%type<node_t> expr_num expr_char expr_string int_expr expr;
// %type<node_t> var_assign param_declr;
%type<stack> list_expr;
%type<integer_t> statement more_else break_rule;

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

expr 			: expr_num		{ $$ = $1; }
				| expr_char		{ $$ = $1; }
				| expr_string	{ $$ = $1; }
				;

int_expr 		: int_expr '+' int_expr 		{
													type = CONS_INTEGER;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons* res_cons = symt_cons_add(CONS_INTEGER, num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| int_expr '-' int_expr 		{
													type = CONS_INTEGER;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons* res_cons = symt_cons_sub(CONS_INTEGER, num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| int_expr '*' int_expr 		{
													type = CONS_INTEGER;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons* res_cons = symt_cons_mult(CONS_INTEGER, num1->cons, num2->cons);
													symt_delete_node(num1); symt_delete_node(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| int_expr '/' int_expr 		{
													type = CONS_INTEGER;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons* res_cons = symt_cons_div(CONS_INTEGER, num1->cons, num2->cons);
													symt_delete_node(num1); symt_delete_node(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| int_expr '%' int_expr 		{
													type = CONS_INTEGER;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons* res_cons = symt_cons_mod(CONS_INTEGER, num1->cons, num2->cons);
													symt_delete_node(num1); symt_delete_node(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| int_expr '^' int_expr 		{
													type = CONS_INTEGER;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons* res_cons = symt_cons_pow(CONS_INTEGER, num1->cons, num2->cons);
													symt_delete_node(num1); symt_delete_node(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| '(' expr_num ')' 				{ $$ = $2; }
				| DOUBLE 						{
													type = CONS_DOUBLE;
													symt_node *result = symt_new();
													result = symt_insert_tab_cons(result, CONS_DOUBLE, &$1);
													$$ = result;
												}
				| INTEGER 						{
													type = CONS_INTEGER;
													symt_node *result = symt_new();
													result = symt_insert_tab_cons(result, CONS_INTEGER, &$1);
													$$ = result;
												}
				| IDENTIFIER					{
													symt_node *var = symt_search_by_name(tab, $1, VAR, NULL, level);
													assertf(var != NULL, "variable %s has not been declared at line ", $1);

													symt_node *result = symt_new();
													result = symt_insert_tab_cons(result, symt_get_type_data(var->var->type), var->var->value);
													$$ = result;
												}
				;

expr_num 		: expr_num '<' expr_num 		{
													type = CONS_BOOL;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons *res_cons = symt_cons_lt(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr_num '>' expr_num 		{
													type = CONS_BOOL;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons *res_cons = symt_cons_gt(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr_num EQUAL expr_num 		{
													type = CONS_BOOL;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons *res_cons = symt_cons_eq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr_num NOTEQUAL expr_num 	{
													type = CONS_BOOL;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons *res_cons = symt_cons_neq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr_num LESSEQUAL expr_num 	{
													type = CONS_BOOL;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons *res_cons = symt_cons_leq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr_num MOREEQUAL expr_num 	{
													type = CONS_BOOL;
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													symt_cons *res_cons = symt_cons_geq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr_num AND expr_num 		{
													type = CONS_BOOL;
													symt_node* num1 = (symt_node*)$1;
													symt_node* num2 = (symt_node*)$3;
													int value1_int = *((int*)num1->cons->value);
													int value2_int = *((int*)num2->cons->value);
													int result = value1_int && value2_int;

													symt_node *result_n = symt_new();
													result_n = symt_insert_tab_cons(result_n, CONS_INTEGER, &result);
													symt_delete(num1); symt_delete(num2);
													$$ = result_n;
				 								}
				| expr_num OR expr_num 			{
													type = CONS_BOOL;
													symt_node* num1 = $1;
													symt_node* num2 = $3;
													int value1_int = *((int*)num1->cons->value);
													int value2_int = *((int*)num2->cons->value);
													int result = value1_int || value2_int;

													symt_node *result_n = symt_new();
													result_n = symt_insert_tab_cons(result_n, CONS_INTEGER, &result);
													symt_delete(num1); symt_delete(num2);
													$$ = result_n;
												}
				| NOT expr_num 					{
													type = CONS_BOOL;
													symt_node* num1 = (symt_node*)$2;
													int value1 = *((int*)num1->cons->value);
													int result = !value1;

													symt_node *res_cons = symt_new();
													res_cons = symt_insert_tab_cons(res_cons, CONS_INTEGER, &result);
													symt_delete(num1);
													$$ = res_cons;
												}
				| int_expr 						{ $$ = $1; }
				| T 							{
													type = CONS_BOOL;
													int true_val = 1;
													symt_node *res_cons = symt_new();
													res_cons = symt_insert_tab_cons(res_cons, CONS_INTEGER, &true_val);
													$$ = res_cons;
												}
				| F 							{
													type = CONS_BOOL;
													int false_val = 0;
													symt_node *res_cons = symt_new();
													res_cons = symt_insert_tab_cons(res_cons, CONS_INTEGER, &false_val);
													$$ = res_cons;
												}
				;

expr_char       : expr_char '+' expr_char       {
													type = CONS_CHAR;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_add(CONS_CHAR , num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | expr_char '-' expr_char       {
													type = CONS_CHAR;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_sub(CONS_CHAR , num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | expr_char '*' expr_char       {
													type = CONS_CHAR;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_mult(CONS_CHAR , num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | expr_char '/' expr_char       {
													type = CONS_CHAR;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_div(CONS_CHAR , num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | expr_char '%' expr_char       {
													type = CONS_CHAR;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_mod(CONS_CHAR , num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | expr_char '^' expr_char       {
													type = CONS_CHAR;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_pow(CONS_CHAR , num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | expr_char '<' expr_char       {
													type = CONS_BOOL;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_lt(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | expr_char '>' expr_char       {
													type = CONS_BOOL;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_gt(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | expr_char EQUAL expr_char     {
													type = CONS_BOOL;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_eq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | expr_char NOTEQUAL expr_char  {
													type = CONS_BOOL;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_neq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | expr_char LESSEQUAL expr_char {
													type = CONS_BOOL;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_leq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | expr_char MOREEQUAL expr_char {
													type = CONS_BOOL;
                                                    symt_node* num1 = (symt_node*)$1;
                                                    symt_node* num2 = (symt_node*)$3;
                                                    symt_cons *res_cons = symt_cons_geq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
                                                }
                | CHAR                          {
													type = CONS_CHAR;
                                                    symt_node *result = symt_new();
													result = symt_insert_tab_cons(result, CONS_CHAR, &$1);
													$$ = result;
                                                }
                ;

expr_string 	: expr_string '+' expr_string	{
													type = CONS_STR;
													symt_node *str1 = (symt_node*)$1;
													symt_node *str2 = (symt_node*)$3;

													int len_result = strlen((char*)str1->cons->value); strlen((char*)str2->cons->value);
													char *res = (char *)(ml_malloc(sizeof(char) * len_result));
													strcpy(res, (char*)str1->cons->value); strcat(res, (char*)str2->cons->value);
													symt_delete(str1); symt_delete(str2);

													symt_node *result = symt_new();
													result = symt_insert_tab_cons(result, CONS_STR, $1);
													$$ = result;
												}
				| STRING		 				{
													type = CONS_STR;
													symt_node *result = symt_new_node();
													result = symt_insert_tab_cons(result, CONS_STR, $1);
													$$ = result;
												}
				;

// __________ Constants and Data type __________

data_type 		: I8_TYPE 						{ $$ = I8; 	}
				| I16_TYPE 						{ $$ = I16; }
				| I32_TYPE 						{ $$ = I32; }
				| I64_TYPE 						{ $$ = I64; }
				| F32_TYPE 						{ $$ = F32; }
				| F64_TYPE 						{ $$ = F64; }
				| CHAR_TYPE 					{ $$ = C; 	}
				| STR_TYPE 						{ $$ = STR; }
				| BOOL_TYPE 					{ $$ = B; 	}
				;

arr_data_type 	: I8_TYPE '[' int_expr ']'    	{
													value_list_expr_t = CONS_INTEGER;
													symt_node *node = (symt_node*)$3;
													array_length = *((int*)node->cons->value);
													$$ = I8;
												}
				| I16_TYPE '[' int_expr ']' 	{
													value_list_expr_t = CONS_INTEGER;
													symt_node *node = (symt_node*)$3;
													array_length = *((int*)node->cons->value);
													$$ = I16;
												}
				| I32_TYPE '[' int_expr ']'		{
													value_list_expr_t = CONS_INTEGER;
													symt_node *node = (symt_node*)$3;
													array_length = *((int*)node->cons->value);
													$$ = I32;
												}
				| I64_TYPE '[' int_expr ']'		{
													value_list_expr_t = CONS_INTEGER;
													symt_node *node = (symt_node*)$3;
													array_length = *((int*)node->cons->value);
													$$ = I64;
												}
				| F32_TYPE '[' int_expr ']'		{
													value_list_expr_t = CONS_DOUBLE;
													symt_node *node = (symt_node*)$3;
													array_length = *((int*)node->cons->value);
													$$ = F32;
												}
				| F64_TYPE '[' int_expr ']'		{
													value_list_expr_t = CONS_DOUBLE;
													symt_node *node = (symt_node*)$3;
													array_length = *((int*)node->cons->value);
													$$ = F64;
												}
				| CHAR_TYPE '[' int_expr ']'	{
													value_list_expr_t = CONS_CHAR;
													symt_node *node = (symt_node*)$3;
													array_length = *((int*)node->cons->value);
													$$ = C;
												}
				| BOOL_TYPE '[' int_expr ']'	{
													value_list_expr_t = CONS_INTEGER;
													symt_node *node = (symt_node*)$3;
													array_length = *((int*)node->cons->value);
													$$ = B;
												}
				;

// __________ Declaration for variables __________

param_declr 	: IDENTIFIER ':' data_type							{
																		symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																		assertf(var == NULL, "variable %s has already been declared", $1);

																		symt_node* node = symt_new();
																		node = symt_insert_tab_var(node, $1, rout_name, $3, 0, 0, NULL, 0, true, level);
																		tab = symt_push(tab, node);
																		symt_print(tab);
																	}
				| IDENTIFIER ':' I8_TYPE '[' ']'					{
																		symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																		assertf(var == NULL, "variable %s has already been declared", $1);

																		symt_node* node = symt_new();
																		node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, true, level);
																		tab = symt_push(tab, node);
																		symt_print(tab);
																	}
				| IDENTIFIER ':' I16_TYPE '[' ']'					{
																		symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																		assertf(var == NULL, "variable %s has already been declared", $1);

																		symt_node* node = symt_new();
																		node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, true, level);
																		tab = symt_push(tab, node);
																		symt_print(tab);
																	}
				| IDENTIFIER ':' I32_TYPE '[' ']'					{
																		symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																		assertf(var == NULL, "variable %s has already been declared", $1);

																		symt_node* node = symt_new();
																		node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, true, level);
																		tab = symt_push(tab, node);
																		symt_print(tab);
																	}
				| IDENTIFIER ':' I64_TYPE '[' ']'					{
																		symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																		assertf(var == NULL, "variable %s has already been declared", $1);

																		symt_node* node = symt_new();
																		node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, true, level);
																		tab = symt_push(tab, node);
																		symt_print(tab);
																	}
				| IDENTIFIER ':' F32_TYPE '[' ']'					{
																		symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																		assertf(var == NULL, "variable %s has already been declared", $1);

																		symt_node* node = symt_new();
																		node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, true, level);
																		tab = symt_push(tab, node);
																		symt_print(tab);
																	}
				| IDENTIFIER ':' F64_TYPE '[' ']'					{
																		symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																		assertf(var == NULL, "variable %s has already been declared", $1);

																		symt_node* node = symt_new();
																		node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, true, level);
																		tab = symt_push(tab, node);
																		symt_print(tab);
																	}
				| IDENTIFIER ':' CHAR_TYPE '[' ']'					{
																		symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																		assertf(var == NULL, "variable %s has already been declared", $1);

																		symt_node* node = symt_new();
																		node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, true, level);
																		tab = symt_push(tab, node);
																		symt_print(tab);
																	}
				| IDENTIFIER ':' BOOL_TYPE '[' ']'					{
																		symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																		assertf(var == NULL, "variable %s has already been declared", $1);

																		symt_node* node = symt_new();
																		node = symt_insert_tab_var(node, $1, rout_name,	 $3, 1, -1, NULL, 0, true, level);
																		tab = symt_push(tab, node);
																		symt_print(tab);
																	}
				;

// __________ Assignation for variables __________

var_assign      : IDENTIFIER '=' expr								{
																		symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																		assertf(var != NULL, "variable %s has not been declared", $1);

																		symt_node *value = (symt_node *)$3;
																		symt_assign_var(var->var, value->cons);
																		//$$ = var;
																		symt_print(tab);
																	}
                | IDENTIFIER '[' int_expr ']' '=' expr				{
																		symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																		assertf(var != NULL, "variable %s has not been declared", $1);
																		symt_node *index = (symt_node*)$3;
																		symt_node *value = (symt_node*)$6;

																		symt_assign_var_at(var->var, value->cons, *((int*)index->cons->value));
																		//$$ = var;
																		symt_print(tab);
																	}
                ;

// __________ Declaration and Assignation for variables __________

list_expr 		: expr					{
											struct Stack stack;
											symt_node* node = (symt_node*)$1;
											stack.name = symt_get_name_from_node(node);
											stack.value = symt_get_value_from_node(node);
											stack.type = type;
											stack.next_value = NULL;
											$$ = &stack;
										}
				| expr ',' list_expr	{
											Stack *right_stack = (Stack*)$3;
											Stack* stack = (Stack *)(ml_malloc(sizeof(Stack)));
											symt_node* node = (symt_node*)$1;
											stack->name = symt_get_name_from_node(node);
											stack->value = symt_get_value_from_node(node);
											stack->type = type;
											stack->next_value = (Stack *)$3;
											$$ = stack;
										}
				;

ext_var 		: in_var
				| HIDE IDENTIFIER ':' data_type										{
																						symt_node *var = symt_search_by_name(tab, $2, VAR, NULL, level);
																						assertf(var == NULL, "variable %s has already been declared", $2);

																						var = symt_insert_var($2, NULL, $4, 0, 0, NULL, 1, false, level);
																						tab = symt_push(tab, var);
																						symt_print(tab);
																					}
				| HIDE IDENTIFIER ':' arr_data_type									{
																						symt_node *var = symt_search_by_name(tab, $2, VAR, NULL, level);
																						assertf(var == NULL, "variable %s has already been declared", $2);

																						var = symt_insert_var($2, NULL, $4, 1, array_length, NULL, 1, false, level);
																						tab = symt_push(tab, var);
																						symt_print(tab);
																					}
				| HIDE IDENTIFIER ':' data_type '=' expr							{
																						symt_node *var = symt_search_by_name(tab, $2, VAR, NULL, level);
																						assertf(var == NULL, "variable %s has already been declared", $2);

																						var = symt_insert_var($2, NULL, $4, 0, 0, NULL, 1, false, level);

																						symt_node *value = (symt_node *)$6;
																						symt_assign_var(var->var, value->cons);
																						tab = symt_push(tab, var);
																						symt_print(tab);
																					}
				| HIDE IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'			{
																						symt_node *var = symt_search_by_name(tab, $2, VAR, NULL, level);
																						assertf(var == NULL, "variable %s has already been declared", $2);

																						var = symt_insert_var($2,NULL, $4, 0, 0, NULL, 1, false, level);
																						tab = symt_push(tab, var);

																						var = symt_search_by_name(tab, $2, VAR, NULL, level);
																						assertf(var != NULL, "variable %s has not been declared", $2);

																						char *str_type_1 = symt_strget_vartype(var->var->type);
																						char *str_type_2 = symt_strget_vartype($4);
																						assertf(var->var->type == $4, "type %s does not match %s at %s variable declaration", str_type_1, str_type_2, $2);

																						struct Stack *pila = $7;
																						struct Stack *valores_pila = $7;
																						int *zero = (int *)(ml_malloc(sizeof(int)));

																						switch(value_list_expr_t)
																						{
																							case CONS_INTEGER:;
																								int *zero_int = (int *)(ml_malloc(sizeof(int)));
																								int* value_int = (int*)value_list_expr;

																								for(int i = 0; i < array_length; i++)
																								{
																									symt_cons* constate = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																									constate->type = value_list_expr_t;

																									if(pila) constate->value = pila->value;
																									else constate->value = (void*)zero_int;

																									symt_can_assign(var->var->type, constate);
																									if(pila) pila = pila->next_value;
																									ml_free(constate);
																								}

																								int *valores_int = (int *)(ml_malloc(sizeof(int)*array_length));

																								for(int i = 0; valores_pila; i++)
																								{
																									*(valores_int+i) = *((int*)valores_pila->value);
																									valores_pila = valores_pila->next_value;
																								}

																								var->var->value = (void*)valores_int;
																							break;

																							case CONS_DOUBLE:;
																								double *zero_double = (double *)(ml_malloc(sizeof(double)));
																								double* value_double = (double*)value_list_expr;

																								for(int i = 0; i < array_length; i++)
																								{
																									symt_cons* constate = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																									constate->type = value_list_expr_t;

																									if(pila) constate->value = pila->value;
																									else constate->value = (void*)zero;

																									symt_can_assign(var->var->type, constate);
																									if(pila) pila = pila->next_value;
																									ml_free(constate);
																								}

																								double *valores_double = (double *)(ml_malloc(sizeof(double)*array_length));

																								for(int i = 0; valores_pila; i++)
																								{
																									*(valores_double+i) = *((double*)valores_pila->value);
																									valores_pila = valores_pila->next_value;
																								}

																								var->var->value = (void*)valores_double;
																							break;

																							case CONS_CHAR:;
																								char *zero_char = (char *)(ml_malloc(sizeof(char)));
																								char* value_char = (char*)value_list_expr;

																								for(int i = 0; i < array_length; i++)
																								{
																									symt_cons* constate = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																									constate->type = value_list_expr_t;

																									if(pila) constate->value = pila->value;
																									else constate->value = (void*)zero_char;

																									symt_can_assign(var->var->type, constate);
																									if(pila) pila = pila->next_value;
																									ml_free(constate);
																								}

																								char *valores_char = (char *)(ml_malloc(sizeof(char)*array_length));

																								for(int i = 0; valores_pila; i++)
																								{
																									*(valores_char+i) = *((char*)valores_pila->value);
																									valores_pila = valores_pila->next_value;
																								}

																								var->var->value = (void*)valores_char;
																							break;
																						}

																						symt_print(tab);
																					}
				;

in_var 			: IDENTIFIER ':' data_type 											{
																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var == NULL, "variable %s has already been declared", $1);

																						symt_node* node = symt_new();
																						node = symt_insert_tab_var(node, $1, rout_name,  $3, 0, 0, NULL, 0, false, level);
																						tab = symt_push(tab, node);
																						symt_print(tab);
																					}
				| IDENTIFIER ':' arr_data_type										{
																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var == NULL, "variable %s has already been declared", $1);

																						symt_node* node = symt_new();
																						node = symt_insert_tab_var(node, $1, rout_name,  $3, 1, array_length, NULL, 0, false, level);
																						tab = symt_push(tab, node);
																						symt_print(tab);
																					}
				| IDENTIFIER '=' expr												{
																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						symt_node *value = (symt_node *)$3;
																						symt_assign_var(var->var, value->cons);
																						symt_print(tab);
																					}
				| IDENTIFIER '[' expr ']' '=' expr									{
																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var != NULL, "variable %s has not been declared", $1);
																						symt_node *index = (symt_node*)$3;
																						symt_node *value = (symt_node*)$6;

																						symt_assign_var_at(var->var, value->cons, *((int*)index->cons->value));
																						symt_print(tab);
																					}
				| IDENTIFIER ':' data_type '=' expr									{
																						symt_node *var_without_value = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var_without_value == NULL, "variable %s has already been declared", $1);

																						symt_node *result_node = symt_new();
																						result_node = symt_insert_tab_var(result_node, $1, rout_name, $3, 0, 0, NULL, 0, false, level);

																						symt_node *value = (symt_node *)$5;
																						symt_assign_var(result_node->var, value->cons);
																						tab = symt_push(tab, result_node);
																						symt_print(tab);
																					}
				| IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'				{
																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var == NULL, "variable %s has already been declared", $1);

																						tab = symt_insert_tab_var(tab, $1, rout_name, $3, 1, array_length, NULL, 0, false, level);
																						var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var != NULL, "variable %s has not been declared", $1);
																						assertf(var->var->type == $3, "type %s does not match %s at %s variable declaration", symt_strget_vartype(var->var->type), symt_strget_vartype($3), $1);
																						struct Stack *pila = $6;
																						struct Stack *valores_pila = $6;
																						switch(value_list_expr_t){
																							case CONS_INTEGER:;
																								int *zero_int = (int *)(ml_malloc(sizeof(int)));

																								for(int i = 0; i < array_length; i++){
																									symt_cons* constate = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																									constate->type = value_list_expr_t;
																									if (pila) constate->value = pila->value;
																									else constate->value = (void*)zero_int;
																									symt_can_assign(var->var->type, constate);
																									if(pila) pila = pila->next_value;
																									ml_free(constate);
																								}
																								int *valores_int = (int *)(ml_malloc(sizeof(int)*array_length));
																								for(int i = 0; valores_pila; i++){
																									*(valores_int+i) = *((int*)valores_pila->value);
																									valores_pila = valores_pila->next_value;
																								}
																								var->var->value = (void*)valores_int;
																								break;
																							case CONS_DOUBLE:;
																								double *zero_double = (double *)(ml_malloc(sizeof(double)));
																								double* value_double = (double*)value_list_expr;
																								for(int i = 0; i < array_length; i++){
																									symt_cons* constate = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																									constate->type = value_list_expr_t;
																									if(pila){
																										constate->value = pila->value;
																									}else {
																										constate->value = (void*)zero_double;
																									}
																									symt_can_assign(var->var->type, constate);
																									if(pila) pila = pila->next_value;
																									ml_free(constate);
																								}
																								double *valores_double = (double *)(ml_malloc(sizeof(double)*array_length));
																								for(int i = 0; valores_pila; i++){
																									*(valores_double+i) = *((double*)valores_pila->value);
																									valores_pila = valores_pila->next_value;
																								}
																								var->var->value = (void*)valores_double;
																								break;
																							case CONS_CHAR:;
																								char *zero_char = (char *)(ml_malloc(sizeof(char)));
																								char* value_char = (char*)value_list_expr;
																								for(int i = 0; i < array_length; i++){
																									symt_cons* constate = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																									constate->type = value_list_expr_t;
																									if(pila){
																										constate->value = pila->value;
																									}else {
																										constate->value = (void*)zero_char;
																									}
																									symt_can_assign(var->var->type, constate);
																									if(pila) pila = pila->next_value;
																									ml_free(constate);
																								}
																								char *valores_char = (char *)(ml_malloc(sizeof(char)*array_length));
																								for(int i = 0; valores_pila; i++){
																									*(valores_char+i) = *((char*)valores_pila->value);
																									valores_pila = valores_pila->next_value;
																								}
																								var->var->value = (void*)valores_char;
																								break;
																						}
																						symt_print(tab);
																					}
				;

// __________ Procedures and functions __________

func_declr 		: BEGIN_FUNCTION IDENTIFIER { rout_name = $2; } ':' data_type '(' declr_params ')' 						{
																															symt_node *result = symt_search_by_name(tab, $2, FUNCTION, NULL, level);
																															assertf(result == NULL, "function %s has already been defined", $2);
																															tab = symt_insert_tab_rout(tab, FUNCTION, rout_name, $5, false, level++);
																														}
																			EOL statement END_FUNCTION 					{
																															//assertf($11 != false, "empty functions are not valid");
																															symt_end_block(tab); level--; rout_name = NULL;
																														}
				| HIDE BEGIN_FUNCTION IDENTIFIER { rout_name = $3; } ':' data_type '(' declr_params ')' 				{
																															symt_node *result = symt_search_by_name(tab, $3, FUNCTION, NULL, level);
																															assertf(result == NULL, "function %s has already been defined", $3);
																															tab = symt_insert_tab_rout(tab, FUNCTION, rout_name, $6, true, level++);
																														}
																			EOL statement END_FUNCTION 					{
																															//assertf($12 != false, "empty functions are not valid");
																															symt_end_block(tab); level--; rout_name = NULL;
																														}
				;

proc_declr 		: BEGIN_PROCEDURE IDENTIFIER { rout_name = $2; } '(' declr_params ')' 									{
																															symt_node *result = symt_search_by_name(tab, $2, PROCEDURE, NULL, level);
																															assertf(result == NULL, "procedure %s has already been defined", $2);
																															tab = symt_insert_tab_rout(tab, PROCEDURE, rout_name, VOID, false, level++);
																														}
																			EOL statement END_PROCEDURE 				{
																															//assertf($9 != false, "empty procedures are not valid");
																															symt_end_block(tab); level--; rout_name = NULL;
																														}
				| HIDE BEGIN_PROCEDURE IDENTIFIER { rout_name = $3; } '(' declr_params ')' 								{
																															symt_node *result = symt_search_by_name(tab, $3, PROCEDURE, NULL, level);
																															assertf(result == NULL, "procedure %s has already been defined", $3);
																															tab = symt_insert_tab_rout(tab, PROCEDURE, rout_name, VOID, true, level++);
																														}
																			EOL statement END_PROCEDURE 				{
																															//assertf($10 != false, "empty procedures are not valid");
																															symt_end_block(tab); level--; rout_name = NULL;
																														}
				;

// __________ Parameters __________

declr_params 	: | param_declr ',' declr_params
				| param_declr
				;

// __________ Call a function __________

call_func 		: CALL IDENTIFIER					{
														symt_node *result = symt_search_by_name(tab, $2, FUNCTION, NULL, 0);
														if (result == NULL) result = symt_search_by_name(tab, $2, PROCEDURE, NULL, 0);
														assertf(result != NULL, "%s routine does not exist", $2);

														symt_node *params = symt_search_param(tab, $2);
														assertf(params == NULL, "%s routine does not need parameters", $2);
													}
				| CALL IDENTIFIER list_expr			{
														symt_node *result = symt_search_by_name(tab, $2, FUNCTION, NULL, 0);
														if (result == NULL) result = symt_search_by_name(tab, $2, PROCEDURE, NULL, 0);
														assertf(result != NULL, "%s routine does not exist", $2);

														symt_node *params = symt_search_param(tab, $2);
														assertf(params != NULL, "%s routine needs parameters", $2);

														struct Stack* iter = (struct Stack*)$3;
														symt_node *iter_p = params;

														int *int_value;
														double *double_value;
														char *char_value;
														symt_cons *cons;
														bool no_more_params = false;

														while (true)
														{
															if (iter_p->id != VAR) { no_more_params = true; break; }
															if (strcmp(iter_p->var->rout_name, $2) != 0) { no_more_params = true; break; }
															if (iter != NULL) break;

															symt_cons_t cons_t = symt_get_type_data(iter_p->var->type);
															assertp(iter->type == cons_t, "type does not match");

															switch(iter->type)
															{
																case CONS_INTEGER:
																	int_value = (int*)iter->value;
																	cons = symt_new_cons(iter->type, int_value);
																	symt_assign_var(iter_p->var, cons);
																break;

																case CONS_DOUBLE:
																	double_value = (double*)iter->value;
																	cons = symt_new_cons(iter->type, double_value);
																	symt_assign_var(iter_p->var, cons);
																break;

																case CONS_CHAR:
																	char_value = (char*)iter->value;
																	cons = symt_new_cons(iter->type, char_value);
																	symt_assign_var(iter_p->var, cons);
																break;

																case CONS_STR:
																	char_value = (char*)iter->value;
																	cons = symt_new_cons(iter->type, char_value);
																	symt_assign_var(iter_p->var, cons);
																break;

																case CONS_BOOL:
																	int_value = (int*)iter->value;
																	cons = symt_new_cons(iter->type, int_value);
																	symt_assign_var(iter_p->var, cons);
																break;
															}

															if (iter_p->var->is_array == true)
															{
																symt_node *aux = symt_search_by_name(tab, iter->name, VAR, NULL, level);
																iter_p->var->array_length = aux->var->array_length;
															}

															iter = iter->next_value;
															iter_p = iter_p->next_node;
														}

														assertp(iter == NULL && no_more_params == true, "invalid number of parameters");
													}
				;

// __________ Add libraries __________

add_libraries 	: ADD_LIBRARY PATH_ADD_LIBRARY EOL add_libraries
				| ADD_LIBRARY PATH_ADD_LIBRARY EOL;

// __________ Switch case __________

switch_case     : EOL switch_case | expr ':' EOL statement BREAK EOL switch_case
                | DEFAULT_SWITCH ':' EOL statement BREAK EOL more_EOL
                ;

more_EOL        : | EOL more_EOL
                ;

// __________ Statement __________

statement 		: { $$ = false; } | in_var EOL statement														 															{ $$ = true; }
				| { level++; } BEGIN_IF '(' expr ')' EOL statement break_rule more_else							END_IF { symt_end_block(tab); level--; } EOL statement 		{ $$ = true; }
				| { level++; } BEGIN_WHILE '(' expr ')' EOL statement break_rule 								END_WHILE { symt_end_block(tab); level--;} EOL statement 	{ $$ = true; }
				| { level++; } BEGIN_FOR '(' in_var ',' expr ',' var_assign ')' EOL statement break_rule		END_FOR { symt_end_block(tab); level--; } EOL statement 	{ $$ = true; }
                | { level++; } BEGIN_SWITCH '(' IDENTIFIER ')' EOL switch_case END_SWITCH 						END_SWITCH { symt_end_block(tab); level--; } EOL statement 	{ $$ = true; }
				| { level++; } call_func EOL statement															{ level--; $$ = true; }
				| RETURN expr EOL statement	 																																{ $$ = true; }
				| CONTINUE EOL statement     																																{ $$ = true; }
				| EOL statement   			 																																{
																																												if ($2 != false) $$ = true;
																																												else $$ = false;
																																											}
				| error EOL { printf(" at expression\n"); } statement																										{ $$ = true; }
				;

more_else 		: { $$ = false; } | ELSE_IF EOL statement break_rule { $$ = true; }
				| ELSE_IF BEGIN_IF '(' expr ')' EOL statement break_rule more_else { $$ = true; }
				;

break_rule 		: { $$ = false; } | BREAK EOL statement { $$ = true;}
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
		level = 0;
		tab = symt_new();
		num_lines = 1;
		s_error = 0;
		l_error = 0;

		printf(" >> Analyzing syntax for %s ... ", argv[i]);
		yyin = fopen(argv[i], "r");
		yyparse();

		fclose(yyin);

		if (s_error == 0 && l_error == 0) printf("\n %s: OK\n", argv[i]);
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
