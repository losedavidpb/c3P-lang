#include "../../../include/symt_var.h"

#include "../../../include/assertb.h"
#include "../../../include/memlib.h"
#include "../../../include/arrcopy.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"
#include "../../../include/symt_cons.h"

symt_cons_t symt_get_type_data(symt_var_t type)
{
	switch (type)
	{
		case I8: case I16: case I32: case I64: return CONS_INTEGER; break;
		case F32: case F64: return CONS_DOUBLE; 					break;
		case C: return CONS_CHAR;									break;
		case B: return CONS_INTEGER;								break;
		case STR: return CONS_STR;									break;
		default: return (symt_cons_t)SYMT_ROOT_ID;					break;
	}
}

symt_var* symt_new_var(symt_name_t rout_name, symt_name_t name, symt_var_t type, bool is_array, size_t array_length, symt_value_t value, bool is_hide, bool is_param)
{
	symt_var *n_var = (symt_var *)(ml_malloc(sizeof(symt_var)));
	n_var->name = strcopy(name);
	n_var->rout_name = strcopy(name);
	n_var->type = type;

	if (type != B)
		n_var->value = symt_copy_value(value, symt_get_type_data(type), array_length);
	else if (value != NULL)
	{
		n_var->value = (bool*)(ml_malloc(sizeof(bool)));
		bool value_bool = symt_to_bool(*((int*)value));
		n_var->value = &value_bool;
	}

	n_var->is_array = is_array;
	n_var->array_length = array_length;
	n_var->is_hide = is_hide;
	n_var->is_param = is_param;
	return n_var;
}

symt_node* symt_insert_var(symt_name_t rout_name, symt_name_t name, symt_var_t type, bool is_array, size_t array_length, symt_value_t value, bool is_hide, bool is_param, symt_level_t level)
{
	symt_var *n_var = symt_new_var(rout_name, name, type, is_array, array_length, value, is_hide, is_param);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = VAR;
	new_node->var = n_var;
	new_node->level = level;
	new_node->next_node = NULL;
	return new_node;
}

void symt_can_assign(symt_var_t type, symt_cons *cons)
{
	assertp(cons != NULL, "passed constant has not be defined");
	assertp(cons->value != NULL, "constant has not a valid value");
	assertf(symt_get_type_data(type) == cons->type, "type does not match for assignation");

	int *int_value = NULL;
	double *double_value = NULL;

	switch(cons->type)
	{
		case CONS_INTEGER:
			int_value = (int*)cons->value;

			switch(type)
			{
				case I8: assertf(symt_check_range(*int_value, I8_MIN, I8_MAX), "passed value is not at range for %s", "i8"); 	 break;
				case I16: assertf(symt_check_range(*int_value, I16_MIN, I16_MAX), "passed value is not at range for %s", "i16"); break;
				case I32: assertf(symt_check_range(*int_value, I32_MIN, I32_MAX), "passed value is not at range for %s", "i32"); break;
				default: break;
			}
		break;

		case CONS_DOUBLE:
			double_value = (double*)cons->value;

			switch(type)
			{
				case F32: assertf(symt_check_range(*double_value, F32_MIN, F32_MAX), "passed value is not at range for %s", "f32"); break;
				case F64: assertf(symt_check_range(*double_value, F64_MIN, F64_MAX), "passed value is not at range for %s", "f64"); break;
				default: break;
			}
		break;

		default: break;	// Just to avoid warnings
	}
}

void symt_assign_var(symt_var *var, symt_cons *value)
{
	assertp(var != NULL, "variable has not been defined");
	assertp(value != NULL, "constant has not been defined");
	symt_can_assign(var->type, value);

	var->value = symt_copy_value(value->value, value->type, 0);
}

void symt_assign_var_at(symt_var *var, symt_cons *value, size_t index)
{
	assertp(var != NULL, "variable has not been defined");
	assertp(value != NULL, "constant has not been defined");
	symt_can_assign(var->type, value);

	int *int_value = NULL;
	double *double_value = NULL;
	char *char_value = NULL;

	switch(symt_get_type_data(var->type))
	{
		case CONS_INTEGER:
			int_value = (int*)var->value;
			*(int_value + index) = *((int*)value->value);
		break;

		case CONS_DOUBLE:
			double_value = (double*)var->value;
			*(double_value + index) = *((double*)value->value);
		break;

		case CONS_CHAR: case CONS_STR:
			char_value = (char*)var->value;
			*(char_value + index) = *((char*)value->value);
		break;

		default: break;
	}
}

void symt_delete_var(symt_var *var)
{
	if (var != NULL)
	{
		ml_free(var->name); var->name = NULL;
		ml_free(var->rout_name); var->rout_name = NULL;
		symt_cons_t var_type = symt_get_type_data(var->type);
		symt_delete_value_cons(var_type, var->value);
		var->type = (symt_var_t)SYMT_ROOT_ID;
		ml_free(var); var = NULL;
	}
}

symt_var *symt_copy_var(symt_var *var)
{
	if (var != NULL)
	{
		symt_var *n_var = (symt_var *)(ml_malloc(sizeof(symt_var)));
		n_var->name = strcopy(var->name);
		n_var->rout_name = strcopy(var->rout_name);
		n_var->type = var->type;
		n_var->value = symt_copy_value(var->value, symt_get_type_data(n_var->type), var->array_length);
		n_var->is_array = var->is_array;
		n_var->array_length = var->array_length;
		n_var->is_hide = var->is_hide;
		n_var->is_param = var->is_param;
		return n_var;
	}

	return NULL;
}
