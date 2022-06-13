// symt_rout.h -*- C -*-
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
 *	ISO C99 Standard: Utilities to manage a procedure or function
 */

#ifndef SYMT_ROUT_H
#define SYMT_ROUT_H

#include "symt_type.h"

/* Create a routine symbol */
symt_rout* symt_new_rout(symt_id_t id, symt_name_t name, symt_var_t type, symt_natural_t label);

/* Insert routine symbol to a symbol node */
symt_node* symt_insert_rout(symt_id_t id, symt_name_t name, symt_var_t type, symt_natural_t level, symt_natural_t label);

/* Delete passed routine symbol */
void symt_delete_rout(symt_rout *rout);

/* Copy passed routine into a new one at a new direction */
symt_rout *symt_copy_rout(symt_rout *rout);

#endif	// SYMT_ROUT_H
