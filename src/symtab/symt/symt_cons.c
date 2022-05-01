#include "../../../include/symt_cons.h"

#include "../../../include/assertb.h"
#include "../../../include/memlib.h"
#include "../../../include/arrcopy.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include <stdbool.h>

#define to_bool(num) num != 1? false : true

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

void symt_assign_cons(symt_cons *var, symt_value_t value)
{
	assertp(var != NULL, "passed constant has not been defined");
	var->value = value;
}

symt_cons *symt_cons_add(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num1->type));
	assertf(num2->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(type, NULL);

	switch(type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = value1_int + value2_int;
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			double value_double = value1_double + value2_double;
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			char value_char = value1_char + value2_char;
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_sub(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num1->type));
	assertf(num2->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(type, NULL);

	switch(type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = value1_int - value2_int;
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			double value_double = value1_double - value2_double;
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			char value_char = value1_char - value2_char;
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_mult(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num1->type));
	assertf(num2->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(type, NULL);

	switch(type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = value1_int * value2_int;
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			double value_double = value1_double * value2_double;
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			char value_char = value1_char * value2_char;
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_div(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num1->type));
	assertf(num2->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(type, NULL);

	switch(type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = value1_int / value2_int;
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			double value_double = value1_double / value2_double;
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			char value_char = value1_char / value2_char;
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_mod(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num1->type));
	assertf(num2->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(type, NULL);

	switch(type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = (int)fmod((double)value1_int, (double)value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			double value_double = fmod(value1_double, value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			char value_char = (int)fmod((double)value1_char, (double)value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_pow(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num1->type));
	assertf(num2->type == type, "type %s does not match %s for first operand", symt_strget_constype(type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(type, NULL);

	switch(type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = (int)pow((double)value1_int, (double)value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			double value_double = pow(value1_double, value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			char value_char = (int)pow((double)value1_char, (double)value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_gt(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == num2->type, "type %s does not match %s for first operand", symt_strget_constype(num1->type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(CONS_INTEGER, NULL);

	switch(num1->type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = to_bool(value1_int > value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			int value_double = to_bool(value1_double > value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			int value_char = to_bool(value1_char > value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_lt(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == num2->type, "type %s does not match %s for first operand", symt_strget_constype(num1->type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(CONS_INTEGER, NULL);

	switch(num1->type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = to_bool(value1_int < value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			int value_double = to_bool(value1_double < value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			int value_char = to_bool(value1_char < value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_eq(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == num2->type, "type %s does not match %s for first operand", symt_strget_constype(num1->type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(CONS_INTEGER, NULL);

	switch(num1->type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = to_bool(value1_int == value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			int value_double = to_bool(value1_double == value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			int value_char = to_bool(value1_char == value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_neq(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == num2->type, "type %s does not match %s for first operand", symt_strget_constype(num1->type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(CONS_INTEGER, NULL);

	switch(num1->type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = to_bool(value1_int != value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			int value_double = to_bool(value1_double != value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			int value_char = to_bool(value1_char != value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_leq(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == num2->type, "type %s does not match %s for first operand", symt_strget_constype(num1->type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(CONS_INTEGER, NULL);

	switch(num1->type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = to_bool(value1_int <= value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			int value_double = to_bool(value1_double <= value2_double);
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			int value_char = to_bool(value1_char <= value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

symt_cons *symt_cons_geq(symt_cons* num1, symt_cons* num2)
{
	assertp(num1 != NULL, "first operand has not be defined");
	assertp(num2 != NULL, "first operand has not be defined");
	assertf(num1->type == num2->type, "type %s does not match %s for first operand", symt_strget_constype(num1->type), symt_strget_constype(num2->type));

	symt_cons *result = symt_new_cons(CONS_INTEGER, NULL);

	switch(num1->type)
	{
		case CONS_INTEGER:;
			int value1_int = *((int*)num1->value);
			int value2_int = *((int*)num2->value);
			int value_int = to_bool(value1_int >= value2_int);
			symt_assign_cons(result, &value_int);
		break;

		case CONS_DOUBLE:;
			double value1_double = *((double*)num1->value);
			double value2_double = *((double*)num2->value);
			int value_double = to_bool((int)(value1_double >= value2_double));
			symt_assign_cons(result, &value_double);
		break;

		case CONS_CHAR:;
			char value1_char = *((char*)num1->value);
			char value2_char = *((char*)num2->value);
			int value_char = to_bool(value1_char >= value2_char);
			symt_assign_cons(result, &value_char);
		break;
	}

	return result;
}

void symt_delete_value_cons(symt_cons_t type, symt_value_t value)
{
	switch (type)
	{
		case CONS_INTEGER: ml_free(((int *)value)); 	break;
		case CONS_DOUBLE: ml_free(((double *)value)); 	break;
		case CONS_CHAR: ml_free(((char *)value)); 		break;
	}
}

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
