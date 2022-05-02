#include "../../../include/symt_while.h"

#include "../../../include/memlib.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"
#include <stdlib.h>

symt_while* symt_new_while(symt_node *cond, symt_node *statements)
{
	symt_while *while_val = (symt_while *)(ml_malloc(sizeof(symt_while)));
	while_val->cond = symt_copy_node(cond);
	while_val->statements = symt_copy_node(statements);
	return while_val;
}

symt_node* symt_insert_while(symt_node *cond, symt_node *statements)
{
	symt_while *while_val = symt_new_while(cond, statements);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = WHILE;
	new_node->while_val = while_val;
	new_node->next_node = NULL;
	return new_node;
}

void symt_delete_while(symt_while *while_val)
{
	if (while_val != NULL)
	{
		symt_delete_node(while_val->cond);
		symt_delete_node(while_val->statements);
		ml_free(while_val); while_val = NULL;
	}
}

symt_while *symt_copy_while(symt_while *while_val)
{
	if (while_val != NULL)
	{
		symt_while *while_val_ = (symt_while *)(ml_malloc(sizeof(symt_while)));
		while_val_->cond = symt_copy_node(while_val->cond);
		while_val_->statements = symt_copy_node(while_val->statements);
		return while_val_;
	}

	return NULL;
}
