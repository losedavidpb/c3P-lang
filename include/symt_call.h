/* Utilities to manage a call */
#ifndef SYMT_CALL_H
#define SYMT_CALL_H

#include "symt_type.h"

/* Create a call symbol */
symt_call* symt_new_call(symt_name_t name, symt_var_t type, symt_node *params);

/* Insert call symbol to a symbol node */
symt_node* symt_insert_call(symt_name_t name, symt_var_t type, symt_node *params, symt_level_t level);

/* Delete passed call symbol */
void symt_delete_call(symt_call *call);

/* Copy passed call into a new one at a new direction */
symt_call *symt_copy_call(symt_call *call);

#endif	// SYMT_CALL_H
