/* Utilities to manage an if */
#ifndef SYMT_IF_H
#define SYMT_IF_H

#include "symt_type.h"

/* Create a if symbol */
symt_if_else* symt_new_if(symt_node *cond, symt_node *statements_if, symt_node *statements_else);

/* Insert if symbol to a symbol node */
symt_node* symt_insert_if(symt_node *cond, symt_node *statements_if, symt_node *statements_else);

/* Delete passed if symbol */
void symt_delete_if(symt_if_else *if_val);

/* Copy passed if symbol into a new one at a new direction */
symt_if_else *symt_copy_if(symt_if_else *if_val);

#endif	// SYMT_IF_H
