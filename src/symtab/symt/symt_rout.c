#include "../include/symt_rout.h"

#include "../include/memlib.h"
#include "../include/arrcopy.h"
#include "../include/symt_type.h"
#include "../include/symt_node.h"

symt_rout* symt_new_rout(symt_id_t id, symt_name_t name, symt_var_t type, bool is_hide)
{
	symt_rout *rout = (symt_rout *)(ml_malloc(sizeof(symt_rout)));
	rout->is_hide = is_hide;
	rout->name = strcopy(name);
	rout->type = type;
	return rout;
}

symt_node* symt_insert_rout(symt_id_t id, symt_name_t name, symt_var_t type, bool is_hide, symt_level_t level)
{
	symt_rout *rout = symt_new_rout(id, name, type, is_hide);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = id;
	new_node->rout = rout;
	new_node->level = level;
	new_node->next_node = NULL;
	return new_node;
}

void symt_delete_rout(symt_rout *rout)
{
	if (rout != NULL)
	{
		ml_free(rout->name); rout->name = NULL;
		ml_free(rout); rout = NULL;
	}
}

symt_rout *symt_copy_rout(symt_rout *rout)
{
	if (rout != NULL)
	{
		symt_rout *rout_ = (symt_rout *)(ml_malloc(sizeof(symt_rout)));
		rout_->is_hide = rout->is_hide;
		rout_->name = strcopy(rout->name);
		rout_->type = rout->type;
		return rout_;
	}

	return NULL;
}
