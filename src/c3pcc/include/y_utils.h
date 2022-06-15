// y_utils.h -*- C -*-
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
 *	ISO C99 Standard: Globals and utilities for Bison
 */

#ifndef Y_UTILS_H
#define Y_UTILS_H

#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>

#include "symt.h"
#include "assertb.h"
#include "arrcopy.h"
#include "memlib.h"
#include "qwriter.h"
#include "f_reader.h"

static FILE *obj;										// Object file for Q code
static symt_natural_t q_dir = QW_FIRST_DIR;				// Direction to store globals
static symt_natural_t q_dir_var;						// Direction for local variables and parameters
static symt_natural_t section_label = 0;				// Section label for STAT and CODE
static symt_natural_t num_reg = 2;						// Current register used to store a value

static symt_natural_t level = 0;						// Current level of symbol table
static symt_natural_t label = 2;						// Label that will be created at Q file
static symt_tab *tab; 									// Symbol table

static bool globals = true;								// Specify if variables are globals
static bool is_var;										// Specify if next symbols are variables
static symt_natural_t offset;							// Offset for local variables and parameters
static symt_natural_t prev_offset;						// Previous offset for local variables and parameters

static symt_cons_t type;								// Type of a value defined as constant
static symt_cons_t var_type;							// Type for variables

static bool is_expr;									// Check if current line is an expression
static symt_natural_t num_int_cons = 0;					// Number of integer constants stored at memory
static symt_natural_t num_double_cons = 0;				// Number of double constants stored at memory

static symt_natural_t begin_last_loop = 0;				// Label for the start of a loop
static symt_natural_t end_last_loop = 0;				// Label for the end of a loop

static symt_natural_t array_length = 0;  				// Array length for current token
static void *value_list_expr; 							// Array value for current token
static symt_cons_t value_list_expr_t;					// Constant for a part of a list expression

static bool print_array_value = false;					// Check if arrays would be printed

static bool is_call = false;							// Check if it is a call statement
static symt_name_t rout_name;							// Routine name for variables
static bool is_param;									// Check if it is a parameter

/* Check if passed name has passed extension */
int ends_with(const char* name, const char* ext, symt_natural_t length);

/* Write constant at Bison */
symt_node* write_cons(symt_cons_t, symt_value_t);

/* Write an expression at Bison */
symt_node* write_expr(symt_node*, symt_node*, qw_op_t, symt_natural_t);

/* Free constants stored at stack */
void free_mem();

#endif	// Y_UTILS_H
