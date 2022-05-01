#include "../include/consop.h"

#include "../include/memlib.h"
#include "../include/assertb.h"

#include <math.h>

void *__consop_get_value(symt_cons_t type, symt_cons* value)
{
	int *value_int = NULL;
	double *value_double = NULL;
	char *value_char = NULL;

	switch(value->type)
	{
		case INTEGER_:;
			value_int = (int*)value->value;
			if (value->type == type) return value_int;

			if (type == DOUBLE_)
			{
				value_double = (double*)ml_malloc(sizeof(double));
				*value_double = (double)(*(value_int));
				return value_double;
			}

			if (type == CHAR_)
			{
				value_char = (char*)ml_malloc(sizeof(char));
				*value_char = (char)(*(value_int));
				return value_char;
			}
		break;

		case DOUBLE_:;
			value_double = (double*)value->value;
			if (value->type == type) return value_double;

			if (type == INTEGER_)
			{
				value_int = (int*)ml_malloc(sizeof(int));
				*value_int = (int)(*(value_double));
				return value_int;
			}

			if (type == CHAR_)
			{
				value_char = (char*)ml_malloc(sizeof(char));
				*value_char = (char)(*(value_double));
				return value_char;
			}
		break;

		case CHAR_:;
			value_char = (char*)value->value;
			if (value->type == type) return value_char;

			if (type == INTEGER_)
			{
				value_int = (int*)ml_malloc(sizeof(int));
				*value_int = (int)(*(value_char));
				return value_int;
			}

			if (type == DOUBLE_)
			{
				value_double = (double*)ml_malloc(sizeof(double));
				*value_double = (double)(*(value_char));
				return value_double;
			}
		break;
	}

	return NULL;
}

symt_node *consop_add(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(type == INTEGER_ || type == DOUBLE_ || type == CHAR_, "passed type is invalid");

	assertp(num1 != NULL, "first operand must be not null");
	assertp(num1->type == INTEGER_ || num1->type == DOUBLE_ || num1->type == CHAR_, "passed type is invalid for first operand");
	assertp(num1->value != NULL, "first operand value must be not null");

	assertp(num2 != NULL, "second operand must be not null");
	assertp(num2->type == INTEGER_ || num2->type == DOUBLE_ || num2->type == CHAR_, "passed type is invalid for second operand");
	assertp(num2->value != NULL, "second operand value must be not null");

	symt_node *result = symt_new();

	switch(type)
	{
		case INTEGER_:;
			int value1_i = *((int*)__consop_get_value(type, num1));
			int value2_i = *((int*)__consop_get_value(type, num2));
			int* result_val_i = (int*)(ml_malloc(sizeof(int)));
			*result_val_i = value1_i + value2_i;
			result = symt_insert_const(result, type, result_val_i);
		break;

		case DOUBLE_:;
			double value1_d = *((double*)__consop_get_value(type, num1));
			double value2_d = *((double*)__consop_get_value(type, num2));
			double* result_val_d = (double*)(ml_malloc(sizeof(double)));
			*result_val_d = value1_d + value2_d;
			result = symt_insert_const(result, type, result_val_d);
		break;

		case CHAR_:;
			char value1_c = *((char*)__consop_get_value(type, num1));
			char value2_c = *((char*)__consop_get_value(type, num1));
			char* result_val_c = (char*)(ml_malloc(sizeof(char)));
			*result_val_c = value1_c + value2_c;
			result = symt_insert_const(result, type, result_val_c);
		break;
	}

	return result;
}

symt_node *consop_sub(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(type == INTEGER_ || type == DOUBLE_ || type == CHAR_, "passed type is invalid");

	assertp(num1 != NULL, "first operand must be not null");
	assertp(num1->type == INTEGER_ || num1->type == DOUBLE_ || num1->type == CHAR_, "passed type is invalid for first operand");
	assertp(num1->value != NULL, "first operand value must be not null");

	assertp(num2 != NULL, "second operand must be not null");
	assertp(num2->type == INTEGER_ || num2->type == DOUBLE_ || num2->type == CHAR_, "passed type is invalid for second operand");
	assertp(num2->value != NULL, "second operand value must be not null");

	symt_node *result = symt_new();

	switch(type)
	{
		case INTEGER_:;
			int value1_i = *((int*)__consop_get_value(type, num1));
			int value2_i = *((int*)__consop_get_value(type, num2));
			int* result_val_i = (int*)(ml_malloc(sizeof(int)));
			*result_val_i = value1_i - value2_i;
			result = symt_insert_const(result, type, result_val_i);
		break;

		case DOUBLE_:;
			double value1_d = *((double*)__consop_get_value(type, num1));
			double value2_d = *((double*)__consop_get_value(type, num2));
			double* result_val_d = (double*)(ml_malloc(sizeof(double)));
			*result_val_d = value1_d - value2_d;
			result = symt_insert_const(result, type, result_val_d);
		break;

		case CHAR_:;
			char value1_c = *((char*)__consop_get_value(type, num1));
			char value2_c = *((char*)__consop_get_value(type, num2));
			char* result_val_c = (char*)(ml_malloc(sizeof(char)));
			*result_val_c = value1_c - value2_c;
			result = symt_insert_const(result, type, result_val_c);
		break;
	}

	return result;
}

symt_node *consop_mult(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(type == INTEGER_ || type == DOUBLE_ || type == CHAR_, "passed type is invalid");

	assertp(num1 != NULL, "first operand must be not null");
	assertp(num1->type == INTEGER_ || num1->type == DOUBLE_ || num1->type == CHAR_, "passed type is invalid for first operand");
	assertp(num1->value != NULL, "first operand value must be not null");

	assertp(num2 != NULL, "second operand must be not null");
	assertp(num2->type == INTEGER_ || num2->type == DOUBLE_ || num2->type == CHAR_, "passed type is invalid for second operand");
	assertp(num2->value != NULL, "second operand value must be not null");

	symt_node *result = symt_new();

	switch(type)
	{
		case INTEGER_:;
			int value1_i = *((int*)__consop_get_value(type, num1));
			int value2_i = *((int*)__consop_get_value(type, num2));
			int* result_val_i = (int*)(ml_malloc(sizeof(int)));
			*result_val_i = value1_i * value2_i;
			result = symt_insert_const(result, type, result_val_i);
		break;

		case DOUBLE_:;
			double value1_d = *((double*)__consop_get_value(type, num1));
			double value2_d = *((double*)__consop_get_value(type, num2));
			double* result_val_d = (double*)(ml_malloc(sizeof(double)));
			*result_val_d = value1_d * value2_d;
			result = symt_insert_const(result, type, result_val_d);
		break;

		case CHAR_:;
			char value1_c = *((char*)__consop_get_value(type, num1));
			char value2_c = *((char*)__consop_get_value(type, num2));
			char* result_val_c = (char*)(ml_malloc(sizeof(char)));
			*result_val_c = value1_c * value2_c;
			result = symt_insert_const(result, type, result_val_c);
		break;
	}

	return result;
}

symt_node *consop_div(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(type == INTEGER_ || type == DOUBLE_ || type == CHAR_, "passed type is invalid");

	assertp(num1 != NULL, "first operand must be not null");
	assertp(num1->type == INTEGER_ || num1->type == DOUBLE_ || num1->type == CHAR_, "passed type is invalid for first operand");
	assertp(num1->value != NULL, "first operand value must be not null");

	assertp(num2 != NULL, "second operand must be not null");
	assertp(num2->type == INTEGER_ || num2->type == DOUBLE_ || num2->type == CHAR_, "passed type is invalid for second operand");
	assertp(num2->value != NULL, "second operand value must be not null");

	symt_node *result = symt_new();

	switch(type)
	{
		case INTEGER_:;
			int value1_i = *((int*)__consop_get_value(type, num1));
			int value2_i = *((int*)__consop_get_value(type, num2));
			int* result_val_i = (int*)(ml_malloc(sizeof(int)));
			*result_val_i = value1_i / value2_i;
			result = symt_insert_const(result, type, result_val_i);
		break;

		case DOUBLE_:;
			double value1_d = *((double*)__consop_get_value(type, num1));
			double value2_d = *((double*)__consop_get_value(type, num2));
			double* result_val_d = (double*)(ml_malloc(sizeof(double)));
			*result_val_d = value1_d / value2_d;
			result = symt_insert_const(result, type, result_val_d);
		break;

		case CHAR_:;
			char value1_c = *((char*)__consop_get_value(type, num1));
			char value2_c = *((char*)__consop_get_value(type, num2));
			char* result_val_c = (char*)(ml_malloc(sizeof(char)));
			*result_val_c = value1_c / value2_c;
			result = symt_insert_const(result, type, result_val_c);
		break;
	}

	return result;
}

symt_node *consop_mod(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(type == INTEGER_ || type == DOUBLE_ || type == CHAR_, "passed type is invalid");

	assertp(num1 != NULL, "first operand must be not null");
	assertp(num1->type == INTEGER_ || num1->type == DOUBLE_ || num1->type == CHAR_, "passed type is invalid for first operand");
	assertp(num1->value != NULL, "first operand value must be not null");

	assertp(num2 != NULL, "second operand must be not null");
	assertp(num2->type == INTEGER_ || num2->type == DOUBLE_ || num2->type == CHAR_, "passed type is invalid for second operand");
	assertp(num2->value != NULL, "second operand value must be not null");

	symt_node *result = symt_new();

	switch(type)
	{
		case INTEGER_:;
			int value1_i = *((int*)__consop_get_value(type, num1));
			int value2_i = *((int*)__consop_get_value(type, num2));
			int* result_val_i = (int*)(ml_malloc(sizeof(int)));
			*result_val_i = (int)fmod((double)value1_i, (double)value1_i);
			result = symt_insert_const(result, type, result_val_i);
		break;

		case DOUBLE_:;
			double value1_d = *((double*)__consop_get_value(type, num1));
			double value2_d = *((double*)__consop_get_value(type, num2));
			double* result_val_d = (double*)(ml_malloc(sizeof(double)));
			*result_val_d = (int)fmod((double)value1_d, (double)value1_d);
			result = symt_insert_const(result, type, result_val_d);
		break;

		case CHAR_:;
			char value1_c = *((char*)__consop_get_value(type, num1));
			char value2_c = *((char*)__consop_get_value(type, num2));
			char* result_val_c = (char*)(ml_malloc(sizeof(char)));
			*result_val_c = (int)fmod((double)value1_c, (double)value1_c);
			result = symt_insert_const(result, type, result_val_c);
		break;
	}

	return result;
}

symt_node *consop_pow(symt_cons_t type, symt_cons* num1, symt_cons* num2)
{
	assertp(type == INTEGER_ || type == DOUBLE_ || type == CHAR_, "passed type is invalid");

	assertp(num1 != NULL, "first operand must be not null");
	assertp(num1->type == INTEGER_ || num1->type == DOUBLE_ || num1->type == CHAR_, "passed type is invalid for first operand");
	assertp(num1->value != NULL, "first operand value must be not null");

	assertp(num2 != NULL, "second operand must be not null");
	assertp(num2->type == INTEGER_ || num2->type == DOUBLE_ || num2->type == CHAR_, "passed type is invalid for second operand");
	assertp(num2->value != NULL, "second operand value must be not null");

	symt_node *result = symt_new();

	switch(type)
	{
		case INTEGER_:;
			int value1_i = *((int*)__consop_get_value(type, num1));
			int value2_i = *((int*)__consop_get_value(type, num2));
			int* result_val_i = (int*)(ml_malloc(sizeof(int)));
			*result_val_i = (int)pow((double)value1_i, (double)value2_i);
			result = symt_insert_const(result, type, result_val_i);
		break;

		case DOUBLE_:;
			double value1_d = *((double*)__consop_get_value(type, num1));
			double value2_d = *((double*)__consop_get_value(type, num2));
			double* result_val_d = (double*)(ml_malloc(sizeof(double)));
			*result_val_d = (int)pow((double)value1_d, (double)value2_d);
			result = symt_insert_const(result, type, result_val_d);
		break;

		case CHAR_:;
			char value1_c = *((char*)__consop_get_value(type, num1));
			char value2_c = *((char*)__consop_get_value(type, num2));
			char* result_val_c = (char*)(ml_malloc(sizeof(char)));
			*result_val_c = (int)pow((double)value1_c, (double)value2_c);
			result = symt_insert_const(result, type, result_val_c);
		break;
	}

	return result;
}
