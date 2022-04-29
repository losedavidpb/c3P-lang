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
	int variable_type = 0; // Variable data type for curren token
	void *value_list_expr; // Array value for current token
	int token_id = SYMT_ROOT_ID;

	// Return integer which is the equivalent token
	// at current symbol table
	int bison2symt_enum(int);

	// This functions have to be declared in order to
	// avoid warnings related to implicit declaration
	int yylex(void);
	void yyerror(const char *s);
	int fuzzy_compare(double a, double b, double c);
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

%token HIDE

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
%type<node_t> ext_var;
%type<node_t> var_assign;
%type<node_t> switch_case;
%type<integer_t> arr_data_type

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

expr 			: expr_num		{
									if(fuzzy_compare($1,1,0.0)){
										double *value = (double*)(ml_malloc(sizeof(double)));
										*value = $1;
										symt_node* result = symt_new();
										result = symt_insert_const(result, DOUBLE_, value);
										$$ = result;
									}else{
										int *value = (int*)(ml_malloc(sizeof(int)));
										*value = $1;
										symt_node* result = symt_new();
										result = symt_insert_const(result, INTEGER_, value);
										$$ = result;
									}

						  		}
				| expr_char		{
									char *value = (char*)(ml_malloc(sizeof(char)));
									*value = $1;
						  			symt_node* result = symt_new();
						  			result = symt_insert_const(result, CHAR_, value);
						  			$$ = result;
								}
				| expr_string	{
									char *value = strdup($1);
						  			symt_node* result = symt_new();
						  			result = symt_insert_const(result, CHAR_, value);
						  			$$ = result;
								}
				| IDENTIFIER	{
									symt_node *var;
									var = symt_search_by_name(tab, $1, GLOBAL_VAR);
									if (var == NULL) var = symt_search_by_name(tab, $1, LOCAL_VAR);
									assertp(var != NULL, "variable does not exist");
									$$ = var;
								};

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

data_type 		: INTEGER_TYPE 					{ variable_type = INTEGER_; }
				| DOUBLE_TYPE 					{ variable_type = DOUBLE_; }
				| CHAR_TYPE 					{ variable_type = CHAR_; }
				| STR_TYPE 						{ variable_type = CHAR_; }
				| BOOL_TYPE 					{ variable_type = INTEGER_; }
				;

arr_data_type 	: INTEGER_TYPE '[' int_expr ']' { array_length = $3; $$ = INTEGER_; }
				| DOUBLE_TYPE '[' int_expr ']'	{ array_length = $3; $$ = DOUBLE_; }
				| CHAR_TYPE '[' int_expr ']'	{ array_length = $3; $$ = CHAR_; }
				| STR_TYPE '[' int_expr ']'		{ array_length = $3; $$ = CHAR_; }
				| BOOL_TYPE '[' int_expr ']'	{ array_length = $3; $$ = INTEGER_; }
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

var_assign 		: IDENTIFIER '=' expr						{
																symt_node *var;
																var = symt_search_by_name(tab, $1, token_id);
																assertp(var != NULL, "variable does not exist");
																var->var->value = $3;
															}
				| IDENTIFIER '[' expr ']' '=' expr			{
																symt_node *var;
																var = symt_search_by_name(tab, $1, token_id);
																assertp(var != NULL, "variable does not exist");
																symt_node *index_node = (symt_node *)$3;
																symt_node *result_node = (symt_node *)$6;
																void *index_value = symt_get_value_from_node(index_node);
																void *result_value = symt_get_value_from_node(result_node);
																int *index_value_int;
																if (var->var->type == INTEGER_)
																{
																	index_value_int = (int *)index_value;

																	if(result_node->id == LOCAL_VAR || result_node->id == GLOBAL_VAR){
																		assertp(*index_value_int >= 0 && *index_value_int < var->var->array_length, "array index out of bounds");
																		assertp(result_node->var->type == INTEGER_, "type does not match");
																	}else if(result_node->id == CONSTANT){
																		assertp(result_node->cons->type == INTEGER_, "type does not match");
																	}
																	int *result_value_int = (int*)result_value;

																	int *var_array = (int *)var->var->value;
																	if (result_node->id == CALL_)
																	{
																		symt_call *value_call = (symt_call *)result_value;
																		//*(var_array+index_value_int) = value_call;
																	}
																	else
																	{
																		*(var_array + *index_value_int) = *(result_value_int);
																	}
																}
																else
																{
																	index_value_int = (int *)index_value;

																	if(result_node->id == LOCAL_VAR || result_node->id == GLOBAL_VAR){
																		assertp(*index_value_int >= 0 && *index_value_int < var->var->array_length, "array index out of bounds");
																		assertp(result_node->var->type == DOUBLE_, "type does not match");
																	}else if(result_node->id == CONSTANT){
																		assertp(result_node->cons->type == DOUBLE_, "type does not match");
																	}
																	double *result_value_double = (double*)result_value;

																	double *var_array = (double *)var->var->value;
																	if (result_node->id == CALL_)
																	{
																		symt_call *value_call = (symt_call *)result_value;
																		//*(var_array+index_value_int) = value_call;
																	}
																	else
																	{
																		*(var_array + *index_value_int) = *(result_value_double);
																	}
																}
															}
				;

// __________ Declaration and Assignation for variables __________

list_expr 		: expr					{
											symt_node* node = (symt_node*)$1;
											value_list_expr = symt_get_value_from_node(node);
										}
				| expr ',' list_expr	{
											symt_node* node = (symt_node*)$1;
											value_list_expr = symt_get_value_from_node(node);
										}
				;

ext_var 		: { token_id = GLOBAL_VAR; } in_var { token_id = LOCAL_VAR; }
				| HIDE IDENTIFIER ':' data_type										{
																						symt_node *var;
																						var = symt_search_by_name(tab, $2, GLOBAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, GLOBAL_VAR, $2, variable_type, 0, 0, NULL, 1);
																					}
				| HIDE IDENTIFIER ':' arr_data_type									{
																						symt_node *var;
																						var = symt_search_by_name(tab, $2, GLOBAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, GLOBAL_VAR, $2, $4, 1, array_length, NULL, 1);
																					}
				| HIDE IDENTIFIER ':' data_type '=' expr							{
																						symt_node *var;
																						var = symt_search_by_name(tab, $2, GLOBAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, GLOBAL_VAR, $2, variable_type, 0, 0, $6, 1);
																					}
				| HIDE IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'			{
																						symt_node *var;
																						var = symt_search_by_name(tab, $2, GLOBAL_VAR);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, GLOBAL_VAR, $2, $4, 1, array_length, NULL, 1);
																						var = symt_search_by_name(tab, $2, GLOBAL_VAR);
																						assertp(var != NULL, "variable does not exist");
																						assertp(var->var->type == $4, "type does not match");
																						var->var->value = value_list_expr;
																					}
				;

in_var 			: IDENTIFIER ':' data_type 											{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, token_id);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, token_id, $1, variable_type, 0, 0, NULL, 0);
																					}
				| IDENTIFIER ':' arr_data_type										{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, token_id);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, token_id, $1, $3, 1, array_length, NULL, 0);
																					}
				| IDENTIFIER '=' expr												{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, token_id);
																						assertp(var != NULL, "variable does not exist");
																						var->var->value = $3;
																					}
				| IDENTIFIER '[' expr ']' '=' expr									{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, token_id);
																						assertp(var != NULL, "variable does not exist");
																						symt_node *index_node = (symt_node *)$3;
																						symt_node *result_node = (symt_node *)$6;
																						void *index_value = symt_get_value_from_node(index_node);
																						void *result_value = symt_get_value_from_node(result_node);
																						int *index_value_int;
																						if (var->var->type == INTEGER_)
																						{
																							index_value_int = (int *)index_value;

																							if(result_node->id == LOCAL_VAR || result_node->id == GLOBAL_VAR){
																								assertp(*index_value_int >= 0 && *index_value_int < var->var->array_length, "array index out of bounds");
																								assertp(result_node->var->type == INTEGER_, "type does not match");
																							}else if(result_node->id == CONSTANT){
																								assertp(result_node->cons->type == INTEGER_, "type does not match");
																							}
																							int *result_value_int = (int*)result_value;

																							int *var_array = (int *)var->var->value;
																							if (result_node->id == CALL_)
																							{
																								symt_call *value_call = (symt_call *)result_value;
																								//*(var_array+index_value_int) = value_call;
																							}
																							else
																							{
																								*(var_array + *index_value_int) = *(result_value_int);
																							}
																						}
																						else
																						{
																							index_value_int = (int *)index_value;

																							if(result_node->id == LOCAL_VAR || result_node->id == GLOBAL_VAR){
																								assertp(*index_value_int >= 0 && *index_value_int < var->var->array_length, "array index out of bounds");
																								assertp(result_node->var->type == DOUBLE_, "type does not match");
																							}else if(result_node->id == CONSTANT){
																								assertp(result_node->cons->type == DOUBLE_, "type does not match");
																							}
																							double *result_value_double = (double*)result_value;

																							double *var_array = (double *)var->var->value;
																							if (result_node->id == CALL_)
																							{
																								symt_call *value_call = (symt_call *)result_value;
																								//*(var_array+index_value_int) = value_call;
																							}
																							else
																							{
																								*(var_array + *index_value_int) = *(result_value_double);
																							}
																						}
																					}
				| IDENTIFIER ':' data_type '=' expr									{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, token_id);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, token_id, $1, variable_type, 0, 0, $5, 0);
																					}
				| IDENTIFIER ':' arr_data_type '=' '{' list_expr '}'				{
																						symt_node *var;
																						var = symt_search_by_name(tab, $1, token_id);
																						assertp(var == NULL, "variable already exists");
																						tab = symt_insert_var(tab, token_id, $1, $3, 1, array_length, NULL, 0);
																						var = symt_search_by_name(tab, $1, token_id);
																						assertp(var != NULL, "variable does not exist");
																						assertp(var->var->type == $3, "type does not match");
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
																											tab = symt_insert_switch(tab, var->var, casos);
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
		case INTEGER:
		case INTEGER_: return INTEGER_; 	break;
		case DOUBLE:
		case DOUBLE_: return DOUBLE_; 	break;
		case CHAR:
		case CHAR_: return CHAR_; 		break;
		case CALL:
		case CALL_: return CALL_; 		break;
		default: return -1; 			break;
	}
}
int fuzzy_compare(double a, double c, double e) {
   return abs(a - c)  <= e;
}
