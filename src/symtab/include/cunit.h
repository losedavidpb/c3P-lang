/* Extension with utilities for unit tests at C */
#ifndef CUNIT_H
#define CUNIT_H

#include "assertb.h"

/* Print a message with main title for current tests
   stored at a test file that use CUnit */
#define test_welcome(test_file_name) \
    printf("\e[0;32mTEST \e[0m\e[0;34m::\e[0m \e[0;36m%s\e[0m\n\e[0;35m==============================\e[0m\n", test_file_name)

/* Print section name for current list of tests */
#define test_name(section_name) \
    printf(" \e[0;33m*\e[0m \e[0;34mTest\e[0m \e[0;36m%s\e[0m\n", section_name)

/* Print test line for current list of asserts */
#define test_assert(test_name) \
    printf("    \e[0;33m>>\e[0m %s ............", test_name)

/* Print OK message whether all tests has no errors */
#define show_ok() \
    printf(" \e[0;32mOK\e[0m\n")

/* Print FAIL message whether some tests has errors */
#define show_bad() \
    printf(" \e[0;31mFAIL\e[0m\n")

#endif	// CUNIT_H
