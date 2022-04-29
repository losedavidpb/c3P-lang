#include "symt.h"

#include "lib/assertb.h"
#include "lib/copy.h"
#include "lib/memlib.h"

#include <stdbool.h>
#include <stdio.h>
#include <string.h>

/* Private */

void __symt_delete_value_cons(symt_cons_t type, symt_value_t value)
{
	switch (type)
	{
		case INTEGER_: ml_free(((int *)value)); 	break;
		case DOUBLE_: ml_free(((double *)value)); 	break;
		case CHAR_: ml_free(((char *)value)); 		break;
	}
}

void *__symt_copy_value(symt_value_t *value, symt_cons_t type, int num_elems)
{
	void *copy_value = NULL;

	if (value != NULL)
	{
		switch (type)
		{
			case INTEGER_: copy_value = intcopy((int *)value, num_elems + 1); 		break;
			case DOUBLE_: copy_value = doublecopy((double *)value, num_elems + 1);	break;
			case CHAR_: copy_value = strcopy((char *)value); 						break;
		}
	}

	return copy_value;
}

symt_var *__symt_copy_var(symt_var *var)
{
	symt_var *n_var = (symt_var *)(ml_malloc(sizeof(symt_var)));
	n_var->name = strcopy(var->name);
	n_var->type = var->type;
	n_var->value = __symt_copy_value(var->value, symt_get_type_data(n_var->type), var->array_length);
	n_var->is_array = var->is_array;
	n_var->array_length = var->array_length;
	n_var->is_hide = var->is_hide;
	n_var->is_readonly = var->is_readonly;
	return n_var;
}

symt_cons *__symt_copy_cons(symt_cons *cons)
{
	symt_cons *constant = (symt_cons *)(ml_malloc(sizeof(symt_cons)));
	constant->type = cons->type;
	constant->value = __symt_copy_value(cons->value, cons->type, 0);
	constant->value = cons->value;
	constant->name = strcopy(cons->name);
	return constant;
}

symt_call *__symt_copy_call(symt_call *call_value)
{
	symt_call *call_value_ = (symt_call *)(ml_malloc(sizeof(symt_call)));
	call_value_->type = call_value->type;
	call_value_->params = symt_copy(call_value->params);
	call_value_->name = strcopy(call_value->name);
	return call_value_;
}

symt_routine *__symt_copy_rout(symt_routine *rout)
{
	symt_routine *function = (symt_routine *)(ml_malloc(sizeof(symt_routine)));
	function->is_hide = rout->is_hide;
	function->is_readonly = rout->is_readonly;
	function->params = symt_copy(rout->params);
	function->statements = symt_copy(rout->statements);
	function->name = strcopy(rout->name);
	function->type = rout->type;
	return function;
}

symt_if_else *__symt_copy_if(symt_if_else *if_val)
{
	symt_if_else *if_val_ = (symt_if_else *)(ml_malloc(sizeof(symt_if_else)));
	if_val_->if_statements = symt_copy(if_val->if_statements);
	if_val_->else_statements = symt_copy(if_val->else_statements);
	if_val_->cond = symt_copy(if_val->cond);
	return if_val_;
}

symt_switch *__symt_copy_switch(symt_switch *switch_val)
{
	symt_switch *sw = (symt_switch *)(malloc(sizeof(symt_switch)));
	sw->key_var = __symt_copy_var(switch_val->key_var);
	sw->cases = symt_copy(switch_val->cases);
	return sw;
}

symt_while *__symt_copy_while(symt_while *while_val)
{
	symt_while *while_val_ = (symt_while *)(ml_malloc(sizeof(symt_while)));
	while_val_->cond = symt_copy(while_val->cond);
	while_val_->statements = symt_copy(while_val->statements);
	return while_val_;
}

symt_for *__symt_copy_for(symt_for *for_val)
{
	symt_for *for_val_ = (symt_for *)(ml_malloc(sizeof(symt_for)));
	for_val_->cond = symt_copy(for_val->cond);
	for_val_->statements = symt_copy(for_val->statements);
	for_val_->incr = symt_copy(for_val->incr);
	for_val_->iter_op = symt_copy(for_val->iter_op);
	if(for_val_->incr != NULL) for_val_->incr->next_node = NULL;
	return for_val;
}

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
				case CONSTANT:; if (strcmp(name, iter->cons->name) == 0) return search_prev == true ? prev : iter; 						break;
				case FUNCTION:; case PROCEDURE:; if (strcmp(name, iter->rout->name) == 0) return search_prev == true ? prev : iter; 	break;
				case CALL_:; if (strcmp(name, iter->call->name) == 0) return search_prev == true ? prev : iter; 						break;
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

				case CALL_:;
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

/* Public */

bool symt_is_valid_id(symt_id_t id)
{
	bool cond = id == LOCAL_VAR || id == GLOBAL_VAR;
	cond = cond || id == CONSTANT || id == IF || id == WHILE;
	cond = cond || id == FOR || id == SWITCH || id == FUNCTION;
	cond = cond || id == PROCEDURE || id == CALL_;
	return cond;
}

symt_cons_t symt_get_type_data(symt_var_t type)
{
	switch (type)
	{
		case I8: case I16: case I32: case I64: return INTEGER_; break;
		case F32: case F64: return DOUBLE_; 					break;
		case C: return CHAR_;									break;
		case B: return INTEGER_;								break;
		default: return -1;										break;
	}
}

symt_value_t symt_get_value_from_node(symt_node *node)
{
	assertp(node != NULL, "passed node is null");
	assertp(node->id == LOCAL_VAR || node->id == GLOBAL_VAR || node->id == CONSTANT || node->id == CALL_, "node has not got a value");

	if (node->id == LOCAL_VAR || node->id == GLOBAL_VAR)
	{
		assertp(node->var != NULL, "variable has not be defined");
		return node->var->value;
	}

	if (node->id == CONSTANT)
	{
		assertp(node->cons != NULL, "constant has not be defined");
		return node->cons->value;
	}

	assertp(node->call != NULL, "call has not be defined");
	return node->call;
}

symt_node *symt_copy(symt_node *node)
{
	symt_node *copy_node = NULL;

	if (node != NULL)
	{
		copy_node = (symt_node *)(ml_malloc(sizeof(symt_node)));

		copy_node->id = node->id;
		if (node->call != NULL) copy_node->call = __symt_copy_call(node->call);
		if (node->cons != NULL) copy_node->cons = __symt_copy_cons(node->cons);
		if (node->for_val != NULL) copy_node->for_val = __symt_copy_for(node->for_val);
		if (node->while_val != NULL) copy_node->while_val = __symt_copy_while(node->while_val);
		if (node->if_val != NULL) copy_node->if_val = __symt_copy_if(node->if_val);
		if (node->switch_val != NULL) copy_node->switch_val = __symt_copy_switch(node->switch_val);
		if (node->var != NULL) copy_node->var = __symt_copy_var(node->var);
		if (node->rout != NULL) copy_node->rout = __symt_copy_rout(node->rout);
		if (node->next_node != NULL) copy_node->next_node = symt_copy(node->next_node);
	}

	return copy_node;
}

symt_tab *symt_new()
{
	symt_tab *tab = NULL;
	tab = (symt_tab *)(ml_malloc(sizeof(symt_tab)));
	tab->id = SYMT_ROOT_ID;
	return tab;
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

	iter->next_node = symt_copy(node);
	iter->next_node->next_node = NULL;

	return tab;
}

symt_tab *symt_insert_call(symt_tab *tab, const symt_name_t name, const symt_var_t type, struct symt_node *params)
{
	symt_call *call_value = (symt_call *)(ml_malloc(sizeof(symt_call)));
	call_value->type = type;
	call_value->params = symt_copy(params);
	call_value->name = strcopy(name);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = CALL_;
	new_node->call = call_value;
	new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab *symt_insert_var(symt_tab *tab, const symt_id_t id, const symt_name_t name, const symt_var_t type, bool is_array, int array_length, symt_value_t value, bool is_hide, bool is_readonly)
{
	symt_var *n_var = (symt_var *)(ml_malloc(sizeof(symt_var)));
	n_var->name = strcopy(name);
	n_var->type = type;
	n_var->value = __symt_copy_value(value, symt_get_type_data(type), array_length);
	n_var->is_array = is_array;
	n_var->array_length = array_length;
	n_var->is_hide = is_hide;
	n_var->is_readonly = is_readonly;

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = id;
	new_node->var = n_var;
	new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab *symt_insert_const(symt_tab *tab, const symt_name_t name, const symt_cons_t type, symt_value_t value)
{
	symt_cons *constant = (symt_cons *)(ml_malloc(sizeof(symt_cons)));
	constant->type = type;
	constant->value = __symt_copy_value(value, type, 0);
	constant->name = strcopy(name);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = CONSTANT;
	new_node->cons = constant;
	new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab *symt_insert_rout(symt_tab *tab, const symt_id_t id, const symt_name_t name, const symt_var_t type, struct symt_node *params, bool is_hide, bool is_readonly, symt_node *statements)
{
	symt_routine *function = (symt_routine *)(ml_malloc(sizeof(symt_routine)));
	function->is_hide = is_hide;
	function->is_readonly = is_readonly;
	function->params = symt_copy(params);
	function->statements = symt_copy(statements);
	function->name = strcopy(name);
	if (id == FUNCTION) function->type = type;

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = id;
	new_node->rout = function;
	new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab *symt_insert_if(symt_tab *tab, symt_node *cond, symt_node *statements_if, symt_node *statements_else)
{
	symt_if_else *if_val = (symt_if_else *)(ml_malloc(sizeof(symt_if_else)));
	if_val->if_statements = symt_copy(statements_if);
	if_val->else_statements = symt_copy(statements_else);
	if_val->cond = symt_copy(cond);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = IF;
	new_node->if_val = if_val;
	new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab *symt_insert_while(symt_tab *tab, symt_node *cond, symt_node *statements)
{
	symt_while *while_val = (symt_while *)(ml_malloc(sizeof(symt_while)));
	while_val->cond = symt_copy(cond);
	while_val->statements = symt_copy(statements);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = WHILE;
	new_node->while_val = while_val;
	new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab *symt_insert_for(symt_tab *tab, symt_node *cond, symt_node *statements, symt_node *iter_var, symt_node *iter_op)
{
	if (iter_var != NULL) iter_var->next_node = NULL;

	symt_for *for_val_ = (symt_for *)(ml_malloc(sizeof(symt_for)));
	for_val_->cond = symt_copy(cond);
	for_val_->statements = symt_copy(statements);
	for_val_->incr = symt_copy(iter_var);
	for_val_->iter_op = symt_copy(iter_op);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = FOR;
	new_node->for_val = for_val_;
	new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab *symt_insert_switch(symt_tab *tab, symt_var *iter_var, symt_node *cases)
{
	symt_switch *sw = (symt_switch *)(malloc(sizeof(symt_switch)));
	sw->key_var = __symt_copy_var(iter_var);
	sw->cases = symt_copy(cases);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = SWITCH;
	new_node->switch_val = sw;
	new_node->next_node = NULL;

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
				dest = symt_insert_var(dest,
					iter->id, iter->var->name, iter->var->type,
					iter->var->is_array, iter->var->array_length,
					iter->var->value, iter->var->is_hide, iter->var->is_readonly
				);
			}
		}
		else if (iter->id == FUNCTION || iter->id == PROCEDURE)
		{
			if (iter->rout->is_hide == false)
			{
				dest = symt_insert_rout(dest,
					iter->id, iter->rout->name, iter->rout->type,
					iter->rout->params, iter->rout->is_hide,
					iter->rout->is_readonly, iter->rout->statements
				);
			}
		} else dest = symt_push(dest, iter);

		iter = iter->next_node;
	}

	return dest;
}

void symt_delete(symt_tab *tab)
{
	assertp(tab != NULL, "table has not been constructed");
	symt_node *iter = tab, *prev = NULL;

	while (iter != NULL)
	{
		iter->id = SYMT_ROOT_ID;

		// Global and local variables
		if (iter->var != NULL)
		{
			ml_free(iter->var->name);
			iter->var->name = NULL;
			symt_cons_t var_type = symt_get_type_data(iter->var->type);
			__symt_delete_value_cons(var_type, iter->var->value);
			iter->var->value = NULL;
			iter->var->type = SYMT_ROOT_ID;
			ml_free(iter->var);
			iter->var = NULL;
		}

		// Constant
		if (iter->cons != NULL)
		{
			ml_free(iter->cons->name);
			iter->cons->name = NULL;
			__symt_delete_value_cons(iter->cons->type, iter->cons->value);
			iter->cons->value = NULL;
			iter->cons->type = SYMT_ROOT_ID;
			ml_free(iter->cons);
			iter->cons = NULL;
		}

		// If
		if (iter->if_val != NULL)
		{
			if (iter->if_val->cond != NULL) symt_delete(iter->if_val->cond);
			if (iter->if_val->if_statements != NULL) symt_delete(iter->if_val->if_statements);
			if (iter->if_val->else_statements != NULL) symt_delete(iter->if_val->else_statements);
			ml_free(iter->if_val);
			iter->if_val = NULL;
		}

		// While
		if (iter->while_val != NULL)
		{
			if (iter->while_val->cond != NULL) symt_delete(iter->while_val->cond);
			if (iter->while_val->statements != NULL) symt_delete(iter->while_val->statements);
			ml_free(iter->while_val);
			iter->while_val = NULL;
		}

		// Switch
		if (iter->switch_val != NULL)
		{
			symt_node *temp_switch_var = (symt_node *)(ml_malloc(sizeof(symt_node)));
			temp_switch_var->id = iter->switch_val->type_key;
			temp_switch_var->var = iter->switch_val->key_var;

			symt_delete(temp_switch_var);
			if (iter->switch_val->cases != NULL) symt_delete(iter->switch_val->cases);
			ml_free(iter->switch_val);
			iter->switch_val = NULL;
		}

		// For
		if (iter->for_val != NULL)
		{
			if (iter->for_val->incr != NULL) iter->for_val->incr->next_node = NULL;
			if (iter->for_val->cond != NULL) symt_delete(iter->for_val->cond);
			if (iter->for_val->iter_op != NULL) symt_delete(iter->for_val->iter_op);
			if (iter->for_val->statements != NULL) symt_delete(iter->for_val->statements);
			if (iter->for_val->incr != NULL) symt_delete(iter->for_val->incr);

			ml_free(iter->for_val);
			iter->for_val = NULL;
		}

		// Procedures and Functions
		if (iter->rout != NULL)
		{
			ml_free(iter->rout->name);
			iter->rout->name = NULL;
			if (iter->rout->params != NULL) symt_delete(iter->rout->params);
			if (iter->rout->statements != NULL) symt_delete(iter->rout->statements);
			ml_free(iter->rout);
			iter->rout = NULL;
		}

		// Call
		if (iter->call != NULL)
		{
			ml_free(iter->call->name);
			iter->call->name = NULL;
			if (iter->call->params != NULL) symt_delete(iter->call->params);
			ml_free(iter->call);
			iter->call = NULL;
		}

		prev = iter;
		iter = iter->next_node;
		prev->next_node = NULL;
		ml_free(prev);
		prev = NULL;
	}

	tab = NULL;
}

#ifdef _SYMT_JUST_COMPILE
void main() { }
#endif