#include "../../../include/symt_node.h"

#include "../../../include/assertb.h"
#include "../../../include/arrcopy.h"
#include "../../../include/memlib.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"
#include "../../../include/symt_cons.h"
#include "../../../include/symt_for.h"
#include "../../../include/symt_if.h"
#include "../../../include/symt_while.h"
#include "../../../include/symt_switch.h"
#include "../../../include/symt_routine.h"
#include "../../../include/symt_var.h"
#include "../../../include/symt_call.h"
#include <stdlib.h>
#include <string.h>

void symt_delete_value_cons(symt_cons_t type, symt_value_t value)
{
	switch (type)
	{
		case CONS_INTEGER: ml_free(((int *)value)); 	break;
		case CONS_DOUBLE: ml_free(((double *)value)); 	break;
		case CONS_CHAR: ml_free(((char *)value)); 		break;
	}
}

symt_node* symt_new_node()
{
	symt_tab *tab = NULL;
	tab = (symt_tab *)(ml_malloc(sizeof(symt_tab)));
	tab->id = SYMT_ROOT_ID;
	return tab;
}

bool symt_is_valid_id(symt_id_t id)
{
	bool cond = id == LOCAL_VAR || id == GLOBAL_VAR;
	cond = cond || id == CONSTANT || id == IF || id == WHILE;
	cond = cond || id == FOR || id == SWITCH || id == FUNCTION;
	cond = cond || id == PROCEDURE || id == CALL_FUNC;
	return cond;
}

symt_value_t symt_get_value_from_node(symt_node *node)
{
	assertp(node != NULL, "passed node is null");
	assertp(node->id == LOCAL_VAR || node->id == GLOBAL_VAR || node->id == CONSTANT || node->id == CALL_FUNC, "node has not got a value");

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

symt_cons_t symt_get_type_value_from_node(symt_node *node)
{
	assertp(node != NULL, "table has not been constructed");
	assertp(node->id == LOCAL_VAR || node->id == GLOBAL_VAR || node->id == CONSTANT, "passed node has not a valid type");

	if (node->id == LOCAL_VAR || node->id == GLOBAL_VAR)
		return symt_get_type_data(node->var->type);
	else
		return node->cons->type;
}

void symt_printf_value(symt_node* node)
{
	symt_value_t value = symt_get_value_from_node(node);
	symt_cons_t type = symt_get_type_value_from_node(node);

	if ((node->id == LOCAL_VAR || node->id == GLOBAL_VAR) && node->var->is_array)
	{
		if (type == CONS_INTEGER || type == CONS_DOUBLE)
		{
			if (type == CONS_INTEGER)
			{
				int *int_value = (int*)value;
				printf(" | value = { ");
				for (int i = 0; i < node->var->array_length; i++) printf("%d ", *(int_value + i));
				printf("}");
			}
			else
			{
				double *double_value = (double*)value;
				printf(" | value = { ");
				for (int i = 0; i < node->var->array_length; i++) printf("%lf ", *(double_value + i));
				printf("}");
			}
		}
		else
		{
			char *str_value = (char*)value;
			printf(" | type = %s", str_value);
		}
	}
	else
	{
		switch(type)
		{
			case CONS_INTEGER: printf(" | type = %d", *(int*)value); break;
			case CONS_DOUBLE: printf(" | type = %lf", *(double*)value); break;
			case CONS_CHAR: printf(" | type = %c", *(char*)value); break;
		}
	}
}

void *symt_copy_value(symt_value_t *value, symt_cons_t type, int num_elems)
{
	void *copy_value = NULL;

	if (value != NULL)
	{
		switch (type)
		{
			case CONS_INTEGER: copy_value = intcopy((int *)value, num_elems + 1); 		break;
			case CONS_DOUBLE: copy_value = doublecopy((double *)value, num_elems + 1);	break;
			case CONS_CHAR: copy_value = strdup((char *)value); 						break;
		}
	}

	return copy_value;
}

void symt_delete_node(symt_node *node)
{
	assertp(node != NULL, "table has not been constructed");
	symt_node *iter = node, *prev = NULL;

	while (iter != NULL)
	{
		iter->id = SYMT_ROOT_ID;

		// Global and local variables
		symt_delete_var(iter->var);
		iter->var = NULL;

		// Constant
		symt_delete_cons(iter->cons);
		iter->cons = NULL;

		// If
		symt_delete_if(iter->if_val);
		iter->if_val = NULL;

		// While
		symt_delete_while(iter->while_val);
		iter->while_val = NULL;

		// Switch
		symt_delete_switch(iter->switch_val);
		iter->switch_val = NULL;

		// For
		symt_delete_for(iter->for_val);
		iter->for_val = NULL;

		// Procedures and Functions
		symt_delete_rout(iter->rout);
		iter->rout = NULL;

		// Call
		symt_delete_call(iter->call);
		iter->call = NULL;

		prev = iter;
		iter = iter->next_node;
		prev->next_node = NULL;
		ml_free(prev);
		prev = NULL;
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

		if (node->call != NULL) copy_node->call = symt_copy_call(node->call);
		if (node->cons != NULL) copy_node->cons = symt_copy_cons(node->cons);
		if (node->for_val != NULL) copy_node->for_val = symt_copy_for(node->for_val);
		if (node->while_val != NULL) copy_node->while_val = symt_copy_while(node->while_val);
		if (node->if_val != NULL) copy_node->if_val = symt_copy_if(node->if_val);
		if (node->switch_val != NULL) copy_node->switch_val = symt_copy_switch(node->switch_val);
		if (node->var != NULL) copy_node->var = symt_copy_var(node->var);
		if (node->rout != NULL) copy_node->rout = symt_copy_rout(node->rout);
		if (node->next_node != NULL) copy_node->next_node = symt_copy_node(node->next_node);
	}

	return copy_node;
}
