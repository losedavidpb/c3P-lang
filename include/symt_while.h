/* Utilities to manage a while */
#ifndef SYMT_WHILE_H
#define SYMT_WHILE_H

#include "symt_type.h"

/* Create a if symbol */
symt_while* symt_new_while(symt_node *cond, symt_node *statements);

/* Insert while symbol to a symbol node */
symt_node* symt_insert_while(symt_node *cond, symt_node *statements);

/* Delete passed if symbol */
void symt_delete_while(symt_while *while_val);

/* Copy passed if symbol into a new one at a new direction */
symt_while *symt_copy_while(symt_while *while_val);

#endif	// SYMT_WHILE_H
