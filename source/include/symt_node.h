// symt_node.h -*- C -*-
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
 *	ISO C99 Standard: Utilities to manage a symbol node
 */

#ifndef SYMT_NODE_H
#define SYMT_NODE_H

#include "symt_type.h"

#define symt_strget_id(id)							\
	(id == VAR? "VAR" :								\
	(id == FUNCTION? "FUNCTION" :					\
	(id == PROCEDURE? "PROCEDURE" :					\
	(id == CONSTANT? "CONSTANT" : "undefined"))))

// Uncomment this to enable development mode
//#ifndef DEV_MODE
//#define DEV_MODE
//#endif

/* Create dynamically a new symbol node */
symt_node* symt_new_node();

/* Check if passed identifier is valid */
bool symt_is_valid_id(symt_id_t id);

/* Get the name of passed node whether that field exists */
symt_name_t symt_get_name_from_node(symt_node *node);

/* Get the value of passed node whether that field exists */
symt_value_t symt_get_value_from_node(symt_node *node);

/* Get the primitive type for passed node */
symt_cons_t symt_get_type_value_from_node(symt_node *node);

#ifdef DEV_MODE
/* Print value for passed node */
void symt_printf_value(symt_node* node);
#endif

/* Copy passed value into a new reference */
symt_value_t symt_copy_value(symt_value_t value, symt_cons_t type, symt_natural_t num_elems);

/* Clean from memory passed symbol node
   if has been created before */
void symt_delete_node(symt_node *node);

/* Copy passed node into a new one at a new direction */
symt_node *symt_copy_node(symt_node *node);

#endif	// SYMT_NODE_H
