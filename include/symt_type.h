/* Basic symbols and types used by symt to store tokens */
#ifndef SYMT_TYPE_H
#define SYMT_TYPE_H

#include <stdbool.h>
#include <stddef.h>

// Cast an integer to a boolean value
#define to_bool(num) num != 1? false : true

// Identifier which only could be associated
// to first element which is defined at stack
#define SYMT_ROOT_ID -1

/* Optional identifier for symbols used to
   distinguish instances with the same id */
typedef char * symt_name_t;

/* Available symbols for symbol tables which
   which will be used as identifiers */
typedef enum symt_id_t
{
	VAR,
    //LOCAL_VAR,      // local variables inside routines
    //GLOBAL_VAR,     // global variables outside routines
    CONSTANT,       // constants for primitive data
    //IF,             // if and if-else statements
    //WHILE,          // while loops
    FUNCTION,       // routines with a return
    PROCEDURE,      // routines with any return
    CALL_FUNC,      // call statement for functions
	//CONTINUE,		// continue statement
	//BREAK,			// break statement
	//RETURN,			// return statement
} symt_id_t;

/* Type for values stored at local and global
   variables, which has not been casted */
typedef void * symt_value_t;

/* Types for primitive data at constants */
typedef enum symt_cons_t { CONS_INTEGER, CONS_DOUBLE, CONS_CHAR, CONS_STR } symt_cons_t;

/* Primitive types for variables and return functions */
typedef enum symt_var_t { I8, I16, I32, I64, F32, F64, B, C, STR, VOID } symt_var_t;

/* Range of values for integers */
#define I8_MIN -128
#define I8_MAX 127
#define I16_MIN -32768
#define I16_MAX 32768
#define I32_MIN -214.483648
#define I32_MAX 2147483647
#define I64_MIN -9223372036854775808
#define I64_MAX 9223372036854775807

/* Range of values for floats */
#define F32_MIN -1.5e-45
#define F32_MAX 3.4e38
#define F64_MIN -5.0e-324
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
    symt_name_t name;
    symt_var_t type;
    symt_value_t value;
    bool is_hide;
	bool is_array;
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
    bool is_hide;
    struct symt_node *params;
    //struct symt_node *statements;
} symt_rout;

/* Type for if and if-else statements */
/*typedef struct symt_if_else
{
    struct symt_node *if_statements;
    struct symt_node *else_statements;
} symt_if_else;*/

/* Type for while loops */
/*typedef struct symt_while
{
    struct symt_node *statements;
} symt_while;*/

/* Type for calling routines */
typedef struct symt_call
{
    symt_name_t name;
    symt_var_t type;
    struct symt_node *params;
} symt_call;

/* Type for return statement */
/*typedef struct symt_return
{
	struct symt_node *return_stmt;
} symt_return;*/

/* Type for a node which is are at a symbol table */
typedef struct symt_node
{
	int level;
    symt_id_t id;
    symt_rout* rout;
    symt_var* var;
    symt_cons* cons;
    symt_call* call;
    //symt_if_else* if_val;
    //symt_while* while_val;
	//symt_return* return_val;
    struct symt_node *next_node;
} symt_node;

/* Type for a symbol table */
typedef symt_node symt_tab;

#endif	// SYMT_TYPE_H
