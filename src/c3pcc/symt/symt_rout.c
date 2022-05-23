// symt_rout.c -*- C -*-
//
// This file is part of the c3P language compiler. This project
// is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License
//
// This project is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// If not, see <http://www.gnu.org/licenses/>.
//

/*
 *	ISO C99 Standard: Routine implementation for symt
 */

#include "../include/symt_rout.h"

#include "../include/memlib.h"
#include "../include/arrcopy.h"
#include "../include/symt_type.h"
#include "../include/symt_node.h"
#include <stdlib.h>

symt_rout* symt_new_rout(symt_id_t id, symt_name_t name, symt_var_t type, symt_label_t label)
{
	symt_rout *rout = (symt_rout *)(ml_malloc(sizeof(symt_rout)));
	rout->name = strcopy(name);
	rout->type = type;
	rout->label = label;
	return rout;
}

symt_node* symt_insert_rout(symt_id_t id, symt_name_t name, symt_var_t type, symt_level_t level, symt_label_t label)
{
	symt_rout *rout = symt_new_rout(id, name, type, label);
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
		rout_->name = strcopy(rout->name);
		rout_->label = rout->label;
		rout_->type = rout->type;
		return rout_;
	}

	return NULL;
}
