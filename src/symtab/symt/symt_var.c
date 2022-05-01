#include "../../../include/symt_routine.h"

#include "../../../include/assertb.h"
#include "../../../include/memlib.h"
#include "../../../include/arrcopy.h"
#include "../../../include/symt_type.h"
#include "../../../include/symt_node.h"
#include "../../../include/symt_cons.h"
#include <stdlib.h>
#include <string.h>

symt_cons_t symt_get_type_data(symt_var_t type)
{
	switch (type)
	{
		case I8: case I16: case I32: case I64: return CONS_INTEGER; break;
		case F32: case F64: return CONS_DOUBLE; 					break;
		case C: return CONS_CHAR;									break;
		case B: return CONS_INTEGER;								break;
		default: return -1;										break;
	}
}

symt_var* symt_new_var(symt_id_t id, symt_name_t name, symt_var_t type, bool is_array, int array_length, symt_value_t value, bool is_hide)
{
	symt_var *n_var = (symt_var *)(ml_malloc(sizeof(symt_var)));
	n_var->name = strdup(name);
	n_var->type = type;
	n_var->value = symt_copy_value(value, symt_get_type_data(type), array_length);
	n_var->is_array = is_array;
	n_var->array_length = array_length;
	n_var->is_hide = is_hide;
	return n_var;
}

symt_node* symt_insert_var(symt_id_t id, symt_name_t name, symt_var_t type, bool is_array, int array_length, symt_value_t value, bool is_hide)
{
	symt_var *n_var = symt_new_var(id, name, type, is_array, array_length, value, is_hide);

	symt_node *new_node = (symt_node *)(ml_malloc(sizeof(symt_node)));
	new_node->id = id;
	new_node->var = n_var;
	new_node->next_node = NULL;
	return new_node;
}

void symt_can_assign(symt_var_t type, symt_value_t value, symt_cons *cons)
{
	assertp(cons != NULL, "passed constant has not be defined");
	assertp(cons->value != NULL, "constant has not a valid value");
	assertf(symt_get_type_data(type) == cons->type, "type does not match for assignation");

	switch(cons->type)
	{
		case CONS_INTEGER:;
			int *int_value = (int*)cons->value;

			switch(type)
			{
				case I8: assertf(symt_check_range(*int_value, I8_MIN, I8_MAX), "passed value is not at range for %s", "i8"); break;
				case I16: assertf(symt_check_range(*int_value, I16_MIN, I16_MAX), "passed value is not at range for %s", "i16"); break;
				case I32: assertf(symt_check_range(*int_value, I32_MIN, I32_MAX), "passed value is not at range for %s", "i32"); break;
				default: break;
			}
		break;

		case CONS_DOUBLE:;
			double *double_value = (double*)cons->value;

			switch(type)
			{
				case F32: assertf(symt_check_range(*double_value, F32_MIN, F32_MAX), "passed value is not at range for %s", "f32"); break;
				case F64: assertf(symt_check_range(*double_value, F64_MIN, F64_MAX), "passed value is not at range for %s", "f64"); break;
				default: break;
			}
		break;

		default: break;
	}
}

void symt_assign_var(symt_var *var, symt_cons *value);

void symt_assign_var_at(symt_var *, symt_cons *value, int index);

void symt_delete_var(symt_var *var)
{
	if (var != NULL)
	{
		ml_free(var->name);
		var->name = NULL;
		symt_cons_t var_type = symt_get_type_data(var->type);
		symt_delete_value_cons(var_type, var->value);
		var->value = NULL;
		var->type = SYMT_ROOT_ID;
		ml_free(var);
		var = NULL;
	}
}

symt_var *symt_copy_var(symt_var *var)
{
	symt_var *n_var = (symt_var *)(ml_malloc(sizeof(symt_var)));
	n_var->name = strdup(var->name);
	n_var->type = var->type;
	n_var->value = symt_copy_value(var->value, symt_get_type_data(n_var->type), var->array_length);
	n_var->is_array = var->is_array;
	n_var->array_length = var->array_length;
	n_var->is_hide = var->is_hide;
	return n_var;
}
