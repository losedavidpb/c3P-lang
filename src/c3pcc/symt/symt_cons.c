// symt_cons.c -*- C -*-
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
 *	ISO C99 Standard: Constant implementation for symt
 */

#include "../include/symt_cons.h"

#include "../include/f_reader.h"
#include "../include/assertb.h"
#include "../include/memlib.h"
#include "../include/arrcopy.h"
#include "../include/symt_type.h"
#include "../include/symt_node.h"
#include <math.h>
#include <ctype.h>

symt_cons *symt_new_cons(symt_cons_t type, symt_value_t value, symt_natural_t q_dir, symt_natural_t offset, bool is_param)
{
	symt_cons *constant = (symt_cons *)(ml_malloc(sizeof(symt_cons)));
	constant->value = symt_copy_value(value, type, 0);
	constant->q_dir = q_dir;
	constant->type = type;
	constant->offset = offset;
	constant->is_param = is_param;
	return constant;
}

symt_node* symt_insert_cons(symt_cons_t type, symt_value_t value, symt_natural_t q_dir, symt_natural_t offset, bool is_param)
{
	symt_cons *constant = symt_new_cons(type, value, q_dir, offset, is_param);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = CONSTANT;
	new_node->cons = constant;
	new_node->next_node = NULL;
	return new_node;
}

void symt_assign_cons(symt_cons *var, symt_value_t value)
{
	assertp(var != NULL, "passed constant has not been defined");
	var->value = symt_copy_value(value, var->type, 0);
}

symt_cons *symt_cons_add(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons = symt_strget_constype(type);
	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);

	assertf(num1->type == type, "type %s does not match %s for first operand", type_cons, type_cons_1);
	assertf(num2->type == type, "type %s does not match %s for first operand", type_cons, type_cons_2);

	symt_cons *result = symt_new_cons(type, NULL, 0, 0, false);

	int value1_int, value2_int, value_int;
	double value1_double, value2_double, value_double;
	char value1_char, value2_char, value_char;

	switch(type)
	{
		case CONS_INTEGER:
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = value1_int + value2_int;
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = value1_double + value2_double;
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = value1_char + value2_char;
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_sub(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons = symt_strget_constype(type);
	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);

	assertf(num1->type == type, "type %s does not match %s for first operand", type_cons, type_cons_1);
	assertf(num2->type == type, "type %s does not match %s for first operand", type_cons, type_cons_2);

	symt_cons *result = symt_new_cons(type, NULL, 0, 0, false);

	int value1_int, value2_int, value_int;
	double value1_double, value2_double, value_double;
	char value1_char, value2_char, value_char;

	switch(type)
	{
		case CONS_INTEGER:
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = value1_int - value2_int;
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = value1_double - value2_double;
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = value1_char - value2_char;
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_mult(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons = symt_strget_constype(type);
	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);

	assertf(num1->type == type, "type %s does not match %s for first operand", type_cons, type_cons_1);
	assertf(num2->type == type, "type %s does not match %s for first operand", type_cons, type_cons_2);

	symt_cons *result = symt_new_cons(type, NULL, 0, 0, false);

	int value1_int, value2_int, value_int;
	double value1_double, value2_double, value_double;
	char value1_char, value2_char, value_char;

	switch(type)
	{
		case CONS_INTEGER:
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = value1_int * value2_int;
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = value1_double * value2_double;
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = value1_char * value2_char;
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_div(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons = symt_strget_constype(type);
	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);

	assertf(num1->type == type, "type %s does not match %s for first operand", type_cons, type_cons_1);
	assertf(num2->type == type, "type %s does not match %s for first operand", type_cons, type_cons_2);

	symt_cons *result = symt_new_cons(type, NULL, 0, 0, false);

	int value1_int, value2_int, value_int;
	double value1_double, value2_double, value_double;
	char value1_char, value2_char, value_char;

	switch(type)
	{
		case CONS_INTEGER:
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = value1_int / value2_int;
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = value1_double / value2_double;
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = value1_char / value2_char;
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_mod(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons = symt_strget_constype(type);
	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);

	assertf(num1->type == type, "type %s does not match %s for first operand", type_cons, type_cons_1);
	assertf(num2->type == type, "type %s does not match %s for first operand", type_cons, type_cons_2);

	symt_cons *result = symt_new_cons(type, NULL, 0, 0, false);

	int value1_int, value2_int, value_int;
	double value1_double, value2_double, value_double;
	char value1_char, value2_char, value_char;

	switch(type)
	{
		case CONS_INTEGER:
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = (int)fmod((double)value1_int, (double)value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = fmod(value1_double, value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = (int)fmod((double)value1_char, (double)value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_pow(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons = symt_strget_constype(type);
	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);

	assertf(num1->type == type, "type %s does not match %s for first operand", type_cons, type_cons_1);
	assertf(num2->type == type, "type %s does not match %s for first operand", type_cons, type_cons_2);

	symt_cons *result = symt_new_cons(type, NULL, 0, 0, false);

	int value1_int, value2_int, value_int;
	double value1_double, value2_double, value_double;
	char value1_char, value2_char, value_char;

	switch(type)
	{
		case CONS_INTEGER:;
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = (int)pow((double)value1_int, (double)value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = pow(value1_double, value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = (int)pow((double)value1_char, (double)value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_gt(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);
	assertf(num1->type == num2->type, "type %s for first operand does match type %s for second operand", type_cons_1, type_cons_2);

	symt_cons *result = symt_new_cons(CONS_BOOL, NULL, 0, 0, false);

	int value1_int, value2_int, value_int, value_double, value_char;
	double value1_double, value2_double;
	char value1_char, value2_char;

	switch(num1->type)
	{
		case CONS_INTEGER:
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = symt_to_bool(value1_int > value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = symt_to_bool(value1_double > value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = symt_to_bool(value1_char > value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_lt(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);
	assertf(num1->type == num2->type, "type %s for first operand does match type %s for second operand", type_cons_1, type_cons_2);

	symt_cons *result = symt_new_cons(CONS_BOOL, NULL, 0, 0, false);

	int value1_int, value2_int, value_int, value_double, value_char;
	double value1_double, value2_double;
	char value1_char, value2_char;

	switch(num1->type)
	{
		case CONS_INTEGER:
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = symt_to_bool(value1_int < value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = symt_to_bool(value1_double < value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = symt_to_bool(value1_char < value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_eq(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);
	assertf(num1->type == num2->type, "type %s for first operand does match type %s for second operand", type_cons_1, type_cons_2);

	symt_cons *result = symt_new_cons(CONS_BOOL, NULL, 0, 0, false);

	int value1_int, value2_int, value_int, value_double, value_char;
	double value1_double, value2_double;
	char value1_char, value2_char;

	switch(num1->type)
	{
		case CONS_INTEGER:
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = symt_to_bool(value1_int == value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = symt_to_bool(value1_double == value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = symt_to_bool(value1_char == value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_neq(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);
	assertf(num1->type == num2->type, "type %s for first operand does match type %s for second operand", type_cons_1, type_cons_2);

	symt_cons *result = symt_new_cons(CONS_BOOL, NULL, 0, 0, false);

	int value1_int, value2_int, value_int, value_double, value_char;
	double value1_double, value2_double;
	char value1_char, value2_char;

	switch(num1->type)
	{
		case CONS_INTEGER:
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = symt_to_bool(value1_int != value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = symt_to_bool(value1_double != value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = symt_to_bool(value1_char != value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_leq(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);
	assertf(num1->type == num2->type, "type %s for first operand does match type %s for second operand", type_cons_1, type_cons_2);

	symt_cons *result = symt_new_cons(CONS_BOOL, NULL, 0, 0, false);

	int value1_int, value2_int, value_int, value_double, value_char;
	double value1_double, value2_double;
	char value1_char, value2_char;

	switch(num1->type)
	{
		case CONS_INTEGER:
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = symt_to_bool(value1_int <= value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = symt_to_bool(value1_double <= value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = symt_to_bool(value1_char <= value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_geq(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");

	char* type_cons_1 = symt_strget_constype(num1->type);
	char* type_cons_2 = symt_strget_constype(num2->type);
	assertf(num1->type == num2->type, "type %s for first operand does match type %s for second operand", type_cons_1, type_cons_2);

	symt_cons *result = symt_new_cons(CONS_BOOL, NULL, 0, 0, false);

	int value1_int, value2_int, value_int, value_double, value_char;
	double value1_double, value2_double;
	char value1_char, value2_char;

	switch(num1->type)
	{
		case CONS_INTEGER:;
			value1_int = *((int*)num1->value);
			value2_int = *((int*)num2->value);
			value_int = symt_to_bool(value1_int >= value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			value1_double = *((double*)num1->value);
			value2_double = *((double*)num2->value);
			value_double = symt_to_bool((int)(value1_double >= value2_double));
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			value1_char = *((char*)num1->value);
			value2_char = *((char*)num2->value);
			value_char = symt_to_bool(value1_char >= value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

void symt_delete_value_cons(symt_cons_t type, symt_value_t value)
{
	switch (type)
	{
		case CONS_INTEGER: ml_free(((int *)value)); 					break;
		case CONS_DOUBLE: ml_free(((double *)value)); 					break;
		case CONS_CHAR: ml_free(((char *)value)); 		break;
	}
}

void symt_delete_cons(symt_cons *cons)
{
	if (cons != NULL)
	{
		symt_delete_value_cons(cons->type, cons->value); cons->value = NULL;
		cons->type = (symt_cons_t)SYMT_NULL;
		ml_free(cons); cons = NULL;
	}
}

symt_cons *symt_copy_cons(symt_cons *cons)
{
	if (cons != NULL)
	{
		symt_cons *constant = (symt_cons *)(ml_malloc(sizeof(symt_cons)));
		constant->type = cons->type;
		constant->value = symt_copy_value(cons->value, cons->type, 0);
		constant->q_dir = cons->q_dir;
		constant->offset = cons->offset;
		constant->is_param = cons->is_param;
		return constant;
	}

	return NULL;
}
