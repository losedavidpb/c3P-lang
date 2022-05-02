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
  	#include "../../include/symt_if.h"
  	#include "../../include/symt_while.h"
  	#include "../../include/symt_call.h"
  	#include "../../include/symt_rout.h"
  	#include "../../include/symt_node.h"

	#include "../../include/assertb.h"
	#include "../../include/arrcopy.h"
	#include "../../include/memlib.h"

	extern int l_error;	  // Specify if lexical errors were detected
	extern int num_lines; // Number of lines processed

	extern FILE *yyin; // Bison file to be checked

	int yydebug = 1; // Enable this to active debug mode
	int s_error = 0; // Specify if syntax errors were detected

	symt_tab *tab; // Table of symbol

	int array_length = 0;  // Array length for current token
	void *value_list_expr; // Array value for current token
	int token_id = SYMT_ROOT_ID;
	symt_cons_t value_list_expr_t;

	// Structure of a stack of void values
	typedef struct Stack
	{
		void* value;
		struct Stack *next_value;
	} Stack;

	// Stack for list expression
	struct Stack *cola;

	// Print content of passed stack
	void print_stack(struct Stack *p);

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
%token<integer_t> T
%token<integer_t> F

%token<type_t> I8_TYPE
%token<type_t> I16_TYPE
%token<type_t> I32_TYPE
%token<type_t> I64_TYPE
%token<type_t> F32_TYPE
%token<type_t> F64_TYPE
%token<type_t> CHAR_TYPE
%token<type_t> STR_TYPE
%token<type_t> BOOL_TYPE

%token BEGIN_IF END_IF ELSE_IF
%token BEGIN_WHILE END_WHILE
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

%type<node_t> BEGIN_WHILE;
%type<node_t> BEGIN_IF;
%type<node_t> CONTINUE;
%type<node_t> BREAK;
%type<node_t> RETURN;
%type<node_t> EOL;
%type<node_t> call_func;
%type<node_t> CALL;
%type<node_t> error;

%type<node_t> expr_num;
%type<node_t> expr_char;
%type<node_t> expr_string;
%type<node_t> int_expr;
%type<node_t> expr;
%type<stack> list_expr;

%type<node_t> statement;
%type<node_t> more_else;

%type<node_t> in_var;
%type<node_t> ext_var;

%type<integer_t> data_type;
%type<integer_t> arr_data_type;

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
													symt_node *result = symt_new();
													result = symt_insert_tab_cons(result, CONS_DOUBLE, &$1);
													$$ = result;
												}
				| INTEGER 						{
													symt_node *result = symt_new();
													result = symt_insert_tab_cons(result, CONS_INTEGER, &$1);
													$$ = result;
												}
				| IDENTIFIER					{
													symt_node *var = symt_search_by_name(tab, $1, GLOBAL_VAR);
													if (var == NULL) var = symt_search_by_name(tab, $1, LOCAL_VAR);
													assertf(var != NULL, "variable %s has not been declared at line ", $1);

													symt_node *result = symt_new();
													result = symt_insert_tab_cons(result, symt_get_type_data(var->var->type), var->var->value);
													$$ = result;
												}
				;

expr_num 		: expr_num '<' expr_num 		{
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
													int true_val = 1;
													symt_node *res_cons = symt_new();
													res_cons = symt_insert_tab_cons(res_cons, CONS_INTEGER, &true_val);
													$$ = res_cons;
												}
				| F 							{
													int false_val = 0;
													symt_node *res_cons = symt_new();
													res_cons = symt_insert_tab_cons(res_cons, CONS_INTEGER, &false_val);
													$$ = res_cons;
												}
				;

expr_char       : expr_char '+' expr_char       {
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
                                                    symt_node *result = symt_new();
													result = symt_insert_tab_cons(result, CONS_CHAR, &$1);
													$$ = result;
                                                }
                ;

expr_string 	: expr_string '+' expr_string	{
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
				| STR_TYPE '[' int_expr ']'		{
													value_list_expr_t = CONS_CHAR;
													symt_node *node = (symt_node*)$3;
													array_length = *((int*)node->cons->value);
													$$ = STR;
												}
				| BOOL_TYPE '[' int_expr ']'	{
													value_list_expr_t = CONS_INTEGER;
													symt_node *node = (symt_node*)$3;
													array_length = *((int*)node->cons->value);
													$$ = B;
												}
				;

// __________ Declaration for variables __________

param_declr 	: IDENTIFIER ':' data_type
				| IDENTIFIER ':' I8_TYPE '[' ']'
				| IDENTIFIER ':' I16_TYPE '[' ']'
				| IDENTIFIER ':' I32_TYPE '[' ']'
				| IDENTIFIER ':' I64_TYPE '[' ']'
				| IDENTIFIER ':' F32_TYPE '[' ']'
				| IDENTIFIER ':' F64_TYPE '[' ']'
				| IDENTIFIER ':' CHAR_TYPE '[' ']'
				| IDENTIFIER ':' STR_TYPE '[' ']'
				| IDENTIFIER ':' BOOL_TYPE '[' ']'
				| IDENTIFIER ':' I8_TYPE  '[' int_expr ']'
				| IDENTIFIER ':' I16_TYPE '[' int_expr ']'
				| IDENTIFIER ':' I32_TYPE '[' int_expr ']'
				| IDENTIFIER ':' I64_TYPE '[' int_expr ']'
				| IDENTIFIER ':' F32_TYPE '[' int_expr ']'
				| IDENTIFIER ':' F64_TYPE '[' int_expr ']'
				| IDENTIFIER ':' CHAR_TYPE '[' int_expr ']'
				| IDENTIFIER ':' STR_TYPE '[' int_expr ']'
				| IDENTIFIER ':' BOOL_TYPE '[' int_expr ']'
				;

// __________ Declaration and Assignation for variables __________

list_expr 		: expr					{
											struct Stack pila;
											//cola = (Stack *)(ml_malloc(sizeof(Stack)));
											symt_node* node = (symt_node*)$1;
											pila.value = symt_get_value_from_node(node);
											pila.next_value = NULL;
											$$ = &pila;
										}
				| expr ',' list_expr	{
											struct Stack *pila = (Stack *)$3;

											if(pila == NULL){
												printf("\n mierda\n");
											}

											struct Stack* new_pila = (Stack *)(ml_malloc(sizeof(Stack)));

											symt_node* node = (symt_node*)$1;
											new_pila->value = symt_get_value_from_node(node);
											new_pila->next_value = pila;

											//cola = new_pila;
											$$ = new_pila;
										}
				;

ext_var 		: { token_id = GLOBAL_VAR; } in_var { token_id = LOCAL_VAR; }
				| HIDE IDENTIFIER ':' data_type										{
																						symt_node *var = symt_search_by_name(tab, $2, GLOBAL_VAR);
																						assertf(var == NULL, "variable %s has already been declared", $2);

																						var = symt_insert_var(GLOBAL_VAR, $2, $4, 0, 0, NULL, 1);
																						tab = symt_push(tab, var); $$ = var; symt_print(tab);
																					}
				| HIDE IDENTIFIER ':' arr_data_type									{
																						symt_node *var = symt_search_by_name(tab, $2, GLOBAL_VAR);
																						assertf(var == NULL, "variable %s has already been declared", $2);

																						var = symt_insert_var(GLOBAL_VAR, $2, $4, 1, array_length, NULL, 1);
																						tab = symt_push(tab, var); $$ = var; symt_print(tab);
																					}
				| HIDE IDENTIFIER ':' data_type '=' expr							{
																						symt_node *var = symt_search_by_name(tab, $2, GLOBAL_VAR);
																						assertf(var == NULL, "variable %s has already been declared", $2);

																						var = symt_insert_var(GLOBAL_VAR, $2, $4, 0, 0, NULL, 1);

																						symt_node *value = (symt_node *)$6;
																						symt_assign_var(var->var, value->cons);
																						tab = symt_push(tab, var);
																						$$ = var; symt_print(tab);
																					}
				| HIDE IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'			{
																						symt_node *var = symt_search_by_name(tab, $2, GLOBAL_VAR);
																						assertf(var == NULL, "variable %s has already been declared", $2);

																						var = symt_insert_var(GLOBAL_VAR, $2, $4, 0, 0, NULL, 1);
																						tab = symt_push(tab, var);

																						var = symt_search_by_name(tab, $2, GLOBAL_VAR);
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

																						$$ = var; symt_print(tab);
																					}
				;

in_var 			: IDENTIFIER ':' data_type 											{
																					    if (token_id == SYMT_ROOT_ID) token_id = LOCAL_VAR;
																						symt_node *var = symt_search_by_name(tab, $1, token_id);
																						assertf(var == NULL, "variable %s has already been declared", $1);

																						symt_node* node = symt_new();
																						node = symt_insert_tab_var(node, token_id, $1, $3, 0, 0, NULL, 0);

																						tab = symt_push(tab, node); $$ = node;
																						token_id = SYMT_ROOT_ID; symt_print(tab);
																					}
				| IDENTIFIER ':' arr_data_type										{
																						if (token_id == SYMT_ROOT_ID) token_id = LOCAL_VAR;
																						symt_node *var = symt_search_by_name(tab, $1, token_id);
																						assertf(var == NULL, "variable %s has already been declared", $1);

																						symt_node* node = symt_new();
																						node = symt_insert_tab_var(node, token_id, $1, $3, 1, array_length, NULL, 0);
																						tab = symt_push(tab, node);
																						$$ = node; token_id = SYMT_ROOT_ID; symt_print(tab);
																					}
				| IDENTIFIER '=' expr												{
																						symt_node *var = symt_search_by_name(tab, $1, LOCAL_VAR);
																						if (var == NULL) var = symt_search_by_name(tab, $1, GLOBAL_VAR);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						symt_node *value = (symt_node *)$3;
																						symt_assign_var(var->var, value->cons);
																						$$ = var; token_id = SYMT_ROOT_ID;
																						symt_print(tab);
																					}
				| IDENTIFIER '[' expr ']' '=' expr									{
																						if (token_id == SYMT_ROOT_ID) token_id = LOCAL_VAR;
																						symt_node *var = symt_search_by_name(tab, $1, token_id);
																						assertf(var != NULL, "variable %s has not been declared", $1);
																						symt_node *index = (symt_node*)$3;
																						symt_node *value = (symt_node*)$6;

																						symt_assign_var_at(var->var, value->cons, *((int*)index->cons->value));
																						$$ = var; token_id = SYMT_ROOT_ID; symt_print(tab);
																					}
				| IDENTIFIER ':' data_type '=' expr									{
																						if (token_id == SYMT_ROOT_ID) token_id = LOCAL_VAR;
																						symt_node *var_without_value = symt_search_by_name(tab, $1, token_id);
																						assertf(var_without_value == NULL, "variable %s has already been declared", $1);

																						symt_node *result_node = symt_new();
																						result_node = symt_insert_tab_var(result_node, token_id, $1, $3, 0, 0, NULL, 0);

																						symt_node *value = (symt_node *)$5;
																						symt_assign_var(result_node->var, value->cons);
																						tab = symt_push(tab, result_node);

																						$$ = result_node; token_id = SYMT_ROOT_ID; symt_print(tab);
																					}
				| IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'				{
																						if (token_id == SYMT_ROOT_ID) token_id = LOCAL_VAR;
																						symt_node *var = symt_search_by_name(tab, $1, token_id);
																						assertf(var == NULL, "variable %s has already been declared", $1);

																						tab = symt_insert_tab_var(tab, token_id, $1, $3, 1, array_length, NULL, 0);
																						var = symt_search_by_name(tab, $1, token_id);
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
																									if(pila){
																										constate->value = pila->value;
																									}else {
																										constate->value = (void*)zero_int;
																									}
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
																						$$ = var; token_id = SYMT_ROOT_ID;
																						symt_print(tab);
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

// __________ Statement __________

statement 		: { $$ = NULL; } | in_var EOL statement
				| BEGIN_IF '(' expr ')' EOL statement break_rule more_else								{
																											symt_node *cond = (symt_node *)$3;

																											symt_node *statement_if = NULL;
																											if ($6 != NULL) statement_if = (symt_node *)$6;

																											symt_node *statement_else = NULL;
																											if ($8 != NULL) statement_else = (symt_node *)$8;

																											tab = symt_insert_tab_if(tab, cond, statement_if, statement_else);
																											symt_print(tab);
																										} END_IF { symt_end_block(tab, IF); } EOL statement
				| BEGIN_WHILE '(' expr ')' EOL statement break_rule 									{
																											symt_node *cond = (symt_node *)$3;
																											symt_node *statement = NULL;
																											if ($6 != NULL) statement = (symt_node *)$6;

																											tab = symt_insert_tab_while(tab, cond, statement);
																											symt_print(tab);
																										} END_WHILE { symt_end_block(tab, WHILE); } EOL statement
				| call_func EOL statement
				| RETURN expr EOL statement
				| CONTINUE EOL statement
				| EOL statement
				| error EOL { printf(" at expression\n"); } statement
				;

more_else 		: {} | ELSE_IF EOL statement break_rule 												{
																											symt_node *statement = symt_new();
																											statement = (symt_node *)$3;
																											$$ = statement;
																										}
				| ELSE_IF BEGIN_IF '(' expr ')' EOL statement break_rule more_else 						{
																											symt_node* else_node = symt_new();
																											symt_node *cond = symt_new(); cond = (symt_node *)$4;
																											symt_node *statement_if = symt_new(); statement_if = (symt_node *)$7;
																											symt_node *statement_else = (symt_node *)$9;
																											else_node = symt_insert_tab_if(else_node, cond, statement_if, statement_else);
																											$$ = else_node;
																										}
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

void print_stack(struct Stack *p)
{
	assertp(p != NULL, "pila has not been constructed");
	struct Stack *node = p; int i = 0;

	while(node)
	{
		printf("\n valor en la posicion %d de la pila -> %d", i++, *((int*)(node->value)));
		node = node->next_value;
	}
}
