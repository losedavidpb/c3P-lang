// symt_stack.c -*- C -*-
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
 *	ISO C99 Standard: Stack implementation
 */

#include "../include/symt_stack.h"

#include "../include/memlib.h"

symt_stack *symt_new_stack()
{
	symt_stack *stack;
	stack = (symt_stack*)(ml_malloc(sizeof(symt_stack)));
	if (stack == NULL) return NULL;
	return stack;
}

symt_stack *symt_new_stack_elem(
	symt_name_t name, symt_value_t value, symt_var_t type, symt_natural_t q_dir,
	symt_natural_t offset, bool is_param, symt_stack* next
)
{
	symt_stack *stack = symt_new_stack();
	stack->name = name;
	stack->value = value;
	stack->type = type;
    stack->q_dir = q_dir;
	stack->next = next;
	stack->offset = offset;
	stack->is_param = is_param;
	return  stack;
}
