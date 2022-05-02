/* Utilities to manage a switch */
#ifndef SYMT_SWITCH_H
#define SYMT_SWITCH_H

#include "symt_type.h"

/* Create for symbol */
symt_switch* symt_new_switch(symt_var *iter_var, symt_node *cases);

/* Insert switch symbol to a symbol node */
symt_node* symt_insert_switch(symt_var *iter_var, symt_node *cases);

/* Delete passed for symbol */
void symt_delete_switch(symt_switch *switch_val);

/* Copy passed for symbol into a new one at a new direction */
symt_switch *symt_copy_switch(symt_switch *switch_val);

#endif	// SYMT_SWITCH_H
