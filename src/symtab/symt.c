#include "../../include/symt.h"

#include "../../include/assertb.h"
#include "../../include/arrcopy.h"
#include "../../include/memlib.h"
#include "../../include/symt_type.h"
#include "../../include/symt_cons.h"
#include "../../include/symt_rout.h"
#include "../../include/symt_var.h"
#include "../../include/symt_node.h"
#include <stdio.h>
#include <string.h>

symt_tab *symt_new()
{
	symt_tab *tab = symt_new_node();
	assertp(tab != NULL, "table has not been defined");
	return tab;
}

symt_node *symt_search_param(symt_tab *tab, symt_name_t name)
{
	assertp(tab != NULL, "table has not been defined");
	assertp(name != NULL, "function has not been defined");
	symt_node *iter = tab;

	while (iter != NULL)
	{
		if (iter->id == VAR)
		{
			int cond = strcmp(name, iter->var->name);
			if (iter->var->is_param && cond == 0) break;
		}

		iter = iter->next_node;
	}

	return iter;
}

symt_node *symt_search_by_name(symt_tab *tab, symt_name_t name, symt_id_t id, symt_name_t rout_name, symt_level_t level)
{
	assertp(tab != NULL, "table has not been defined");
	symt_node *iter = tab;

	while (iter != NULL)
	{
		if (iter->id == id)
		{
			if (iter->level == level)
			{
				switch (iter->id)
				{
					case VAR:
						if (strcmp(iter->var->name, name) == 0)
						{
							if (rout_name == NULL && iter->var->rout_name == NULL) return iter;
							else if (rout_name != NULL && iter->var->rout_name != NULL)
							{
								if (strcmp(rout_name, iter->var->rout_name) == 0) return iter;
							}
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

	if (iter->id == SYMT_ROOT_ID)
	{
		symt_delete(iter);
		node->next_node = NULL;
		return node;
	}

	while (iter->next_node != NULL)
		iter = iter->next_node;

	iter->next_node = symt_copy_node(node);
	iter->next_node->next_node = NULL;
	return tab;
}


symt_tab* symt_insert_tab_var(symt_tab *tab, symt_name_t name, symt_name_t rout_name, symt_var_t type, bool is_array, size_t array_length, symt_value_t value, bool is_hide, bool is_param, symt_level_t level)
{
	symt_node *new_node = symt_insert_var(name, rout_name, type, is_array, array_length, value, is_hide, is_param, level);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_cons(symt_tab *tab, symt_cons_t type, symt_value_t value)
{
	symt_node *new_node = symt_insert_cons(type, value);
	return symt_push(tab, new_node);
}

symt_tab* symt_insert_tab_rout(symt_tab *tab, symt_id_t id, symt_name_t name, symt_var_t type, bool is_hide, symt_level_t level)
{
	symt_node *new_node = symt_insert_rout(id, name, type, is_hide, level);
	return symt_push(tab, new_node);
}

void symt_end_block(symt_tab *tab)
{
	assertp(tab != NULL, "table has not been constructed");
	symt_node *iter = tab, *prev_iter = NULL, *prev_level = NULL;

	while (iter->next_node != NULL)
	{
		if (iter->level != iter->next_node->level)
			prev_level = iter;

		iter = iter->next_node;
	}

	symt_delete(prev_level->next_node);
	prev_level->next_node = NULL;
}

symt_tab *symt_merge(symt_tab *src, symt_tab *dest)
{
	assertp(src != NULL, "table src has not been constructed");
	assertp(dest != NULL, "table dest has not been constructed");
	symt_node *iter = src;

	while (iter != NULL)
	{
		if (iter->id == VAR)
		{
			if (iter->var->is_hide == false)
			{
				dest = symt_insert_tab_var(dest,
					iter->var->rout_name, iter->var->name, iter->var->type,
					iter->var->is_array, iter->var->array_length,
					iter->var->value, iter->var->is_hide,
					iter->var->is_param, iter->level
				);
			}
		}
		else if (iter->id == FUNCTION || iter->id == PROCEDURE)
		{
			if (iter->rout->is_hide == false)
			{
				dest = symt_insert_tab_rout(dest,
					iter->id, iter->rout->name, iter->rout->type,
					iter->rout->is_hide, iter->level
				);
			}
		} else dest = symt_push(dest, iter);

		iter = iter->next_node;
	}

	return dest;
}

void symt_delete(symt_tab *tab)
{
	symt_delete_node(tab);
	tab = NULL;
}

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
				message = " name = %s | rout_name = %s | type = %s | is_hide = %d | is_array = %d | array_length = %d | level = %d | is_param = %d";
				printf(message, node->var->name, rout_name, str_type, node->var->is_hide, node->var->is_array, node->var->array_length, node->level, node->var->is_param);
				symt_printf_value(node);
			break;

			case FUNCTION: case PROCEDURE:
				str_type = symt_strget_vartype(node->rout->type);
				if (str_type == NULL) str_type = "void";
				if (strcmp(str_type, "undefined") == 0) str_type = "void";
				message = " name = %s | type = %s | is_hide = %d | level = %d";
				printf(message, node->rout->name, str_type, node->rout->is_hide, node->level);
			break;

			default: break; // Just to avoid warning
		}

		node = node->next_node;
	}
}

#ifdef _SYMT_JUST_COMPILE
void main() { }
#endif
