#include "symt.h"

#include "lib/assertb.h"
#include "lib/memlib.h"
#include "lib/copy.h"

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

/* Private */

bool __symt_is_valid_id(symt_id_t id)
{
    bool cond = id == LOCAL_VAR ||  id == GLOBAL_VAR;
    cond = cond || id == CONSTANT || id == IF || id == WHILE;
    cond = cond || id == FOR || id == SWITCH || id == FUNCTION;
    cond = cond || id == PROCEDURE || id == CALL;
    return cond;
}

symt_cons_t __symt_get_type_data(symt_var_t type)
{
    switch (type)
    {
        case I8: case I16: case I32: case I64:  return INTEGER; break;
        case F32: case F64:                     return DOUBLE; break;
        case C:                                 return CHAR; break;
        case B:                                 return B; break;
        default:                                return -1; break;
    }
}

void __symt_delete_value_cons(symt_cons_t type, symt_value_t value)
{
    switch(type)
    {
        case INTEGER:   ml_free(((int *)value));    break;
        case DOUBLE:    ml_free(((double *)value)); break;
        case CHAR:      ml_free(((char *)value));   break;
    }
}

/* Public */

symt_tab *symt_new()
{
    symt_tab *tab = NULL;
    tab = (symt_tab *)(ml_malloc(sizeof(symt_tab)));
    tab->id = SYMT_ROOT_ID;
    return tab;
}

symt_node *symt_search(symt_tab *tab, symt_id_t id)
{
    assertp(tab != NULL, "table has not been constructed");
    symt_node *iter = tab, *result = NULL;

    while (iter != NULL)
    {
        if (iter->id == id) return iter;

        if (id != FUNCTION && id != PROCEDURE)
        {
            switch (iter->id)
            {
                case FUNCTION:; case PROCEDURE:;
                    if (iter->rout->params != NULL)
                    {
                        result = symt_search(iter->rout->params, id);
                        if (result != NULL) return result;
                    }

                    if (iter->rout->statements != NULL)
                    {
                        result = symt_search(iter->rout->statements, id);
                        if (result != NULL) return result;
                    }
                break;

                case IF:;
                    if (iter->if_val->cond != NULL)
                    {
                        result = symt_search(iter->if_val->cond, id);
                        if (result != NULL) return result;
                    }

                    if (iter->if_val->if_statements != NULL)
                    {
                        result = symt_search(iter->if_val->if_statements, id);
                        if (result != NULL) return result;
                    }

                    if (iter->if_val->else_statements != NULL)
                    {
                        result = symt_search(iter->if_val->else_statements, id);
                        if (result != NULL) return result;
                    }
                break;

                case WHILE:;
                    if (iter->while_val->cond != NULL)
                    {
                        result = symt_search(iter->while_val->cond, id);
                        if (result != NULL) return result;
                    }

                    if (iter->while_val->statements != NULL)
                    {
                        result = symt_search(iter->while_val->statements, id);
                        if (result != NULL) return result;
                    }
                break;

                case FOR:;
                    if (iter->for_val->cond != NULL)
                    {
                        result = symt_search(iter->for_val->cond, id);
                        if (result != NULL) return result;
                    }

                    if (iter->for_val->iter_op != NULL)
                    {
                        result = symt_search(iter->for_val->iter_op, id);
                        if (result != NULL) return result;
                    }

                    if (iter->for_val->statements != NULL)
                    {
                        result = symt_search(iter->for_val->statements, id);
                        if (result != NULL) return result;
                    }
                break;

                case SWITCH:;
                    if (iter->switch_val->cases != NULL)
                    {
                        result = symt_search(iter->switch_val->cases, id);
                        if (result != NULL) return result;
                    }
                break;

                case CALL:;
                    if (iter->call->params != NULL)
                    {
                        result = symt_search(iter->call->params, id);
                        if (result != NULL) return result;
                    }
                break;
            }
        }

        iter = iter->next_node;
    }

    return NULL;
}

symt_node *symt_search_by_name(symt_tab *tab, symt_name_t name, symt_id_t id)
{
    assertp(tab != NULL, "table has not been constructed");
    symt_node *iter = tab, *result = NULL;

    while (iter != NULL)
    {
        if (iter->id != id)
        {
            if (id != FUNCTION && id != PROCEDURE)
            {
                switch (iter->id)
                {
                    case FUNCTION:; case PROCEDURE:;
                        if (iter->rout->params != NULL)
                        {
                            result = symt_search_by_name(iter->rout->params, name, id);
                            if (result != NULL) return result;
                        }

                        if (iter->rout->statements != NULL)
                        {
                            result = symt_search_by_name(iter->rout->statements, name, id);
                            if (result != NULL) return result;
                        }
                    break;

                    case IF:;
                        if (iter->if_val->cond != NULL)
                        {
                            result = symt_search_by_name(iter->if_val->cond, name, id);
                            if (result != NULL) return result;
                        }

                        if (iter->if_val->if_statements)
                        {
                            result = symt_search_by_name(iter->if_val->if_statements, name, id);
                            if (result != NULL) return result;
                        }

                        if (iter->if_val->else_statements != NULL)
                        {
                            result = symt_search_by_name(iter->if_val->else_statements, name, id);
                            if (result != NULL) return result;
                        }
                    break;

                    case WHILE:;
                        if (iter->while_val->cond != NULL)
                        {
                            result = symt_search_by_name(iter->while_val->cond, name, id);
                            if (result != NULL) return result;
                        }

                        if (iter->while_val->statements != NULL)
                        {
                            result = symt_search_by_name(iter->while_val->statements, name, id);
                            if (result != NULL) return result;
                        }
                    break;

                    case FOR:;
                        if (iter->for_val->cond != NULL)
                        {
                            result = symt_search_by_name(iter->for_val->cond, name, id);
                            if (result != NULL) return result;
                        }

                        if (iter->for_val->iter_op != NULL)
                        {
                            result = symt_search_by_name(iter->for_val->iter_op, name, id);
                            if (result != NULL) return result;
                        }

                        if (iter->for_val->statements != NULL)
                        {
                            result = symt_search_by_name(iter->for_val->statements, name, id);
                            if (result != NULL) return result;
                        }
                    break;

                    case SWITCH:;
                        if (iter->switch_val->cases != NULL)
                        {
                            result = symt_search_by_name(iter->switch_val->cases, name, id);
                            if (result != NULL) return result;
                        }
                    break;

                    case CALL:;
                        if (iter->call->params != NULL)
                        {
                            result = symt_search_by_name(iter->call->params, name, id);
                            if (result != NULL) return result;
                        }
                    break;
                }
            }
        }
        else
        {
            switch(iter->id)
            {
                case LOCAL_VAR:; case GLOBAL_VAR:;
                    if (strcmp(name, iter->var->name) == 0) return iter;
                break;

                case CONSTANT:;
                    if (strcmp(name, iter->cons->name) == 0) return iter;
                break;

                case FUNCTION:; case PROCEDURE:;
                    if (strcmp(name, iter->rout->name) == 0) return iter;
                break;

                case CALL:;
                    if (strcmp(name, iter->call->name) == 0) return iter;
                break;
            }
        }

        iter = iter->next_node;
    }

    return NULL;
}

symt_tab* symt_push(symt_tab *tab, symt_node *node)
{
    assertp(tab != NULL, "table has not been constructed");
    assertp(node != NULL, "node has not been defined");
    if (__symt_is_valid_id(node->id) == false) return tab;

    symt_node *iter = tab;

    if (iter->id == SYMT_ROOT_ID)
    {
        symt_delete(iter);
        return node;
    }

    while (iter->next_node != NULL)
        iter = iter->next_node;

    iter->next_node = node;
    node->next_node = NULL;
    return tab;
}

symt_tab * symt_insert_call(symt_tab *tab, const symt_name_t name, const symt_var_t type, struct symt_node *params)
{
	symt_call* call_value = (symt_call*)(ml_malloc(sizeof(symt_call)));
	call_value->type = type;
	call_value->params = params;
	call_value->name = strcopy(name);

	symt_node *new_node = (symt_node*)(ml_malloc(sizeof(symt_node)));
	new_node->id = CALL;
	new_node->call = call_value;
    new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab * symt_insert_var(symt_tab *tab, const symt_id_t id, const symt_name_t name, const symt_var_t type, bool is_array, int array_length, symt_value_t value, bool is_hide, bool is_readonly)
{
	symt_var* n_var = (symt_var*)(ml_malloc(sizeof(symt_var)));
    n_var->name = strcopy(name);
	n_var->type = type;
	n_var->value = value;
	n_var->is_array = is_array;
	n_var->array_length = array_length;
    n_var->is_hide = is_hide;
    n_var->is_readonly = is_readonly;

	symt_node *new_node = (symt_node*)(ml_malloc(sizeof(symt_node)));
	new_node->id = id;
	new_node->var = n_var;
    new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab * symt_insert_const(symt_tab *tab, const symt_name_t name, const symt_cons_t type, symt_value_t value)
{
	symt_cons* constant = (symt_cons*)(ml_malloc(sizeof(symt_cons)));
	constant->type = type;
	constant->value = value;
	constant->name = strcopy(name);

	symt_node *new_node = (symt_node*)(ml_malloc(sizeof(symt_node)));
	new_node->id = CONSTANT;
	new_node->cons = constant;
    new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab * symt_insert_rout(symt_tab *tab, const symt_id_t id, const symt_name_t name, const symt_var_t type, struct symt_node *params, bool is_hide, bool is_readonly, symt_node *statements)
{
	symt_routine* function = (symt_routine*)(ml_malloc(sizeof(symt_routine)));
	function->is_hide = is_hide;
    function->is_readonly = is_readonly;
	function->params = params;
	function->statements = statements;
	function->name = strcopy(name);
	if(id == FUNCTION) function->type = type;

	symt_node *new_node = (symt_node*)(ml_malloc(sizeof(symt_node)));

	new_node->id = id;
	new_node->rout = function;
    new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab * symt_insert_if(symt_tab *tab, symt_node *cond, symt_node *statements_if, symt_node *statements_else)
{
	symt_if_else* if_val = (symt_if_else*)(ml_malloc(sizeof(symt_if_else)));
	if_val->if_statements = statements_if;
	if_val->else_statements = statements_else;
	if_val->cond = cond;

	symt_node *new_node = (symt_node*)(ml_malloc(sizeof(symt_node)));
	new_node->id = IF;
	new_node->if_val = if_val;
    new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab * symt_insert_while(symt_tab *tab, symt_node *cond, symt_node *statements)
{
	symt_while* while_val = (symt_while*)(ml_malloc(sizeof(symt_while)));
	while_val->cond = cond;
	while_val->statements = statements;

	symt_node *new_node = (symt_node*)(ml_malloc(sizeof(symt_node)));
	new_node->id = WHILE;
	new_node->while_val = while_val;
    new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab * symt_insert_for(symt_tab *tab, symt_node *cond, symt_node *statements, symt_node *iter_var, symt_node *iter_op)
{
	symt_for* for_val_ = (symt_for*)(ml_malloc(sizeof(symt_for)));
	for_val_->cond = cond;
	for_val_->statements = statements;
    for_val_->incr = iter_var;
    for_val_->iter_op = iter_op;

	symt_node *new_node = (symt_node*)(ml_malloc(sizeof(symt_node)));

	new_node->id = FOR;
	new_node->for_val = for_val_;
    new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

symt_tab * symt_insert_switch(symt_tab *tab, symt_var *iter_var, symt_node *cases, int num_cases)
{
	symt_switch* sw = (symt_switch*)(malloc(sizeof(symt_switch)));
	sw->key_var = iter_var;
	sw->cases = cases;

	symt_node *new_node = (symt_node*)(ml_malloc(sizeof(symt_node)));

	new_node->id = SWITCH;
	new_node->switch_val = sw;
    new_node->next_node = NULL;

	return symt_push(tab, new_node);
}

void symt_end_block(symt_tab *tab, const symt_id_t id_block)
{
    assertp(tab != NULL, "table has not been constructed");

    symt_node *block_node = symt_search(tab, id_block);

    if (block_node != NULL)
    {
        symt_delete(block_node);
        block_node = NULL;
    }
}

symt_tab* symt_merge(symt_tab *src, symt_tab *dest)
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
            ml_free(iter->var->name); iter->var->name = NULL;
            symt_cons_t var_type = __symt_get_type_data(iter->var->type);
            __symt_delete_value_cons(var_type, iter->var->value);
            iter->var->value = NULL; iter->var->type = SYMT_ROOT_ID;
            ml_free(iter->var); iter->var = NULL;
        }

        // Constant
        if (iter->cons != NULL)
        {
            ml_free(iter->cons->name); iter->cons->name = NULL;
            __symt_delete_value_cons(iter->cons->type, iter->cons->value);
            iter->cons->value = NULL; iter->cons->type = SYMT_ROOT_ID;
            ml_free(iter->cons); iter->cons = NULL;
        }

        // If
        if (iter->if_val != NULL)
        {
            if (iter->if_val->cond != NULL) symt_delete(iter->if_val->cond);
            if (iter->if_val->if_statements != NULL) symt_delete(iter->if_val->if_statements);
            if (iter->if_val->else_statements != NULL) symt_delete(iter->if_val->else_statements);
            ml_free(iter->if_val); iter->if_val = NULL;
        }

        // While
        if (iter->while_val != NULL)
        {
            if (iter->while_val->cond != NULL) symt_delete(iter->while_val->cond);
            if (iter->while_val->statements != NULL) symt_delete(iter->while_val->statements);
            ml_free(iter->while_val); iter->while_val = NULL;
        }

        // Switch
        if (iter->switch_val != NULL)
        {
            symt_node *temp_switch_var = (symt_node *)(ml_malloc(sizeof(symt_node)));
            temp_switch_var->id = iter->switch_val->type_key;
            temp_switch_var->var = iter->switch_val->key_var;

            symt_delete(temp_switch_var);
            if (iter->switch_val->cases != NULL) symt_delete(iter->switch_val->cases);
            ml_free(iter->switch_val); iter->switch_val = NULL;
        }

        // For
        if (iter->for_val != NULL)
        {
            if (iter->for_val->cond != NULL) symt_delete(iter->for_val->cond);
            if (iter->for_val->iter_op != NULL) symt_delete(iter->for_val->iter_op);
            if (iter->for_val->statements != NULL) symt_delete(iter->for_val->statements);
            if (iter->for_val->incr != NULL) symt_delete(iter->for_val->incr);

            ml_free(iter->for_val); iter->for_val = NULL;
        }

        // Procedures and Functions
        if (iter->rout != NULL)
        {
            ml_free(iter->rout->name); iter->rout->name = NULL;
            if (iter->rout->params != NULL) symt_delete(iter->rout->params);
            if (iter->rout->statements != NULL) symt_delete(iter->rout->statements);
            ml_free(iter->rout); iter->rout = NULL;
        }

        // Call
        if (iter->call != NULL)
        {
            ml_free(iter->call->name); iter->call->name = NULL;
            if (iter->call->params != NULL) symt_delete(iter->call->params);
            ml_free(iter->call); iter->call = NULL;
        }

        prev = iter;
        iter = iter->next_node;
        prev->next_node = NULL;
        ml_free(prev); prev = NULL;
    }

    tab = NULL;
}

#ifdef _SYMT_JUST_COMPILE
void main() {}
#endif