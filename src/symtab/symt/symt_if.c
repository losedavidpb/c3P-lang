//#include "../../../include/symt_if.h"
//
//#include "../../../include/memlib.h"
//#include "../../../include/symt_type.h"
//#include "../../../include/symt_node.h"
//
//symt_if_else* symt_new_if(symt_node *statements_if, symt_node *statements_else)
//{
//	symt_if_else *if_val = (symt_if_else *)(ml_malloc(sizeof(symt_if_else)));
//	if_val->if_statements = symt_copy_node(statements_if);
//	if_val->else_statements = symt_copy_node(statements_else);
//	return if_val;
//}
//
//symt_node* symt_insert_if(symt_node *statements_if, symt_node *statements_else)
//{
//	symt_if_else *if_val = symt_new_if(statements_if, statements_else);
//
//	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
//	new_node->id = IF;
//	new_node->if_val = if_val;
//	new_node->next_node = NULL;
//	return new_node;
//}
//
//void symt_delete_if(symt_if_else *if_val)
//{
//	if (if_val != NULL)
//	{
//		symt_delete_node(if_val->if_statements);
//		symt_delete_node(if_val->else_statements);
//		ml_free(if_val); if_val = NULL;
//	}
//}
//
//symt_if_else *symt_copy_if(symt_if_else *if_val)
//{
//	if (if_val != NULL)
//	{
//		symt_if_else *if_val_ = (symt_if_else *)(ml_malloc(sizeof(symt_if_else)));
//		if_val_->if_statements = symt_copy_node(if_val->if_statements);
//		if_val_->else_statements = symt_copy_node(if_val->else_statements);
//		return if_val_;
//	}
//
//	return NULL;
//}
