#include "../../../include/symt_for.h"

#include "../../../include/memlib.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"
#include <stdlib.h>

symt_for* symt_new_for(symt_node *cond, symt_node *statements, symt_node *iter_var, symt_node *iter_op)
{
	if (iter_var != NULL) iter_var->next_node = NULL;

	symt_for *for_val_ = (symt_for *)(ml_malloc(sizeof(symt_for)));
	for_val_->cond = symt_copy_node(cond);
	for_val_->statements = symt_copy_node(statements);
	for_val_->incr = symt_copy_node(iter_var);
	for_val_->iter_op = symt_copy_node(iter_op);

	return for_val_;
}

symt_node* symt_insert_for(symt_node *cond, symt_node *statements, symt_node *iter_var, symt_node *iter_op)
{
	symt_for* for_val_ = symt_new_for(cond, statements, iter_var, iter_op);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = FOR;
	new_node->for_val = for_val_;
	new_node->next_node = NULL;

	return new_node;
}

void symt_delete_for(symt_for *for_val)
{
	if (for_val != NULL)
	{
		if (for_val->incr != NULL) for_val->incr->next_node = NULL;
		if (for_val->cond != NULL) symt_delete_node(for_val->cond);
		if (for_val->iter_op != NULL) symt_delete_node(for_val->iter_op);
		if (for_val->statements != NULL) symt_delete_node(for_val->statements);
		if (for_val->incr != NULL) symt_delete_node(for_val->incr);
		ml_free(for_val); for_val = NULL;
	}
}

symt_for *symt_copy_for(symt_for *for_val)
{
	symt_for *for_val_ = (symt_for *)(ml_malloc(sizeof(symt_for)));
	for_val_->cond = symt_copy_node(for_val->cond);
	for_val_->statements = symt_copy_node(for_val->statements);
	for_val_->incr = symt_copy_node(for_val->incr);
	for_val_->iter_op = symt_copy_node(for_val->iter_op);
	if(for_val_->incr != NULL) for_val_->incr->next_node = NULL;
	return for_val;
}
