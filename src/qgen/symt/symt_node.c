// symt_node.c -*- C -*-
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
 *	ISO C99 Standard: Node implementation for symt
 */

#include "../../../include/symt_node.h"

#include "../../../include/assertb.h"
#include "../../../include/arrcopy.h"
#include "../../../include/memlib.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"
#include "../../../include/symt_cons.h"
#include "../../../include/symt_rout.h"
#include "../../../include/symt_var.h"
#include <stdio.h>

symt_node* symt_new_node()
{
	symt_tab *tab = NULL;
	tab = (symt_tab *)(ml_malloc(sizeof(symt_tab)));
	tab->id = SYMT_ROOT_ID;
	return tab;
}

bool symt_is_valid_id(symt_id_t id)
{
	assertp(id != SYMT_ROOT_ID, "passed indentifier is invalid");
	char *str_id = symt_strget_id(id);
	return strcmp(str_id, "undefined") != 0;
}

symt_name_t symt_get_name_from_node(symt_node *node)
{
	assertp(node != NULL, "passed node is null");

	switch(node->id)
	{
		case VAR: return node->var->name; 						break;
		case FUNCTION: case PROCEDURE: return node->rout->name; break;
		default: /* Just to avoid warnings */					break;
	}

	return NULL;
}

symt_value_t symt_get_value_from_node(symt_node *node)
{
	assertp(node != NULL, "passed node is null");
	assertp(node->id == VAR || node->id == CONSTANT, "node has not got a value");

	if (node->id == VAR)
	{
		assertp(node->var != NULL, "variable has not be defined");
		return node->var->value;
	}

	if (node->id == CONSTANT)
	{
		assertp(node->cons != NULL, "constant has not be defined");
		return node->cons->value;
	}

	return NULL;
}

symt_cons_t symt_get_type_value_from_node(symt_node *node)
{
	assertp(node != NULL, "table has not been constructed");
	assertp(node->id == VAR || node->id == CONSTANT, "passed node has not a valid type");

	if (node->id == VAR) return symt_get_type_data(node->var->type);
	else return node->cons->type;
}

void symt_printf_value(symt_node* node)
{
	assertp(node != NULL, "node have not been defined");
	symt_value_t value = symt_get_value_from_node(node);
	symt_cons_t type = symt_get_type_value_from_node(node);

	if (value != NULL)
	{
		if (node->id == VAR && node->var->is_array)
		{
			if (type == CONS_INTEGER)
			{
				int *int_value = (int*)value;
				printf(" | value = { ");
				for (int i = 0; i < node->var->array_length; i++) printf("%d ", *(int_value + i));
				printf("}");
			}
			else if (type == CONS_DOUBLE)
			{
				double *double_value = (double*)value;
				printf(" | value = { ");
				for (int i = 0; i < node->var->array_length; i++) printf("%lf ", *(double_value + i));
				printf("}");
			}
			else if (type == CONS_CHAR)
			{
				char *char_value = (char*)value;
				printf(" | value = %s", char_value);
			}
		}
		else
		{
			switch(type)
			{
				case CONS_INTEGER: printf(" | value = %d", *(int*)value); 		break;
				case CONS_DOUBLE: printf(" | value = %lf", *(double*)value); 	break;
				case CONS_CHAR: printf(" | value = %c", *(char*)value); 			break;
				case CONS_STR: printf(" | value = %s", (char*)value); 			break;
				default: break;
			}
		}
	} else printf(" | value = NULL");
}

symt_value_t symt_copy_value(symt_value_t value, symt_cons_t type, size_t num_elems)
{
	symt_value_t copy_value = NULL;
	int *int_val = NULL;
	double *double_val = NULL;
	char *char_val = NULL;
	char _char_val_;

	if (value != NULL)
	{
		switch (type)
		{
			case CONS_INTEGER: copy_value = intcopy((int *)value, num_elems + 1); 		break;
			case CONS_DOUBLE: copy_value = doublecopy((double *)value, num_elems + 1); 	break;
			case CONS_CHAR: copy_value = strcopy((char *)value);						break;
			case CONS_STR: copy_value = strcopy((char *)value);							break;
			default: break;
		}

		// Special restrictions for characters
		if (type == CONS_CHAR) assertp(*((char*)copy_value) != '\'', "' is a special character");
	}
	else
	{
		switch(type)
		{
			case CONS_INTEGER:
				int_val = (int*)(ml_malloc(num_elems * sizeof(int)));
				for (int i = 0; i < num_elems; i++) *(int_val + i) = 0;
				copy_value = int_val;
			break;

			case CONS_DOUBLE:
				double_val = (double*)(ml_malloc(num_elems * sizeof(double)));
				for (int i = 0; i < num_elems; i++) *(double_val + i) = 0;
				copy_value = double_val;
			break;

			case CONS_CHAR: case CONS_STR:
				char_val = (char*)(ml_malloc(num_elems * sizeof(char)));
				for (int i = 0; i < num_elems; i++) *(char_val + i) = ' ';
				copy_value = char_val;
			break;

			default: break;
		}
	}

	return copy_value;
}

void symt_delete_node(symt_node *node)
{
	symt_node *iter = node, *prev = NULL;
	if (node == NULL) return;

	while (iter != NULL)
	{
		if (iter->id == VAR) symt_delete_var(iter->var); iter->var = NULL;
		if (iter->id == CONSTANT) symt_delete_cons(iter->cons); iter->cons = NULL;
		if (iter->id == PROCEDURE || iter->id == FUNCTION) symt_delete_rout(iter->rout); iter->rout = NULL;

		iter->id = SYMT_ROOT_ID;
		prev = iter; iter = iter->next_node;
		prev->next_node = NULL;
		ml_free(prev); prev = NULL;
	}

	node = NULL;
}

symt_node *symt_copy_node(symt_node *node)
{
	symt_node *copy_node = NULL;

	if (node != NULL)
	{
		copy_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
		copy_node->id = node->id;
		copy_node->level = node->level;
		copy_node->cons = symt_copy_cons(node->cons);
		copy_node->var = symt_copy_var(node->var);
		copy_node->rout = symt_copy_rout(node->rout);
		copy_node->next_node = symt_copy_node(node->next_node);
	}

	return copy_node;
}
