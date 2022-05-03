#include "../../../../include/arrcopy.h"
#include "../../../../include/memlib.h"
#include "../../../../include/cunit.h"
#include <string.h>
#include <stdbool.h>

void test_copy()
{
	int *test_int_src, *copy_int_val;
	bool *test_bool_src, *copy_bool_val;
	float *test_float_src, *copy_float_val;
	double *test_double_src, *copy_double_val;
	char *test_char_src, *copy_char_val;
	int test_num_elems;

	test_num_elems = 10;
	test_int_src = (int*)(ml_malloc(test_num_elems * sizeof(int)));
	for (int i = 0; i < test_num_elems; i++) *(test_int_src + i) = i;

	test_assert("test_intcopy");
	copy_int_val = intcopy(test_int_src, test_num_elems);

	for (int i = 0; i < test_num_elems; i++)
	{
		int cond = *(test_int_src + i) == *(copy_int_val + i);
		assertf(cond, "array not equal at %d", i);
	}

	show_ok();

	test_num_elems = 10;
	test_bool_src = (bool*)(ml_malloc(test_num_elems * sizeof(bool)));
	for (int i = 0; i < test_num_elems; i++) *(test_bool_src + i) = i;

	test_assert("test_boolcopy");
	copy_bool_val = boolcopy(test_bool_src, test_num_elems);

	for (int i = 0; i < test_num_elems; i++)
	{
		int cond = *(test_bool_src + i) == *(copy_bool_val + i);
		assertf(cond, "array not equal at %d", i);
	}

	show_ok();

	test_num_elems = 10;
	test_float_src = (float*)(ml_malloc(test_num_elems * sizeof(float)));
	for (int i = 0; i < test_num_elems; i++) *(test_float_src + i) = i;

	test_assert("test_floatcopy");
	copy_float_val = floatcopy(test_float_src, test_num_elems);

	for (int i = 0; i < test_num_elems; i++)
	{
		int cond = *(test_float_src + i) == *(copy_float_val + i);
		assertf(cond, "array not equal at %d", i);
	}

	show_ok();

	test_num_elems = 10;
	test_double_src = (double*)(ml_malloc(test_num_elems * sizeof(double)));
	for (int i = 0; i < test_num_elems; i++) *(test_double_src + i) = i;

	test_assert("test_doublecopy");
	copy_double_val = doublecopy(test_double_src, test_num_elems);

	for (int i = 0; i < test_num_elems; i++)
	{
		int cond = *(test_double_src + i) == *(copy_double_val + i);
		assertf(cond, "array not equal at %d", i);
	}

	show_ok();

	test_num_elems = 10;
	test_char_src = (char*)(ml_malloc(test_num_elems * sizeof(char)));
	strcat(test_char_src, "aaaaaaaaaa");

	test_assert("test_strcopy");
	copy_char_val = strcopy(test_char_src);

	for (int i = 0; i < test_num_elems; i++)
	{
		int cond = *(test_char_src + i) == *(copy_char_val + i);
		assertf(cond, "array not equal at %d", i);
	}

	show_ok();
}

int main(int nargc, char *argv[])
{
    test_welcome("arrcopy");
    test_copy();
    return 0;
}
