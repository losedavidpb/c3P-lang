#include "symt.h"

#include "lib/assertb.h"
#include "lib/memlib.h"

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

/* Private */

bool _symt_is_private(symt_var_mod_t **modifiers)
{
    if (modifiers != NULL)
    {
        if (*modifiers != NULL) if (*(*modifiers) == HIDE) return true;
        if (*(modifiers + 1) != NULL) if (*(*(modifiers + 1)) == HIDE) return true;
    }

    return false;
}

symt_cons_t _symt_get_type_data(symt_var_t type)
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

void _symt_delete_value_cons(symt_cons_t type, symt_value_t value)
{
    switch(type)
    {
        case INTEGER:; ml_free(((int *)value)); break;
        case DOUBLE:; ml_free(((double *)value)); break;
        case CHAR:; ml_free(((char *)value)); break;
    }
}

/* Public */

symt_tab *symt_new()
{
    symt_tab *tab;
    tab = (symt_tab *)(ml_malloc(sizeof(symt_tab)));
    tab->id = SYMT_ROOT_ID;
    return tab;
}

symt_node *symt_search(symt_tab *tab, symt_id_t id)
{
    assertf(tab != NULL, "table has not been constructed");
    symt_node *iter = tab, *result = NULL;

    while (iter != NULL)
    {
        if (iter->id == id) return iter;

        if (id != FUNCTION && id != PROCEDURE)
        {
            switch (iter->id)
            {
                case FUNCTION:; case PROCEDURE:;
                    result = symt_search(iter->rout->params, id);
                    if (result != NULL) return result;

                    result = symt_search(iter->rout->statements, id);
                    if (result != NULL) return result;
                break;

                case IF:;
                    result = symt_search(iter->if_val->cond, id);
                    if (result != NULL) return result;

                    result = symt_search(iter->if_val->if_statements, id);
                    if (result != NULL) return result;

                    result = symt_search(iter->if_val->else_statements, id);
                    if (result != NULL) return result;
                break;

                case WHILE:;
                    result = symt_search(iter->while_val->cond, id);
                    if (result != NULL) return result;

                    result = symt_search(iter->while_val->statements, id);
                    if (result != NULL) return result;
                break;

                case FOR:;
                    result = symt_search(iter->for_val->cond, id);
                    if (result != NULL) return result;

                    result = symt_search(iter->for_val->iter_op, id);
                    if (result != NULL) return result;

                    result = symt_search(iter->for_val->statements, id);
                    if (result != NULL) return result;
                break;

                case SWITCH:;
                    result = symt_search(iter->switch_val->cases, id);
                    if (result != NULL) return result;
                break;

                case CALL:;
                    result = symt_search(iter->call->params, id);
                    if (result != NULL) return result;
                break;
            }
        }

        iter = iter->next_node;
    }

    return NULL;
}

symt_node *symt_search_by_name(symt_tab *tab, symt_name_t name, symt_id_t id)
{
    assertf(tab != NULL, "table has not been constructed");
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
                        result = symt_search_by_name(iter->rout->params, name, id);
                        if (result != NULL) return result;

                        result = symt_search_by_name(iter->rout->statements, name, id);
                        if (result != NULL) return result;
                    break;

                    case IF:;
                        result = symt_search_by_name(iter->if_val->cond, name, id);
                        if (result != NULL) return result;

                        result = symt_search_by_name(iter->if_val->if_statements, name, id);
                        if (result != NULL) return result;

                        result = symt_search_by_name(iter->if_val->else_statements, name, id);
                        if (result != NULL) return result;
                    break;

                    case WHILE:;
                        result = symt_search_by_name(iter->while_val->cond, name, id);
                        if (result != NULL) return result;

                        result = symt_search_by_name(iter->while_val->statements, name, id);
                        if (result != NULL) return result;
                    break;

                    case FOR:;
                        result = symt_search_by_name(iter->for_val->cond, name, id);
                        if (result != NULL) return result;

                        result = symt_search_by_name(iter->for_val->iter_op, name, id);
                        if (result != NULL) return result;

                        result = symt_search_by_name(iter->for_val->statements, name, id);
                        if (result != NULL) return result;
                    break;

                    case SWITCH:;
                        result = symt_search_by_name(iter->switch_val->cases, name, id);
                        if (result != NULL) return result;
                    break;

                    case CALL:;
                        result = symt_search_by_name(iter->call->params, name, id);
                        if (result != NULL) return result;
                    break;
                }
            }
        }
        else
        {
            switch(iter->id)
            {
                case LOCAL_VAR:; case GLOBAL_VAR:;
                    if (strcmp(name, iter->var->name) == true) return iter;
                break;

                case CONSTANT:;
                    if (strcmp(name, iter->cons->name) == true) return iter;
                break;

                case FUNCTION:; case PROCEDURE:;
                    if (strcmp(name, iter->rout->name) == true) return iter;
                break;

                case CALL:;
                    if (strcmp(name, iter->call->name) == true) return iter;
                break;
            }
        }

        iter = iter->next_node;
    }

    return NULL;
}

symt_tab* symt_push(symt_tab *tab, symt_node *node)
{
    assertf(tab != NULL, "table has not been constructed");
    assertf(node != NULL, "node has not been defined");

    node->next_node = tab->next_node;
    ml_free(tab);

    return node;
}

void symt_insert_call(symt_tab *tab, const symt_name_t name, const symt_var_t type, struct symt_node *params)
{

}

void symt_insert_var(symt_tab *tab, const symt_id_t id, const symt_name_t name, const symt_var_t type, bool is_array, int array_length, symt_value_t value, symt_var_mod_t **modifiers)
{

}

void symt_insert_const(symt_tab *tab, const symt_name_t name, const symt_name_t type, symt_value_t value)
{

}

void symt_insert_rout(symt_tab *tab, const symt_id_t id, const symt_name_t name, const symt_var_t type, struct symt_node *params, symt_var_mod_t **modifiers, symt_node *statements)
{

}

void symt_insert_if(symt_tab *tab, symt_node *cond, symt_node *statements_if, symt_node *statements_else)
{

}

void symt_insert_while(symt_tab *tab, symt_node *cond, symt_node *statements)
{

}

void symt_insert_for(symt_tab *tab, symt_node *cond, symt_node *statements, symt_var *iter_var)
{

}

void symt_insert_switch(symt_tab *tab, symt_var *iter_var, symt_if_else *cases, int num_cases)
{

}

void symt_end_block(symt_tab *tab, const symt_id_t id_block)
{
    assertf(tab != NULL, "table has not been constructed");

    symt_node *block_node = symt_search(tab, id_block);

    if (block_node != NULL)
    {
        ml_free(block_node->next_node);
        block_node->next_node = NULL;
    }
}

void symt_merge(symt_tab *src, symt_tab *dest)
{
    assertf(src != NULL, "table src has not been constructed");
    assertf(dest != NULL, "table dest has not been constructed");
    symt_node *iter = src;

    while (iter != NULL)
    {
        if (iter->id == LOCAL_VAR || iter->id == GLOBAL_VAR)
        {
            if (_symt_is_private(iter->var->modifiers) == false)
            {
                symt_insert_var(dest,
                    iter->id, iter->var->name, iter->var->type,
                    iter->var->is_array, iter->var->array_length,
                    iter->var->value, iter->var->modifiers
                );
            }
        }
        else if (iter->id == FUNCTION || iter->id == PROCEDURE)
        {
            if (_symt_is_private(iter->rout->modifiers) == false)
            {
                symt_insert_rout(dest,
                    iter->id, iter->rout->name, iter->rout->type,
                    iter->rout->params, iter->rout->modifiers,
                    iter->rout->statements
                );
            }
        } else symt_push(dest, iter);

        iter = iter->next_node;
    }
}

void symt_delete(symt_tab *tab)
{
    assertf(tab != NULL, "table has not been constructed");
    symt_node *iter = tab;

    while (iter != NULL)
    {
        switch(iter->id)
        {
            case LOCAL_VAR:; case GLOBAL_VAR:;
                ml_free(iter->var->name);
                ml_free(iter->var->modifiers);
                _symt_delete_value_cons(_symt_get_type_data(iter->var->type), iter->var->value);
                ml_free(iter->var);
            break;

            case CONSTANT:;
                ml_free(iter->cons->name);
                _symt_delete_value_cons(iter->cons->type, iter->cons->value);
                ml_free(iter->cons);
            break;

            case IF:;
                symt_delete(iter->if_val->cond);
                symt_delete(iter->if_val->if_statements);
                symt_delete(iter->if_val->else_statements);
                ml_free(iter->if_val);
            break;

            case WHILE:;
                symt_delete(iter->while_val->cond);
                symt_delete(iter->while_val->statements);
                ml_free(iter->while_val);
            break;

            case SWITCH:;
                symt_node *temp_switch_var = (symt_node *)(ml_malloc(sizeof(symt_node)));
                temp_switch_var->id = iter->switch_val->type_key;
                temp_switch_var->var = iter->switch_val->key_var;

                symt_delete(temp_switch_var);
                symt_delete(iter->switch_val->cases);
                ml_free(iter->switch_val);
            break;

            case FOR:;
                symt_delete(iter->for_val->cond);
                symt_delete(iter->for_val->iter_op);
                symt_delete(iter->for_val->statements);

                symt_node *temp_for_var = (symt_node *)(ml_malloc(sizeof(symt_node)));
                temp_for_var->id = LOCAL_VAR;
                temp_for_var->var = iter->for_val->incr;

                symt_delete(temp_for_var);
                ml_free(iter->for_val);
            break;

            case FUNCTION:; case PROCEDURE:;
                ml_free(iter->rout->name);
                ml_free(iter->rout->modifiers);
                symt_delete(iter->rout->params);
                symt_delete(iter->rout->statements);
                ml_free(iter->rout);
            break;

            case CALL:;
                ml_free(iter->call->name);
                symt_delete(iter->call->params);
                ml_free(iter->call);
            break;
        }

        iter = iter->next_node;
    }

    ml_free(tab);
}

#ifdef _SYMT_JUST_COMPILE
void main() {}
#endif