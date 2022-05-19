/* Utilities to manage a constant */
#ifndef SYMT_CONS_H
#define SYMT_CONS_H

#include "symt_type.h"
#include <ctype.h>
#include <math.h>

/* Get string representation for constant types */
#define symt_strget_constype(type)					\
	(type == CONS_INTEGER? "integer" :				\
	(type == CONS_DOUBLE? "double" :				\
	(type == CONS_STR? "string" :					\
	(type == CONS_CHAR? "char" : "undefined"))))

/* Create a new constant symbol */
symt_cons *symt_new_cons(symt_cons_t type, symt_value_t value, int q_direction);

/* Insert const symbol to a symbol node */
symt_node* symt_insert_cons(symt_cons_t type, symt_value_t value, int q_direction);

/* Assign value at passed constant */
void symt_assign_cons(symt_cons *var, symt_value_t value);

/* Return a constant with the result of the addition */
symt_cons *symt_cons_add(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of the subtraction */
symt_cons *symt_cons_sub(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of the multiplication */
symt_cons *symt_cons_mult(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of the division */
symt_cons *symt_cons_div(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of the modular operation */
symt_cons *symt_cons_mod(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of the pow operation */
symt_cons *symt_cons_pow(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of greater than operation*/
symt_cons *symt_cons_gt(symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of less than operation*/
symt_cons *symt_cons_lt(symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of equal to operation*/
symt_cons *symt_cons_eq(symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of not equal to operation*/
symt_cons *symt_cons_neq(symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of less or equal to operation*/
symt_cons *symt_cons_leq(symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of greater or equal to operation*/
symt_cons *symt_cons_geq(symt_cons* num1, symt_cons* num2);

/* Delete passed value of a constant of passed type */
void symt_delete_value_cons(symt_cons_t type, symt_value_t value);

/* Delete passed constant symbol */
void symt_delete_cons(symt_cons *cons);

/* Copy passed constant into a new one at a new direction */
symt_cons *symt_copy_cons(symt_cons *cons);

#endif	// SYMT_CONS_H
