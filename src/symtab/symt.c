#include "../../include/symt.h"

#include "../../include/assertb.h"
#include "../../include/arrcopy.h"
#include "../../include/memlib.h"

#include "../../include/symt_type.h"
#include "../../include/symt_call.h"
#include "../../include/symt_cons.h"
//#include "../../include/symt_if.h"
#include "../../include/symt_rout.h"
#include "../../include/symt_var.h"
//#include "../../include/symt_while.h"
//#include "../../include/symt_return.h"
#include "../../include/symt_node.h"
#include <stdio.h>

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
				case VAR:; if (strcmp(name, iter->var->name) == 0) return search_prev == true ? prev : iter; 	break;
				//case LOCAL_VAR:; case GLOBAL_VAR:; if (strcmp(name, iter->var->name) == 0) return search_prev == true ? prev : iter; 	break;
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

					/*if (iter->rout->statements != NULL)
					{
						result = __symt_search(iter->rout->statements, id, name, search_name, search_prev);
						if (result != NULL) return result;
					}*/
				break;

				/*
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
				*/

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

symt_tab *symt_insert_tab_call(symt_tab *tab, symt_name_t name, symt_var_t type, symt_node *params)
{
	symt_node *new_node = symt_insert_call(name, type, params);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_var(symt_tab *tab, symt_id_t id, symt_name_t name, symt_var_t type, bool is_array, size_t array_length, symt_value_t value, bool is_hide)
{
	symt_node *new_node = symt_insert_var(id, name, type, is_array, array_length, value, is_hide);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_cons(symt_tab *tab, symt_cons_t type, symt_value_t value)
{
	symt_node *new_node = symt_insert_cons(type, value);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_rout(symt_tab *tab, symt_id_t id, symt_name_t name, symt_var_t type, symt_node *params, bool is_hide, symt_node *statements)
{
	symt_node *new_node = symt_insert_rout(id, name, type, params, is_hide/*, statements*/);
	return symt_push(tab, new_node);
}

/*
symt_tab *symt_insert_tab_if(symt_tab *tab, symt_node *statements_if, symt_node *statements_else)
{
	symt_node *new_node = symt_insert_if(statements_if, statements_else);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_while(symt_tab *tab, symt_node *statements)
{
	symt_node *new_node = symt_insert_while(statements);
	return symt_push(tab, new_node);
}

symt_tab *symt_insert_tab_return(symt_tab *tab, symt_node *return_stmt)
{
	symt_node *new_node = symt_insert_return(return_stmt);
	return symt_push(tab, new_node);
}
*/
void symt_end_block(symt_tab *tab/*, symt_id_t id_block)*/)
{
	assertp(tab != NULL, "table has not been constructed");
	symt_node *iter = tab, *last_iter = tab, *prev_iter = NULL;

	while (iter->next_node != NULL)
		iter = iter->next_node;

	while (iter->next_node != NULL)
	{
		if (last_iter->level == iter->level) break;
		prev_iter = last_iter;
		last_iter = last_iter->next_node;
	}

	prev_iter->next_node = NULL;
	symt_delete(last_iter);

	/*symt_node *block_node = __symt_search(tab, id_block, NULL, false, true);

	if (block_node != NULL)
	{
		if (block_node->next_node != NULL) symt_delete(block_node->next_node);
		block_node->next_node = NULL;
	}
	else if (tab->next_node == NULL && id_block == tab->id)
	{
		symt_delete(tab);
		tab = NULL;
	}*/
}

symt_tab *symt_merge(symt_tab *src, symt_tab *dest)
{
	assertp(src != NULL, "table src has not been constructed");
	assertp(dest != NULL, "table dest has not been constructed");
	symt_node *iter = src;

	while (iter != NULL)
	{
		if (iter->id == VAR)
		//if (iter->id == LOCAL_VAR || iter->id == GLOBAL_VAR)
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
					iter->rout->params, iter->rout->is_hide//,
					//iter->rout->statements
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
	char *str_type, *message;

	while(node != NULL)
	{
		printf("\n id = %s |", symt_strget_id(node->id));

		switch (node->id)
		{
			//case LOCAL_VAR: case GLOBAL_VAR:
			case VAR:
				str_type = symt_strget_vartype(node->var->type);
				message = " name = %s | type = %s | is_hide = %d | is_array = %d | array_length = %d";
				printf(message, node->var->name, str_type, node->var->is_hide, node->var->is_array, node->var->array_length);
				symt_printf_value(node);
			break;

			case FUNCTION:; case PROCEDURE:;
				str_type = symt_strget_vartype(node->rout->type);
				message = " name = %s | type = %s | is_hide = %d | params = %d | statements = %d";
				printf(message, node->rout->name, str_type, node->rout->params, node->rout->statements);
				/*if (iter->rout->params != NULL)
				{
					result = __symt_search(iter->rout->params, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}

				if (iter->rout->statements != NULL)
				{
					result = __symt_search(iter->rout->statements, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}*/
			break;

			//case IF:;
			//	message = " cond = %d | if_statements = %d | else_statements = %d";
			//	printf(message, node->if_val->cond, node->if_val->if_statements, node->if_val->else_statements);
			//	/*if (iter->if_val->cond != NULL)
			//	{
			//		result = __symt_search(iter->if_val->cond, id, name, search_name, search_prev);
			//		if (result != NULL) return result;
			//	}
//
			//	if (iter->if_val->if_statements != NULL)
			//	{
			//		result = __symt_search(iter->if_val->if_statements, id, name, search_name, search_prev);
			//		if (result != NULL) return result;
			//	}
//
			//	if (iter->if_val->else_statements != NULL)
			//	{
			//		result = __symt_search(iter->if_val->else_statements, id, name, search_name, search_prev);
			//		if (result != NULL) return result;
			//	}*/
			//break;

			//case WHILE:;
			//	message = " cond = %d | statements = %d ";
			//	printf(message, node->while_val->cond, node->while_val->statements);
			//	/*if (iter->while_val->cond != NULL)
			//	{
			//		result = __symt_search(iter->while_val->cond, id, name, search_name, search_prev);
			//		if (result != NULL) return result;
			//	}
//
			//	if (iter->while_val->statements != NULL)
			//	{
			//		result = __symt_search(iter->while_val->statements, id, name, search_name, search_prev);
			//		if (result != NULL) return result;
			//	}*/
			//break;

			case CALL_FUNC:;
				str_type = symt_strget_vartype(node->call->type);
				message = " name = %s | type = %d | params = %d ";
				printf(message, node->call->name, str_type, node->call->params);
				/*if (iter->call->params != NULL)
				{
					result = __symt_search(iter->call->params, id, name, search_name, search_prev);
					if (result != NULL) return result;
				}*/
			break;

			default: break; // Just to avoid warning
		}

		node = node->next_node;
	}
}

#ifdef _SYMT_JUST_COMPILE
void main() { }
#endif
