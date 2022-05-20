// symt.h -*- C -*-
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
 *	ISO C99 Standard: Symbol table
 */
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
symt_tab* symt_insert_tab_var(symt_tab *tab, symt_name_t name, symt_name_t rout_name, symt_var_t type, bool is_array, size_t array_length, symt_value_t value, bool is_param, symt_level_t level, int q_direction);

/* Insert const symbol to the symbol table */
symt_tab* symt_insert_tab_cons(symt_tab *tab, symt_cons_t type, symt_value_t value);

/* Insert const symbol to the symbol table with Q direction */
symt_tab* symt_insert_tab_cons_q(symt_tab *tab, symt_cons_t type, symt_value_t value, int q_direction);

/* Insert routine symbol to the symbol table */
symt_tab* symt_insert_tab_rout(symt_tab *tab, symt_id_t id, symt_name_t name, symt_var_t type, symt_level_t level, symt_label_t label);

/* Finish a block statement */
void symt_end_block(symt_tab *tab, symt_level_t level);

/* Clean from memory passed symbol table
   if has been created before */
void symt_delete(symt_tab *tab);

/* Print content of passed symbol table */
void symt_print(symt_tab *tab);

#endif  // SYMT_H
