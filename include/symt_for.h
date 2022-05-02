/* Utilities to manage a for */
#ifndef SYMT_FOR_H
#define SYMT_FOR_H

#include "symt_type.h"

/* Create for symbol*/
symt_for* symt_new_for(symt_node *cond, symt_node *statements, symt_node *iter_var, symt_node *iter_op);

/* Insert for symbol to a symbol node */
symt_node* symt_insert_for(symt_node *cond, symt_node *statements, symt_node *iter_var, symt_node *iter_op);

/* Delete passed for symbol */
void symt_delete_for(symt_for *for_val);

/* Copy passed for symbol into a new one at a new direction */
symt_for *symt_copy_for(symt_for *for_val);

#endif	// SYMT_FOR_H
