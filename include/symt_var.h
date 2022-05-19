/* Utilities to manage a local or global variable */
#ifndef SYMT_VAR_H
#define SYMT_VAR_H

#include "symt_type.h"
#include "symt_cons.h"
#include <stddef.h>
#include <stdbool.h>

/* Get string representation for variable types */
#define symt_strget_vartype(type)				\
	(type == I8? "i8" :							\
	(type == I16? "i16" :						\
	(type == I32? "i32" :						\
	(type == I64? "i64" :						\
	(type == F32? "f32" :						\
	(type == F64? "f64" :						\
	(type == C? "c" :							\
	(type == STR? "str" :						\
	(type == B? "b" : "undefined")))))))))

/* Create a new variable symbol */
symt_var* symt_new_var(symt_name_t name, symt_name_t rout_name, symt_var_t type, bool is_array, size_t array_length, symt_value_t value, bool is_param);

/* Insert var symbol to a node */
symt_node* symt_insert_var(symt_name_t name, symt_name_t rout_name, symt_var_t type, bool is_array, size_t array_length, symt_value_t value, bool is_param, symt_level_t level);

/* Check if passed constant could be assigned to the variable */
void symt_can_assign(symt_var_t type, symt_cons *cons);

/* Assign value of passed constant at variable whether it is not an array */
void symt_assign_var(symt_var *var, symt_cons *value);

/* Assign value of passed constant at variable index whether it is an array */
void symt_assign_var_at(symt_var *var, symt_cons *value, size_t index);

/* Get the constant type for passed variable type */
symt_cons_t symt_get_type_data(symt_var_t type);

/* Delete passed variable symbol */
void symt_delete_var(symt_var *var);

/* Copy passed variable into a new one at a new direction */
symt_var *symt_copy_var(symt_var *var);

#endif	// STMT_VAR_H
