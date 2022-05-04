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

void test_subcopy()
{
	const int test_num_elems = 10;
	const int start_dx = 0;
	const int end_dx = 5;

	int *test_int_src = (int *)(ml_malloc(test_num_elems * sizeof(int)));
	for (int i = 0; i < test_num_elems; i++) *(test_int_src + i) = i;

	bool *test_bool_src = (bool *)(ml_malloc(test_num_elems * sizeof(bool)));
	for (int i = 0; i < test_num_elems; i++) *(test_bool_src + i) = true;

	float *test_float_src = (float *)(ml_malloc(test_num_elems * sizeof(float)));
	for (int i = 0; i < test_num_elems; i++) *(test_float_src + i) = i;

	double *test_double_src = (double *)(ml_malloc(test_num_elems * sizeof(double)));
	for (int i = 0; i < test_num_elems; i++) *(test_double_src + i) = i;

	char *test_char_src = (char *)(ml_malloc(test_num_elems * sizeof(char)));
	test_char_src = strcat(test_char_src, "AAAAAAAAAA");

	test_assert("test_intsub");
	int *test_int_dest = intsub(test_int_src, start_dx, end_dx);
	for (int i = 0, j = start_dx; i < (end_dx - start_dx); i++, j++)
	{
		int dest_val = *(test_int_dest + i), src_val = *(test_int_src + j);
		assertf(dest_val == src_val, "%d must be equal to %d at %d", dest_val, src_val, i);
	}
	show_ok();

	test_assert("test_boolsub");
	bool *test_bool_dest = boolsub(test_bool_src, start_dx, end_dx);
	for (int i = 0, j = start_dx; i < (end_dx - start_dx); i++, j++)
	{
		bool dest_val = *(test_bool_dest + i), src_val = *(test_bool_src + j);
		assertf(dest_val == src_val, "%d must be equal to %d at %d", dest_val, src_val, i);
	}
	show_ok();

	test_assert("test_floatsub");
	float *test_float_dest = floatsub(test_float_src, start_dx, end_dx);
	for (int i = 0, j = start_dx; i < (end_dx - start_dx); i++, j++)
	{
		float dest_val = *(test_float_dest + i), src_val = *(test_float_src + j);
		assertf(dest_val == src_val, "%lf must be equal to %lf at %d", dest_val, src_val, i);
	}
	show_ok();

	test_assert("test_intsub");
	double *test_double_dest = doublesub(test_double_src, start_dx, end_dx);
	for (int i = 0, j = start_dx; i < (end_dx - start_dx); i++, j++)
	{
		double dest_val = *(test_double_dest + i), src_val = *(test_double_src + j);
		assertf(dest_val == src_val, "%lf must be equal to %lf at %d", dest_val, src_val, i);
	}
	show_ok();

	test_assert("test_charsub");
	char *test_char_dest = strsub(test_char_src, start_dx, end_dx);
	for (int i = 0, j = start_dx; i < (end_dx - start_dx); i++, j++)
	{
		char dest_val = *(test_char_dest + i), src_val = *(test_char_src + j);
		assertf(dest_val == src_val, "%c must be equal to %c at %d", dest_val, src_val, i);
	}
	show_ok();
}

int main(int nargc, char *argv[])
{
    test_welcome("arrcopy");
    test_copy();
	test_subcopy();
    return 0;
}
