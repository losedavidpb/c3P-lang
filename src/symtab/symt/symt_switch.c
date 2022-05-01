#include "../../../include/symt_switch.h"

#include "../../../include/memlib.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"
#include "../../../include/symt_var.h"
#include <stdlib.h>

symt_switch* symt_new_switch(symt_var *iter_var, symt_node *cases)
{
	symt_switch *sw = (symt_switch *)(malloc(sizeof(symt_switch)));
	sw->key_var = symt_copy_var(iter_var);
	sw->cases = symt_copy_node(cases);
	return sw;
}

symt_node* symt_insert_switch(symt_var *iter_var, symt_node *cases)
{
	symt_switch* sw = symt_new_switch(iter_var, cases);
	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = SWITCH;
	new_node->switch_val = sw;
	new_node->next_node = NULL;
	return new_node;
}

void symt_delete_switch(symt_switch *switch_val)
{
	if (switch_val != NULL)
	{
		symt_node *temp_switch_var = (symt_node *)(ml_malloc(sizeof(symt_node)));
		temp_switch_var->id = switch_val->type_key;
		temp_switch_var->var = switch_val->key_var;

		symt_delete_node(temp_switch_var);
		if (switch_val->cases != NULL) symt_delete_node(switch_val->cases);
		ml_free(switch_val);
		switch_val = NULL;
	}
}

symt_switch *symt_copy_switch(symt_switch *switch_val)
{
	symt_switch *sw = (symt_switch *)(malloc(sizeof(symt_switch)));
	sw->key_var = symt_copy_var(switch_val->key_var);
	sw->cases = symt_copy_node(switch_val->cases);
	return sw;
}
