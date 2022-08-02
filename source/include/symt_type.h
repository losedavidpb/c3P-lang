// symt_type.h -*- C -*-
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
 *	ISO C99 Standard: Types for symt
 */

#ifndef SYMT_TYPE_H
#define SYMT_TYPE_H

#include <stdbool.h>
#include <stddef.h>

/* Check if passed value is between passed limits */
#define symt_check_range(value, min, max) value >= min && value <= max

/* Cast an integer to a boolean value */
#define symt_to_bool(num) num != 1? false : true

/* Get memory size for passed data type */
#define symt_get_type_size(type) type == CONS_DOUBLE? 8 : 4

// Null value for numbers
#define SYMT_NULL -1

/* Optional identifier for symbols used to
   distinguish instances with the same id */
typedef char * symt_name_t;

/* Type natural numbers */
typedef size_t symt_natural_t;

/* Available symbols for symbol tables which
   which will be used as identifiers */
typedef enum symt_id_t
{
	VAR,			// local and global variables
    CONSTANT,       // constants for primitive data
    FUNCTION,       // routines with a return
    PROCEDURE,      // routines with any return
} symt_id_t;

/* Type for values stored at local and global
   variables, which has not been casted */
typedef void * symt_value_t;

/* Types for primitive data at constants */
typedef enum symt_cons_t { CONS_INTEGER, CONS_DOUBLE, CONS_CHAR, CONS_BOOL } symt_cons_t;

/* Primitive types for variables and return functions */
typedef enum symt_var_t { I8, I16, I32, I64, F32, F64, B, C, VOID } symt_var_t;

/* Range of values for integers */
#define I8_MIN -128
#define I8_MAX 127
#define I16_MIN -32768
#define I16_MAX 32768
#define I32_MIN -214483648
#define I32_MAX 2147483647
#define I64_MIN -9223372036854775808
#define I64_MAX 9223372036854775807

/* Range of values for floats */
#define F32_MIN -3.4e37
#define F32_MAX 3.4e38
#define F64_MIN -1.7e308
#define F64_MAX 1.7e308

/* Range of values for characters */
#define CHAR_MIN I64_MIN
#define CHAR_MAX I64_MAX

/* Range of values for booleans */
#define BOOL_MIN false
#define BOOL_MAX true

/* Type for local and global variables */
typedef struct symt_var
{
    symt_name_t name, rout_name;
    symt_var_t type;
    symt_value_t value;
    symt_natural_t array_length, offset, q_dir;
	bool is_array, is_param;
} symt_var;

/* Type for constants */
typedef struct symt_cons
{
    symt_cons_t type;
    symt_value_t value;
	symt_natural_t offset, q_dir;
	bool is_param;
} symt_cons;

/* Type for functions and procedures */
typedef struct symt_rout
{
    symt_name_t name;
    symt_var_t type;
	symt_natural_t label;
} symt_rout;

/* Type for a node which is are at a symbol table */
typedef struct symt_node
{
	symt_natural_t level;
    symt_id_t id;
    symt_rout* rout;
    symt_var* var;
    symt_cons* cons;
    struct symt_node* next_node;
} symt_node;

/* Type for a symbol table */
typedef symt_node symt_tab;

#endif	// SYMT_TYPE_H
