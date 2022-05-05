/* Stack with variables used when Bison is parsing c3P */
#ifndef YY_STACK_H
#define YY_STACK_H
#include <stdio.h>
#include "symt_type.h"

/* Structure of all globals used at Bison for c3P */
typedef struct yystack_t
{
	int l_error;	  				// Specify if lexical errors were detected
	int num_lines; 					// Number of lines processed
	FILE *yyin;						// Current file for Bison

	int s_error; 				// Specify if syntax errors were detected

	symt_level_t level;			// Current level of symbol table
	symt_tab *tab; 					// Symbol table

	symt_cons_t type;				// Type of a value
	int array_length;  			// Array length for current token
	void *value_list_expr; 			// Array value for current token
	symt_cons_t value_list_expr_t;	// Constant for a part of a list expression
	symt_name_t rout_name;			// Routine name for variables

	char* current_file;

	struct yystack_t *next;
} yystack_t;

/* Create a new dynamic stack */
yystack_t *yystack_new(char* file_name);

/* Push a new element at current stack */
void yystack_push(yystack_t* stack, yystack_t *new_value);

/* Pop first element of the stack */
yystack_t *yystack_pop(yystack_t* stack);

#endif	// YY_STACK_H
