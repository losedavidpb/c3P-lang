#include "../../include/symt.h"

#include "../../include/assertb.h"
#include "../../include/arrcopy.h"
#include "../../include/memlib.h"
#include "../../include/symt_type.h"
#include "../../include/symt_call.h"
#include "../../include/symt_cons.h"
#include "../../include/symt_for.h"
#include "../../include/symt_if.h"
#include "../../include/symt_rout.h"
#include "../../include/symt_switch.h"
#include "../../include/symt_var.h"
#include "../../include/symt_while.h"
#include "../../include/symt_node.h"
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

symt_node *__symt_search(symt_tab *tab, symt_id_t id, symt_name_t name, bool search_name, bool search_prev)
{
	assertp(tab != NULL, "table has not been constructed");
	symt_node *iter = tab, *result = NULL, *prev = NULL;

	while (iter != NULL)
	{
		if (iter->id == id)
		{
			if (search_name == false) return search_prev == true ? prev : iter;

			switch (iter->id)
			{
				case LOCAL_VAR:; case GLOBAL_VAR:; if (strcmp(name, iter->var->name) == 0) return search_prev == true ? prev : iter; 	break;
				case FUNCTION:; case PROCEDURE:; if (strcmp(name, iter->rout->name) == 0) return search_prev == true ? prev : iter; 	break;
				case CALL_FUNC:; if (strcmp(name, iter->call->name) == 0) return search_prev == true ? prev : iter; 					break;
				default: /* Just to avoid warning */ 																					break;
			}
		}

		if (id != FUNCTION && id != PROCEDURE)
		{
			switch (iter->id)
			{
				case FUNCTION:; case PROCEDURE:;
					if (iter->rout->params != NULL)
					{
						result = __symt_search(iter->rout->params, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}

					if (iter->rout->statements != NULL)
					{
						result = __symt_search(iter->rout->statements, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}
				break;

				case IF:;
					if (iter->if_val->cond != NULL)
					{
						result = __symt_search(iter->if_val->cond, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}

					if (iter->if_val->if_statements != NULL)
					{
						result = __symt_search(iter->if_val->if_statements, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}

					if (iter->if_val->else_statements != NULL)
					{
						result = __symt_search(iter->if_val->else_statements, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}
				break;

				case WHILE:;
					if (iter->while_val->cond != NULL)
					{
						result = __symt_search(iter->while_val->cond, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}

					if (iter->while_val->statements != NULL)
					{
						result = __symt_search(iter->while_val->statements, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}
				break;

				case FOR:;
					if (iter->for_val->cond != NULL)
					{
						result = __symt_search(iter->for_val->cond, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}

					if (iter->for_val->iter_op != NULL)
					{
						result = __symt_search(iter->for_val->iter_op, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}

					if (iter->for_val->statements != NULL)
					{
						result = __symt_search(iter->for_val->statements, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}
				break;

				case SWITCH:;
					if (iter->switch_val->cases != NULL)
					{
						result = __symt_search(iter->switch_val->cases, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}
				break;

				case CALL_FUNC:;
					if (iter->call->params != NULL)
					{
						result = __symt_search(iter->call->params, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}
				break;
				default: break; // Just to avoid warning
			}
		}

		prev = iter;
		iter = iter->next_node;
	}

	return NULL;
}

symt_tab *symt_new()
{
	return symt_new_node();
}

symt_node *symt_search(symt_tab *tab, symt_id_t id)
{
	return __symt_search(tab, id, NULL, false, false);
}

symt_node *symt_search_by_name(symt_tab *tab, symt_name_t name, symt_id_t id)
{
	return __symt_search(tab, id, name, true, false);
}

symt_tab *symt_push(symt_tab *tab, symt_node *node)
{
	assertp(tab != NULL, "table has not been constructed");
	assertp(node != NULL, "node has not been defined");
	if (symt_is_valid_id(node->id) == false) return tab;

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

symt_tab *symt_insert_tab_call(symt_tab *tab, const symt_name_t name, const symt_var_t type, struct symt_node *params)
{
	symt_node *new_node = symt_insert_call(name, type, params);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_var(symt_tab *tab, symt_id_t id, symt_name_t name, symt_var_t type, bool is_array, int array_length, symt_value_t value, bool is_hide)
{
	symt_node *new_node = symt_insert_var(id, name, type, is_array, array_length, value, is_hide);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_const(symt_tab *tab, const symt_cons_t type, symt_value_t value)
{
	symt_node *new_node = symt_insert_cons(type, value);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_rout(symt_tab *tab, symt_id_t id, symt_name_t name, symt_var_t type, struct symt_node *params, bool is_hide, symt_node *statements)
{
	symt_node *new_node = symt_insert_rout(id, name, type, params, is_hide, statements);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_if(symt_tab *tab, symt_node *cond, symt_node *statements_if, symt_node *statements_else)
{
	symt_node *new_node = symt_insert_if(cond, statements_if, statements_else);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_while(symt_tab *tab, symt_node *cond, symt_node *statements)
{
	symt_node *new_node = symt_insert_while(cond, statements);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_for(symt_tab *tab, symt_node *cond, symt_node *statements, symt_node *iter_var, symt_node *iter_op)
{
	symt_node *new_node = symt_insert_for(cond, statements, iter_var, iter_op);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_switch(symt_tab *tab, symt_var *iter_var, symt_node *cases)
{
	symt_node *new_node = symt_insert_switch(iter_var, cases);
	return symt_push(tab, new_node);
}

void symt_end_block(symt_tab *tab, const symt_id_t id_block)
{
	assertp(tab != NULL, "table has not been constructed");

	symt_node *block_node = __symt_search(tab, id_block, NULL, false, true);

	if (block_node != NULL)
	{
		if (block_node->next_node != NULL) symt_delete(block_node->next_node);
		block_node->next_node = NULL;
	}
	else if (tab->next_node == NULL && id_block == tab->id)
	{
		symt_delete(tab);
		tab = NULL;
	}
}

symt_tab *symt_merge(symt_tab *src, symt_tab *dest)
{
	assertp(src != NULL, "table src has not been constructed");
	assertp(dest != NULL, "table dest has not been constructed");
	symt_node *iter = src;

	while (iter != NULL)
	{
		if (iter->id == LOCAL_VAR || iter->id == GLOBAL_VAR)
		{
			if (iter->var->is_hide == false)
			{
				dest = symt_insert_tab_var(dest,
					iter->id, iter->var->name, iter->var->type,
					iter->var->is_array, iter->var->array_length,
					iter->var->value, iter->var->is_hide
				);
			}
		}
		else if (iter->id == FUNCTION || iter->id == PROCEDURE)
		{
			if (iter->rout->is_hide == false)
			{
				dest = symt_insert_tab_rout(dest,
					iter->id, iter->rout->name, iter->rout->type,
					iter->rout->params, iter->rout->is_hide,
					iter->rout->statements
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

#ifdef _SYMT_JUST_COMPILE
void main() { }
#endif
