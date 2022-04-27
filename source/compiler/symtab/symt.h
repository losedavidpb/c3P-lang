/* ---------------------------------------------------------------

   symt.h        Symbol table for c3P language

   This library provides the definition of a symbol table wich is
   defined as a stack that stores all the avaiable symbols of c3P
   programming language.

   Authors      losedavidpb (https://github.com/losedavidpb)
                HectorMartinAlvarez (https://github.com/HectorMartinAlvarez)

   --------------------------------------------------------------- */

#ifndef SYMT_H
#define SYMT_H 1

#include <stdbool.h>

// Uncomment this to compile library with main
//#define _SYMT_JUST_COMPILE

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
    LOCAL_VAR,      // local variables inside routines
    GLOBAL_VAR,     // global variables outside routines
    CONSTANT,       // constants for primitive data
    IF,             // if and if-else statements
    WHILE,          // while loops
    FOR,            // for loops
    SWITCH,         // switch statement
    FUNCTION,       // routines with a return
    PROCEDURE,      // routines with any return
    CALL_,          // call statement for functions
} symt_id_t;

/* Type for values stored at local and global
   variables, which has not been casted */
typedef void * symt_value_t;

/* Types for primitive data at constants */
typedef enum symt_cons_t { INTEGER_, DOUBLE_, CHAR_ } symt_cons_t;

/* Primitive types for variables and return functions */
typedef enum symt_var_t { I8, I16, I32, I64, F32, F64, B, C, STR, VOID } symt_var_t;

/* Type for local and global variables */
typedef struct symt_var
{
    symt_name_t name;
    symt_var_t type;
    symt_value_t value;
    bool is_hide;
    bool is_readonly;
    bool is_array;
    int array_length;
} symt_var;

/* Type for constants */
typedef struct symt_cons
{
    symt_name_t name;
    symt_cons_t type;
    symt_value_t value;
} symt_cons;

/* Type for functions and procedures */
typedef struct symt_routine
{
    symt_name_t name;
    symt_var_t type;
    bool is_hide;
    bool is_readonly;
    struct symt_node *params;
    struct symt_node *statements;
} symt_routine;

/* Type for if and if-else statements */
typedef struct symt_if_else
{
    struct symt_node *cond;
    struct symt_node *if_statements;
    struct symt_node *else_statements;
} symt_if_else;

/* Type for while loops */
typedef struct symt_while
{
    struct symt_node *cond;
    struct symt_node *statements;
} symt_while;

/* Type for "for" loops */
typedef struct symt_for
{
    struct symt_node *incr;
    struct symt_node *cond;
    struct symt_node *iter_op;
    struct symt_node *statements;
} symt_for;

/* Type for switch statements */
typedef struct symt_switch
{
    symt_id_t type_key;
    symt_var *key_var;
    struct symt_node *cases;
} symt_switch;

/* Type for calling routines */
typedef struct symt_call
{
    symt_name_t name;
    symt_var_t type;
    struct symt_node *params;
} symt_call;

/* Type for a node which is are at a symbol table */
typedef struct symt_node
{
    symt_id_t id;
    symt_routine* rout;
    symt_var* var;
    symt_cons* cons;
    symt_call* call;
    symt_if_else* if_val;
    symt_while* while_val;
    symt_for* for_val;
    symt_switch* switch_val;
    struct symt_node *next_node;
} symt_node;

/* Type for a symbol table */
typedef symt_node symt_tab;

/* Create dynamically a new symbol table */
symt_tab* symt_new();

/* Search at passed symbol table an element that has
   the same identifier, or NULL in other case */
symt_node *symt_search(symt_tab *tab, symt_id_t id);

/* Search at passed symbol table an element that has
   the same identifier and name, or NULL in other case */
symt_node *symt_search_by_name(symt_tab *tab, symt_name_t name, symt_id_t id);

/* Push passed symbol to the symbol table.
   You should avoid the used of this method, since
   it has no control about the state of passed node. */
symt_tab* symt_push(symt_tab *tab, symt_node *node);

/* Insert call symbol to the symbol table */
symt_tab* symt_insert_call(symt_tab *tab, const symt_name_t name, const symt_var_t type, struct symt_node *params);

/* Insert var symbol to the symbol table */
symt_tab* symt_insert_var(symt_tab *tab, const symt_id_t id, const symt_name_t name, const symt_var_t type, bool is_array, int array_length, symt_value_t value, bool is_hide, bool is_readonly);

/* Insert const symbol to the symbol table */
symt_tab* symt_insert_const(symt_tab *tab, const symt_name_t name, const symt_cons_t type, symt_value_t value);

/* Insert routine symbol to the symbol table */
symt_tab* symt_insert_rout(symt_tab *tab, const symt_id_t id, const symt_name_t name, const symt_var_t type, struct symt_node *params, bool is_hide, bool is_readonly, symt_node *statements);

/* Insert if symbol to the symbol table */
symt_tab* symt_insert_if(symt_tab *tab, symt_node *cond, symt_node *statements_if, symt_node *statements_else);

/* Insert while symbol to the symbol table */
symt_tab* symt_insert_while(symt_tab *tab, symt_node *cond, symt_node *statements);

/* Insert for symbol to the symbol table */
symt_tab* symt_insert_for(symt_tab *tab, symt_node *cond, symt_node *statements, symt_node *iter_var, symt_node *iter_op);

/* Insert switch symbol to the symbol table */
symt_tab* symt_insert_switch(symt_tab *tab, symt_var *iter_var, symt_node *cases, int num_cases);

/* Finish a block statement */
void symt_end_block(symt_tab *tab, const symt_id_t id_block);

/* Include all the elements of source at dest,
   deleting private instances at stack */
symt_tab* symt_merge(symt_tab *src, symt_tab *dest);

/* Clean from memory passed symbol table
   if has been created before */
void symt_delete(symt_tab *tab);

#endif  // SYMT_H
