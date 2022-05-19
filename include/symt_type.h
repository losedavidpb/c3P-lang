/* Basic symbols and types used by symt to store tokens */
#ifndef SYMT_TYPE_H
#define SYMT_TYPE_H

#include <stdbool.h>
#include <stddef.h>

/* Check if passed value is between passed limits */
#define symt_check_range(value, min, max) value >= min && value <= max

/* Cast an integer to a boolean value */
#define symt_to_bool(num) num != 1? false : true

// Identifier which only could be associated
// to first element which is defined at stack
#define SYMT_ROOT_ID -1

// Null value for enumerators
#define SYMT_NULL -1

/* Optional identifier for symbols used to
   distinguish instances with the same id */
typedef char * symt_name_t;

/* Level for each node that is stored at symbol table.
   Global variables must be at level -1, while the rest
   of nodes, except constants, would start from 0 to a
   specific natural number. */
typedef int symt_level_t;

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
typedef enum symt_cons_t { CONS_INTEGER, CONS_DOUBLE, CONS_CHAR, CONS_STR, CONS_BOOL } symt_cons_t;

/* Primitive types for variables and return functions */
typedef enum symt_var_t { I8, I16, I32, I64, F32, F64, B, C, STR, VOID } symt_var_t;

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
    bool is_array, is_param;
    size_t array_length;
} symt_var;

/* Type for constants */
typedef struct symt_cons
{
    symt_cons_t type;
    symt_value_t value;
} symt_cons;

/* Type for functions and procedures */
typedef struct symt_rout
{
    symt_name_t name;
    symt_var_t type;
} symt_rout;

/* Type for a node which is are at a symbol table */
typedef struct symt_node
{
	symt_level_t level;
    symt_id_t id;
    symt_rout* rout;
    symt_var* var;
    symt_cons* cons;
    struct symt_node* next_node;
} symt_node;

/* Type for a symbol table */
typedef symt_node symt_tab;

#endif	// SYMT_TYPE_H
