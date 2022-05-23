/* ---------------------------------------------------------------

   symt.h        Symbol table for c3P language

   This library provides the definition of a symbol table wich is
   defined as a stack that stores all the avaiable symbols of c3P
   programming language.

   Authors      losedavidpb (https://github.com/losedavidpb)
                HectorMartinAlvarez (https://github.com/HectorMartinAlvarez)

   --------------------------------------------------------------- */

#ifndef SYMT_H
#define SYMT_H

#include "symt_type.h"
#include <stdbool.h>
#include <stddef.h>

// Uncomment this to compile library with main
//#define _SYMT_JUST_COMPILE

/* Create dynamically a new symbol table */
symt_tab* symt_new();

/* Search a parameter based on its name */
symt_node *symt_search_param(symt_tab *tab, symt_name_t name);

/* Search at passed symbol table an element that has
   the same identifier, name and level, or NULL in other case */
symt_node *symt_search_by_name(symt_tab *tab, symt_name_t name, symt_id_t id, symt_name_t rout_name, symt_level_t level);

/* Push passed symbol to the symbol table.
   You should avoid the used of this method, since
   it has no control about the state of passed node. */
symt_tab* symt_push(symt_tab *tab, symt_node *node);

/* Insert var symbol to the symbol table */
symt_tab* symt_insert_tab_var(symt_tab *tab, symt_name_t name, symt_name_t rout_name, symt_var_t type, bool is_array, size_t array_length, symt_value_t value, bool is_hide, bool is_param, symt_level_t level);

/* Insert const symbol to the symbol table */
symt_tab* symt_insert_tab_cons(symt_tab *tab, symt_cons_t type, symt_value_t value);

/* Insert routine symbol to the symbol table */
symt_tab* symt_insert_tab_rout(symt_tab *tab, symt_id_t id, symt_name_t name, symt_var_t type, bool is_hide, symt_level_t level);

/* Finish a block statement */
void symt_end_block(symt_tab *tab);

/* Include all the elements of source at dest,
   deleting private instances at stack */
symt_tab* symt_merge(symt_tab *src, symt_tab *dest);

/* Clean from memory passed symbol table
   if has been created before */
void symt_delete(symt_tab *tab);

/* Print content of passed symbol table */
void symt_print(symt_tab *tab);

#endif  // SYMT_H
