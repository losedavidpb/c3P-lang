// c3pbison.y -*- C -*-
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
 *	ISO C99 Standard: Syntax analyzer for c3p language
 */

%{
	#include <math.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <stdbool.h>
	#include <unistd.h>
	#include <stdio.h>

	#include "../../include/symt.h"
	#include "../../include/symt_stack.h"
	#include "../../include/symt_cons.h"
	#include "../../include/symt_var.h"
  	#include "../../include/symt_rout.h"
  	#include "../../include/symt_node.h"
	#include "../../include/assertb.h"
	#include "../../include/arrcopy.h"
	#include "../../include/memlib.h"
	#include "../../include/qwriter.h"

	extern int l_error;	  			// Specify if lexical errors were detected
	extern int num_lines; 			// Number of lines processed
	extern FILE *yyin;				// Current file for Bison

	int yydebug = 1; 				// Enable this to active debug mode
	int s_error = 0; 				// Specify if syntax errors were detected

	// Just to avoid warnings
	int yylex(void);
	void yyerror(const char *s);

	FILE *obj;						// Object file for Q code
	int q_direction = 0x11fea;		// Memory direction to save variables
	int num_reg = 2;				// Current register used to store a value
	symt_label_t label = 1;			// Label that will be created at Q file
	int begin_last_loop = 0;		// Label for the start of a loop
	int end_last_loop = 0;			// Label for the end of a loop
	int q_direction_var;			// Direction for variable that would be stored
	bool is_var;
	bool is_expr;

	symt_level_t level = 0;			// Current level of symbol table
	symt_tab *tab; 					// Symbol table

	symt_cons_t type;				// Type of a value
	size_t array_length = 0;  		// Array length for current token
	void *value_list_expr; 			// Array value for current token
	symt_cons_t value_list_expr_t;	// Constant for a part of a list expression
	symt_name_t rout_name;			// Routine name for variables
%}

%union
{
	int integer_t;
	double double_t;
	char *string_t;
	char char_t;
	struct symt_node *node_t;
	struct symt_stack *stack_t;
}

%token<string_t> IDENTIFIER STRING
%token<integer_t> INTEGER T F
%token<double_t> DOUBLE
%token<char_t> CHAR

%token<integer_t> I8_TYPE I16_TYPE I32_TYPE I64_TYPE
%token<integer_t> F32_TYPE F64_TYPE
%token<integer_t> CHAR_TYPE STR_TYPE
%token<integer_t> BOOL_TYPE

%token BEGIN_IF END_IF ELSE_IF
%token BEGIN_FOR END_FOR BEGIN_WHILE END_WHILE CONTINUE BREAK
%token BEGIN_PROCEDURE END_PROCEDURE BEGIN_FUNCTION END_FUNCTION RETURN CALL
%token AND OR NOT

%token EQUAL "=="
%token NOTEQUAL "!="
%token LESSEQUAL "<="
%token MOREEQUAL ">="

%token EOL

%type<integer_t> data_type arr_data_type statement more_else;
%type<node_t> expr_num expr_char expr_string int_expr expr iden_expr;
%type<stack_t> list_expr;

%left '+' '-' '*' '/' '%'
%left '<' '>' EQUAL NOTEQUAL LESSEQUAL MOREEQUAL AND OR
%left '(' ')' ':' ',' '[' ']' '{' '}'
%right '^' NOT '='

%start program
%define parse.error verbose

%%

// __________ Expression __________

expr 			: expr_num	{ $$ = $1; }   | expr_char	{ $$ = $1; }
				| expr_string { $$ = $1; } | iden_expr	{ $$ = $1; }
				| '(' expr ')' { $$ = $2; }
				;

int_expr 		: '(' int_expr ')' 				{ is_expr = false; $$ = $2; }
				| INTEGER 						{
													type = CONS_INTEGER; is_expr = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_INTEGER, &$1);
													qw_write_value_to_reg(obj, num_reg, CONS_INTEGER, $$->cons->value);
													if (num_reg > 1) num_reg--;
												}
				;

expr_num 		: T 							{
													type = CONS_BOOL; int true_val = 1; is_expr = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_INTEGER, &true_val);
													qw_write_value_to_reg(obj, num_reg, CONS_INTEGER, $$->cons->value);
													if (num_reg > 1) num_reg--;
												}
				| F 							{
													type = CONS_BOOL; int false_val = 0; is_expr = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_INTEGER, &false_val);
													qw_write_value_to_reg(obj, num_reg, CONS_INTEGER, $$->cons->value);
													if (num_reg > 1) num_reg--;
												}
				| DOUBLE 						{
													type = CONS_DOUBLE; is_expr = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_DOUBLE, &$1);
													qw_write_value_to_reg(obj, num_reg, CONS_DOUBLE, $$->cons->value);
													if (num_reg > 1) num_reg--;
												}
				| INTEGER 						{
													type = CONS_INTEGER; is_expr = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_INTEGER, &$1);
													qw_write_value_to_reg(obj, num_reg, CONS_INTEGER, $$->cons->value);
													if (num_reg > 1) num_reg--;
												}
				;

expr_char       : CHAR                          {
													type = CONS_CHAR; is_expr = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_CHAR, &$1);
													qw_write_value_to_reg(obj, num_reg, CONS_CHAR, $$->cons->value);
													if (num_reg > 1) num_reg--;
                                                }
				;

expr_string 	: STRING		 				{
													type = CONS_STR; is_expr = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_STR, $1);
													qw_write_value_to_reg(obj, num_reg, CONS_STR, $$->cons->value);
													if (num_reg > 1) num_reg--;
												}
				;

iden_expr		: expr '+' expr					{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													num_reg = 2;
													qw_write_expr(obj, QW_ADD, type, -1);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_add(type, $1->cons, $3->cons);
													symt_delete($1); symt_delete($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr '-' expr 				{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													qw_write_expr(obj, QW_SUB, type, -1);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_sub(type, $1->cons, $3->cons);
													symt_delete($1); symt_delete($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr '*' expr 				{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													qw_write_expr(obj, QW_MULT, type, -1);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_mult(type, $1->cons, $3->cons);
													symt_delete_node($1); symt_delete_node($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr '/' expr 				{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													qw_write_expr(obj, QW_DIV, type, -1);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_div(type, $1->cons, $3->cons);
													symt_delete_node($1); symt_delete_node($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr '%' expr 				{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													qw_write_expr(obj, QW_MOD, type, label++);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_mod(type, $1->cons, $3->cons);
													symt_delete_node($1); symt_delete_node($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr '^' expr 				{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													qw_write_expr(obj, QW_POW, type, label++);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_pow(type, $1->cons, $3->cons);
													symt_delete_node($1); symt_delete_node($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr '<' expr 				{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													qw_write_expr(obj, QW_LESS, type, -1);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_lt($1->cons, $3->cons);
													symt_delete($1); symt_delete($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr '>' expr 				{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													qw_write_expr(obj, QW_GREATER, type, -1);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_gt($1->cons, $3->cons);
													symt_delete($1); symt_delete($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr EQUAL expr 				{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													qw_write_expr(obj, QW_EQUAL, type, -1);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_eq($1->cons, $3->cons);
													symt_delete($1); symt_delete($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr NOTEQUAL expr 			{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													qw_write_expr(obj, QW_NOT_EQUAL, type, -1);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_neq($1->cons, $3->cons);
													symt_delete($1); symt_delete($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr LESSEQUAL expr 			{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													qw_write_expr(obj, QW_LESS_THAN, type, -1);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_leq($1->cons, $3->cons);
													symt_delete($1); symt_delete($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr MOREEQUAL expr 			{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													qw_write_expr(obj, QW_GREATER_THAN, type, -1);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_geq($1->cons, $3->cons);
													symt_delete($1); symt_delete($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr AND expr 				{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													assertf(type != CONS_CHAR, "char types does not support logic operation");
													qw_write_expr(obj, QW_AND, type, -1);

													int result = *((int*)$1->cons->value) && *((int*)$3->cons->value);
													$$ = symt_insert_tab_cons(symt_new(), CONS_INTEGER, &result);
													symt_delete($1); symt_delete($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| expr OR expr 					{
													is_expr = true;

													if ($1->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $1->cons->type, $1->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if ($3->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $3->cons->type, $3->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													assertf(type != CONS_CHAR, "char types does not support logic operation");
													qw_write_expr(obj, QW_OR, type, -1);

													int result = *((int*)$1->cons->value) || *((int*)$3->cons->value);
													$$ = symt_insert_tab_cons(symt_new(), CONS_INTEGER, &result);
													symt_delete($1); symt_delete($3);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| NOT expr 						{
													is_expr = false;

													if ($2->cons->q_direction != 0)
													{
														qw_write_var_to_reg(obj, num_reg, $2->cons->type, $2->cons->q_direction);
														if (num_reg > 1) num_reg--;
													}

													if (num_reg > 1) num_reg = 2;
													assertf(type != CONS_CHAR, "char types does not support logic operation");
													qw_write_expr(obj, QW_NOT, type, -1);

													int result = !(*((int*)$2->cons->value));
													$$ = symt_insert_tab_cons(symt_new(), CONS_INTEGER, &result);
													symt_delete($2);

													if (q_direction_var != 0 && is_var == true)
														qw_write_reg_to_var(obj, 1, type, q_direction_var);
												}
				| IDENTIFIER '[' int_expr ']'	{
													is_expr = false;

													if (num_reg > 1) num_reg = 2;
													symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
													if (var == NULL) var = symt_search_by_name(tab, $1, VAR, NULL, 0);
													assertf(var != NULL, "variable %s has not been declared", $1);

													switch(type)
													{
														case CONS_INTEGER:; case CONS_BOOL:;
															int *int_value = (int*)var->var->value;
															$$ = symt_insert_tab_cons_q(symt_new(), type, (int_value + *((int*)$3->cons->value)), var->var->q_direction);
														break;

														case CONS_DOUBLE:;
															double *double_value = (double*)var->var->value;
															$$ = symt_insert_tab_cons_q(symt_new(), type, (double_value + *((int*)$3->cons->value)), var->var->q_direction);
														break;

														case CONS_CHAR:; case CONS_STR:;
															char *char_value = (char*)var->var->value;
															$$ = symt_insert_tab_cons_q(symt_new(), type, (char_value + *((int*)$3->cons->value)), var->var->q_direction);
														break;
													}
												}
				| IDENTIFIER					{
													is_expr = false;

													symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
													if (var == NULL) var = symt_search_by_name(tab, $1, VAR, NULL, 0);
													assertf(var != NULL, "variable %s has not been declared", $1);

													if (q_direction_var == 0 && is_var == true) q_direction_var = var->var->q_direction;
													type = symt_get_type_data(var->var->type);
													$$ = symt_insert_tab_cons_q(symt_new(), type, var->var->value, var->var->q_direction);
												}
				;

// __________ Constants and Data type __________

data_type 		: I8_TYPE { $$ = I8; }   | I16_TYPE { $$ = I16; }
				| I32_TYPE { $$ = I32; } | I64_TYPE { $$ = I64; }
				| F32_TYPE { $$ = F32; } | F64_TYPE { $$ = F64; }
				| CHAR_TYPE { $$ = C; }  | STR_TYPE { $$ = STR; }
				| BOOL_TYPE { $$ = B; }
				;

arr_data_type 	: I8_TYPE '[' int_expr ']'    	{
													value_list_expr_t = CONS_INTEGER; $$ = I8;
													array_length = *((int*)$3->cons->value);
												}
				| I16_TYPE '[' int_expr ']' 	{
													value_list_expr_t = CONS_INTEGER; $$ = I16;
													array_length = *((int*)$3->cons->value);
												}
				| I32_TYPE '[' int_expr ']'		{
													value_list_expr_t = CONS_INTEGER; $$ = I32;
													array_length = *((int*)$3->cons->value);
												}
				| I64_TYPE '[' int_expr ']'		{
													value_list_expr_t = CONS_INTEGER; $$ = I64;
													array_length = *((int*)$3->cons->value);
												}
				| F32_TYPE '[' int_expr ']'		{
													value_list_expr_t = CONS_DOUBLE; $$ = F32;
													array_length = *((int*)$3->cons->value);
												}
				| F64_TYPE '[' int_expr ']'		{
													value_list_expr_t = CONS_DOUBLE; $$ = F64;
													array_length = *((int*)$3->cons->value);
												}
				| CHAR_TYPE '[' int_expr ']'	{
													value_list_expr_t = CONS_CHAR; $$ = C;
													array_length = *((int*)$3->cons->value);
												}
				| BOOL_TYPE '[' int_expr ']'	{
													value_list_expr_t = CONS_INTEGER; $$ = B;
													array_length = *((int*)$3->cons->value);
												}
				;

// __________ Declaration for variables __________

param_declr 	: IDENTIFIER ':' data_type			{
														assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);
														symt_node* node = symt_insert_tab_var(symt_new(), $1, rout_name, $3, false, -1, NULL, false, level, q_direction);
														tab = symt_push(tab, node);
													}
				| IDENTIFIER ':' I8_TYPE '[' ']'	{
														assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);
														symt_node* node = symt_insert_tab_var( symt_new(), $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														tab = symt_push(tab, node); q_direction -= 4;
													}
				| IDENTIFIER ':' I16_TYPE '[' ']'	{
														assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);
														symt_node* node = symt_insert_tab_var(symt_new(), $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														tab = symt_push(tab, node); q_direction -= 4;
													}
				| IDENTIFIER ':' I32_TYPE '[' ']'	{
														assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);
														symt_node* node = symt_insert_tab_var(symt_new(), $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														tab = symt_push(tab, node); q_direction -= 4;
													}
				| IDENTIFIER ':' I64_TYPE '[' ']'	{
														assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);
														symt_node* node = symt_insert_tab_var(symt_new(), $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														tab = symt_push(tab, node); q_direction -= 4;
													}
				| IDENTIFIER ':' F32_TYPE '[' ']'	{
														assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);

														symt_node* node = symt_insert_tab_var(symt_new(), $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														tab = symt_push(tab, node); q_direction -= 8;
													}
				| IDENTIFIER ':' F64_TYPE '[' ']'	{
														assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);
														symt_node* node = symt_insert_tab_var(symt_new(), $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														tab = symt_push(tab, node); q_direction -= 8;
													}
				| IDENTIFIER ':' CHAR_TYPE '[' ']'	{
														assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);
														symt_node* node = symt_insert_tab_var(symt_new(), $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														tab = symt_push(tab, node); q_direction -= 4;
													}
				| IDENTIFIER ':' BOOL_TYPE '[' ']'	{
														assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);
														symt_node* node = symt_insert_tab_var(symt_new(), $1, rout_name, $3, 1, -1, NULL, 0, level, q_direction);
														tab = symt_push(tab, node); q_direction -= 4;
													}
				;

// __________ Declaration and Assignation for variables __________

list_expr 	: expr					{ $$ = symt_new_stack_elem(symt_get_name_from_node($1), symt_get_value_from_node($1), type, NULL); }
			| expr ',' list_expr	{ $$ = symt_new_stack_elem(symt_get_name_from_node($1), symt_get_value_from_node($1), type, $3); }
			;

var 		:   IDENTIFIER ':' data_type 										{
																					num_reg = 2; q_direction_var = 0; type = symt_get_type_data($3);
																					symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					assertf(var == NULL, "variable %s has already been declared", $1);

																					if (symt_get_type_data($3) == CONS_DOUBLE) q_direction -= 8; else q_direction -= 4;

																					symt_node* node = symt_insert_tab_var(symt_new(), $1, rout_name, $3, 0, 0, NULL, 0, level, q_direction);
																					qw_write_value_to_var(obj, symt_get_type_data($3), node->var->q_direction, node->var->value);
																					tab = symt_push(tab, node);
																				}
				| IDENTIFIER ':' arr_data_type									{
																					num_reg = 2; q_direction_var = 0; type = symt_get_type_data($3);
																					symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					assertf(var == NULL, "variable %s has already been declared", $1);

																					symt_node* node = symt_new();
																					node = symt_insert_tab_var(node, $1, rout_name, $3, 1, array_length, NULL, 0, level, q_direction);
																					//q_direction = qw_write_array(obj, symt_get_type_data($3), q_direction, node->var->array_length);
																					tab = symt_push(tab, node);
																				}
				| IDENTIFIER '=' expr											{
																					q_direction_var = 0;
																					symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					type = symt_get_type_data(var->var->type);
																					assertf(var != NULL, "variable %s has not been declared", $1);

																					num_reg = is_expr == true? 1 : 2;
																					symt_assign_var(var->var, $3->cons);
																					qw_write_reg_to_var(obj, num_reg, $3->cons->type, var->var->q_direction);
																					num_reg = 2;
																				}
				| IDENTIFIER '[' expr ']' '=' expr								{
																					num_reg = 2; q_direction_var = 0;
																					symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					type = symt_get_type_data(var->var->type);
																					assertf(var != NULL, "variable %s has not been declared", $1);

																					symt_assign_var_at(var->var, $6->cons, *((int*)$3->cons->value));
																					qw_write_value_to_var(obj, $6->cons->type, var->var->q_direction, var->var->value);
																				}
				| IDENTIFIER ':' data_type '=' expr								{
																					num_reg = 2; q_direction_var = 0; type = symt_get_type_data($3);
																					assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);

																					if (symt_get_type_data($3) == CONS_DOUBLE) q_direction -= 8; else q_direction -= 4;

																					symt_node* result = symt_insert_tab_var(symt_new(), $1, rout_name, $3, 0, 0, NULL, 0, level, q_direction);
																					symt_assign_var(result->var, $5->cons);
																					qw_write_reg_to_var(obj, num_reg, $5->cons->type, result->var->q_direction);
																					tab = symt_push(tab, result);
																				}
				| IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'			{
																					// ...........

																					num_reg = 2; q_direction_var = 0;
																					assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);

																					if (symt_get_type_data($3) == CONS_DOUBLE) q_direction -= 8; else q_direction -= 4;
																					tab = symt_insert_tab_var(tab, $1, rout_name, $3, 1, array_length, NULL, 0, level, q_direction);

																					symt_node* var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																					assertf(var != NULL, "variable %s has not been declared", $1);
																					assertf(var->var->type == $3, "type %s does not match %s at %s variable declaration", symt_strget_vartype(var->var->type), symt_strget_vartype($3), $1);
																					symt_stack *stack = $6, *stack_v = $6;

																					switch(value_list_expr_t)
																					{
																						case CONS_INTEGER:;
																							int *zero_int = (int *)(ml_malloc(sizeof(int)));
																							int *values_int = (int *)(ml_malloc(sizeof(int)*array_length));

																							for (int i = 0; i < array_length; i++)
																							{
																								symt_cons* cons = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																								cons->type = value_list_expr_t;

																								if (stack) cons->value = stack->value;
																								else cons->value = (void*)zero_int;

																								symt_can_assign(var->var->type, cons);
																								if(stack) stack = stack->next;
																								ml_free(cons);
																							}

																							for(int i = 0; stack_v; i++)
																							{
																								*(values_int+i) = *((int*)stack_v->value);
																								stack_v = stack_v->next;
																							}

																							var->var->value = (void*)values_int;
																						break;

																						case CONS_DOUBLE:;
																							double *zero_double = (double *)(ml_malloc(sizeof(double)));
																							double *values_double = (double *)(ml_malloc(sizeof(double)*array_length));

																							for(int i = 0; i < array_length; i++)
																							{
																								symt_cons* cons = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																								cons->type = value_list_expr_t;

																								if(stack) cons->value = stack->value;
																								else cons->value = (void*)zero_double;

																								symt_can_assign(var->var->type, cons);
																								if (stack) stack = stack->next;
																								ml_free(cons);
																							}

																							for(int i = 0; stack_v; i++)
																							{
																								*(values_double+i) = *((double*)stack_v->value);
																								stack_v = stack_v->next;
																							}

																							var->var->value = (void*)values_double;
																						break;

																						case CONS_CHAR:;
																							char *zero_char = (char *)(ml_malloc(sizeof(char)));
																							char *values_char = (char *)(ml_malloc(sizeof(char) * array_length));

																							for(int i = 0; i < array_length; i++)
																							{
																								symt_cons* cons = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																								cons->type = value_list_expr_t;

																								if(stack) cons->value = stack->value;
																								else cons->value = (void*)zero_char;

																								symt_can_assign(var->var->type, cons);
																								if(stack) stack = stack->next;
																								ml_free(cons);
																							}

																							for(int i = 0; stack_v; i++)
																							{
																								*(values_char+i) = *((char*)stack_v->value);
																								stack_v = stack_v->next;
																							}

																							var->var->value = (void*)values_char;
																						break;
																					}
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
																										assertf(symt_search_by_name(tab, rout_name, FUNCTION, NULL, 0) == NULL, "function %s has already been defined", rout_name);
																										tab = symt_insert_tab_rout(tab, FUNCTION, rout_name, $5, level++, label);
																										qw_write_routine(obj, rout_name, label++, false);
																									} EOL statement RETURN expr EOL END_FUNCTION {
																										symt_end_block(tab, level); level--;
																										qw_write_close_routine(obj, rout_name, false);
																										rout_name = NULL;
																									}
				;

proc_declr 		: BEGIN_PROCEDURE IDENTIFIER { rout_name = $2; } '(' declr_params ')' 				{
																										assertf(symt_search_by_name(tab, rout_name, PROCEDURE, NULL, 0) == NULL, "procedure %s has already been defined", rout_name);
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

														assertf(symt_search_param(tab, $2) == NULL, "%s routine does not need parameters", $2);
														qw_write_call(obj, result->rout->label, label++);
													}
				| CALL IDENTIFIER list_expr			{
														symt_node *result = symt_search_by_name(tab, $2, FUNCTION, NULL, 0);
														if (result == NULL) result = symt_search_by_name(tab, $2, PROCEDURE, NULL, 0);
														assertf(result != NULL, "%s routine does not exist", $2);

														symt_node *params = symt_search_param(tab, $2);
														assertf(params != NULL, "%s routine needs parameters", $2);

														symt_stack* iter = $3;
														symt_node *iter_p = params;
														bool no_more_params = false;

														while (true)
														{
															if (iter_p->id != VAR) { no_more_params = true; break; }
															if (strcmp(iter_p->var->rout_name, $2) != 0) { no_more_params = true; break; }
															if (iter != NULL) break;

															assertp(iter->type == symt_get_type_data(iter_p->var->type), "type does not match");

															switch(iter->type)
															{
																case CONS_INTEGER: case CONS_BOOL:;
																	int *int_value = (int*)iter->value;
																	symt_assign_var(iter_p->var, symt_new_cons(iter->type, int_value, 0));
																break;

																case CONS_DOUBLE:;
																	double *double_value = (double*)iter->value;
																	symt_assign_var(iter_p->var, symt_new_cons(iter->type, double_value, 0));
																break;

																case CONS_CHAR: case CONS_STR:;
																	char *char_value = (char*)iter->value;
																	symt_assign_var(iter_p->var, symt_new_cons(iter->type, char_value, 0));
																break;
															}

															if (iter_p->var->is_array == true)
															{
																symt_node *aux = symt_search_by_name(tab, iter->name, VAR, NULL, level);
																iter_p->var->array_length = aux->var->array_length;
															}

															iter = iter->next;
															iter_p = iter_p->next_node;
														}

														assertp(iter == NULL && no_more_params == true, "invalid number of parameters");
														qw_write_call(obj, result->rout->label, label++);
													}
				;

// __________ Assignation for variables __________

var_assign      : IDENTIFIER '=' expr					{
															symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
															assertf(var != NULL, "variable %s has not been declared", $1);
															symt_assign_var(var->var, $3->cons);
															qw_write_reg_to_var(obj, 1, $3->cons->type, var->var->q_direction);
														}
                | IDENTIFIER '[' int_expr ']' '=' expr	{
															symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
															assertf(var != NULL, "variable %s has not been declared", $1);
															symt_assign_var_at(var->var, $6->cons, *((int*)$3->cons->value));
															// ............
														}
                ;

// __________ Statement __________

statement 		: { $$ = false; is_var = true; } | var { is_var = false; } EOL statement { $$ = true; }
				| { level++; is_var = false; } BEGIN_IF '(' expr ')' { qw_write_condition(obj, label); num_reg = 2; $<integer_t>$=label++; } EOL statement { qw_write_new_label(obj, $<integer_t>6); } more_else	END_IF { symt_end_block(tab, level); level--; } EOL statement { $$ = true; }
				| { level++; begin_last_loop=label; $<integer_t>$=label; qw_write_begin_loop(obj, label++); is_var = false; } BEGIN_WHILE '(' expr ')' { qw_write_condition(obj, label); end_last_loop=label; num_reg = 2; $<integer_t>$=label++; } EOL statement END_WHILE { symt_end_block(tab, level); level--; qw_write_end_loop(obj, $<integer_t>1, $<integer_t>6); } EOL statement { $$ = true; }
				| { level++; is_var = true; } BEGIN_FOR '(' var ',' { is_var = false; begin_last_loop=label; $<integer_t>$=label; qw_write_begin_loop(obj, label++); } var_assign ',' expr ')'	{ qw_write_condition(obj, label); end_last_loop=label; num_reg = 2; $<integer_t>$=label++; } EOL statement END_FOR { symt_end_block(tab, level); level--; qw_write_end_loop(obj, $<integer_t>6, $<integer_t>11); } EOL statement { $$ = true; }
				| { level++; } call_func EOL statement	{ level--; $$ = true; }
				| CONTINUE { qw_write_goto(obj, begin_last_loop); } EOL statement { $$ = true; }
                | BREAK { qw_write_goto(obj, end_last_loop); } EOL statement { $$ = true; }
				| EOL statement { if ($2 != false) $$ = true; else $$ = false; }
				| error EOL { printf(" at expression\n"); } statement { $$ = true; }
				;

more_else 		: { $$ = false; } | ELSE_IF { symt_end_block(tab, level); } EOL statement { $$ = true; }
				| ELSE_IF { symt_end_block(tab, level); } BEGIN_IF '(' expr ')' { qw_write_condition(obj, label); $<integer_t>$=label++;  } EOL statement { qw_write_new_label(obj, $<integer_t>7); } more_else { $$ = true; }
				;

// __________ Main program __________

program 		: | var program | func_declr program
				| proc_declr program | EOL program
				;

%%

int main(int argc, char **argv)
{
	if (argc == 2)
	{
		tab = symt_new();

		symt_name_t object_f = strappend(argv[1], ".q.c");
		obj = qw_new(object_f); qw_prepare(obj);
		yyin = fopen(argv[1], "r");

		yyparse();
		qw_close(obj, label);
		fclose(yyin);

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
