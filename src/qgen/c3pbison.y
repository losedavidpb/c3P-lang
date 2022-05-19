%{
	/*
		Compiler for c3P programming language

		SYNTAX
	  		./c3pbison C3P_FILE

		AUTHOR
	  		losedavidpb (https://github.com/losedavidpb)
	  		HectorMartinAlvarez (https://github.com/HectorMartinAlvarez)
  	*/

	#include <math.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <stdbool.h>
	#include <unistd.h>
	#include <stdio.h>

	#include "../../include/symt.h"
	#include "../../include/symt_cons.h"
	#include "../../include/symt_var.h"
  	#include "../../include/symt_rout.h"
  	#include "../../include/symt_node.h"
	#include "../../include/assertb.h"
	#include "../../include/arrcopy.h"
	#include "../../include/memlib.h"
	#include "../../include/qlang/Qlib.h"
	#include "../../include/qlang/qwriter.h"

	extern int l_error;	  			// Specify if lexical errors were detected
	extern int num_lines; 			// Number of lines processed
	extern FILE *yyin;				// Current file for Bison

	FILE *obj;						// Object file
	symt_label_t label = 1;			// Label that will be created
	int q_direction = 0x11fea;		// Memory direction for Q

	int begin_last_loop = 0;		// Label for the start of a loop
	int end_last_loop = 0;			// Label for the end of a loop
	bool no_store_expr;				// Check if expression would be stored at a variable
	bool is_for;					// Check if it is a for loop

	int yydebug = 1; 				// Enable this to active debug mode
	int s_error = 0; 				// Specify if syntax errors were detected

	symt_level_t level = 0;			// Current level of symbol table
	symt_tab *tab; 					// Symbol table

	symt_cons_t type;				// Type of a value
	int array_length = 0;  			// Array length for current token
	void *value_list_expr; 			// Array value for current token
	symt_cons_t value_list_expr_t;	// Constant for a part of a list expression
	symt_name_t rout_name;			// Routine name for variables

	// Structure of a stack of void values
	typedef struct Stack
	{
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
%token BEGIN_WHILE END_WHILE CONTINUE BREAK
%token BEGIN_PROCEDURE END_PROCEDURE BEGIN_FUNCTION END_FUNCTION RETURN CALL
%token AND OR NOT

%token EQUAL "=="
%token NOTEQUAL "!="
%token LESSEQUAL "<="
%token MOREEQUAL ">="

%token EOL

%type<integer_t> data_type arr_data_type;
%type<node_t> expr_num expr_char expr_string int_expr expr iden_expr;
%type<integer_t> statement more_else;
%type<stack> list_expr;

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

%start program

%define parse.error verbose

%%

// __________ Expression __________


expr 			: expr_num						{ $$ = $1; }
				| expr_char						{ $$ = $1; }
				| expr_string					{ $$ = $1; }
				| iden_expr						{ $$ = $1; }
				| '(' expr ')'					{ $$ = $2; }
				;

int_expr 		: '(' int_expr ')' 				{ $$ = $2; }
				| INTEGER 						{
													type = CONS_INTEGER;
													symt_node *result = symt_new();
													result = symt_insert_tab_cons(result, CONS_INTEGER, &$1);
													$$ = result;
												}
				;

expr_num 		: T 							{
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
				;

expr_char       : CHAR                          {
													type = CONS_CHAR;
                                                    symt_node *result = symt_new();
													result = symt_insert_tab_cons(result, CONS_CHAR, &$1);
													$$ = result;
                                                }
				;

expr_string 	: STRING		 				{
													type = CONS_STR;
													symt_node *result = symt_new_node();
													result = symt_insert_tab_cons(result, CONS_STR, $1);
													$$ = result;
												}
				;

iden_expr		: expr '+' expr					{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_ADD, num1, num2, -1, no_store_expr);

													symt_cons* res_cons = symt_cons_add(type, num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr '-' expr 				{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_SUB, num1, num2, -1, no_store_expr);

													symt_cons* res_cons = symt_cons_sub(type, num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr '*' expr 				{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_MULT, num1, num2, -1, no_store_expr);

													symt_cons* res_cons = symt_cons_mult(type, num1->cons, num2->cons);
													symt_delete_node(num1); symt_delete_node(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr '/' expr 				{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_DIV, num1, num2, -1, no_store_expr);

													symt_cons* res_cons = symt_cons_div(type, num1->cons, num2->cons);
													symt_delete_node(num1); symt_delete_node(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr '%' expr 				{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_MOD, num1, num2, label++, no_store_expr);

													symt_cons* res_cons = symt_cons_mod(type, num1->cons, num2->cons);
													symt_delete_node(num1); symt_delete_node(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr '^' expr 				{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_POW, num1, num2, label++, no_store_expr);

													symt_cons* res_cons = symt_cons_pow(type, num1->cons, num2->cons);
													symt_delete_node(num1); symt_delete_node(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr '<' expr 				{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_LESS, num1, num2, -1, no_store_expr);

													symt_cons *res_cons = symt_cons_lt(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr '>' expr 				{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_GREATER, num1, num2, -1, no_store_expr);

													symt_cons *res_cons = symt_cons_gt(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr EQUAL expr 				{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_EQUAL, num1, num2, -1, no_store_expr);

													symt_cons *res_cons = symt_cons_eq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr NOTEQUAL expr 			{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_NOT_EQUAL, num1, num2, -1, no_store_expr);

													symt_cons *res_cons = symt_cons_neq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr LESSEQUAL expr 			{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_LESS_THAN, num1, num2, -1, no_store_expr);

													symt_cons *res_cons = symt_cons_leq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr MOREEQUAL expr 			{
													symt_node *num1 = (symt_node*)$1;
													symt_node *num2 = (symt_node*)$3;
													qw_write_expr(obj, QW_GREATER_THAN, num1, num2, -1, no_store_expr);

													symt_cons *res_cons = symt_cons_geq(num1->cons, num2->cons);
													symt_delete(num1); symt_delete(num2);

													symt_node *result = symt_new();
													result->id = CONSTANT;
													result->cons = res_cons;
													$$ = result;
												}
				| expr AND expr 				{
													symt_node* num1 = (symt_node*)$1;
													symt_node* num2 = (symt_node*)$3;
													assertf(num1->cons->type != CONS_CHAR, "char types does not support logic operation");

													qw_write_expr(obj, QW_AND, num1, num2, -1, no_store_expr);
													int value1_int = *((int*)num1->cons->value);
													int value2_int = *((int*)num2->cons->value);
													int result = value1_int && value2_int;

													symt_node *result_n = symt_new();
													result_n = symt_insert_tab_cons(result_n, CONS_INTEGER, &result);
													symt_delete(num1); symt_delete(num2);
													$$ = result_n;
												}
				| expr OR expr 					{
													symt_node* num1 = $1;
													symt_node* num2 = $3;
													assertf(num1->cons->type != CONS_CHAR, "char types does not support logic operation");

													qw_write_expr(obj, QW_OR, num1, num2, -1, no_store_expr);
													int value1_int = *((int*)num1->cons->value);
													int value2_int = *((int*)num2->cons->value);
													int result = value1_int || value2_int;

													symt_node *result_n = symt_new();
													result_n = symt_insert_tab_cons(result_n, CONS_INTEGER, &result);
													symt_delete(num1); symt_delete(num2);
													$$ = result_n;
												}
				| NOT expr 						{
													symt_node* num1 = (symt_node*)$2;
													assertf(num1->cons->type != CONS_CHAR, "char types does not support logic operation");
													qw_write_expr(obj, QW_NOT, num1, NULL, -1, no_store_expr);

													int value1 = *((int*)num1->cons->value);
													int result = !value1;

													symt_node *res_cons = symt_new();
													res_cons = symt_insert_tab_cons(res_cons, CONS_INTEGER, &result);
													symt_delete(num1);
													$$ = res_cons;
												}
				| IDENTIFIER '[' int_expr ']'	{
													symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
													if (var == NULL) var = symt_search_by_name(tab, $1, VAR, NULL, 0);
													assertf(var != NULL, "variable %s has not been declared", $1);
													symt_node *index = (symt_node*)$3;

													int *int_value = NULL;
													double *double_value = NULL;
													char *char_value = NULL;

													symt_node *result = symt_new();
													symt_cons_t type = symt_get_type_data(var->var->type);

													switch(type)
													{
														case CONS_INTEGER:
															int_value = (int*)var->var->value;
															result = symt_insert_tab_cons_q(result, type, (int_value + *((int*)index->cons->value)), result->var->q_direction);
														break;

														case CONS_DOUBLE:
															double_value = (double*)var->var->value;
															result = symt_insert_tab_cons_q(result, type, (double_value + *((int*)index->cons->value)), result->var->q_direction);
														break;

														case CONS_CHAR: case CONS_STR:
															char_value = (char*)var->var->value;
															result = symt_insert_tab_cons_q(result, type, (char_value + *((int*)index->cons->value)), result->var->q_direction);
														break;

														default: break;	// Just to avoid warnings
													}

													$$ = result;
												}
				| IDENTIFIER					{
													symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
													if (var == NULL) var = symt_search_by_name(tab, $1, VAR, NULL, 0);
													assertf(var != NULL, "variable %s has not been declared", $1);

													symt_node *result = symt_new();
													result = symt_insert_tab_cons_q(result, symt_get_type_data(var->var->type), var->var->value, var->var->q_direction);
													$$ = result;
												};

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

param_declr 	: IDENTIFIER ':' data_type			{
														symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
														assertf(var == NULL, "variable %s has already been declared", $1);

														symt_node* node = symt_new();
														node = symt_insert_tab_var(node, $1, rout_name, $3, false, -1, NULL, false, level, q_direction);
														tab = symt_push(tab, node);
														symt_print(tab);
													}
				| IDENTIFIER ':' I8_TYPE '[' ']'	{
														symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
														assertf(var == NULL, "variable %s has already been declared", $1);

														symt_node* node = symt_new();
														node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														q_direction -= 4;
														tab = symt_push(tab, node);
														symt_print(tab);
													}
				| IDENTIFIER ':' I16_TYPE '[' ']'	{
														symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
														assertf(var == NULL, "variable %s has already been declared", $1);

														symt_node* node = symt_new();
														node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														q_direction -= 4;
														tab = symt_push(tab, node);
														symt_print(tab);
													}
				| IDENTIFIER ':' I32_TYPE '[' ']'	{
														symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
														assertf(var == NULL, "variable %s has already been declared", $1);

														symt_node* node = symt_new();
														node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														q_direction -= 4;
														tab = symt_push(tab, node);
														symt_print(tab);
													}
				| IDENTIFIER ':' I64_TYPE '[' ']'	{
														symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
														assertf(var == NULL, "variable %s has already been declared", $1);

														symt_node* node = symt_new();
														node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														q_direction -= 4;
														tab = symt_push(tab, node);
														symt_print(tab);
													}
				| IDENTIFIER ':' F32_TYPE '[' ']'	{
														symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
														assertf(var == NULL, "variable %s has already been declared", $1);

														symt_node* node = symt_new();
														node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														q_direction -= 8;
														tab = symt_push(tab, node);
														symt_print(tab);
													}
				| IDENTIFIER ':' F64_TYPE '[' ']'	{
														symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
														assertf(var == NULL, "variable %s has already been declared", $1);

														symt_node* node = symt_new();
														node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														q_direction -= 8;
														tab = symt_push(tab, node);
														symt_print(tab);
													}
				| IDENTIFIER ':' CHAR_TYPE '[' ']'	{
														symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
														assertf(var == NULL, "variable %s has already been declared", $1);

														symt_node* node = symt_new();
														node = symt_insert_tab_var(node, $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														q_direction -= 4;
														tab = symt_push(tab, node);
														symt_print(tab);
													}
				| IDENTIFIER ':' BOOL_TYPE '[' ']'	{
														symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
														assertf(var == NULL, "variable %s has already been declared", $1);

														symt_node* node = symt_new();
														node = symt_insert_tab_var(node, $1, rout_name,	 $3, 1, -1, NULL, 0, level, q_direction);
														q_direction -= 4;
														tab = symt_push(tab, node);
														symt_print(tab);
													}
				;


// __________ Declaration and Assignation for variables __________

list_expr 	: expr					{
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

var 		:   IDENTIFIER ':' data_type 										{
																					assertp(is_for == false, "local variable is not valid");
																					symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					assertf(var == NULL, "variable %s has already been declared", $1);

																					symt_node* node = symt_new();
																					node = symt_insert_tab_var(node, $1, rout_name, $3, 0, 0, NULL, 0, level, q_direction);
																					symt_cons_t type_n = symt_get_type_data(node->var->type);
																					if (type_n == CONS_DOUBLE) q_direction -= 8; else q_direction -= 4;
																					tab = symt_push(tab, node);

																					qw_write_value_to_var(obj, type_n, node->var->q_direction, node->var->value);
																					symt_print(tab);
																				}
				| IDENTIFIER ':' arr_data_type									{
																					assertp(is_for == false, "local variable is not valid");
																					symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					assertf(var == NULL, "variable %s has already been declared", $1);

																					symt_node* node = symt_new();
																					node = symt_insert_tab_var(node, $1, rout_name,  $3, 1, array_length, NULL, 0, level, q_direction);
																					symt_cons_t type_n = symt_get_type_data(node->var->type);
																					if (type_n == CONS_DOUBLE) q_direction -= 8; else q_direction -= 4;
																					tab = symt_push(tab, node);

																					qw_write_value_to_var(obj, type_n, var->var->q_direction, var->var->value);
																					symt_print(tab);
																				}
				| IDENTIFIER '=' expr											{
																					assertp(is_for == false, "local variable is not valid");
																					symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					assertf(var != NULL, "variable %s has not been declared", $1);

																					symt_node *value = (symt_node *)$3;
																					symt_assign_var(var->var, value->cons);

																					symt_print(tab);
																				}
				| IDENTIFIER '[' expr ']' '=' expr								{
																					assertp(is_for == false, "local variable is not valid");
																					symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					assertf(var != NULL, "variable %s has not been declared", $1);
																					symt_node *index = (symt_node*)$3;
																					symt_node *value = (symt_node*)$6;

																					symt_assign_var_at(var->var, value->cons, *((int*)index->cons->value));
																					qw_write_value_to_var(obj, symt_get_type_data(var->var->type), var->var->q_direction, var->var->value);
																					symt_print(tab);
																				}
				| IDENTIFIER ':' data_type '=' expr								{
																					symt_node *var_without_value = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					assertf(var_without_value == NULL, "variable %s has already been declared", $1);

																					symt_node *result_node = symt_new();
																					result_node = symt_insert_tab_var(result_node, $1, rout_name, $3, 0, 0, NULL, 0, level, q_direction);
																					symt_cons_t type_n = symt_get_type_data(result_node->var->type);
																					if (type_n == CONS_DOUBLE) q_direction -= 8; else q_direction -= 4;

																					symt_node *value = (symt_node *)$5;
																					symt_assign_var(result_node->var, value->cons);
																					tab = symt_push(tab, result_node);
																					qw_write_value_to_var(obj, type_n, result_node->var->q_direction, result_node->var->value);

																					if (is_for == true)
																					{
																						fprintf(obj, "\n\tR7=R7+4;\t// Restore R7 for loop");
																						qw_write_begin_loop(obj, label++);
																					}

																					symt_print(tab);
																				}
				| IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'			{
																					assertp(is_for == false, "local variable is not valid");
																					symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					assertf(var == NULL, "variable %s has already been declared", $1);

																					tab = symt_insert_tab_var(tab, $1, rout_name, $3, 1, array_length, NULL, 0, level, q_direction);
																					q_direction -= 4;

																					var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					assertf(var != NULL, "variable %s has not been declared", $1);
																					assertf(var->var->type == $3, "type %s does not match %s at %s variable declaration", symt_strget_vartype(var->var->type), symt_strget_vartype($3), $1);

																					struct Stack *pila = $6, *valores_pila = $6;

																					switch(value_list_expr_t)
																					{
																						case CONS_INTEGER:;
																							int *zero_int = (int *)(ml_malloc(sizeof(int)));
																							int *valores_int = (int *)(ml_malloc(sizeof(int)*array_length));

																							for (int i = 0; i < array_length; i++)
																							{
																								symt_cons* cons = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																								cons->type = value_list_expr_t;

																								if (pila) cons->value = pila->value;
																								else cons->value = (void*)zero_int;

																								symt_can_assign(var->var->type, cons);
																								if(pila) pila = pila->next_value;
																								ml_free(cons);
																							}

																							for(int i = 0; valores_pila; i++)
																							{
																								*(valores_int+i) = *((int*)valores_pila->value);
																								valores_pila = valores_pila->next_value;
																							}

																							var->var->value = (void*)valores_int;
																						break;

																						case CONS_DOUBLE:;
																							double *zero_double = (double *)(ml_malloc(sizeof(double)));
																							double *valores_double = (double *)(ml_malloc(sizeof(double)*array_length));

																							for(int i = 0; i < array_length; i++)
																							{
																								symt_cons* cons = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																								cons->type = value_list_expr_t;

																								if(pila) cons->value = pila->value;
																								else cons->value = (void*)zero_double;

																								symt_can_assign(var->var->type, cons);
																								if (pila) pila = pila->next_value;
																								ml_free(cons);
																							}

																							for(int i = 0; valores_pila; i++)
																							{
																								*(valores_double+i) = *((double*)valores_pila->value);
																								valores_pila = valores_pila->next_value;
																							}

																							var->var->value = (void*)valores_double;
																						break;

																						case CONS_CHAR:;
																							char *zero_char = (char *)(ml_malloc(sizeof(char)));
																							char *valores_char = (char *)(ml_malloc(sizeof(char) * array_length));

																							for(int i = 0; i < array_length; i++)
																							{
																								symt_cons* cons = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																								cons->type = value_list_expr_t;

																								if(pila) cons->value = pila->value;
																								else cons->value = (void*)zero_char;

																								symt_can_assign(var->var->type, cons);
																								if(pila) pila = pila->next_value;
																								ml_free(cons);
																							}

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
				| call_assing
				;

call_assing		:	IDENTIFIER '=' CALL IDENTIFIER									{
																						symt_node *result = symt_search_by_name(tab, $4, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $4, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $4);

																						symt_node *params = symt_search_param(tab, $4);
																						assertf(params == NULL, "%s routine does need parameters", $4);

																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						assertf(result->rout->type == var->var->type, "type does not match");
																						symt_print(tab);
																					}
				| 	IDENTIFIER  '='  CALL IDENTIFIER list_expr						{
																						symt_node *result = symt_search_by_name(tab, $4, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $4, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $4);

																						symt_node *params = symt_search_param(tab, $4);
																						assertf(params != NULL, "%s routine does not need parameters", $4);

																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						assertf(result->rout->type == var->var->type, "type does not match");
																						symt_print(tab);
																					}
				| 	IDENTIFIER '[' expr ']' '='  CALL IDENTIFIER					{
																						symt_node *result = symt_search_by_name(tab, $7, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $7, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $7);

																						symt_node *params = symt_search_param(tab, $7);
																						assertf(params == NULL, "%s routine does need parameters", $7);

																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						assertf(result->rout->type == var->var->type, "type does not match");
																						symt_print(tab);
																					}
				| 	IDENTIFIER ':' data_type '=' CALL IDENTIFIER					{
																						symt_node *result = symt_search_by_name(tab, $6, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $6, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $6);

																						symt_node *params = symt_search_param(tab, $6);
																						assertf(params == NULL, "%s routine does need parameters", $6);

																						assertf(result->rout->type == $3, "type does not match")
																						symt_node* node = symt_new();
																						node = symt_insert_tab_var(node, $1, rout_name,  $3, 0, 0, NULL, 0, level, q_direction);
																						tab = symt_push(tab, node);
																						symt_print(tab);
																					}
				| 	IDENTIFIER ':' data_type '=' CALL IDENTIFIER list_expr			{
																						symt_node *result = symt_search_by_name(tab, $6, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $6, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $6);

																						symt_node *params = symt_search_param(tab, $6);
																						assertf(params != NULL, "%s routine does not need parameters", $6);

																						assertf(result->rout->type == $3, "type does not match")
																						symt_node* node = symt_new();
																						node = symt_insert_tab_var(node, $1, rout_name,  $3, 0, 0, NULL, 0, level, q_direction);
																						tab = symt_push(tab, node);
																						symt_print(tab);
																					}
				| 	IDENTIFIER '[' expr ']' '='  CALL IDENTIFIER list_expr			{
																						symt_node *result = symt_search_by_name(tab, $7, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $7, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $7);

																						symt_node *params = symt_search_param(tab, $7);
																						assertf(params != NULL, "%s routine does not need parameters", $7);

																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						assertf(result->rout->type == var->var->type, "type does not match");
																						symt_print(tab);
																					}
				;

// __________ Procedures and functions __________

func_declr 		: BEGIN_FUNCTION IDENTIFIER { rout_name = $2; } ':' data_type '(' declr_params ')' 	{
																										symt_node *result = symt_search_by_name(tab, rout_name, FUNCTION, NULL, 0);
																										assertf(result == NULL, "function %s has already been defined", rout_name);

																										tab = symt_insert_tab_rout(tab, FUNCTION, rout_name, $5, level++, label);
																										qw_write_routine(obj, rout_name, label++, false);
																									} EOL statement RETURN expr EOL END_FUNCTION {
																										symt_end_block(tab, level); level--;
																										qw_write_close_routine(obj, rout_name, false);
																										rout_name = NULL;
																									}
				;

proc_declr 		: BEGIN_PROCEDURE IDENTIFIER { rout_name = $2; } '(' declr_params ')' 				{
																										symt_node *result = symt_search_by_name(tab, rout_name, PROCEDURE, NULL, 0);
																										assertf(result == NULL, "procedure %s has already been defined", rout_name);

																										tab = symt_insert_tab_rout(tab, PROCEDURE, rout_name, VOID, level++, label);
																										qw_write_routine(obj, rout_name, label++, strcmp(rout_name, "main") == 0);
																									} EOL statement END_PROCEDURE {
																										qw_write_close_routine(obj, rout_name, strcmp(rout_name, "main") == 0);
																										symt_end_block(tab, level); level--;
																										rout_name = NULL;
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

														qw_write_call(obj, result->rout->label, label++);
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
																case CONS_INTEGER: case CONS_BOOL:
																	int_value = (int*)iter->value;
																	cons = symt_new_cons(iter->type, int_value, 0);
																	symt_assign_var(iter_p->var, cons);
																break;

																case CONS_DOUBLE:
																	double_value = (double*)iter->value;
																	cons = symt_new_cons(iter->type, double_value, 0);
																	symt_assign_var(iter_p->var, cons);
																break;

																case CONS_CHAR: case CONS_STR:
																	char_value = (char*)iter->value;
																	cons = symt_new_cons(iter->type, char_value, 0);
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

														qw_write_call(obj, result->rout->label, label++);
													}
				;

// __________ Statement __________

statement 		: { $$ = false; } | var EOL statement														 														{ $$ = true; }
				| { level++; no_store_expr = true; } BEGIN_IF '(' expr ')' { qw_write_condition(obj, label); $<integer_t>$=label++; } EOL statement 				{
																																										no_store_expr = false;
																																										qw_write_new_label(obj, $<integer_t>6);
																																									} more_else	END_IF {
																																										symt_end_block(tab, level); level--;
																																									} EOL statement { $$ = true; }
				| { level++; begin_last_loop=label; $<integer_t>$=label; qw_write_begin_loop(obj, label++); no_store_expr = true; } BEGIN_WHILE '(' expr ')' 		{
																																										no_store_expr = false;
																																										qw_write_condition(obj, label);
																																										end_last_loop=label;
																																										$<integer_t>$=label++;
																																									} EOL statement END_WHILE {
																																										symt_end_block(tab, level); level--;
																																										qw_write_end_loop(obj, $<integer_t>1, $<integer_t>6);
																																									} EOL statement { $$ = true; }
				| { level++; } call_func EOL statement																												{ level--; $$ = true; }
				| CONTINUE { qw_write_goto(obj, begin_last_loop); } EOL statement     																				{ $$ = true; }
                | BREAK { qw_write_goto(obj, end_last_loop); } EOL statement 																						{ $$ = true; }
				| EOL statement   			 																														{
																																										if ($2 != false) $$ = true;
																																										else $$ = false;
																																									}
				| error EOL { printf(" at expression\n"); } statement																								{ $$ = true; }
				;

more_else 		: { $$ = false; } | ELSE_IF { symt_end_block(tab, level); } EOL statement { $$ = true; }
				| ELSE_IF { symt_end_block(tab, level); } BEGIN_IF '(' expr ')' { $<integer_t>$=++label; qw_write_condition(obj, label); } EOL statement { qw_write_new_label(obj, $<integer_t>7); } more_else { $$ = true; }
				;

// __________ Main program __________

program 		: | var program
				| func_declr program
				| proc_declr program
				| EOL program
				;

%%

int main(int argc, char **argv)
{
	if (argc == 2)
	{
		tab = symt_new();

		symt_name_t object_f = strappend(argv[1], ".q.c");
		obj = qw_new(object_f);
		qw_prepare(obj);

		yyin = fopen(argv[1], "r");
		yyparse();

		qw_close(obj, label);
		fclose(yyin);

		if (s_error == 0 && l_error == 0)
			printf("\n %s: OK\n", argv[1]);

		ml_free(object_f);
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
