#include "../../include/arrcopy.h"
#include "../../include/memlib.h"
#include "../../include/assertb.h"

#include <stdio.h>
#include <string.h>
#include <stdbool.h>

// Show main title for the list of unit tests
// that are going to be executed
#define test_welcome() \
    printf("\e[0;32mTEST \e[0m\e[0;34m::\e[0m \e[0;36mcopy\e[0m\n\e[0;35m==============================\e[0m\n")

// Show test's name at current terminal
#define test_name(message) \
    printf(" \e[0;33m*\e[0m \e[0;34mTest\e[0m \e[0;36m%s\e[0m\n", message)

// Show assert's message at current terminal
#define test_assert(message) \
    printf("    \e[0;33m>>\e[0m %s ............", message)

// Show a message that informs that current test
// has not errors at current assert
#define show_ok() \
    printf(" \e[0;32mOK\e[0m\n")

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
    test_welcome();
    test_copy();
    return 0;
}
