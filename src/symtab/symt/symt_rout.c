#include "../../../include/symt_routine.h"

#include "../../../include/memlib.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"
#include <stdlib.h>
#include <string.h>

symt_routine* symt_new_rout(symt_id_t id, symt_name_t name, symt_var_t type, struct symt_node *params, bool is_hide, symt_node *statements)
{
	symt_routine *function = (symt_routine *)(ml_malloc(sizeof(symt_routine)));
	function->is_hide = is_hide;
	function->params = symt_copy_node(params);
	function->statements = symt_copy_node(statements);
	function->name = strdup(name);
	if (id == FUNCTION) function->type = type;
	return function;
}

symt_node* symt_insert_rout(symt_id_t id, symt_name_t name, symt_var_t type, struct symt_node *params, bool is_hide, symt_node *statements)
{
	symt_routine *function = symt_new_rout(id, name, type, params, is_hide, statements);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = id;
	new_node->rout = function;
	new_node->next_node = NULL;
	return new_node;
}

void symt_delete_rout(symt_routine *rout)
{
	if (rout != NULL)
	{
		ml_free(rout->name);
		rout->name = NULL;
		if (rout->params != NULL) symt_delete_node(rout->params);
		if (rout->statements != NULL) symt_delete_node(rout->statements);
		ml_free(rout);
		rout = NULL;
	}
}

symt_routine *symt_copy_rout(symt_routine *rout)
{
	symt_routine *function = (symt_routine *)(ml_malloc(sizeof(symt_routine)));
	function->is_hide = rout->is_hide;
	function->params = symt_copy_node(rout->params);
	function->statements = symt_copy_node(rout->statements);
	function->name = strdup(rout->name);
	function->type = rout->type;
	return function;
}
