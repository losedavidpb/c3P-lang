#include "../../../include/symt_call.h"

#include "../../../include/memlib.h"
#include "../../../include/arrcopy.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"

symt_return* symt_new_return(symt_node *return_stmt)
{
	symt_return *ret = (symt_return*)(ml_malloc(sizeof(symt_return*)));
	ret->return_stmt = symt_copy_node(return_stmt);
	return ret;
}

symt_node* symt_insert_return(symt_node *return_stmt)
{
	symt_return *ret = symt_new_return(return_stmt);

	symt_node *new_node = (symt_node*)(ml_malloc(sizeof(symt_node)));
	new_node->id = RETURN;
	new_node->return_val = ret;
	return new_node;
}

void symt_delete_return(symt_return *ret)
{
	if (ret != NULL)
	{
		symt_delete_node(ret->return_stmt);
		ml_free(ret); ret = NULL;
	}
}

symt_return *symt_copy_return(symt_return *ret)
{
	symt_return *ret_ = (symt_return*)(ml_malloc(sizeof(symt_return)));
	ret->return_stmt = symt_copy_node(ret->return_stmt);
	return ret_;
}
