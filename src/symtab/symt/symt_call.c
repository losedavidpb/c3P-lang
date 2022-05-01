#include "../../../include/symt_call.h"

#include "../../../include/memlib.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"
#include <stdlib.h>
#include <string.h>

symt_call* symt_new_call(symt_name_t name, symt_var_t type, struct symt_node *params)
{
	symt_call *call_value = (symt_call *)(ml_malloc(sizeof(symt_call)));
	call_value->type = type;
	call_value->params = symt_copy_node(params);
	call_value->name = strdup(name);
	return call_value;
}

symt_node* symt_insert_call(symt_name_t name, symt_var_t type, struct symt_node *params)
{
	symt_call *call_value = symt_new_call(name, type, params);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = CALL_FUNC;
	new_node->call = call_value;
	new_node->next_node = NULL;
	return new_node;
}

void symt_delete_call(symt_call *call)
{
	if (call != NULL)
	{
		ml_free(call->name);
		call->name = NULL;
		if (call->params != NULL) symt_delete_node(call->params);
		ml_free(call);
		call = NULL;
	}
}

symt_call *symt_copy_call(symt_call *call)
{
	symt_call *call_value_ = (symt_call *)(ml_malloc(sizeof(symt_call)));
	call_value_->type = call_value_->type;
	call_value_->params = symt_copy_node(call_value_->params);
	call_value_->name = strdup(call_value_->name);
	return call_value_;
}
