/* Expansion of assert for beautiful style */
#ifndef ASSERT_B_H
#define ASSERT_B_H

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

/* Default value of errno that defines
   that if has no errors */
#define NO_ERROR 0

/* Refresh value of errno so if there's no errors,
   it will be defined as "None" */
#define clean_errno() errno == NO_ERROR? "None" : strerror(errno)

/* Print an error message to store as a log format */
#define log_error(M, ...) fprintf(stderr, "\e[0;31m[ERROR]\e[0m \e[1m(%s:%d: errno: %s):\e[0m " M "\n", __FILE__, __LINE__, clean_errno(), ##__VA_ARGS__)

/* Assert a condition and print an error message if it fails.
   It is possible to define variables to define the format as printf */
#define assertf(A, M, ...) if (!(A)) { log_error(M, ##__VA_ARGS__); assert(A); }

/* Assert a condition and print an error message if it fails with no exit.
   It is possible to define variables to define the format as printf */
#define assertf_no_exit(A, M, ...) if (!(A)) { log_error(M, ##__VA_ARGS__); }

/* Assert a condition and print an error message if it fails.
   It is not possible to define variables to define the format as printf */
#define assertp(A, M) if (!(A)) { log_error(M); assert(A); }

/* Assert a condition and print an error message if it fails with no exit.
   It is not possible to define variables to define the format as printf */
#define assertp_no_exit(A, M) if (!(A)) { log_error(M); }

#endif  // ASSERT_B_H