/* Operations for constants stored at symbol tables */
#ifndef CONS_OP_H
#define CONS_OP_H

#include "symt.h"

/* Return a constant with the result of an addition */
symt_node *consop_add(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of an subtraction */
symt_node *consop_sub(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of an multiplication */
symt_node *consop_mult(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of an division */
symt_node *consop_div(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of an modular operation */
symt_node *consop_mod(symt_cons_t type, symt_cons* num1, symt_cons* num2);

/* Return a constant with the result of an pow operation */
symt_node *consop_pow(symt_cons_t type, symt_cons* num1, symt_cons* num2);

symt_node *consop_greater_than(symt_cons_t type, symt_cons* num1, symt_cons* num2);

symt_node *consop_less_than(symt_cons_t type, symt_cons* num1, symt_cons* num2);

symt_node *consop_equal_to(symt_cons_t type, symt_cons* num1, symt_cons* num2);

symt_node *consop_notequal_than(symt_cons_t type, symt_cons* num1, symt_cons* num2);

#endif	// CONS_OP_H
