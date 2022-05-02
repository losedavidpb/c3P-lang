/* Utilities to manage a procedure or function */
#ifndef SYMT_ROUT_H
#define SYMT_ROUT_H

#include "symt_type.h"

/* Create a routine symbol */
symt_rout* symt_new_rout(symt_id_t id, symt_name_t name, symt_var_t type, symt_node *params, bool is_hide/*, symt_node *statements*/);

/* Insert routine symbol to a symbol node */
symt_node* symt_insert_rout(symt_id_t id, symt_name_t name, symt_var_t type, symt_node *params, bool is_hide/*,symt_node *statements*/);

/* Delete passed routine symbol */
void symt_delete_rout(symt_rout *rout);

/* Copy passed routine into a new one at a new direction */
symt_rout *symt_copy_rout(symt_rout *rout);

#endif	// SYMT_ROUT_H
