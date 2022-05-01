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

#include "symt_type.h"
#include <stdbool.h>

// Uncomment this to compile library with main
//#define _SYMT_JUST_COMPILE

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
symt_tab* symt_insert_tab_call(symt_tab *tab, const symt_name_t name, const symt_var_t type, struct symt_node *params);

/* Insert var symbol to the symbol table */
symt_tab* symt_insert_tab_var(symt_tab *tab, const symt_id_t id, const symt_name_t name, const symt_var_t type, bool is_array, int array_length, symt_value_t value, bool is_hide);

/* Insert const symbol to the symbol table */
symt_tab* symt_insert_tab_cons(symt_tab *tab, const symt_cons_t type, symt_value_t value);

/* Insert routine symbol to the symbol table */
symt_tab* symt_insert_tab_rout(symt_tab *tab, const symt_id_t id, const symt_name_t name, const symt_var_t type, struct symt_node *params, bool is_hide, symt_node *statements);

/* Insert if symbol to the symbol table */
symt_tab* symt_insert_tab_if(symt_tab *tab, symt_node *cond, symt_node *statements_if, symt_node *statements_else);

/* Insert while symbol to the symbol table */
symt_tab* symt_insert_tab_while(symt_tab *tab, symt_node *cond, symt_node *statements);

/* Insert for symbol to the symbol table */
symt_tab* symt_insert_tab_for(symt_tab *tab, symt_node *cond, symt_node *statements, symt_node *iter_var, symt_node *iter_op);

/* Insert switch symbol to the symbol table */
symt_tab* symt_insert_tab_switch(symt_tab *tab, symt_var *iter_var, symt_node *cases);

/* Finish a block statement */
void symt_end_block(symt_tab *tab, const symt_id_t id_block);

/* Include all the elements of source at dest,
   deleting private instances at stack */
symt_tab* symt_merge(symt_tab *src, symt_tab *dest);

/* Clean from memory passed symbol table
   if has been created before */
void symt_delete(symt_tab *tab);

#endif  // SYMT_H
