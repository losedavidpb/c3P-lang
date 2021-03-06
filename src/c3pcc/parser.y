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

	#include "include/y_utils.h"

	extern FILE *yyin;								// Current file for Bison
	int yydebug = 1; 								// Enable this to active debug mode

	// Just to avoid warnings
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

expr_num 		: T 							{ int true_val = 1; $$ = write_cons(CONS_BOOL, &true_val); }
				| F 							{ int false_val = 0; $$ = write_cons(CONS_BOOL, &false_val); }
				| DOUBLE 						{ $$ = write_cons(CONS_DOUBLE, &$1);  }
				| INTEGER 						{ $$ = write_cons(CONS_INTEGER, &$1); }
				;

expr_char       : CHAR                          { $$ = write_cons(CONS_CHAR, &$1); }
				;

iden_expr		: expr '+' expr					{ $$ = write_expr($1, $3, QW_ADD, -1);	 	 	}
				| expr '-' expr 				{ $$ = write_expr($1, $3, QW_SUB, -1); 		 	}
				| expr '*' expr 				{ $$ = write_expr($1, $3, QW_MULT, -1); 	 	}
				| expr '/' expr 				{ $$ = write_expr($1, $3, QW_DIV, -1); 		 	}
				| expr '%' expr 				{ $$ = write_expr($1, $3, QW_MOD, label++);  	}
				| expr '^' expr 				{ $$ = write_expr($1, $3, QW_POW, label++);  	}
				| expr '<' expr 				{ $$ = write_expr($1, $3, QW_LESS, -1); 	 	}
				| expr '>' expr 				{ $$ = write_expr($1, $3, QW_GREATER, -1);   	}
				| expr EQUAL expr 				{ $$ = write_expr($1, $3, QW_EQUAL, -1); 	 	}
				| expr NOTEQUAL expr 			{ $$ = write_expr($1, $3, QW_NOT_EQUAL, -1); 	}
				| expr LESSEQUAL expr 			{ $$ = write_expr($1, $3, QW_LESS_THAN, -1); 	}
				| expr MOREEQUAL expr 			{ $$ = write_expr($1, $3, QW_GREATER_THAN, -1); }
				| expr AND expr 				{ $$ = write_expr($1, $3, QW_AND, -1);			}
				| expr OR expr 					{ $$ = write_expr($1, $3, QW_OR, -1); 			}
				| NOT expr 						{ $$ = write_expr($2, NULL, QW_NOT, -1);		}
				| IDENTIFIER '[' expr ']'
					{
						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
						if (var == NULL) var = symt_search_by_name(tab, $1, VAR, NULL, 0);
						assertf(var != NULL, "variable %s has not been declared", $1);
						assertf($3->cons->type == CONS_INTEGER, "index must be an integer");

						free_mem(); fprintf(obj, "\n\tR3=R1;\t// Save index at R3");

						switch (symt_get_type_data(var->var->type))
						{
							case CONS_INTEGER:; case CONS_BOOL:;
								int *int_value = (int*)var->var->value;

								$$ = symt_insert_tab_cons_q(
									symt_new(), symt_get_type_data(var->var->type), (int_value + *((int*)$3->cons->value)),
									var->var->q_dir, offset, false
								);

								if (!is_call)
									qw_write_array_to_reg(
										obj, 1, symt_get_type_data(var->var->type), var->var->q_dir,
										*((int*)$3->cons->value), var->var->offset
									);
							break;

							case CONS_DOUBLE:;
								double *double_value = (double*)var->var->value;

								$$ = symt_insert_tab_cons_q(
									symt_new(), symt_get_type_data(var->var->type), (double_value + *((int*)$3->cons->value)),
									var->var->q_dir, offset, false
								);

								if (!is_call)
									qw_write_array_to_reg(
										obj, 1, symt_get_type_data(var->var->type), var->var->q_dir,
										*((int*)$3->cons->value), var->var->offset
									);
							break;

							case CONS_CHAR:;
								char *char_value = (char*)var->var->value;

								$$ = symt_insert_tab_cons_q(
									symt_new(), symt_get_type_data(var->var->type), (char_value + *((int*)$3->cons->value)),
									var->var->q_dir, offset, false
								);

								if (!is_call)
									qw_write_array_to_reg(
										obj, 1, symt_get_type_data(var->var->type), var->var->q_dir,
										*((int*)$3->cons->value), var->var->offset
									);
							break;
						}

						print_array_value = true;
					}
				| IDENTIFIER
					{
						print_array_value = false; is_param = false;
						symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
						if (var == NULL) var = symt_search_by_name(tab, $1, VAR, NULL, 0);
						assertf(var != NULL, "variable %s has not been declared", $1);

						if (q_dir_var == 0 && is_var == true) q_dir_var = var->var->q_dir;
						type = symt_get_type_data(var->var->type);

						$$ = symt_insert_tab_cons_q(
							symt_new(), type, var->var->value, var->var->q_dir,
							var->var->offset, var->var->is_param
						);

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

									qw_write_var_to_reg_with_R6(
										obj, 1, type, var->var->offset,
										true, rout->rout->type == VOID
									);
								}
							}
							else
							{
								symt_node* rout = symt_search_routine(tab, rout_name);

								qw_write_var_to_reg_with_R6(
									obj, 1, type, var->var->offset,
									false, rout->rout->type == VOID
								);
							}
						}
					}
				;

// __________ Constants and Data type __________

data_type 		: I8_TYPE { $$ = I8; }   | I16_TYPE { $$ = I16; } | I32_TYPE { $$ = I32; } | I64_TYPE { $$ = I64; }
				| F32_TYPE { $$ = F32; } | F64_TYPE { $$ = F64; } | CHAR_TYPE { $$ = C; }  | BOOL_TYPE { $$ = B; }
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
														bool cond = symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL;
														assertf(cond, "variable %s has already been declared", $1);

														symt_node* node = symt_insert_tab_var(
															symt_new(), $1, rout_name, $3, false, 0,
															NULL, true, level, q_dir, offset
														);

														tab = symt_push(tab, node);
														symt_natural_t size = symt_get_type_size(type);
														q_dir -= size; offset += size;
													}
				;

// __________ Declaration and Assignation for variables __________

list_expr 	: expr					{ $$ = symt_new_stack_elem(symt_get_name_from_node($1), symt_get_value_from_node($1), type, $1->cons->q_dir, $1->cons->offset, false, NULL); }
			| expr ',' list_expr	{ $$ = symt_new_stack_elem(symt_get_name_from_node($1), symt_get_value_from_node($1), type, $1->cons->q_dir, $1->cons->offset, false, $3); }
			;

var 		:   IDENTIFIER ':' data_type 				{
															symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
															assertf(var == NULL, "variable %s has already been declared", $1);

															symt_cons_t type_n = symt_get_type_data($3);
															symt_natural_t size = symt_get_type_size(type_n);
															q_dir -= size; offset += size;

															symt_node* node = symt_insert_tab_var(
																symt_new(), $1, rout_name, $3, 0, 0,
																NULL, 0, level, q_dir, offset
															);

															type = type_n;
															qw_push_fp(obj, type);
															qw_write_value_to_var(obj, type, node->var->value);
															tab = symt_push(tab, node);
														}
				| IDENTIFIER ':' arr_data_type			{
															symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
															assertf(var == NULL, "variable %s has already been declared", $1);

															type = symt_get_type_data($3);
															symt_natural_t size = symt_get_type_size(type);
															offset += size * array_length;

															symt_node *node = symt_insert_tab_var(
																symt_new(), $1, rout_name, $3, 1, array_length,
																NULL, 0, level, q_dir, offset
															);

															q_dir = qw_write_array(
																obj, type, q_dir, node->var->array_length,
																+section_label, offset, globals
															);

															tab = symt_push(tab, node);
														}
				| IDENTIFIER '=' expr					{
															symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
															assertf(var != NULL, "variable %s has not been declared", $1);
															type = symt_get_type_data(var->var->type);

															symt_assign_var(var->var, $3->cons);

															if (var->level == 0)
																qw_write_reg_to_var(
																	obj, 1, $3->cons->type, var->var->q_dir
																);
															else
																qw_write_reg_to_var_with_R6(
																	obj, 1, $3->cons->type,
																	var->var->offset, var->var->is_param
																);

															free_mem();
														}
				| IDENTIFIER '[' expr ']' '=' expr		{
															symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
															assertf(var != NULL, "variable %s has not been declared", $1);
															type = symt_get_type_data(var->var->type);

															int index = *((int*)$3->cons->value);
															symt_assign_var_at(var->var, $6->cons, index);

															qw_write_reg_to_array(
																obj, 1, $6->cons->type, var->var->q_dir,
																index, var->var->offset
															);

															free_mem();
														}
				| IDENTIFIER ':' data_type '=' expr		{
															bool cond = symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL;
															assertf(cond, "variable %s has already been declared", $1);

															free_mem(); symt_natural_t size = symt_get_type_size(type);
															q_dir -= size; if (!globals) offset += size;

															symt_node* result = symt_insert_tab_var(
																symt_new(), $1, rout_name, $3, 0, 0, NULL,
																0, level, q_dir, offset
															);

															symt_assign_var(result->var, $5->cons);

															qw_push_fp(obj, $5->cons->type);
															qw_write_reg_to_var(obj, 1, $5->cons->type, 0);
															tab = symt_push(tab, result);
														}
				| IDENTIFIER ':' arr_data_type '=' { is_call = true; prev_offset = offset; } '{' list_expr '}'
					{
						is_call = false; offset = prev_offset;
						bool cond = symt_search_by_name(tab, $1, VAR, rout_name, level) == NULL;
						assertf(cond, "variable %s has already been declared", $1);

						symt_natural_t size = symt_get_type_size(symt_get_type_data($3));
						if (globals) q_dir -= size * array_length;
						offset += size * array_length;

						tab = symt_insert_tab_var(tab, $1, rout_name, $3, 1, array_length, NULL, 0, level, q_dir, offset);

						symt_node* var = symt_search_by_name(tab, $1, VAR, rout_name, level);
						assertf(var != NULL, "variable %s has not been declared", $1);

						symt_name_t str_type1 = symt_strget_vartype(var->var->type), str_type2 = symt_strget_vartype($3);
						assertf(var->var->type == $3, "type %s does not match %s at %s variable declaration", str_type1, str_type2, $1);
						symt_stack *stack = $7, *stack_v = $7;
						free_mem();

						switch(value_list_expr_t)
						{
							case CONS_INTEGER:;
								int *zero_int = (int *)(ml_malloc(sizeof(int)));
								int *values_int = (int *)(ml_malloc(sizeof(int) * array_length));

								for (int i = 0; i < array_length; i++)
								{
									symt_cons* cons = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
									cons->type = value_list_expr_t;

									if (stack) cons->value = stack->value;
									else cons->value = (void*)zero_int;

									symt_can_assign(var->var->type, cons);
									if (stack) stack = stack->next;
									ml_free(cons);
								}

								for (int i = 0; stack_v; i++)
								{
									*(values_int + i) = *((int*)stack_v->value);
									stack_v = stack_v->next;
								}

								var->var->value = (void*)values_int;
							break;

							case CONS_DOUBLE:;
								double *zero_double = (double *)(ml_malloc(sizeof(double)));
								double *values_double = (double *)(ml_malloc(sizeof(double) * array_length));

								for(int i = 0; i < array_length; i++)
								{
									symt_cons* cons = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
									cons->type = value_list_expr_t;

									if (stack) cons->value = stack->value;
									else cons->value = (void*)zero_double;

									symt_can_assign(var->var->type, cons);
									if (stack) stack = stack->next;
									ml_free(cons);
								}

								for(int i = 0; stack_v; i++)
								{
									*(values_double + i) = *((double*)stack_v->value);
									stack_v = stack_v->next;
								}

								var->var->value = (void*)values_double;
							break;

							case CONS_CHAR:;
								char *zero_char = (char *)(ml_malloc(sizeof(char)));
								char *values_char = (char *)(ml_malloc(sizeof(char) * array_length));

								for (int i = 0; i < array_length; i++)
								{
									symt_cons* cons = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
									cons->type = value_list_expr_t;

									if (stack) cons->value = stack->value;
									else cons->value = (void*)zero_char;

									symt_can_assign(var->var->type, cons);
									if (stack) stack = stack->next;
									ml_free(cons);
								}

								for (int i = 0; stack_v; i++)
								{
									*(values_char + i) = *((char*)stack_v->value);
									stack_v = stack_v->next;
								}

								var->var->value = (void*)values_char;
							break;
						}

						symt_natural_t pre_q_dir = q_dir;
						q_dir = qw_write_array(obj, symt_get_type_data($3), q_dir, array_length, ++section_label, offset, globals);

						for (int i = 0; i < var->var->array_length; i++)
						{
							switch (value_list_expr_t)
							{
								case CONS_INTEGER: case CONS_BOOL:;
									int *value_int = (int*)(var->var->value) + i;
									qw_write_value_to_reg(obj, 1, symt_get_type_data($3), (void*)value_int);
									qw_write_reg_to_array(obj, 1, symt_get_type_data($3), pre_q_dir, i, offset);
								break;

								case CONS_DOUBLE:;
									double *value_double = (double*)(var->var->value) + i;
									qw_write_value_to_reg(obj, 1, symt_get_type_data($3), (void*)value_double);
									qw_write_reg_to_array(obj, 1, symt_get_type_data($3), pre_q_dir, i, offset);
								break;

								case CONS_CHAR:;
									char *value_char = (char*)(var->var->value) + i;
									qw_write_value_to_reg(obj, 1, symt_get_type_data($3), (void*)value_char);
									qw_write_reg_to_array(obj, 1, symt_get_type_data($3), pre_q_dir, i, offset);
								break;
							}
						}

						q_dir -= symt_get_type_size(symt_get_type_data($3)) * array_length;
					}
				| call_assing
				;

call_assing		:	IDENTIFIER '=' CALL IDENTIFIER							{
																				symt_node *result = symt_search_by_name(tab, $4, FUNCTION, NULL, 0);
																				if (result == NULL) result = symt_search_by_name(tab, $4, PROCEDURE, NULL, 0);
																				assertf(result != NULL, "%s routine does not exist", $4);
																				assertf(result->id != PROCEDURE, "%s routine is a procedure, procedures does not return values", $4);

																				symt_node *params = symt_search_params(tab, $4);
																				assertf(params == NULL, "%s routine does need parameters", $4);

																				symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																				assertf(var != NULL, "variable %s has not been declared", $1);
																				assertf(result->rout->type == var->var->type, "type does not match");
																				symt_natural_t size = 0;

																				fprintf(obj, "\n\tR7=R7-4;\t// Reserve memory for R5");
																				fprintf(obj, "\n\tP(R7)=R5;\t// Save R5 value");

																				if (result->id == FUNCTION)
																				{
																					type = symt_get_type_data(result->rout->type);
																					size = symt_get_type_size(type);
																				}

																				qw_write_call_return(obj, result->rout->label, label++, size, type);
																				fprintf(obj, "\n\tR5=P(R7);\t// Restore R5 value");
																				fprintf(obj, "\n\tR7=R7+4;\t// Reserve memory for R5");

																				if (var->level == 0)
																				{
																					if (!var->var->is_param)
																						qw_write_reg_to_var(obj, 1, type, var->var->q_dir);
																					else
																					{
																						is_param = true;
																						symt_node* rout = symt_search_routine(tab, rout_name);
																						qw_write_var_to_reg_with_R6(obj, 1, type, var->var->offset, true, rout->rout->type == VOID);
																					}
																				}
																				else
																					qw_write_reg_to_var_with_R6(obj, 1, type, var->var->offset, false);
																			}
				| 	IDENTIFIER  '='  CALL IDENTIFIER list_expr				{
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

																				fprintf(obj, "\n\tR7=R7-4;\t// Reserve memory for R5");
																				fprintf(obj, "\n\tP(R7)=R5;\t// Save R5 value");

																				symt_stack* iter = $5;
																				symt_node *iter_p = params;
																				bool no_more_params = false;
																				symt_natural_t r7_offset = 0;
																				symt_natural_t num_params_curr = 0;

																				free_mem();

																				while (true)
																				{
																					if (iter_p->id != VAR) { no_more_params = true; break; }
																					if (strcmp(iter_p->var->rout_name, $4) != 0) { no_more_params = true; break; }
																					if (iter == NULL) break;

																					symt_cons_t param_type = symt_get_type_data(iter_p->var->type);
																					symt_cons_t arg_type = symt_get_type_data(iter->type);
																					assertp(arg_type == param_type, "type does not match");

																					switch (arg_type)
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
																				symt_natural_t size = 0;

																				if (result->id == FUNCTION)
																				{
																					type = symt_get_type_data(result->rout->type);
																					size = symt_get_type_size(type);
																				}

																				qw_write_call_return(obj, result->rout->label, label++, size, type);
																				fprintf(obj, "\n\tR7=R7+%d;\t// Free parameters' space", (int)r7_offset);
																				fprintf(obj, "\n\tR5=P(R7);\t// Restore R5 value");
																				fprintf(obj, "\n\tR7=R7+4;\t// Reserve memory for R5");

																				if (var->level == 0)
																				{
																					if (!var->var->is_param)
																						qw_write_reg_to_var(obj, 1, type, var->var->q_dir);
																					else
																					{
																						is_param = true;
																						symt_node* rout = symt_search_routine(tab, rout_name);
																						qw_write_var_to_reg_with_R6(obj, 1, type, var->var->offset, true, rout->rout->type == VOID);
																					}
																				}
																				else
																					qw_write_reg_to_var_with_R6(obj, 1, type, var->var->offset, false);
																			}
				| 	IDENTIFIER '[' expr ']' '='  CALL IDENTIFIER			{
																				symt_node *result = symt_search_by_name(tab, $7, FUNCTION, NULL, 0);
																				if (result == NULL) result = symt_search_by_name(tab, $7, PROCEDURE, NULL, 0);
																				assertf(result != NULL, "%s routine does not exist", $7);

																				assertf(result->id != PROCEDURE, "%s routine is a procedure, procedures does not return values", $7);

																				symt_node *params = symt_search_params(tab, $7);
																				assertf(params == NULL, "%s routine does need parameters", $7);

																				symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																				assertf(var != NULL, "variable %s has not been declared", $1);

																				assertf(result->rout->type == var->var->type, "type does not match");
																				symt_natural_t size = 0;

																				fprintf(obj, "\n\tR7=R7-4;\t// Reserve memory for R5");
																				fprintf(obj, "\n\tP(R7)=R5;\t// Save R5 value");

																				if(result->id == FUNCTION)
																				{
																					type = symt_get_type_data(result->rout->type);
																					size = symt_get_type_size(type);
																				}

																				qw_write_call_return(obj, result->rout->label, label++, size, type);

																				fprintf(obj, "\n\tR5=P(R7);\t// Restore R5 value");
																				fprintf(obj, "\n\tR7=R7+4;\t// Reserve memory for R5");

																				qw_write_reg_to_array(obj, 1, type, var->var->q_dir, *((int*)$3->cons->value), var->var->offset);
																			}
				| 	IDENTIFIER ':' data_type '=' CALL IDENTIFIER			{
																				symt_node *result = symt_search_by_name(tab, $6, FUNCTION, NULL, 0);
																				if (result == NULL) result = symt_search_by_name(tab, $6, PROCEDURE, NULL, 0);
																				assertf(result != NULL, "%s routine does not exist", $6);
																				assertf(result->id != PROCEDURE, "%s routine is a procedure, procedures does not return values", $6);

																				symt_node *params = symt_search_params(tab, $6);
																				assertf(params == NULL, "%s routine does need parameters", $6);

																				symt_natural_t size = symt_get_type_size(symt_get_type_data($3));
																				q_dir -= size; offset += size;

																				assertf(result->rout->type == $3, "type does not match")
																				symt_node* node = symt_new();
																				node = symt_insert_tab_var(node, $1, rout_name,  $3, 0, 0, NULL, 0, level, q_dir, offset);
																				tab = symt_push(tab, node);

																				size = 0;
																				fprintf(obj, "\n\tR7=R7-4;\t// Reserve memory for R5");
																				fprintf(obj, "\n\tP(R7)=R5;\t// Save R5 value");

																				if (result->id == FUNCTION)
																				{
																					type = symt_get_type_data(result->rout->type);
																					size = symt_get_type_size(type);
																				}

																				qw_write_call_return(obj, result->rout->label, label++, size, type);

																				fprintf(obj, "\n\tR5=P(R7);\t// Restore R5 value");
																				fprintf(obj, "\n\tR7=R7+4;\t// Reserve memory for R5");

																				qw_push_fp(obj, symt_get_type_data($3));
																				qw_write_reg_to_var(obj,1,type,0);
																			}
				| 	IDENTIFIER ':' data_type '=' CALL IDENTIFIER list_expr	{
																				symt_node *result = symt_search_by_name(tab, $6, FUNCTION, NULL, 0);
																				if (result == NULL) result = symt_search_by_name(tab, $6, PROCEDURE, NULL, 0);
																				assertf(result != NULL, "%s routine does not exist", $6);

																				assertf(result->id != PROCEDURE, "%s routine is a procedure, procedures does not return values", $6);

																				symt_node *params = symt_search_params(tab, $6);
																				assertf(params != NULL, "%s routine does not need parameters", $6);

																				symt_natural_t size = symt_get_type_size(symt_get_type_data($3));
																				q_dir -= size; offset += size;

																				assertf(result->rout->type == $3, "type does not match")
																				symt_node* node = symt_new();
																				node = symt_insert_tab_var(node, $1, rout_name,  $3, 0, 0, NULL, 0, level, q_dir, offset);
																				tab = symt_push(tab, node);

																				symt_node* rout = symt_search_routine(tab, rout_name);
																				bool is_void = rout->rout->type == VOID;

																				fprintf(obj, "\n\tR7=R7-4;\t// Reserve memory for R5");
																				fprintf(obj, "\n\tP(R7)=R5;\t// Save R5 value");

																				symt_stack* iter = $7;
																				symt_node *iter_p = params;
																				bool no_more_params = false;
																				symt_natural_t r7_offset = 0;
																				symt_natural_t num_params_curr = 0;

																				free_mem();

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
																				size = 0;

																				if(result->id == FUNCTION)
																				{
																					type = symt_get_type_data(result->rout->type);
																					size = symt_get_type_size(type);
																				}

																				qw_write_call_return(obj, result->rout->label, label++, size, type);
																				fprintf(obj, "\n\tR7=R7+%d;\t// Free parameters' space", (int)r7_offset);

																				fprintf(obj, "\n\tR5=P(R7);\t// Restore R5 value");
																				fprintf(obj, "\n\tR7=R7+4;\t// Reserve memory for R5");

																				qw_push_fp(obj, symt_get_type_data($3));
																				qw_write_reg_to_var(obj,1,type,0);
																			}
				| 	IDENTIFIER '[' expr ']' '='  CALL IDENTIFIER list_expr	{
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

																				fprintf(obj, "\n\tR7=R7-4;\t// Reserve memory for R5");
																				fprintf(obj, "\n\tP(R7)=R5;\t// Save R5 value");

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
																				symt_natural_t size = 0;

																				if(result->id == FUNCTION)
																				{
																					type = symt_get_type_data(result->rout->type);
																					size = symt_get_type_size(type);
																				}

																				qw_write_call_return(obj, result->rout->label, label++, size, type);
																				fprintf(obj, "\n\tR7=R7+%d;\t// Free parameters' space", (int)r7_offset);
																				fprintf(obj, "\n\tR5=P(R7);\t// Restore R5 value");
																				fprintf(obj, "\n\tR7=R7+4;\t// Reserve memory for R5");

																				qw_write_reg_to_array(obj, 1, type, var->var->q_dir, *((int*)$3->cons->value), var->var->offset);
																			}
				| 	IDENTIFIER '=' CALL ARRLENGTH IDENTIFIER				{
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
																				fprintf(obj, "\n\tR1=%d;\t// Set array length at R1", (int)var2->var->array_length);
																				symt_delete_cons(arrlen);

																				if (var1->level == 0)
																				{
																					if (!var1->var->is_param)
																						qw_write_reg_to_var(obj, 1, CONS_INTEGER, var1->var->q_dir);
																					else
																					{
																						is_param = true;
																						symt_node* rout = symt_search_routine(tab, rout_name);
																						qw_write_var_to_reg_with_R6(obj, 1, CONS_INTEGER, var1->var->offset, true, rout->rout->type == VOID);
																					}
																				}
																				else
																					qw_write_reg_to_var_with_R6(obj, 1, CONS_INTEGER, var1->var->offset, false);
																			}
				| 	IDENTIFIER ':' data_type '=' CALL ARRLENGTH IDENTIFIER	{
																				symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
																				assertf(var == NULL, "variable %s has already been declared", $1);

																				symt_natural_t size = symt_get_type_size(symt_get_type_data($3));
																				q_dir -= size; offset += size;

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
				| 	IDENTIFIER '[' expr ']' '='  CALL ARRLENGTH IDENTIFIER	{
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

																			fprintf(obj, "\n\tR7=R7-4;\t// Reserve memory for R5");
																			fprintf(obj, "\n\tP(R7)=R5;\t// Save R5 value");

																			assertf(symt_search_params(tab, $2) == NULL, "%s routine does not need parameters", $2);
																			qw_write_call(obj, result->rout->label, label++);

																			fprintf(obj, "\n\tR5=P(R7);\t// Restore R5 value");
																			fprintf(obj, "\n\tR7=R7+4;\t// Reserve memory for R5");
																		}
				| CALL IDENTIFIER { is_call = true; } list_expr			{
																			is_call = false;
																			symt_node *result = symt_search_by_name(tab, $2, FUNCTION, NULL, 0);
																			if (result == NULL) result = symt_search_by_name(tab, $2, PROCEDURE, NULL, 0);
																			assertf(result != NULL, "%s routine does not exist", $2);
																			assertf(result->id != FUNCTION, "%s routine is a function, you must store the returned value", $2);

																			symt_node *params = symt_search_params(tab, $2);
																			assertf(params != NULL, "%s routine needs parameters", $2);

																			symt_node* rout = symt_search_routine(tab, rout_name);
																			bool is_void = rout->rout->type == VOID;

																			fprintf(obj, "\n\tR7=R7-4;\t// Reserve memory for R5");
																			fprintf(obj, "\n\tP(R7)=R5;\t// Save R5 value");

																			symt_stack* iter = $4; symt_node *iter_p = params;
																			symt_natural_t r7_offset = 0, num_params_curr = 0;
																			bool no_more_params = false;

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
																			fprintf(obj, "\n\tR5=P(R7);\t// Restore R5 value");
																			fprintf(obj, "\n\tR7=R7+4;\t// Reserve memory for R5");
																		}
				| CALL SHOW expr										{
																			bool is_void = true;
																			symt_node* rout = symt_search_routine(tab, rout_name);

																			if (rout == NULL) is_void = false;
																			else if (rout->rout->type != VOID) is_void = false;

																			qw_write_show_value(obj, label++, $3->cons->type, $3->cons->offset, $3->cons->q_dir, $3->cons->value, is_param, is_void, print_array_value, false);
																			print_array_value = false; is_param = false; free_mem();
																		}
				| CALL SHOWLN expr										{
																			bool is_void = true;
																			symt_node* rout = symt_search_routine(tab, rout_name);

																			if (rout == NULL) is_void = false;
																			else if (rout->rout->type != VOID) is_void = false;

																			qw_write_show_value(obj, label++, $3->cons->type, $3->cons->offset, $3->cons->q_dir, $3->cons->value, is_param, is_void, print_array_value, true);
																			print_array_value = false; is_param = false; free_mem();
																		}
				;

// __________ Assignation for variables __________

var_assign      : IDENTIFIER '=' expr					{
															symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
															assertf(var != NULL, "variable %s has not been declared", $1);
															free_mem(); symt_assign_var(var->var, $3->cons);

															if (var->level == 0)
															{
																if (!var->var->is_param)
																	qw_write_reg_to_var(obj, 1, type, var->var->q_dir);
																else
																{
																	is_param = true;
																	symt_node* rout = symt_search_routine(tab, rout_name);
																	qw_write_var_to_reg_with_R6(obj, 1, type, var->var->offset, true, rout->rout->type == VOID);
																}
															}
															else
																qw_write_reg_to_var_with_R6(obj, 1, type, var->var->offset, false);
														}
                | IDENTIFIER '[' expr ']' '=' expr		{
															symt_node *var = symt_search_by_name(tab, $1, VAR, rout_name, level);
															assertf(var != NULL, "variable %s has not been declared", $1);

															free_mem(); symt_assign_var_at(var->var, $6->cons, *((int*)$3->cons->value));
															qw_write_reg_to_array(obj, 1, type, var->var->q_dir, *((int*)$3->cons->value), var->var->offset);
														}
                ;

// __________ Statement __________

statement 		: { $$ = false; is_var = true; } | var { is_var = false; } EOL statement { $$ = true; }
				| { level++; is_var = false; offset+=8; fprintf(obj, "\n\tR7=R7-4;\t// Push frame pointer R7\n\tP(R7)=R5;\t// Store previous R7 when loop has found\n\tR7=R7-4;\t// Push frame pointer\n\tR5=R7;\t// Save R7 direction before going to loop\n\tP(R7)=R7;\t// Save R7 in stack"); } BEGIN_IF '(' expr ')' { free_mem(); qw_write_condition(obj, label); num_reg = 2; $<integer_t>$=label++; } EOL statement { qw_write_new_label(obj, $<integer_t>6); } more_else END_IF { free_mem(); level--;  symt_natural_t new_offset = symt_end_block(tab, level); fprintf(obj, "\n\tR1=P(R5+4);\n\tR7=P(R5);"); fprintf(obj, "\n\tR5=P(R5+4);\t// Restore R5 before this loop\n\tR7=R7+8;// Pop trash of this loop"); offset-=8; offset = new_offset; } EOL statement { $$ = true; }
				| { level++; begin_last_loop=label; $<integer_t>$=label; qw_write_begin_loop(obj, label++, q_dir); is_var = false; offset+=8; } BEGIN_WHILE '(' expr ')' { free_mem(); qw_write_condition(obj, label); end_last_loop=label; num_reg = 2; $<integer_t>$=label++; } EOL statement END_WHILE { free_mem(); level--; symt_natural_t new_offset = symt_end_block(tab, level);  qw_write_end_loop(obj, $<integer_t>1, $<integer_t>6); fprintf(obj, "\n\tR1=P(R5+4);\n\tR7=P(R5);"); fprintf(obj, "\n\tR5=P(R5+4);\t// Restore R5 before this loop\n\tR7=R7+8;// Pop trash of this loop"); offset-=8; offset = new_offset; } EOL statement { $$ = true; }
				| { level++; is_var = true; } BEGIN_FOR '(' var ',' { var_type=type; is_var = false; begin_last_loop=label; $<integer_t>$=label; qw_write_begin_loop(obj, label++, q_dir); offset+=8; } var_assign ',' expr ')' { free_mem(); qw_write_condition(obj, label); end_last_loop=label; num_reg = 2; $<integer_t>$=label++; } EOL statement END_FOR { level--; symt_natural_t new_offset = symt_end_block(tab, level); qw_write_end_loop(obj, $<integer_t>6, $<integer_t>11); free_mem(); fprintf(obj, "\n\tR1=P(R5+4);\n\tR7=P(R5);"); fprintf(obj, "\n\tR5=P(R5+4);\t// Restore R5 before this loop\n\tR7=R7+8;// Pop trash of this loop"); offset-=8; offset-=(int)symt_get_type_size(var_type); fprintf(obj, "\n\tR7=R7+%d;", (int)symt_get_type_size(var_type)); offset = new_offset;} EOL statement { $$ = true; }
				| { level++; } call_func EOL statement	{ level--; $$ = true; }
				| CONTINUE { qw_write_goto(obj, begin_last_loop); } EOL statement { $$ = true; }
                | BREAK { qw_write_goto(obj, end_last_loop); } EOL statement { $$ = true; }
				| EOL statement { if ($2 != false) $$ = true; else $$ = false; }
				| error EOL statement { $$ = true; }
				;

more_else 		: { $$ = false; } | ELSE_IF { symt_end_block(tab, level); } EOL statement { $$ = true; }
				| ELSE_IF { symt_end_block(tab, level); } BEGIN_IF '(' expr ')' { free_mem(); qw_write_condition(obj, label); $<integer_t>$=label++; } EOL statement { qw_write_new_label(obj, $<integer_t>7); } more_else { $$ = true; }
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

void yyerror(const char *mssg)
{
	char *format = "\033[0;31merror:\033[0m \033[1m%s\033[0m: %s, error at line %d\n";
	fprintf(stderr, format, reader.file, mssg, reader.num_line);
}

void free_mem()
{
    if (num_double_cons > 0)
    {
        int num_offset = 0;
        while (num_double_cons > 0) { num_offset += 8; offset -= 8; num_double_cons--; }
        fprintf(obj, "\n\tR7=R7+%d;\t// Pop frame pointer", num_offset);
    }

    if (num_int_cons > 0)
    {
        int num_offset = 0;
        while (num_int_cons > 0) { num_offset += 4; offset -= 4; num_int_cons--; }
        fprintf(obj, "\n\tR7=R7+%d;\t// Pop frame pointer", num_offset);
    }
}

symt_node* write_cons(symt_cons_t type_n, symt_value_t value)
{
	print_array_value = false; type = type_n; is_expr = false;
	is_param = false; offset += symt_get_type_size(type);
	symt_node *res = symt_insert_tab_cons(symt_new(), type, value, offset, false);

	if (!is_call)
	{
		qw_push_fp(obj, type);

		if (type == CONS_DOUBLE)
		{
			double val = *((double*)res->cons->value);
			num_double_cons++; fprintf(obj, "\n\tRR1=%f;\t// Set constant value to RR1", val);
		}
		else
		{
			int val = (*(int*)res->cons->value);
			num_int_cons++; fprintf(obj, "\n\tR1=%d;\t// Set constant value to R1", val);
		}

		qw_write_reg_to_var(obj, 1, type, 0);
	}

	return res;
}

symt_node* write_expr(symt_node* op1, symt_node* op2, qw_op_t sign, symt_natural_t label)
{
	print_array_value = false;
	assertp(globals == false, "globals could not be defined with expressions");

	symt_node* rout = symt_search_routine(tab, rout_name);
	bool is_void = rout->rout->type == VOID;

	if (op1 != NULL)
	{
		if (op1->cons->offset != 0 || op1->cons->is_param)
			qw_write_var_to_reg_with_R6(
				obj, 2, type, op1->cons->offset,
				op1->cons->is_param, is_void
			);
		else
			qw_write_var_to_reg(
				obj, 2, type, op1->cons->q_dir
			);
	}

	if (op2 != NULL)
	{
		if (op2->cons->offset != 0 || op2->cons->is_param)
			qw_write_var_to_reg_with_R6(
				obj, 1, type, op2->cons->offset,
				op2->cons->is_param, is_void
			);
		else
			qw_write_var_to_reg(
				obj, 1, type, op2->cons->q_dir
			);
	}

	qw_write_expr(obj, sign, type, label);
	qw_push_fp(obj, op2->cons->type);

	if (type == CONS_DOUBLE) { num_double_cons++; offset += 8; }
	else { num_int_cons++; offset += 4; }

	qw_write_reg_to_var(obj, 1, type, 0);
	symt_node* res = symt_new(); res->id = CONSTANT;
	int result;

	switch(sign)
	{
		// Arithmetic
		case QW_ADD: res->cons = symt_cons_add(type, op1->cons, op2->cons); 			break;
		case QW_SUB: res->cons = symt_cons_sub(type, op1->cons, op2->cons); 			break;
		case QW_MULT: res->cons = symt_cons_mult(type, op1->cons, op2->cons); 			break;
		case QW_DIV: res->cons = symt_cons_div(type, op1->cons, op2->cons); 			break;
		case QW_POW: res->cons = symt_cons_pow(type, op1->cons, op2->cons); 			break;
		case QW_MOD: res->cons = symt_cons_mod(type, op1->cons, op2->cons); 			break;

		// Comparison
		case QW_LESS: res->cons = symt_cons_lt(op1->cons, op2->cons); 					break;
		case QW_GREATER: res->cons = symt_cons_gt(op1->cons, op2->cons); 				break;
		case QW_GREATER_THAN: res->cons = symt_cons_geq(op1->cons, op2->cons); 			break;
		case QW_LESS_THAN: res->cons = symt_cons_leq(op1->cons, op2->cons); 			break;
		case QW_EQUAL: res->cons = symt_cons_eq(op1->cons, op2->cons); 					break;
		case QW_NOT_EQUAL: res->cons = symt_cons_neq(op1->cons, op2->cons); 			break;

		// Logical
		case QW_AND:
			assertf(type != CONS_CHAR, "char types does not support logic operation");
			result = *((int*)op1->cons->value) && *((int*)op2->cons->value);
			res = symt_insert_tab_cons(res, CONS_BOOL, &result, offset, false);
		break;

		case QW_OR:
			assertf(type != CONS_CHAR, "char types does not support logic operation");
			result = *((int*)op1->cons->value) || *((int*)op2->cons->value);
			res = symt_insert_tab_cons(res, CONS_BOOL, &result, offset, false);
		break;

		case QW_NOT:
			assertf(type != CONS_CHAR, "char types does not support logic operation");
			result = !(*((int*)op1->cons->value));
			res = symt_insert_tab_cons(res, CONS_BOOL, &result, offset, false);
		break;
	}

	res->cons->offset = offset;
	if (op1 != NULL) symt_delete(op1);
	if (op2 != NULL) symt_delete(op2);

	return res;
}
