/* Utilities to manage a symbol node */
#ifndef SYMT_NODE_H
#define SYMT_NODE_H

#include "symt_type.h"

/* Get string representation for identifiers */
#define symt_strget_id(id)							\
	(id == LOCAL_VAR? "LOCAL_VAR" :					\
	(id == GLOBAL_VAR? "GLOBAL_VAR" :				\
	(id == IF? "IF" :								\
	(id == WHILE? "WHILE" :							\
	(id == FUNCTION? "FUNCTION" :					\
	(id == PROCEDURE? "PROCEDURE" :					\
	(id == CONSTANT? "CONSTANT" : 					\
	(id == CALL_FUNC? "CALL" : "undefined"))))))))

/* Create dynamically a new symbol node */
symt_node* symt_new_node();

/* Check if passed identifier is valid */
bool symt_is_valid_id(symt_id_t id);

/* Get the value of passed node whether that field exists */
symt_value_t symt_get_value_from_node(symt_node *node);

/* Get the primitive type for passed node */
symt_cons_t symt_get_type_value_from_node(symt_node *node);

/* Print value for passed node */
void symt_printf_value(symt_node* node);

/* Copy passed value into a new reference */
symt_value_t symt_copy_value(symt_value_t value, symt_cons_t type, size_t num_elems);

/* Clean from memory passed symbol node
   if has been created before */
void symt_delete_node(symt_node *node);

/* Copy passed node into a new one at a new direction */
symt_node *symt_copy_node(symt_node *node);

#endif	// SYMT_NODE_H
