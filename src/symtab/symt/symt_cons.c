#include "../../../include/symt_routine.h"

#include "../../../include/memlib.h"
#include "../../../include/arrcopy.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"
#include <stdlib.h>
#include <string.h>

symt_cons *symt_new_cons(symt_cons_t type, symt_value_t value)
{
	symt_cons *constant = (symt_cons *)(ml_malloc(sizeof(symt_cons)));
	constant->type = type;
	constant->value = symt_copy_value(value, type, 0);
	return constant;
}

symt_node* symt_insert_cons(symt_cons_t type, symt_value_t value)
{
	symt_cons *constant = symt_new_cons(type, value);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = CONSTANT;
	new_node->cons = constant;
	new_node->next_node = NULL;
	return new_node;
}

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
symt_cons *symt_cons_gt(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of less than operation*/
symt_cons *symt_cons_lt(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of equal to operation*/
symt_cons *symt_cons_eq(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of not equal to operation*/
symt_cons *symt_cons_neq(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of less or equal to operation*/
symt_cons *symt_cons_leq(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of greater or equal to operation*/
symt_cons *symt_cons_geq(symt_cons_t type, symt_cons* num1, symt_cons* num2);

void symt_delete_cons(symt_cons *cons)
{
	if (cons != NULL)
	{
		symt_delete_value_cons(cons->type, cons->value);
		cons->value = NULL;
		cons->type = SYMT_ROOT_ID;
		ml_free(cons);
		cons = NULL;
	}
}

symt_cons *symt_copy_cons(symt_cons *cons)
{
	symt_cons *constant = (symt_cons *)(ml_malloc(sizeof(symt_cons)));
	constant->type = cons->type;
	constant->value = symt_copy_value(cons->value, cons->type, 0);
	return constant;
}
