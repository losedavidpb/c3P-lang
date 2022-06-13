%{
	// parser.y
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
	 * Syntax analyzer for c3p language
	 */

	#include <stdio.h>
	#include <string.h>
	#include <stdbool.h>
	#include <unistd.h>
	#include <stdio.h>

	#include "include/symt.h"
	#include "include/assertb.h"
	#include "include/arrcopy.h"
	#include "include/memlib.h"
	#include "include/qwriter.h"
	#include "include/f_reader.h"

	extern FILE *yyin;								// Current file for Bison
	int yydebug = 1; 								// Enable this to active debug mode

	FILE *obj;										// Object file for Q code
	symt_natural_t q_dir = QW_FIRST_DIR;			// Direction to store globals
	symt_natural_t q_dir_var;						// Direction for local variables and parameters
	symt_natural_t section_label = 0;				// Section label for STAT and CODE
	symt_natural_t num_reg = 2;						// Current register used to store a value

	symt_natural_t level = 0;						// Current level of symbol table
	symt_natural_t label = 2;						// Label that will be created at Q file
	symt_tab *tab; 									// Symbol table

	bool globals = true;							// Specify if variables are globals
	bool is_var;									// Specify if next symbols are variables
	symt_natural_t offset;							// Offset for local variables and parameters
	symt_natural_t prev_offset;						// Previous offset for local variables and parameters

	symt_cons_t type;								// Type of a value defined as constant
	bool is_expr;									// Check if current line is an expression
	symt_natural_t num_int_cons = 0;				// Number of integer constants stored at memory
	symt_natural_t num_double_cons = 0;				// Number of double constants stored at memory

	symt_natural_t begin_last_loop = 0;				// Label for the start of a loop
	symt_natural_t end_last_loop = 0;				// Label for the end of a loop

	symt_natural_t array_length = 0;  				// Array length for current token
	void *value_list_expr; 							// Array value for current token
	symt_cons_t value_list_expr_t;					// Constant for a part of a list expression

	bool is_call = false;							// Check if it is a call statement
	symt_name_t rout_name;							// Routine name for variables
	bool is_param;									// Check if it is a parameter

	// Just to avoid warnings
	int ends_with(const char*, const char*, symt_natural_t);
	void free_mem(bool);
	int yylex(void);
	void yyerror(const char *s);
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

%token<string_t> IDENTIFIER
%token<integer_t> INTEGER T F
%token<double_t> DOUBLE
%token<char_t> CHAR

%token<integer_t> I8_TYPE I16_TYPE I32_TYPE I64_TYPE
%token<integer_t> F32_TYPE F64_TYPE
%token<integer_t> CHAR_TYPE
%token<integer_t> BOOL_TYPE

%token BEGIN_IF END_IF ELSE_IF
%token BEGIN_FOR END_FOR BEGIN_WHILE END_WHILE CONTINUE BREAK
%token BEGIN_PROCEDURE END_PROCEDURE BEGIN_FUNCTION END_FUNCTION RETURN CALL
%token ARRLENGTH SHOW SHOWLN
%token AND OR NOT

%token EQUAL "=="
%token NOTEQUAL "!="
%token LESSEQUAL "<="
%token MOREEQUAL ">="

%token EOL

%type<integer_t> data_type arr_data_type statement more_else;
%type<node_t> expr_num expr_char int_expr expr iden_expr;
%type<stack_t> list_expr

%left OR AND
%left EQUAL NOTEQUAL
%left '<' '>' LESSEQUAL MOREEQUAL

%left '+' '-'
%left '*' '/' '%'
%right '^'
%right NOT

%left '(' ')' ':' ',' '[' ']' '{' '}'
%right '='

%start init
%define parse.error verbose

%%

// __________ Expression __________

expr 			: expr_num	{ $$ = $1; }   | expr_char	{ $$ = $1; }
				| iden_expr	{ $$ = $1; }   | '(' expr ')' { $$ = $2; }
				;

int_expr 		: '(' int_expr ')' 				{ is_expr = false; $$ = $2; }
				| INTEGER 						{
													type = CONS_INTEGER; is_expr = false; is_param = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_INTEGER, &$1, offset, false);
												}
				;

expr_num 		: T 							{
													type = CONS_BOOL; int true_val = 1; is_expr = false; offset += 4; is_param = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_BOOL, &true_val, offset, false);

													if (!is_call)
													{
														qw_push_fp(obj, CONS_BOOL);
														num_int_cons++;
														fprintf(obj, "\n\tR1=%d;\t", 1);
														qw_write_reg_to_var(obj, 1, type, 0);
													}
												}
				| F 							{
													type = CONS_BOOL; int false_val = 0; is_expr = false;  offset += 4; is_param = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_BOOL, &false_val, offset, false);

													if(!is_call)
													{
														qw_push_fp(obj, CONS_BOOL);
														num_int_cons++;
														fprintf(obj, "\n\tR1=%d;\t", 0);
														qw_write_reg_to_var(obj, 1, type, 0);
													}
												}
				| DOUBLE 						{
													type = CONS_DOUBLE; is_expr = false;  offset += 8; is_param = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_DOUBLE, &$1, offset, false);

													if(!is_call)
													{
														qw_push_fp(obj, CONS_DOUBLE);
														num_double_cons++;
														fprintf(obj, "\n\tRR1=%f;\t", *((double*)$$->cons->value));
														qw_write_reg_to_var(obj, 1, type, 0);
													}
												}
				| INTEGER 						{
													type = CONS_INTEGER; is_expr = false; offset += 4; is_param = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_INTEGER, &$1, offset, false);

													if(!is_call)
													{
														qw_push_fp(obj, CONS_INTEGER);
														num_int_cons++;
														fprintf(obj, "\n\tR1=%d;\t", *((int*)$$->cons->value));
														qw_write_reg_to_var(obj, 1, type, 0);
													}
												}
				;

expr_char       : CHAR                          {
													type = CONS_CHAR; is_expr = false; offset += 4; is_param = false;
													$$ = symt_insert_tab_cons(symt_new(), CONS_CHAR, &$1, offset, false);

													if(!is_call)
													{
														qw_push_fp(obj, CONS_CHAR);
														num_int_cons++;
														fprintf(obj, "\n\tR1=%d;\t", (*(int*)$$->cons->value));
														qw_write_reg_to_var(obj, 1, type, 0);
													}
                                                }
				;

iden_expr		: expr '+' expr					{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_ADD, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if (type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_add(type, $1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete($1); symt_delete($3);
												}
				| expr '-' expr 				{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_SUB, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_sub(type, $1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete($1); symt_delete($3);
												}
				| expr '*' expr 				{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_MULT, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_mult(type, $1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete_node($1); symt_delete_node($3);
												}
				| expr '/' expr 				{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_DIV, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_div(type, $1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete_node($1); symt_delete_node($3);
												}
				| expr '%' expr 				{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_MOD, type, label++);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_mod(type, $1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete_node($1); symt_delete_node($3);
												}
				| expr '^' expr 				{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_POW, type, label++);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_pow(type, $1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete_node($1); symt_delete_node($3);
												}
				| expr '<' expr 				{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_LESS, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_lt($1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete($1); symt_delete($3);
												}
				| expr '>' expr 				{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_GREATER, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_gt($1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete($1); symt_delete($3);
												}
				| expr EQUAL expr 				{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_EQUAL, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_eq($1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete($1); symt_delete($3);
												}
				| expr NOTEQUAL expr 			{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_NOT_EQUAL, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_neq($1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete($1); symt_delete($3);
												}
				| expr LESSEQUAL expr 			{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_LESS_THAN, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_leq($1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete($1); symt_delete($3);
												}
				| expr MOREEQUAL expr 			{
													assertp(globals == false, "globals could not be defined with expressions");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_GREATER_THAN, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													$$ = symt_new(); $$->id = CONSTANT;
													$$->cons = symt_cons_geq($1->cons, $3->cons);
													$$->cons->offset = offset;
													symt_delete($1); symt_delete($3);
												}
				| expr AND expr 				{
													assertp(globals == false, "globals could not be defined with expressions");
													assertf(type != CONS_CHAR, "char types does not support logic operation");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_AND, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													int result = *((int*)$1->cons->value) && *((int*)$3->cons->value);
													$$ = symt_insert_tab_cons(symt_new(), CONS_BOOL, &result, offset, false);
													symt_delete($1); symt_delete($3);
												}
				| expr OR expr 					{
													assertp(globals == false, "globals could not be defined with expressions");
													assertf(type != CONS_CHAR, "char types does not support logic operation");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($1->cons->offset != 0 || $1->cons->is_param) qw_write_var_to_reg_with_R6(obj, 2, type, $1->cons->offset, $1->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 2, type, $1->cons->q_dir);

													if ($3->cons->offset != 0 || $3->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $3->cons->offset, $3->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $3->cons->q_dir);

													qw_write_expr(obj, QW_OR, type, -1);
													qw_push_fp(obj, $1->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													int result = *((int*)$1->cons->value) || *((int*)$3->cons->value);
													$$ = symt_insert_tab_cons(symt_new(), CONS_BOOL, &result, offset, false);
													symt_delete($1); symt_delete($3);
												}
				| NOT expr 						{
													assertp(globals == false, "globals could not be defined with expressions");
													assertf(type != CONS_CHAR, "char types does not support logic operation");

													symt_node* rout = symt_search_routine(tab, rout_name);
													bool is_void = rout->rout->type == VOID;

													if ($2->cons->offset != 0 || $2->cons->is_param) qw_write_var_to_reg_with_R6(obj, 1, type, $2->cons->offset, $2->cons->is_param, is_void);
													else qw_write_var_to_reg(obj, 1, type, $2->cons->q_dir);

													qw_write_expr(obj, QW_NOT, type, -1);
													qw_push_fp(obj, $2->cons->type);

													if(type == CONS_DOUBLE) { num_double_cons++; offset += 8;
													} else { num_int_cons++; offset += 4; }

													qw_write_reg_to_var(obj, 1, type, 0);

													int result = !(*((int*)$2->cons->value));
													$$ = symt_insert_tab_cons(symt_new(), CONS_BOOL, &result, offset, false);
													symt_delete($2);
												}
				| IDENTIFIER '[' expr ']'		{
													symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
													if (var == NULL) var = symt_search_by_name(tab, $1, VAR, NULL, 0);
													assertf(var != NULL, "variable %s has not been declared", $1);
													assertf($3->cons->type == CONS_INTEGER, "index must be an integer");
													free_mem(false);

													switch(symt_get_type_data(var->var->type))
													{
														case CONS_INTEGER:; case CONS_BOOL:;
															int *int_value = (int*)var->var->value;
															$$ = symt_insert_tab_cons_q(symt_new(), symt_get_type_data(var->var->type), (int_value + *((int*)$3->cons->value)), var->var->q_dir, offset, false);
															if(!is_call) qw_write_array_to_reg(obj, 1, symt_get_type_data(var->var->type), var->var->q_dir, *((int*)$3->cons->value), var->var->offset);
														break;

														case CONS_DOUBLE:;
															double *double_value = (double*)var->var->value;
															$$ = symt_insert_tab_cons_q(symt_new(), symt_get_type_data(var->var->type), (double_value + *((int*)$3->cons->value)), var->var->q_dir, offset, false);
															if(!is_call) qw_write_array_to_reg(obj, 1, symt_get_type_data(var->var->type), var->var->q_dir, *((int*)$3->cons->value), var->var->offset);
														break;

														case CONS_CHAR:;
															char *char_value = (char*)var->var->value;
															$$ = symt_insert_tab_cons_q(symt_new(), symt_get_type_data(var->var->type), (char_value + *((int*)$3->cons->value)), var->var->q_dir, offset, false);
															if(!is_call) qw_write_array_to_reg(obj, 1, symt_get_type_data(var->var->type), var->var->q_dir, *((int*)$3->cons->value), var->var->offset);
														break;
													}
												}
				| IDENTIFIER					{
													symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
													if (var == NULL) var = symt_search_by_name(tab, $1, VAR, NULL, 0);
													assertf(var != NULL, "variable %s has not been declared", $1);

													if (q_dir_var == 0 && is_var == true) q_dir_var = var->var->q_dir;
													type = symt_get_type_data(var->var->type);
													$$ = symt_insert_tab_cons_q(symt_new(), type, var->var->value, var->var->q_dir, var->var->offset, var->var->is_param);

													is_param = false;

													if (!is_call)
													{
														if (var->level == 0)
														{
															if (!var->var->is_param)
															{
																qw_write_var_to_reg(obj, 1, type, var->var->q_dir);
															}
															else
															{
																is_param = true;
																symt_node* rout = symt_search_routine(tab, rout_name);
																bool is_void = rout->rout->type == VOID;
																qw_write_var_to_reg_with_R6(obj, 1, type, var->var->offset, true, is_void);
															}
														}
														else
														{
															symt_node* rout = symt_search_routine(tab, rout_name);
															bool is_void = rout->rout->type == VOID;
															qw_write_var_to_reg_with_R6(obj, 1, type, var->var->offset, false, is_void);
														}
													}
												}
				;

// __________ Constants and Data type __________

data_type 		: I8_TYPE { $$ = I8; }   | I16_TYPE { $$ = I16; }
				| I32_TYPE { $$ = I32; } | I64_TYPE { $$ = I64; }
				| F32_TYPE { $$ = F32; } | F64_TYPE { $$ = F64; }
				| CHAR_TYPE { $$ = C; }  | BOOL_TYPE { $$ = B; }
				;

arr_data_type 	: I8_TYPE '[' int_expr ']'    	{ value_list_expr_t = CONS_INTEGER; $$ = I8; array_length = *((int*)$3->cons->value); }
				| I16_TYPE '[' int_expr ']' 	{ value_list_expr_t = CONS_INTEGER; $$ = I16; array_length = *((int*)$3->cons->value); }
				| I32_TYPE '[' int_expr ']'		{ value_list_expr_t = CONS_INTEGER; $$ = I32; array_length = *((int*)$3->cons->value); }
				| I64_TYPE '[' int_expr ']'		{ value_list_expr_t = CONS_INTEGER; $$ = I64; array_length = *((int*)$3->cons->value); }
				| F32_TYPE '[' int_expr ']'		{ value_list_expr_t = CONS_DOUBLE; $$ = F32; array_length = *((int*)$3->cons->value); }
				| F64_TYPE '[' int_expr ']'		{ value_list_expr_t = CONS_DOUBLE; $$ = F64; array_length = *((int*)$3->cons->value); }
				| CHAR_TYPE '[' int_expr ']'	{ value_list_expr_t = CONS_CHAR; $$ = C; array_length = *((int*)$3->cons->value); }
				| BOOL_TYPE '[' int_expr ']'	{ value_list_expr_t = CONS_INTEGER; $$ = B; array_length = *((int*)$3->cons->value); }
				;

// __________ Declaration for variables __________

param_declr 	: IDENTIFIER ':' data_type			{
														assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);

														symt_node* node = symt_insert_tab_var(symt_new(), $1, rout_name, $3, false, 0, NULL, true, level, q_dir, offset);
														tab = symt_push(tab, node);

														symt_natural_t size = symt_get_type_size(type);
														q_dir -= size; offset += size;
													}
				;

// __________ Declaration and Assignation for variables __________

list_expr 	: expr					{ $$ = symt_new_stack_elem(symt_get_name_from_node($1), symt_get_value_from_node($1), type, $1->cons->q_dir, $1->cons->offset, false, NULL); }
			| expr ',' list_expr	{ $$ = symt_new_stack_elem(symt_get_name_from_node($1), symt_get_value_from_node($1), type, $1->cons->q_dir, $1->cons->offset, false, $3); }
			;

var 		:   IDENTIFIER ':' data_type 															{
																										symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																										assertf(var == NULL, "variable %s has already been declared", $1);

																										symt_natural_t size = symt_get_type_size($3);
																										q_dir -= size; offset += size;

																										symt_node* node = symt_new();
																										node = symt_insert_tab_var(node, $1, rout_name, $3, 0, 0, NULL, 0, level, q_dir, offset);
																										type = symt_get_type_data($3);

																										qw_push_fp(obj, type);
																										qw_write_value_to_var(obj, type, node->var->value);

																										tab = symt_push(tab, node);
																									}
				| IDENTIFIER ':' arr_data_type														{
																										symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																										assertf(var == NULL, "variable %s has already been declared", $1);

																										symt_natural_t size = symt_get_type_size($3);
																										offset += size * array_length;

																										symt_node* node = symt_new();
																										node = symt_insert_tab_var(node, $1, rout_name, $3, 1, array_length, NULL, 0, level, q_dir, offset);
																										q_dir = qw_write_array(obj, symt_get_type_data($3), q_dir, node->var->array_length, ++section_label, offset, globals);

																										tab = symt_push(tab, node);
																									}
				| IDENTIFIER '=' expr																{
																										symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																										type = symt_get_type_data(var->var->type);
																										assertf(var != NULL, "variable %s has not been declared", $1);

																										symt_assign_var(var->var, $3->cons);

																										if (var->level == 0) qw_write_reg_to_var(obj, 1, $3->cons->type, var->var->q_dir);
																										else qw_write_reg_to_var_with_R6(obj, 1, $3->cons->type, var->var->offset, var->var->is_param);
																									}
				| IDENTIFIER '[' expr ']' '=' expr													{
																										symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																										type = symt_get_type_data(var->var->type);
																										assertf(var != NULL, "variable %s has not been declared", $1);

																										symt_assign_var_at(var->var, $6->cons, *((int*)$3->cons->value));
																										qw_write_reg_to_array(obj, 1, $6->cons->type, var->var->q_dir, *((int*)$3->cons->value), var->var->offset);

																										free_mem(true);
																									}
				| IDENTIFIER ':' data_type '=' expr													{
																										assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);

																										free_mem(true);
																										symt_natural_t size = symt_get_type_size(type);
																										q_dir -= size; if (!globals) offset += size;

																										symt_node* result = symt_insert_tab_var(symt_new(), $1, rout_name, $3, 0, 0, NULL, 0, level, q_dir, offset);
																										symt_assign_var(result->var, $5->cons);

																										qw_push_fp(obj, $5->cons->type);
																										qw_write_reg_to_var(obj, 1, $5->cons->type, 0);
																										tab = symt_push(tab, result);
																									}
				| IDENTIFIER ':' arr_data_type '=' { is_call = true; prev_offset = offset; } '{' list_expr '}'			{
																										is_call = false; offset = prev_offset;
																										assertf(symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL, "variable %s has already been declared", $1);

																										if (symt_get_type_data($3) == CONS_DOUBLE) { offset += 8 * array_length; }
																										else { offset += 4 * array_length; }

																										tab = symt_insert_tab_var(tab, $1, rout_name, $3, 1, array_length, NULL, 0, level, q_dir, offset);

																										symt_node* var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																										assertf(var != NULL, "variable %s has not been declared", $1);
																										assertf(var->var->type == $3, "type %s does not match %s at %s variable declaration", symt_strget_vartype(var->var->type), symt_strget_vartype($3), $1);
																										symt_stack *stack = $7, *stack_v = $7;

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

																										int pre_q_dir = q_dir;
																										q_dir = qw_write_array(obj, symt_get_type_data($3), q_dir, array_length, ++section_label, offset, globals);

																										for(int i = 0; i < var->var->array_length; i++)
																										{
																											switch(value_list_expr_t)
																											{
																												case CONS_INTEGER: case CONS_BOOL:;
																													int *value_int = (int*)(var->var->value)+i;
																													qw_write_value_to_reg(obj, 1, symt_get_type_data($3), (void*)value_int);
																													qw_write_reg_to_array(obj, 1, symt_get_type_data($3), pre_q_dir, i, offset);
																												break;
																												case CONS_DOUBLE:;
																													double *value_double = (double*)(var->var->value)+i;
																													qw_write_value_to_reg(obj, 1, symt_get_type_data($3), (void*)value_double);
																													qw_write_reg_to_array(obj, 1, symt_get_type_data($3), pre_q_dir, i, offset);
																												break;
																												case CONS_CHAR:;
																													char *value_char = (char*)(var->var->value)+i;
																													qw_write_value_to_reg(obj, 1, symt_get_type_data($3), (void*)value_char);
																													qw_write_reg_to_array(obj, 1, symt_get_type_data($3), pre_q_dir, i, offset);
																												break;
																											}
																										}

																										if (symt_get_type_data($3) == CONS_DOUBLE) q_dir -= 8 * array_length;
																										else q_dir -= 4 * array_length;
																									}
				| call_assing
				;

call_assing		:	IDENTIFIER '=' CALL IDENTIFIER									{
																						symt_node *result = symt_search_by_name(tab, $4, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $4, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $4);

																						assertf(result->id != PROCEDURE, "%s routine is a procedure, procedures does not return values", $4);

																						symt_node *params = symt_search_params(tab, $4);
																						assertf(params == NULL, "%s routine does need parameters", $4);

																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						assertf(result->rout->type == var->var->type, "type does not match");
																						int size = 0;

																						if(result->id == FUNCTION)
																						{
																							type = symt_get_type_data(result->rout->type);

																							switch(type)
																							{
																								case CONS_INTEGER: case CONS_BOOL: case CONS_CHAR: size = 4; break;
																								case CONS_DOUBLE: size = 8; break;
																							}
																						}
																						qw_write_call_return(obj, result->rout->label, label++, size, type);

																						if (var->level == 0)
																						{
																							if (!var->var->is_param)
																								qw_write_reg_to_var(obj, 1, type, var->var->q_dir);
																							else
																							{
																								is_param = true;
																								symt_node* rout = symt_search_routine(tab, rout_name);
																								bool is_void = rout->rout->type == VOID;
																								qw_write_var_to_reg_with_R6(obj, 1, type, var->var->offset, true, is_void);
																							}
																						}
																						else
																						{
																							qw_write_reg_to_var_with_R6(obj, 1, type, var->var->offset, false);
																						}
																					}
				| 	IDENTIFIER  '='  CALL IDENTIFIER list_expr						{
																						symt_node *result = symt_search_by_name(tab, $4, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $4, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $4);

																						assertf(result->id != PROCEDURE, "%s routine is a procedure, procedures does not return values", $4);

																						symt_node *params = symt_search_params(tab, $4);
																						assertf(params != NULL, "%s routine does not need parameters", $4);

																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						assertf(result->rout->type == var->var->type, "type does not match");

																						symt_node* rout = symt_search_routine(tab, rout_name);
																						bool is_void = rout->rout->type == VOID;

																						symt_stack* iter = $5;
																						symt_node *iter_p = params;
																						bool no_more_params = false;
																						symt_natural_t r7_offset = 0;
																						symt_natural_t num_params_curr = 0;

																						while (true)
																						{
																							if (iter_p->id != VAR) { no_more_params = true; break; }
																							if (strcmp(iter_p->var->rout_name, $4) != 0) { no_more_params = true; break; }
																							if (iter == NULL) break;

																							symt_cons_t param_type = symt_get_type_data(iter_p->var->type);
																							symt_cons_t arg_type = symt_get_type_data(iter->type);
																							assertp(arg_type == param_type, "type does not match");

																							switch(arg_type)
																							{
																								case CONS_INTEGER: case CONS_BOOL:;
																									r7_offset += 4;
																									int *int_value = (int*)iter->value;
																									symt_assign_var(iter_p->var, symt_new_cons(iter->type, int_value, 0, 0, false));

																									if (iter->offset != 0) qw_write_var_to_reg_with_R6(obj, 1, arg_type, iter->offset, false, is_void);
																									else qw_write_var_to_reg(obj, 1, arg_type, iter->q_dir);

																									fprintf(obj, "\n\tR7=R7-4;\t// Set space for parameter");
																									fprintf(obj, "\n\tI(R7)=R1;\t// Save new value for parameter");
																								break;

																								case CONS_DOUBLE:;
																									r7_offset += 8;
																									double *double_value = (double*)iter->value;
																									symt_assign_var(iter_p->var, symt_new_cons(iter->type, double_value, 0, 0, false));

																									if (iter->offset != 0) qw_write_var_to_reg_with_R6(obj, 1, arg_type, iter->offset, false, is_void);
																									else qw_write_var_to_reg(obj, 1, arg_type, iter->q_dir);

																									fprintf(obj, "\n\tR7=R7-8;\t// Set space for parameter");
																									fprintf(obj, "\n\tD(R7)=RR1;\t// Save new value for parameter");
																								break;

																								case CONS_CHAR:
																									r7_offset += 4;
																									char *char_value = (char*)iter->value;
																									symt_assign_var(iter_p->var, symt_new_cons(iter->type, char_value, 0, 0, false));

																									if (iter->offset != 0) qw_write_var_to_reg_with_R6(obj, 1, arg_type, iter->offset, false, is_void);
																									else qw_write_var_to_reg(obj, 1, arg_type, iter->q_dir);

																									fprintf(obj, "\n\tR7=R7-4;\t// Set space for parameter");
																									fprintf(obj, "\n\tI(R7)=R1;\t// Save new value for parameter");
																								break;
																							}

																							if (iter_p->var->is_array == true)
																							{
																								symt_node *aux = symt_search_by_name(tab, iter->name, VAR, NULL, level);
																								iter_p->var->array_length = aux->var->array_length;
																							}

																							iter = iter->next;
																							iter_p = iter_p->next_node;
																							num_params_curr++;
																						}

																						const symt_natural_t num_params = symt_num_params(tab, $4);
																						assertf(num_params_curr == num_params, "invalid number of parameters %d != %d", (int)num_params_curr, (int)num_params);
																						int size = 0;

																						if(result->id == FUNCTION)
																						{
																							type = symt_get_type_data(result->rout->type);

																							switch(type)
																							{
																								case CONS_INTEGER: case CONS_BOOL: case CONS_CHAR: size = 4; break;
																								case CONS_DOUBLE: size = 8; break;
																							}
																						}

																						qw_write_call_return(obj, result->rout->label, label++, size, type);
																						fprintf(obj, "\n\tR7=R7+%d;\t// Free parameters' space", (int)r7_offset);

																						if (var->level == 0)
																						{
																							if (!var->var->is_param)
																								qw_write_reg_to_var(obj, 1, type, var->var->q_dir);
																							else
																							{
																								is_param = true;
																								symt_node* rout = symt_search_routine(tab, rout_name);
																								bool is_void = rout->rout->type == VOID;
																								qw_write_var_to_reg_with_R6(obj, 1, type, var->var->offset, true, is_void);
																							}
																						}
																						else
																						{
																							qw_write_reg_to_var_with_R6(obj, 1, type, var->var->offset, false);
																						}
																					}
				| 	IDENTIFIER '[' expr ']' '='  CALL IDENTIFIER					{
																						symt_node *result = symt_search_by_name(tab, $7, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $7, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $7);

																						assertf(result->id != PROCEDURE, "%s routine is a procedure, procedures does not return values", $7);

																						symt_node *params = symt_search_params(tab, $7);
																						assertf(params == NULL, "%s routine does need parameters", $7);

																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						assertf(result->rout->type == var->var->type, "type does not match");
																						int size = 0;

																						if(result->id == FUNCTION)
																						{
																							type = symt_get_type_data(result->rout->type);

																							switch(type)
																							{
																								case CONS_INTEGER: case CONS_BOOL: case CONS_CHAR: size = 4; break;
																								case CONS_DOUBLE: size = 8; break;
																							}
																						}

																						qw_write_call_return(obj, result->rout->label, label++, size, type);
																						qw_write_reg_to_array(obj, 1, type, var->var->q_dir, *((int*)$3->cons->value), var->var->offset);
																					}
				| 	IDENTIFIER ':' data_type '=' CALL IDENTIFIER					{
																						symt_node *result = symt_search_by_name(tab, $6, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $6, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $6);

																						assertf(result->id != PROCEDURE, "%s routine is a procedure, procedures does not return values", $6);

																						symt_node *params = symt_search_params(tab, $6);
																						assertf(params == NULL, "%s routine does need parameters", $6);

																						if (symt_get_type_data($3) == CONS_DOUBLE){
																							q_dir -= 8;
																							offset += 8;
																						} else{
																							q_dir -= 4;
																							offset += 4;
																						}

																						assertf(result->rout->type == $3, "type does not match")
																						symt_node* node = symt_new();
																						node = symt_insert_tab_var(node, $1, rout_name,  $3, 0, 0, NULL, 0, level, q_dir, offset);
																						tab = symt_push(tab, node);

																						int size = 0;

																						if(result->id == FUNCTION){
																							type = symt_get_type_data(result->rout->type);

																							switch(type)
																							{
																								case CONS_INTEGER: case CONS_BOOL: case CONS_CHAR: size = 4; break;
																								case CONS_DOUBLE: size = 8; break;
																							}
																						}

																						qw_write_call_return(obj, result->rout->label, label++, size, type);

																						qw_push_fp(obj, symt_get_type_data($3));
																						qw_write_reg_to_var(obj,1,type,0);
																					}
				| 	IDENTIFIER ':' data_type '=' CALL IDENTIFIER list_expr			{
																						symt_node *result = symt_search_by_name(tab, $6, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $6, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $6);

																						assertf(result->id != PROCEDURE, "%s routine is a procedure, procedures does not return values", $6);

																						symt_node *params = symt_search_params(tab, $6);
																						assertf(params != NULL, "%s routine does not need parameters", $6);

																						if (symt_get_type_data($3) == CONS_DOUBLE){
																							q_dir -= 8;
																							offset += 8;
																						} else{
																							q_dir -= 4;
																							offset += 4;
																						}

																						assertf(result->rout->type == $3, "type does not match")
																						symt_node* node = symt_new();
																						node = symt_insert_tab_var(node, $1, rout_name,  $3, 0, 0, NULL, 0, level, q_dir, offset);
																						tab = symt_push(tab, node);

																						symt_node* rout = symt_search_routine(tab, rout_name);
																						bool is_void = rout->rout->type == VOID;

																						symt_stack* iter = $7;
																						symt_node *iter_p = params;
																						bool no_more_params = false;
																						symt_natural_t r7_offset = 0;
																						symt_natural_t num_params_curr = 0;

																						while (true)
																						{
																							if (iter_p->id != VAR) { no_more_params = true; break; }
																							if (strcmp(iter_p->var->rout_name, $6) != 0) { no_more_params = true; break; }
																							if (iter == NULL) break;

																							symt_cons_t param_type = symt_get_type_data(iter_p->var->type);
																							symt_cons_t arg_type = symt_get_type_data(iter->type);
																							assertp(arg_type == param_type, "type does not match");

																							switch(arg_type)
																							{
																								case CONS_INTEGER: case CONS_BOOL:;
																									r7_offset += 4;
																									int *int_value = (int*)iter->value;
																									symt_assign_var(iter_p->var, symt_new_cons(iter->type, int_value, 0, 0, false));

																									if (iter->offset != 0) qw_write_var_to_reg_with_R6(obj, 1, arg_type, iter->offset, false, is_void);
																									else qw_write_var_to_reg(obj, 1, arg_type, iter->q_dir);

																									fprintf(obj, "\n\tR7=R7-4;\t// Set space for parameter");
																									fprintf(obj, "\n\tI(R7)=R1;\t// Save new value for parameter");
																								break;

																								case CONS_DOUBLE:;
																									r7_offset += 8;
																									double *double_value = (double*)iter->value;
																									symt_assign_var(iter_p->var, symt_new_cons(iter->type, double_value, 0, 0, false));

																									if (iter->offset != 0) qw_write_var_to_reg_with_R6(obj, 1, arg_type, iter->offset, false, is_void);
																									else qw_write_var_to_reg(obj, 1, arg_type, iter->q_dir);

																									fprintf(obj, "\n\tR7=R7-8;\t");
																									fprintf(obj, "\n\tD(R7)=RR1;\t");
																								break;

																								case CONS_CHAR:
																									r7_offset += 4;
																									char *char_value = (char*)iter->value;
																									symt_assign_var(iter_p->var, symt_new_cons(iter->type, char_value, 0, 0, false));

																									if (iter->offset != 0) qw_write_var_to_reg_with_R6(obj, 1, arg_type, iter->offset, false, is_void);
																									else qw_write_var_to_reg(obj, 1, arg_type, iter->q_dir);

																									fprintf(obj, "\n\tR7=R7-4;\t// Set space for parameter");
																									fprintf(obj, "\n\tI(R7)=R1;\t// Save new value for parameter");
																								break;
																							}

																							if (iter_p->var->is_array == true)
																							{
																								symt_node *aux = symt_search_by_name(tab, iter->name, VAR, NULL, level);
																								iter_p->var->array_length = aux->var->array_length;
																							}

																							iter = iter->next;
																							iter_p = iter_p->next_node;
																							num_params_curr++;
																						}

																						const symt_natural_t num_params = symt_num_params(tab, $6);
																						assertf(num_params_curr == num_params, "invalid number of parameters %d != %d", (int)num_params_curr, (int)num_params);
																						int size = 0;

																						if(result->id == FUNCTION)
																						{
																							type = symt_get_type_data(result->rout->type);

																							switch(type)
																							{
																								case CONS_INTEGER: case CONS_BOOL: case CONS_CHAR: size = 4; break;
																								case CONS_DOUBLE: size = 8; break;
																							}
																						}

																						qw_write_call_return(obj, result->rout->label, label++, size, type);
																						fprintf(obj, "\n\tR7=R7+%d;\t// Free parameters' space", (int)r7_offset);

																						qw_push_fp(obj, symt_get_type_data($3));
																						qw_write_reg_to_var(obj,1,type,0);
																					}
				| 	IDENTIFIER '[' expr ']' '='  CALL IDENTIFIER list_expr			{
																						symt_node *result = symt_search_by_name(tab, $7, FUNCTION, NULL, 0);
																						if (result == NULL) result = symt_search_by_name(tab, $7, PROCEDURE, NULL, 0);
																						assertf(result != NULL, "%s routine does not exist", $7);

																						assertf(result->id != PROCEDURE, "%s routine is a function, you need to catch the returned value", $7);

																						symt_node *params = symt_search_params(tab, $7);
																						assertf(params != NULL, "%s routine does not need parameters", $7);

																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						assertf(result->rout->type == var->var->type, "type does not match");

																						symt_stack* iter = $8;
																						symt_node *iter_p = params;
																						bool no_more_params = false;
																						symt_natural_t r7_offset = 0;
																						symt_natural_t num_params_curr = 0;

																						while (true)
																						{
																							if (iter_p->id != VAR) { no_more_params = true; break; }
																							if (strcmp(iter_p->var->rout_name, $7) != 0) { no_more_params = true; break; }
																							if (iter == NULL) break;

																							symt_cons_t param_type = symt_get_type_data(iter_p->var->type);
																							symt_cons_t arg_type = symt_get_type_data(iter->type);
																							assertp(arg_type == param_type, "type does not match");

																							switch(arg_type)
																							{
																								case CONS_INTEGER: case CONS_BOOL:;
																									r7_offset += 4;
																									int *int_value = (int*)iter->value;
																									symt_assign_var(iter_p->var, symt_new_cons(iter->type, int_value, 0, 0, false));
																									qw_write_var_to_reg(obj, num_reg, param_type, iter->q_dir);
																								break;

																								case CONS_DOUBLE:;
																									r7_offset += 8;
																									double *double_value = (double*)iter->value;
																									symt_assign_var(iter_p->var, symt_new_cons(iter->type, double_value, 0, 0, false));
																									qw_write_var_to_reg(obj, num_reg, param_type, iter->q_dir);
																								break;

																								case CONS_CHAR:
																									r7_offset += 4;
																									char *char_value = (char*)iter->value;
																									symt_assign_var(iter_p->var, symt_new_cons(iter->type, char_value, 0, 0, false));
																									qw_write_var_to_reg(obj, num_reg, param_type, iter->q_dir);
																								break;
																							}

																							if (iter_p->var->is_array == true)
																							{
																								symt_node *aux = symt_search_by_name(tab, iter->name, VAR, NULL, level);
																								iter_p->var->array_length = aux->var->array_length;
																							}

																							iter = iter->next;
																							iter_p = iter_p->next_node;
																							num_params_curr++;
																						}

																						const symt_natural_t num_params = symt_num_params(tab, $7);
																						assertf(num_params_curr == num_params, "invalid number of parameters %d != %d", (int)num_params_curr, (int)num_params);
																						int size = 0;

																						if(result->id == FUNCTION)
																						{
																							type = symt_get_type_data(result->rout->type);

																							switch(type)
																							{
																								case CONS_INTEGER: case CONS_BOOL: case CONS_CHAR: size = 4; break;
																								case CONS_DOUBLE: size = 8; break;
																							}
																						}

																						qw_write_call_return(obj, result->rout->label, label++, size, type);
																						fprintf(obj, "\n\tR7=R7+%d;\t// Free parameters' space", (int)r7_offset);
																						qw_write_reg_to_array(obj, 1, type, var->var->q_dir, *((int*)$3->cons->value), var->var->offset);
																					}
				| 	IDENTIFIER '=' CALL ARRLENGTH IDENTIFIER						{
																						symt_node *var1 = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						if (var1 == NULL) var1 = symt_search_by_name(tab, $1, VAR, NULL, 0);
																						assertf(var1 != NULL, "variable %s has not been declared", $1);

																						symt_node *var2 = symt_search_by_name(tab, $5, VAR, rout_name, level);
																						if (var2 == NULL) var2 = symt_search_by_name(tab, $5, VAR, NULL, 0);
																						assertf(var2 != NULL, "variable %s has not been declared", $5);

																						assertp(CONS_INTEGER == symt_get_type_data(var1->var->type), "Type does not match");
																						assertp(var2->var->is_array == 1, "Variable is not an array");

																						symt_cons* arrlen = symt_new_cons(CONS_INTEGER, &var2->var->array_length, 0, 0, false);
																						symt_assign_var(var1->var, arrlen);
																						fprintf(obj, "\n\tR1=%d;\t", (int)var2->var->array_length);
																						symt_delete_cons(arrlen);

																						if (var1->level == 0)
																						{
																							if (!var1->var->is_param)
																								qw_write_reg_to_var(obj, 1, CONS_INTEGER, var1->var->q_dir);
																							else
																							{
																								is_param = true;
																								symt_node* rout = symt_search_routine(tab, rout_name);
																								bool is_void = rout->rout->type == VOID;
																								qw_write_var_to_reg_with_R6(obj, 1, CONS_INTEGER, var1->var->offset, true, is_void);
																							}
																						}
																						else
																						{
																							qw_write_reg_to_var_with_R6(obj, 1, CONS_INTEGER, var1->var->offset, false);
																						}
																					}
				| 	IDENTIFIER ':' data_type '=' CALL ARRLENGTH IDENTIFIER			{
																						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						assertf(var == NULL, "variable %s has already been declared", $1);

																						if (symt_get_type_data($3) == CONS_DOUBLE) { q_dir -= 8; offset += 8; }
																						else { q_dir -= 4; offset += 4; }

																						symt_node* node = symt_insert_tab_var(symt_new(), $1, rout_name, $3, 0, 0, NULL, 0, level, q_dir, offset);
																						tab = symt_push(tab, node);

																						symt_node *var1 = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						if (var1 == NULL) var1 = symt_search_by_name(tab, $1, VAR, NULL, 0);
																						assertf(var1 != NULL, "variable %s has not been declared", $1);

																						symt_node *var2 = symt_search_by_name(tab, $7, VAR, rout_name, level);
																						if (var2 == NULL) var2 = symt_search_by_name(tab, $7, VAR, NULL, 0);
																						assertf(var2 != NULL, "variable %s has not been declared", $7);

																						assertp(CONS_INTEGER == symt_get_type_data(var1->var->type), "Type does not match");
																						assertp(var2->var->is_array == 1, "Variable is not an array");

																						fprintf(obj, "\n\tR1=%d;\t// Load length for current array", (int)var2->var->array_length);

																						qw_push_fp(obj, CONS_INTEGER);
																						qw_write_reg_to_var(obj, 1, CONS_INTEGER, 0);
																					}
				| 	IDENTIFIER '[' expr ']' '='  CALL ARRLENGTH IDENTIFIER			{
																						symt_node *var1 = symt_search_by_name(tab, $1, VAR, rout_name, level);
																						if (var1 == NULL) var1 = symt_search_by_name(tab, $1, VAR, NULL, 0);
																						assertf(var1 != NULL, "variable %s has not been declared", $1);

																						symt_node *var2 = symt_search_by_name(tab, $8, VAR, rout_name, level);
																						if (var2 == NULL) var2 = symt_search_by_name(tab, $8, VAR, NULL, 0);
																						assertf(var2 != NULL, "variable %s has not been declared", $8);

																						assertp(CONS_INTEGER == symt_get_type_data(var1->var->type), "Type does not match");
																						assertp(var2->var->is_array == 1, "Variable is not an array");

																						symt_cons* arrlen = symt_new_cons(CONS_INTEGER, &var2->var->array_length, 0, 0, false);
																						symt_assign_var_at(var1->var, arrlen, *((int*)$3->cons->value));
																						fprintf(obj, "\n\tR1=%d;\t// Load length for current array", (int)var2->var->array_length);
																						symt_delete_cons(arrlen);

																						qw_write_reg_to_array(obj, 1, CONS_INTEGER, var1->var->q_dir, *((int*)$3->cons->value), var1->var->offset);
																					}
				;

// __________ Procedures and functions __________

func_declr 		: BEGIN_FUNCTION IDENTIFIER { rout_name = $2; offset = 0; } ':' data_type '(' declr_params ')' 	{
																													assertf(symt_search_by_name(tab, rout_name, FUNCTION, NULL, 0) == NULL, "function %s has already been defined", rout_name);
																													tab = symt_insert_tab_rout(tab, FUNCTION, rout_name, $5, level++, label);
																													qw_write_routine(obj, rout_name, label++);
																													symt_invert_offset(tab, rout_name); offset = 0;
																												} EOL statement RETURN expr EOL END_FUNCTION {
																													num_reg = 2; symt_end_block(tab, level--);
																													type = symt_get_type_data($5);
																													symt_natural_t size = symt_get_type_size(type);

																													assertf(type == $13->cons->type, "function %s returned type does not match", $2);
																													qw_write_close_routine_function(obj, rout_name, (int)size, $13->cons->type, $13->cons->q_dir, $13->cons->offset, is_param);
																													rout_name = NULL; num_int_cons = 0; num_double_cons = 0;
																												}
				;

proc_declr 		: BEGIN_PROCEDURE IDENTIFIER { rout_name = $2; offset = 0; } '(' declr_params ')' 				{
																													assertf(symt_search_by_name(tab, rout_name, PROCEDURE, NULL, 0) == NULL, "procedure %s has already been defined", rout_name);

																													if (strcmp(rout_name, "main") == 0)
																													{
																														tab = symt_insert_tab_rout(tab, PROCEDURE, rout_name, VOID, level++, 1);
																														qw_write_routine(obj, rout_name, 1);
																													}
																													else
																													{
																														tab = symt_insert_tab_rout(tab, PROCEDURE, rout_name, VOID, level++, label);
																														qw_write_routine(obj, rout_name, label++);
																													}

																													symt_invert_offset(tab, rout_name); offset = 0;
																												} EOL statement END_PROCEDURE {
																													qw_write_close_routine(obj, rout_name, strcmp(rout_name, "main") == 0);
																													symt_end_block(tab, level--);
																													rout_name = NULL; num_int_cons = 0; num_double_cons = 0;
																												}
				;

// __________ Parameters __________

declr_params 	: | param_declr ',' declr_params
				| param_declr
				;

// __________ Call a function __________

call_func 		: CALL IDENTIFIER										{
																			symt_node *result = symt_search_by_name(tab, $2, FUNCTION, NULL, 0);
																			if (result == NULL) result = symt_search_by_name(tab, $2, PROCEDURE, NULL, 0);
																			assertf(result != NULL, "%s routine does not exist", $2);
																			assertf(result->id != FUNCTION, "%s routine is a function, you must catch the returned value", $2);

																			assertf(symt_search_params(tab, $2) == NULL, "%s routine does not need parameters", $2);
																			qw_write_call(obj, result->rout->label, label++);
																		}
				| CALL IDENTIFIER { is_call = true; } list_expr			{
																			is_call = false;
																			symt_node *result = symt_search_by_name(tab, $2, FUNCTION, NULL, 0);
																			if (result == NULL) result = symt_search_by_name(tab, $2, PROCEDURE, NULL, 0);
																			assertf(result != NULL, "%s routine does not exist", $2);

																			assertf(result->id != FUNCTION, "%s routine is a function, you must to catch the returned value", $2);

																			symt_node *params = symt_search_params(tab, $2);
																			assertf(params != NULL, "%s routine needs parameters", $2);

																			symt_node* rout = symt_search_routine(tab, rout_name);
																			bool is_void = rout->rout->type == VOID;

																			symt_stack* iter = $4;
																			symt_node *iter_p = params;
																			bool no_more_params = false;
																			symt_natural_t r7_offset = 0;
																			symt_natural_t num_params_curr = 0;

																			while (true)
																			{
																				if (iter_p->id != VAR) { no_more_params = true; break; }
																				if (strcmp(iter_p->var->rout_name, $2) != 0) { no_more_params = true; break; }
																				if (iter == NULL) break;

																				symt_cons_t param_type = symt_get_type_data(iter_p->var->type);
																				symt_cons_t arg_type = symt_get_type_data(iter->type);
																				assertp(arg_type == param_type, "type does not match");

																				switch(arg_type)
																				{
																					case CONS_INTEGER: case CONS_BOOL:;
																						r7_offset += 4;
																						int *int_value = (int*)iter->value;
																						symt_assign_var(iter_p->var, symt_new_cons(iter->type, int_value, 0, 0, false));

																						if (iter->offset != 0) qw_write_var_to_reg_with_R6(obj, 1, arg_type, iter->offset, false, is_void);
																						else qw_write_var_to_reg(obj, 1, arg_type, iter->q_dir);

																						fprintf(obj, "\n\tR7=R7-4;\t// Set space for parameter");
																						fprintf(obj, "\n\tI(R7)=R1;\t// Save new value for parameter");
																					break;

																					case CONS_DOUBLE:;
																						r7_offset += 8;
																						double *double_value = (double*)iter->value;
																						symt_assign_var(iter_p->var, symt_new_cons(iter->type, double_value, 0, 0, false));

																						if (iter->offset != 0) qw_write_var_to_reg_with_R6(obj, 1, arg_type, iter->offset, false, is_void);
																						else qw_write_var_to_reg(obj, 1, arg_type, iter->q_dir);

																						fprintf(obj, "\n\tR7=R7-8;\t// Set space for parameter");
																						fprintf(obj, "\n\tD(R7)=RR1;\t// Save new value for parameter");
																					break;

																					case CONS_CHAR:
																						r7_offset += 4;
																						char *char_value = (char*)iter->value;
																						symt_assign_var(iter_p->var, symt_new_cons(iter->type, char_value, 0, 0, false));

																						if (iter->offset != 0) qw_write_var_to_reg_with_R6(obj, 1, arg_type, iter->offset, false, is_void);
																						else qw_write_var_to_reg(obj, 1, arg_type, iter->q_dir);

																						fprintf(obj, "\n\tR7=R7-4;\t// Set space for parameter");
																						fprintf(obj, "\n\tI(R7)=R1;\t// Save new value for parameter");
																					break;
																				}

																				iter = iter->next;
																				iter_p = iter_p->next_node;
																				num_params_curr++;
																			}

																			const symt_natural_t num_params = symt_num_params(tab, $2);
																			assertf(num_params_curr == num_params, "invalid number of parameters %d != %d", (int)num_params_curr, (int)num_params);

																			qw_write_call(obj, result->rout->label, label++);
																			fprintf(obj, "\n\tR7=R7+%d;\t// Free parameters' space", (int)r7_offset);
																		}
				| CALL SHOW expr										{
																			bool is_void = true;
																			symt_node* rout = symt_search_routine(tab, rout_name);

																			if (rout == NULL) is_void = false;
																			else if (rout->rout->type != VOID) is_void = false;

																			qw_write_show_value(obj, label++, $3->cons->type, $3->cons->offset, $3->cons->q_dir, $3->cons->value, is_param, is_void, false);
																			is_param = false;
																		}
				| CALL SHOWLN expr										{
																			bool is_void = true;
																			symt_node* rout = symt_search_routine(tab, rout_name);

																			if (rout == NULL) is_void = false;
																			else if (rout->rout->type != VOID) is_void = false;

																			qw_write_show_value(obj, label++, $3->cons->type, $3->cons->offset, $3->cons->q_dir, $3->cons->value, is_param, is_void, true);
																			is_param = false;
																		}
				;

// __________ Assignation for variables __________

var_assign      : IDENTIFIER '=' expr					{
															symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
															assertf(var != NULL, "variable %s has not been declared", $1);

															free_mem(true);
															symt_assign_var(var->var, $3->cons);

															if (var->level == 0)
															{
																if (!var->var->is_param)
																	qw_write_reg_to_var(obj, 1, type, var->var->q_dir);
																else
																{
																	is_param = true;
																	symt_node* rout = symt_search_routine(tab, rout_name);
																	bool is_void = rout->rout->type == VOID;
																	qw_write_var_to_reg_with_R6(obj, 1, type, var->var->offset, true, is_void);
																}
															}
															else
															{
																qw_write_reg_to_var_with_R6(obj, 1, type, var->var->offset, false);
															}
														}
                | IDENTIFIER '[' int_expr ']' '=' expr	{
															symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
															assertf(var != NULL, "variable %s has not been declared", $1);

															free_mem(true);
															symt_assign_var_at(var->var, $6->cons, *((int*)$3->cons->value));
															qw_write_reg_to_array(obj, 1, type, var->var->q_dir, *((int*)$3->cons->value), var->var->offset);
														}
                ;

// __________ Statement __________

statement 		: { $$ = false; is_var = true; } | var { is_var = false; } EOL statement { $$ = true; }
				| { level++; is_var = false; } BEGIN_IF '(' expr ')' { free_mem(true); qw_write_condition(obj, label); num_reg = 2; $<integer_t>$=label++; } EOL statement { qw_write_new_label(obj, $<integer_t>6); } more_else END_IF { symt_end_block(tab, level); level--; } EOL statement { $$ = true; }
				| { level++; begin_last_loop=label; $<integer_t>$=label; qw_write_begin_loop(obj, label++, q_dir); is_var = false; } BEGIN_WHILE '(' expr ')' { free_mem(true); qw_write_condition(obj, label); end_last_loop=label; num_reg = 2; $<integer_t>$=label++; } EOL statement END_WHILE { level--; symt_end_block(tab, level); qw_write_end_loop(obj, $<integer_t>1, $<integer_t>6); } EOL statement { $$ = true; }
				| { level++; is_var = true; } BEGIN_FOR '(' var ',' { is_var = false; begin_last_loop=label; $<integer_t>$=label; qw_write_begin_loop(obj, label++, q_dir); } var_assign ',' expr ')' { free_mem(true); qw_write_condition(obj, label); end_last_loop = label; num_reg = 2; $<integer_t>$=label++; } EOL statement END_FOR { level--; symt_end_block(tab, level); qw_write_end_loop(obj, $<integer_t>6, $<integer_t>11); } EOL statement { $$ = true; }
				| { level++; } call_func EOL statement	{ level--; $$ = true; }
				| CONTINUE { qw_write_goto(obj, begin_last_loop); } EOL statement { $$ = true; }
                | BREAK { qw_write_goto(obj, end_last_loop); } EOL statement { $$ = true; }
				| EOL statement { if ($2 != false) $$ = true; else $$ = false; }
				| error EOL statement { $$ = true; }
				;

more_else 		: { $$ = false; } | ELSE_IF { symt_end_block(tab, level); } EOL statement { $$ = true; }
				| ELSE_IF { symt_end_block(tab, level); } BEGIN_IF '(' expr ')' { free_mem(true); qw_write_condition(obj, label); $<integer_t>$=label++;  } EOL statement { qw_write_new_label(obj, $<integer_t>7); } more_else { $$ = true; }
				;

// __________ Main program __________

init 			: | var init | EOL init
				| { qw_write_goto(obj, 1); globals = false; offset = 0; } program
				;

program 		: | func_declr program
				| proc_declr program
				| EOL program
				;

%%

int main(int argc, char *argv[])
{
	fr_open_file("c3pc");

	assertp(argc == 2, "invalid number of parameters");
	assertf(access(argv[1], F_OK) == 0, "%s does not exist", argv[1]);
	assertf(ends_with(argv[1], ".c3p", 3) == 0, "%s is not a C3P file", argv[1]);

	tab = symt_new();

	symt_name_t object_f = strappend(argv[1], ".q.c");
	obj = qw_new(object_f); qw_prepare(obj);
	yyin = fopen(argv[1], "r");

	yyparse();
	qw_close(obj, label);
	fclose(yyin);
	fr_close_file();

	symt_name_t name_f = strsub(argv[1], 0, strlen(argv[1]) - 3);
	symt_name_t exec_f = strappend(name_f, ".exe");

	FILE *file = fopen(exec_f, "w");
	fprintf(file, "#!/usr/bin/env bash");
	fprintf(file, "\n\"$PWD\"/iq %s", object_f);
	fprintf(file, "\nrm IQ-cpp.q.c 2>/dev/null");

	ml_free(exec_f);
	ml_free(name_f);
	ml_free(object_f);

	return 0;
}

int ends_with(const char* name, const char* extension, symt_natural_t length)
{
  const char* ldot = strrchr(name, '.');

  if (ldot != NULL)
  {
    if (length == 0) length = strlen(extension);
    return strncmp(ldot + 1, extension, length) == 0;
  }

  return 0;
}

void yyerror(const char *mssg)
{
	char *format = "\033[0;31merror:\033[0m \033[1m%s\033[0m: %s, error at line %d\n";
	fprintf(stderr, format, reader.file, mssg, reader.num_line);
}

void free_mem(bool reduce_offset)
{
	while (num_double_cons > 0)
	{
		qw_pop_fp(obj, CONS_DOUBLE);
		if (reduce_offset) offset -= 8;
		num_double_cons--;
	}

	while (num_int_cons > 0)
	{
		qw_pop_fp(obj, CONS_INTEGER);
		if (reduce_offset) offset -= 4;
		num_int_cons--;
	}
}
