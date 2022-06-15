// symt.c -*- C -*-
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
 *	ISO C99 Standard: Symbol table implementation
 */

#include "include/symt.h"

#include "include/assertb.h"
#include "include/arrcopy.h"
#include "include/memlib.h"
#include "include/symt_type.h"
#include "include/symt_cons.h"
#include "include/symt_rout.h"
#include "include/symt_var.h"
#include "include/symt_node.h"
#include "include/f_reader.h"
#include <string.h>

symt_tab *symt_new()
{
	symt_tab *tab = symt_new_node();
	assertp(tab != NULL, "table has not been defined");
	return tab;
}

symt_node *symt_search_routine(symt_tab *tab, symt_name_t rout_name)
{
	assertp(tab != NULL, "table has not been defined");
	assertp(rout_name != NULL, "function has not been defined");
	symt_node *iter = tab;

	while (iter != NULL)
	{
		if (iter->id == FUNCTION || iter->id == PROCEDURE)
			if (strcmp(rout_name, iter->rout->name) == 0) break;

		iter = iter->next_node;
	}

	return iter;
}

symt_node *symt_search_params(symt_tab *tab, symt_name_t rout_name)
{
	assertp(tab != NULL, "table has not been defined");
	assertp(rout_name != NULL, "function has not been defined");
	symt_node *iter = tab;

	while (iter != NULL)
	{
		if (iter->id == VAR && iter->var->rout_name != NULL)
		{
			int cond = strcmp(rout_name, iter->var->rout_name);
			if (iter->var->is_param && cond == 0) break;
		}

		iter = iter->next_node;
	}

	return iter;
}

symt_natural_t symt_num_params(symt_tab *tab, symt_name_t rout_name)
{
	symt_node *params = symt_search_params(tab, rout_name);
	symt_natural_t num_params = 0;

	while (params != NULL)
	{
		if (params->id != VAR || params->var->rout_name == NULL) break;
		if (strcmp(rout_name, params->var->rout_name) != 0) break;

		params = params->next_node;
		num_params++;
	}

	return num_params;
}

void symt_invert_offset(symt_tab *tab, symt_name_t rout_name)
{
	symt_natural_t num_params = symt_num_params(tab, rout_name);
	symt_natural_t num_params_j = num_params - 1;

	symt_node *params = symt_search_params(tab, rout_name);
	if (num_params == 1 || num_params == 0) return;

	for (int i = 0; i < num_params; i++)
	{
		symt_node *iter = params;
		symt_node *first_param = iter;

		for (int k = 0; k < i; k++)
			first_param = first_param->next_node;

		for (int j = 0; j < num_params_j; j++)
		{
			if (j == num_params_j - 1)
			{
				iter = iter->next_node;
				symt_natural_t offset_first_param = first_param->var->offset;
				first_param->var->offset = iter->var->offset;
				iter->var->offset = offset_first_param;
				num_params_j--;
				break;
			} else iter = iter->next_node;
		}
	}
}

symt_node *symt_search_by_name(
	symt_tab *tab, symt_name_t name, symt_id_t id,
	symt_name_t rout_name, symt_natural_t level
)
{
	assertp(tab != NULL, "table has not been defined");
	symt_node *iter = tab;

	while (iter != NULL)
	{
		if (iter->id == id)
		{
			if (iter->level <= level)
			{
				switch (iter->id)
				{
					case VAR:
						if (strcmp(iter->var->name, name) == 0)
						{
							if (rout_name == NULL && iter->var->rout_name == NULL) return iter;
							if (iter->var->rout_name == NULL && iter->level == 0) return iter;
							else if (rout_name != NULL && iter->var->rout_name != NULL)
								if (strcmp(rout_name, iter->var->rout_name) == 0) return iter;
						}
					break;

					case FUNCTION: case PROCEDURE: if (strcmp(iter->rout->name, name) == 0) return iter;	break;
					default: /* Just to avoid warnings */ 													break;
				}
			}
		}

		iter = iter->next_node;
	}

	return NULL;
}

symt_tab *symt_push(symt_tab *tab, symt_node *node)
{
	assertp(tab != NULL, "table has not been constructed");
	assertp(node != NULL, "node has not been defined");
	if (symt_is_valid_id(node->id) == false) return NULL;
	symt_node *iter = tab;

	if (iter->id == SYMT_NULL)
	{
		node->next_node = NULL;
		return node;
	}

	while (iter->next_node != NULL)
		iter = iter->next_node;

	iter->next_node = symt_copy_node(node);
	iter->next_node->next_node = NULL;
	return tab;
}

symt_tab* symt_insert_tab_var(
	symt_tab *tab, symt_name_t name, symt_name_t rout_name, symt_var_t type,
	bool is_array, symt_natural_t array_length, symt_value_t value, bool is_param,
	symt_natural_t level, symt_natural_t q_dir, symt_natural_t offset)
{
	if (level == 0 && !is_param) offset = 0;
	symt_node *new_node = symt_insert_var(name, rout_name, type, is_array, array_length, value, is_param, level, q_dir, offset);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_cons(
	symt_tab *tab, symt_cons_t type, symt_value_t value,
	symt_natural_t offset, bool is_param
)
{
	symt_node *new_node = symt_insert_cons(type, value, 0, offset, is_param);
	return symt_push(tab, new_node);
}

symt_tab* symt_insert_tab_cons_q(
	symt_tab *tab, symt_cons_t type, symt_value_t value, symt_natural_t q_dir,
	symt_natural_t offset, bool is_param
)
{
	symt_node *new_node = symt_insert_cons(type, value, q_dir, offset, is_param);
	return symt_push(tab, new_node);
}

symt_tab* symt_insert_tab_rout(
	symt_tab *tab, symt_id_t id, symt_name_t name, symt_var_t type,
	symt_natural_t level, symt_natural_t label
)
{
	symt_node *new_node = symt_insert_rout(id, name, type, level, label);
	return symt_push(tab, new_node);
}

symt_natural_t symt_end_block(symt_tab *tab, symt_natural_t level)
{
	assertp(tab != NULL, "table has not been constructed");
	symt_node *iter = tab, *prev_iter = NULL, *prev_level = NULL, *prev_first = NULL;
    bool prev_saved = false;
    symt_natural_t prev_offset = 0;

	while (iter->next_node != NULL)
	{
		if (iter->level == level)
        {
            prev_saved = true;
			prev_level = iter;
        }

        if (iter->id == VAR)
            if (!prev_saved) prev_first=iter;

		iter = iter->next_node;
	}

	if (prev_level == NULL) return 0;

	if (iter->level > prev_level->level)
	{
		if (iter->level != 0)
		{
            if(prev_level->id == VAR)
                prev_offset = prev_level->var->offset;

            if(!prev_first->var->is_param && (prev_first->level > prev_level->level))
                prev_offset = prev_first->var->offset;

			symt_delete(iter);
			prev_level->next_node = NULL;
		}
	}

    if (iter->id == VAR)
        if (iter->level == prev_level->level)
            prev_offset = iter->var->offset;

    return prev_offset;
}

void symt_delete(symt_tab *tab)
{
	symt_delete_node(tab);
	tab = NULL;
}

#ifdef DEV_MODE
void symt_print(symt_tab *tab)
{
	assertp(tab != NULL, "table has not been constructed");
	printf("\n ## Table");

	symt_node *node = (symt_node*)tab;
	char *str_type, *message, *rout_name;

	while(node != NULL)
	{
		printf("\n id = %s |", symt_strget_id(node->id));

		switch (node->id)
		{
			case VAR:
				str_type = symt_strget_vartype(node->var->type);
				rout_name = node->var->rout_name;
				if (rout_name == NULL) rout_name = "null";
				message = " name = %s | rout_name = %s | type = %s | is_array = %d | array_length = %d | level = %d | is_param = %d | offset = %d";
				printf(message, node->var->name, rout_name, str_type, node->var->is_array, node->var->array_length, node->level, node->var->is_param, (int)node->var->offset);
				symt_printf_value(node);
			break;

			case FUNCTION: case PROCEDURE:
				str_type = symt_strget_vartype(node->rout->type);
				if (str_type == NULL) str_type = "void";
				if (strcmp(str_type, "undefined") == 0) str_type = "void";
				message = " name = %s | type = %s | level = %d";
				printf(message, node->rout->name, str_type, node->level);
			break;

			default: break; // Just to avoid warning
		}

		node = node->next_node;
	}
}
#endif

#ifdef _SYMT_JUST_COMPILE
void main() { }
#endif
