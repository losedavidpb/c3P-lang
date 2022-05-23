// symt_stack.h -*- C -*-
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
 *	ISO C99 Standard: Stack of void values for symt
 */

#ifndef SYMT_STACK_H
#define SYMT_STACK_H

#include "symt_type.h"

/* Structure of a stack */
typedef struct symt_stack
{
	symt_name_t name;
	symt_value_t value;
	symt_cons_t type;
    symt_qdir_t q_direction;
	struct symt_stack *next;
} symt_stack;

/* Create a new stack */
symt_stack *symt_new_stack();

/* Create a new element for the stack */
symt_stack *symt_new_stack_elem(symt_name_t name, symt_value_t value, symt_cons_t type, symt_qdir_t q_direction, symt_stack* next);

#endif	// SYMT_STACK_H
