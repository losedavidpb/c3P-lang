//#include "../../../include/symt_call.h"
//
//#include "../../../include/memlib.h"
//#include "../../../include/arrcopy.h"
//#include "../../../include/symt_type.h"
//#include "../../../include/symt_node.h"
//
//symt_call* symt_new_call(symt_name_t name, symt_var_t type, symt_node *params)
//{
//	symt_call *call_value = (symt_call *)(ml_malloc(sizeof(symt_call)));
//	call_value->type = type;
//	call_value->params = symt_copy_node(params);
//	call_value->name = strcopy(name);
//	return call_value;
//}
//
//symt_node* symt_insert_call(symt_name_t name, symt_var_t type, symt_node *params, symt_level_t level)
//{
//	symt_call *call_value = symt_new_call(name, type, params);
//
//	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
//	new_node->id = CALL_FUNC;
//	new_node->call = call_value;
//	new_node->level = level;
//	new_node->next_node = NULL;
//	return new_node;
//}
//
//void symt_delete_call(symt_call *call)
//{
//	if (call != NULL)
//	{
//		ml_free(call->name); call->name = NULL;
//		symt_delete_node(call->params);
//		ml_free(call); call = NULL;
//	}
//}
//
//symt_call *symt_copy_call(symt_call *call)
//{
//	if (call != NULL)
//	{
//		symt_call *call_value_ = (symt_call *)(ml_malloc(sizeof(symt_call)));
//		call_value_->type = call_value_->type;
//		call_value_->params = symt_copy_node(call_value_->params);
//		call_value_->name = strcopy(call_value_->name);
//		return call_value_;
//	}
//
//	return NULL;
//}
//
