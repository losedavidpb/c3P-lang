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
  	#include "../../include/symt_for.h"
  	#include "../../include/symt_switch.h"
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

	// Check if passed number has decimals
	#define has_decimals(num) fmod(num, 1.0) != 0

	// %token<type_t> INTEGER_TYPE %token<type_t> DOUBLE_TYPE

	// This functions have to be declared in order to
	// avoid warnings related to implicit declaration
	int yylex(void);
	void yyerror(const char *s);
	void print_tab(symt_node* ta);
	void print_stack(struct Stack *p);
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

%type<node_t> BEGIN_FOR;
%type<node_t> BEGIN_WHILE;
%type<node_t> BEGIN_IF;
%type<node_t> BEGIN_SWITCH;
%type<node_t> DEFAULT_SWITCH;
%type<node_t> CONTINUE;
%type<node_t> BREAK;
%type<node_t> RETURN;
%type<node_t> EOL;
%type<node_t> call_func;
%type<node_t> CALL;
%type<node_t> error;

%type<double_t> expr_num;
%type<char_t> expr_char;
%type<string_t> expr_string;
%type<double_t> int_expr;
%type<node_t> expr;
%type<stack> list_expr;

%type<node_t> statement;
%type<node_t> switch_case;
%type<node_t> more_else;

%type<node_t> in_var;
%type<node_t> ext_var;
%type<node_t> var_assign;

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

// FALTA BORRAR BASURA TEMPORAL QUE SE USA COMO LAS CONSTANTES

expr 			: expr_num		{
									symt_cons *value = (symt_cons*)$1;
									symt_node *result = symt_new_node();
									result = symt_push(result, value);
									$$ = result;
								}
				| expr_char		{
									symt_cons *value = (symt_cons*)$1;
									symt_node *result = symt_new_node();
									result = symt_push(result, value);
									$$ = result;
				 				}
				| expr_string	{ $$ = $1; }
				| IDENTIFIER	{
									symt_node *var = symt_search_by_name(tab, $1, GLOBAL_VAR);
									if (var == NULL) var = symt_search_by_name(tab, $1, LOCAL_VAR);
									assertf(var != NULL, "variable %s has not been declared", $1);
									$$ = var;
								}
				;

int_expr 		: int_expr '+' int_expr 		{ $$ = symt_cons_add(CONS_INTEGER, $1, $3);  }
				| int_expr '-' int_expr 		{ $$ = symt_cons_sub(CONS_INTEGER, $1, $3);  }
				| int_expr '*' int_expr 		{ $$ = symt_cons_mult(CONS_INTEGER, $1, $3); }
				| int_expr '/' int_expr 		{ $$ = symt_cons_div(CONS_INTEGER, $1, $3);  }
				| int_expr '%' int_expr 		{ $$ = symt_cons_mod(CONS_INTEGER, $1, $3);  }
				| int_expr '^' int_expr 		{ $$ = symt_cons_pow(CONS_INTEGER, $1, $3);  }
				| '(' expr_num ')' 				{ $$ = $2; }
				| DOUBLE 						{ $$ = symt_new_cons(CONS_INTEGER, &$1); 	 }
				| INTEGER 						{ $$ = symt_new_cons(CONS_INTEGER, &$1); 	 }
				;

expr_num 		: expr_num '<' expr_num 		{ $$ = symt_cons_lt($1, $3);  }
				| expr_num '>' expr_num 		{ $$ = symt_cons_gt($1, $3);  }
				| expr_num EQUAL expr_num 		{ $$ = symt_cons_eq($1, $3);  }
				| expr_num NOTEQUAL expr_num 	{ $$ = symt_cons_neq($1, $3); }
				| expr_num LESSEQUAL expr_num 	{ $$ = symt_cons_leq($1, $3); }
				| expr_num MOREEQUAL expr_num 	{ $$ = symt_cons_geq($1, $3); }
				| expr_num AND expr_num 		{
													symt_node* num1 = $1;
													symt_node* num2 = $3;
													int value1_int = *((int*)num1->value);
													int value2_int = *((int*)num2->value);
													int result = value1_int && value2_int;
													$$ = symt_insert_cons(CONS_INTEGER, &result);
				 								}
				| expr_num OR expr_num 			{
													symt_node* num1 = $1;
													symt_node* num2 = $3;
													int value1_int = *((int*)num1->value);
													int value2_int = *((int*)num2->value);
													int result = value1_int || value2_int;
													$$ = symt_insert_cons(CONS_INTEGER, &result);
												}
				| NOT expr_num 					{
													symt_node* num1 = $1;
													int value1 = *((int*)num1->value);
													int result = !value1;
													$$ = symt_insert_cons(CONS_INTEGER, &result);
												}
				| int_expr 						{ $$ = $1; }
				| T 							{ int true_val = 1; $$ = symt_new_cons(CONS_INTEGER, &true_val);   }
				| F 							{ int false_val = 0; $$ = symt_new_cons(CONS_INTEGER, &false_val); }
				;

expr_char 		: expr_char '+' expr_char 		{ $$ = symt_cons_add(CONS_CHAR, $1, $3);  }
				| expr_char '-' expr_char 		{ $$ = symt_cons_sub(CONS_CHAR, $1, $3);  }
				| expr_char '*' expr_char 		{ $$ = symt_cons_mult(CONS_CHAR, $1, $3); }
				| expr_char '/' expr_char 		{ $$ = symt_cons_div(CONS_CHAR, $1, $3);  }
				| expr_char '%' expr_char 		{ $$ = symt_cons_mod(CONS_CHAR, $1, $3);  }
				| expr_char '^' expr_char 		{ $$ = symt_cons_pow(CONS_CHAR, $1, $3);  }
				| expr_char '<' expr_char 		{ $$ = symt_cons_lt($1, $3); 			  }
				| expr_char '>' expr_char 		{ $$ = symt_cons_gt($1, $3); 			  }
				| expr_char EQUAL expr_char 	{ $$ = symt_cons_eq($1, $3); 			  }
				| expr_char NOTEQUAL expr_char 	{ $$ = symt_cons_neq($1, $3); 			  }
				| expr_char LESSEQUAL expr_char { $$ = symt_cons_leq($1, $3); 			  }
				| expr_char MOREEQUAL expr_char { $$ = symt_cons_geq($1, $3);			  }
				| CHAR 							{ $$ = symt_insert_cons(CONS_CHAR, &$1); 	}
				;

expr_string 	: expr_string '+' expr_string	{
													symt_var *str1 = (symt_var*)$1;
													symt_var *str2 = (symt_var*)$3;

													int len_result = str1->array_length + str2->array_length;
													char *res = (char *)(malloc(sizeof(char) * len_result));
													assertp(res != NULL, "internal error at concatenation");
													strcpy(res, (char*)str1->value); strcat(res, (char*)str2->value);

													symt_var *var_n = symt_new_var(LOCAL_VAR, "", CONS_CHAR, true, strlen((char*)$1), $1, false);
													symt_node *result = symt_new_new();
													symt_push(result, var);
													$$ = result;
												}
				| STRING		 				{
													symt_var *var_n = symt_new_var(LOCAL_VAR, "", CONS_CHAR, true, strlen((char*)$1), $1, false);
													symt_node *result = symt_new_node();
													result = symt_push(result, var_n);
													$$ = result;
												}
				;

// __________ Constants and Data type __________

data_type 		: I8_TYPE 						{ $$ = I8; }
				| I16_TYPE 						{ $$ = I16; }
				| I32_TYPE 						{ $$ = I32; }
				| I64_TYPE 						{ $$ = I64; }
				| F32_TYPE 						{ $$ = F32; }
				| F64_TYPE 						{ $$ = F64; }
				| CHAR_TYPE 					{ $$ = CONS_CHAR; }
				| STR_TYPE 						{ $$ = CONS_CHAR; }
				| BOOL_TYPE 					{ $$ = CONS_INTEGER; }
				;

arr_data_type 	: I8_TYPE '[' int_expr ']'    	{ value_list_expr_t = CONS_INTEGER; array_length = $3; $$ = I8; }
				| I16_TYPE '[' int_expr ']' 	{ value_list_expr_t = CONS_INTEGER; array_length = $3; $$ = I16; }
				| I32_TYPE '[' int_expr ']'		{ value_list_expr_t = CONS_INTEGER; array_length = $3; $$ = I32; }
				| I64_TYPE '[' int_expr ']'		{ value_list_expr_t = CONS_INTEGER; array_length = $3; $$ = I64; }
				| F32_TYPE '[' int_expr ']'		{ value_list_expr_t = CONS_DOUBLE; array_length = $3; $$ = F32; }
				| F64_TYPE '[' int_expr ']'		{ value_list_expr_t = CONS_DOUBLE; array_length = $3; $$ = F64; }
				| CHAR_TYPE '[' int_expr ']'	{ value_list_expr_t = CONS_CHAR; array_length = $3; $$ = CONS_CHAR; }
				| STR_TYPE '[' int_expr ']'		{ value_list_expr_t = CONS_CHAR; array_length = $3; $$ = CONS_CHAR; }
				| BOOL_TYPE '[' int_expr ']'	{ value_list_expr_t = CONS_INTEGER; array_length = $3; $$ = CONS_INTEGER; }
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

// __________ Assignation for variables __________

var_assign 		: IDENTIFIER '=' expr						{
																symt_node *var = symt_search_by_name(tab, $1, LOCAL_VAR);
																assertf(var != NULL, "variable %s has not been declared", $1);
																symt_node *value = (symt_node *)$3;
																symt_can_assign(var->var->type, value->cons);
																//var->var->value = value->cons->value;
																symt_assign_var(var->var, value->cons);
																$$ = var;
																print_tab(tab);
															}
				| IDENTIFIER '[' expr ']' '=' expr			{
																symt_node *var = symt_search_by_name(tab, $1, LOCAL_VAR);
																assertf(var != NULL, "variable %s has not been declared", $1);
																symt_node *index_node = (symt_node *)$3;
																symt_node *result_node = (symt_node *)$6;
																void *index_value = symt_get_value_from_node(index_node);
																void *result_value = symt_get_value_from_node(result_node);
																int *index_value_int = (int *)index_value;

																if (var->var->type == CONS_INTEGER)
																{
																	if (result_node->id == LOCAL_VAR || result_node->id == GLOBAL_VAR)
																	{
																		assertf(*index_value_int >= 0 && *index_value_int < var->var->array_length, "array index out of bounds at %s", $1);
																		assertf(result_node->var->type == CONS_INTEGER, "type %s does not match %s at %s indexation", symt_strget_vartype(result_node->var->type), "integer", $1);
																	}
																	else if (result_node->id == CONSTANT)
																	{
																		assertf(result_node->cons->type == CONS_INTEGER, "type %s does not match %s at %s indexation", symt_strget_constype(result_node->cons->type), "integer", $1);
																	}

																	if (result_node->id == CALL_FUNC)
																	{
																		symt_call *value_call = (symt_call *)result_value;
																		//*(var_array+index_value_int) = value_call;
																	}
																	else
																	{
																		//int *result_value_int = (int*)result_value;
																		//int *var_array = (int *)var->var->value;
																		//*(var_array + *index_value_int) = *(result_value_int);
																		symt_assign_var_at(var->var, result_node->cons, *index_value_int);
																	}
																}
																else
																{
																	if (result_node->id == LOCAL_VAR || result_node->id == GLOBAL_VAR)
																	{
																		assertf(*index_value_int >= 0 && *index_value_int < var->var->array_length, "array index out of bounds at %s", $1);
																		assertf(result_node->var->type == CONS_DOUBLE, "type %s does not match %s at %s indexation", symt_strget_vartype(result_node->var->type), "double", $1);
																	} else if(result_node->id == CONSTANT)
																	{
																		assertf(result_node->cons->type == CONS_DOUBLE, "type %s does not match %s at %s indexation", symt_strget_constype(result_node->cons->type), "double", $1);
																	}

																	if (result_node->id == CALL_FUNC)
																	{
																		symt_call *value_call = (symt_call *)result_value;
																		//*(var_array+index_value_int) = value_call;
																	}
																	else
																	{
																		//double *result_value_double = (double*)result_value;
																		//double *var_array = (double *)var->var->value;
																		//*(var_array + *index_value_int) = *(result_value_double);
																		symt_assign_var_at(var->var, result_node->cons, *index_value_int);
																	}
																}

																$$ = var;
																print_tab(tab);
															}
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
																						tab = symt_push(tab, var);
																						$$ = var; print_tab(tab);
																					}
				| HIDE IDENTIFIER ':' arr_data_type									{
																						symt_node *var = symt_search_by_name(tab, $2, GLOBAL_VAR);
																						assertf(var == NULL, "variable %s has already been declared", $2);

																						var = symt_insert_var(GLOBAL_VAR, $2, $4, 1, array_length, NULL, 1);
																						tab = symt_push(tab, var);
																						$$ = var; print_tab(tab);
																					}
				| HIDE IDENTIFIER ':' data_type '=' expr							{
																						symt_node *var = symt_search_by_name(tab, $2, GLOBAL_VAR);
																						assertf(var == NULL, "variable %s has already been declared", $2);

																						var = symt_insert_var(GLOBAL_VAR, $2, $4, 0, 0, NULL, 1);
																						tab = symt_push(tab, var);

																						symt_node *value = (symt_node *)$6;
																						symt_can_assign(var->var->type, value->cons);
																						symt_assign_var(var->var, value->cons);

																						$$ = var; print_tab(tab);
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
																						assertf(var->var->type == $4, "type %s does not match %s at %s variable declaration", str_type, str_type_2, $2);

																						struct Stack *pila = $7;
																						struct Stack *valores_pila = $7;
																						int *zero = (int *)(ml_malloc(sizeof(int)));

																						switch(value_list_expr_t)
																						{
																							case CONS_INTEGER:;
																								int* value_int = (int*)value_list_expr;

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

																								int *valores_int = (int *)(ml_malloc(sizeof(int)*array_length));

																								for(int i = 0; valores_pila; i++)
																								{
																									*(valores_int+i) = *((int*)valores_pila->value);
																									valores_pila = valores_pila->next_value;
																								}

																								var->var->value = (void*)valores_int;
																							break;

																							case CONS_DOUBLE:;
																								double* value_double = (double*)value_list_expr;

																								for(int i = 0; i < array_length; i++)
																								{
																									symt_cons* constate = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																									constate->type = value_list_expr_t;

																									if(pila->value) constate->value = pila->value;
																									else constate->value = (void*)zero;

																									symt_can_assign(var->var->type, constate);
																									if(pila) pila = pila->next_value;
																									ml_free(constate);
																								}

																								double *valores_double = (double *)(ml_malloc(sizeof(double)*array_length));

																								for(int i = 0; valores_pila; i++)
																								{
																									*(valores_double+i) = *((int*)valores_pila->value);
																									valores_pila = valores_pila->next_value;
																								}

																								var->var->value = (void*)valores_double;
																							break;

																							case CONS_CHAR:;
																								char* value_char = (char*)value_list_expr;

																								for(int i = 0; i < array_length; i++)
																								{
																									symt_cons* constate = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																									constate->type = value_list_expr_t;

																									if(pila->value) constate->value = pila->value;
																									else constate->value = (void*)zero;

																									symt_can_assign(var->var->type, constate);
																									if(pila) pila = pila->next_value;
																									ml_free(constate);
																								}

																								char *valores_char = (char *)(ml_malloc(sizeof(char)*array_length));

																								for(int i = 0; valores_pila; i++)
																								{
																									*(valores_char+i) = *((int*)valores_pila->value);
																									valores_pila = valores_pila->next_value;
																								}

																								var->var->value = (void*)valores_char;
																							break;
																						}

																						$$ = var; print_tab(tab);
																					}
				;

in_var 			: IDENTIFIER ':' data_type 											{
																					    if (token_id == SYMT_ROOT_ID) token_id = LOCAL_VAR;
																						symt_node *var = symt_search_by_name(tab, $1, token_id);
																						assertf(var == NULL, "variable %s has already been declared", $1);

																						tab = symt_insert_tab_var(tab, token_id, $1, $3, 0, 0, NULL, 0);
																						$$ = var; token_id = SYMT_ROOT_ID;
																						print_tab(tab);
																					}
				| IDENTIFIER ':' arr_data_type										{
																						if (token_id == SYMT_ROOT_ID) token_id = LOCAL_VAR;
																						symt_node *var = symt_search_by_name(tab, $1, token_id);
																						assertf(var == NULL, "variable %s has already been declared", $1);

																						tab = symt_insert_tab_var(tab, token_id, $1, $3, 1, array_length, NULL, 0);
																						$$ = var; token_id = SYMT_ROOT_ID;
																						print_tab(tab);
																					}
				| IDENTIFIER '=' expr												{
																						if (token_id == SYMT_ROOT_ID) token_id = LOCAL_VAR;
																						symt_node *var = symt_search_by_name(tab, $1, token_id);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						symt_node *value = (symt_node *)$3;
																						symt_can_assign(var->var->type, value->cons);
																						symt_assign_var(var, value);
																						$$ = var; token_id = SYMT_ROOT_ID;
																						print_tab(tab);
																					}
				| IDENTIFIER '[' expr ']' '=' expr									{
																						if (token_id == SYMT_ROOT_ID) token_id = LOCAL_VAR;
																						symt_node *var = symt_search_by_name(tab, $1, token_id);
																						assertf(var != NULL, "variable %s has not been declared", $1);

																						symt_cons *index = (symt_cons*)$3;
																						symt_assign_var_at(var, (symt_cons*)$6, *((int*)index->value));
																						$$ = var; token_id = SYMT_ROOT_ID; print_tab(tab);
																					}
				| IDENTIFIER ':' data_type '=' expr									{
																						if (token_id == SYMT_ROOT_ID) token_id = LOCAL_VAR;
																						symt_node *var_without_value = symt_search_by_name(tab, $1, token_id);
																						assertf(var_without_value == NULL, "variable %s has already been declared", $1);

																						symt_var* var_result = symt_insert_var(token_id, $1, $3, 0, 0, NULL, 0);
																						symt_push(tab, var_result);

																						symt_node *value = (symt_node *)$5;
																						symt_assign_var(var_result, value->cons->value);
																						$$ = var_result; token_id = SYMT_ROOT_ID;
																						print_tab(tab);
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
																						int *zero = (int *)(ml_malloc(sizeof(int)));
																						switch(value_list_expr_t){
																							case CONS_INTEGER:;
																								for(int i = 0; i < array_length; i++){
																									symt_cons* constate = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																									constate->type = value_list_expr_t;
																									if(pila){
																										constate->value = pila->value;
																									}else {
																										constate->value = (void*)zero;
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
																								double* value_double = (double*)value_list_expr;
																								for(int i = 0; i < array_length; i++){
																									symt_cons* constate = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																									constate->type = value_list_expr_t;
																									if(pila->value){
																										constate->value = pila->value;
																									}else {
																										constate->value = (void*)zero;
																									}
																									symt_can_assign(var->var->type, constate);
																									if(pila) pila = pila->next_value;
																									ml_free(constate);
																								}
																								double *valores_double = (double *)(ml_malloc(sizeof(double)*array_length));
																								for(int i = 0; valores_pila; i++){
																									*(valores_double+i) = *((int*)valores_pila->value);
																									valores_pila = valores_pila->next_value;
																								}
																								var->var->value = (void*)valores_double;
																								break;
																							case CONS_CHAR:;
																								char* value_char = (char*)value_list_expr;
																								for(int i = 0; i < array_length; i++){
																									symt_cons* constate = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
																									constate->type = value_list_expr_t;
																									if(pila->value){
																										constate->value = pila->value;
																									}else {
																										constate->value = (void*)zero;
																									}
																									symt_can_assign(var->var->type, constate);
																									if(pila) pila = pila->next_value;
																									ml_free(constate);
																								}
																								char *valores_char = (char *)(ml_malloc(sizeof(char)*array_length));
																								for(int i = 0; valores_pila; i++){
																									*(valores_char+i) = *((int*)valores_pila->value);
																									valores_pila = valores_pila->next_value;
																								}
																								var->var->value = (void*)valores_char;
																								break;
																						}
																						$$ = var; token_id = SYMT_ROOT_ID;
																						print_tab(tab);
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

switch_case 	: EOL switch_case											{ $$ = $2; }
				| expr ':' EOL statement BREAK EOL switch_case				{
																				symt_node* case_node = symt_new();

																				symt_node *cond = (symt_node*)$1;
																				symt_node *statement = NULL;
																				if($4 != NULL) statement = (symt_node *)$4;
																				symt_node* other = (symt_node*)$7;

																				case_node = symt_insert_tab_if(case_node, cond, statement, other);
																				$$ = case_node;
																			}
				| DEFAULT_SWITCH ':' EOL statement BREAK EOL more_EOL		{
																				symt_node* case_node = symt_new();
																				symt_node *statement = NULL;
																				if($4 != NULL) statement = (symt_node *)$4;
																				else statement = NULL;

																				case_node = symt_insert_tab_if(case_node, NULL, statement, NULL);
																				$$ = case_node;
																			}
				;

more_EOL 		: | EOL more_EOL;

// __________ Statement __________

statement 		: { $$ = NULL; } | in_var EOL statement
				| BEGIN_IF '(' expr ')' EOL statement break_rule more_else								{
																											symt_node *cond = (symt_node *)$3;

																											symt_node *statement_if = NULL;
																											if ($6 != NULL) statement_if = (symt_node *)$6;

																											symt_node *statement_else = NULL;
																											if ($8 != NULL) statement_else = (symt_node *)$8;

																											tab = symt_insert_tab_if(tab, cond, statement_if, statement_else);
																											print_tab(tab);
																										} END_IF { symt_end_block(tab, IF); } EOL statement
				| BEGIN_WHILE '(' expr ')' EOL statement break_rule 									{
																											symt_node *cond = (symt_node *)$3;
																											symt_node *statement = NULL;
																											if ($6 != NULL) statement = (symt_node *)$6;

																											tab = symt_insert_tab_while(tab, cond, statement);
																											print_tab(tab);
																										} END_WHILE { symt_end_block(tab, WHILE); } EOL statement
				| BEGIN_FOR  '(' in_var ',' expr ',' var_assign ')' EOL statement break_rule			{
																											symt_node *cond = (symt_node *)$5;
																											symt_node *iter_var = (symt_node *)$3;
																											symt_node *iter_op = (symt_node *)$7;
																											symt_node * statement = NULL;
																											if ($10 != NULL) statement = (symt_node *)$10;

																											tab = symt_insert_tab_for(tab, cond, statement, iter_var, iter_op);
																											print_tab(tab);
																										} END_FOR { symt_end_block(tab, FOR); } EOL statement
				| BEGIN_SWITCH '(' IDENTIFIER ')' EOL switch_case										{
																											symt_node *var = symt_search_by_name(tab, $3, GLOBAL_VAR);
																											if (var == NULL) var = symt_search_by_name(tab, $3, LOCAL_VAR);
																											assertf(var != NULL, "variable %s has not been declared", $3);
																											symt_node *cases_node = NULL;
																											if ($6 != NULL) cases_node = (symt_node *)$6;

																											tab = symt_insert_tab_switch(tab, var->var, cases_node);
																											print_tab(tab);
																										} END_SWITCH { symt_end_block(tab, SWITCH); } EOL statement
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

		if (s_error == 0 && l_error == 0) printf("OK\n");
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

void print_tab(symt_node *__tab)
{
	assertp(__tab != NULL, "table has not been constructed");
	printf("\n ## Table");

	symt_node *node = (symt_node*)__tab;
	char *str_type, *message;

	while(node != NULL)
	{
		printf("\n id = %s | ", symt_strget_id(node->id));

		switch (node->id)
		{
			case LOCAL_VAR: case GLOBAL_VAR:
				str_type = symt_strget_vartype(node->var->type);
				message = " name = %s | type = %s | is_hide = %d | is_array = %d | array_length = %d";
				printf(message, node->var->name, str_type, node->var->is_hide, node->var->is_array, node->var->array_length);
				symt_printf_value(node);
			break;

			case FUNCTION:; case PROCEDURE:;
				str_type = symt_strget_vartype(node->rout->type);
				message = " name = %s | type = %s | is_hide = %d | params = %d | statements = %d";
				printf(message, node->rout->name, str_type, node->rout->params, node->rout->statements);
				/*if (iter->rout->params != NULL)
				{
					result = __symt_search(iter->rout->params, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}

				if (iter->rout->statements != NULL)
				{
					result = __symt_search(iter->rout->statements, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}*/
			break;

			case IF:;
				message = " cond = %d | if_statements = %d | else_statements = %d";
				printf(message, node->if_val->cond, node->if_val->if_statements, node->if_val->else_statements);
				/*if (iter->if_val->cond != NULL)
				{
					result = __symt_search(iter->if_val->cond, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}

				if (iter->if_val->if_statements != NULL)
				{
					result = __symt_search(iter->if_val->if_statements, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}

				if (iter->if_val->else_statements != NULL)
				{
					result = __symt_search(iter->if_val->else_statements, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}*/
			break;

			case WHILE:;
				message = " cond = %d | statements = %d ";
				printf(message, node->while_val->cond, node->while_val->statements);
				/*if (iter->while_val->cond != NULL)
				{
					result = __symt_search(iter->while_val->cond, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}

				if (iter->while_val->statements != NULL)
				{
					result = __symt_search(iter->while_val->statements, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}*/
			break;

			case FOR:;
				message = " incr = %d | cond = %d | iter_op = %d | statements = %d ";
				printf(message, node->for_val->incr, node->for_val->cond, node->for_val->iter_op, node->for_val->statements);
				/*if (iter->for_val->cond != NULL)
				{
					result = __symt_search(iter->for_val->cond, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}

				if (iter->for_val->iter_op != NULL)
				{
					result = __symt_search(iter->for_val->iter_op, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}

				if (iter->for_val->statements != NULL)
				{
					result = __symt_search(iter->for_val->statements, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}*/
			break;

			case SWITCH:;
				message = " key_id = %s | key_var = %d | cases = %d ";
				printf(message, node->switch_val->type_key, node->switch_val->key_var, node->switch_val->cases);
				/*if (iter->switch_val->cases != NULL)
				{
					result = __symt_search(iter->switch_val->cases, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}*/
			break;

			case CALL_FUNC:;
				str_type = symt_strget_vartype(node->call->type);
				message = " name = %s | type = %d | params = %d ";
				printf(message, node->call->name, str_type, node->call->params);
				/*if (iter->call->params != NULL)
				{
					result = __symt_search(iter->call->params, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}*/
			break;

			default: break; // Just to avoid warning
		}

		node = node->next_node;
	}
}
