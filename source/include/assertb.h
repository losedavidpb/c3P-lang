// assertb.h -*- C -*-
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
 *	ISO C99 Standard: Expansion of assert for beautiful style
 */

#ifndef ASSERT_B_H
#define ASSERT_B_H

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <assert.h>
#include <stddef.h>
#include "f_reader.h"

// Uncomment this to enable error messages for testing.
// This flag would only be used during development phase.
//#ifndef DEV_MODE
//#define DEV_MODE
//#endif DEV_MODE

#ifdef DEV_MODE
	/* Default value of errno that defines
	   that if has no errors */
	#define NO_ERROR 0

	/* Refresh value of errno so if there's no errors,
	   it will be defined as "None" */
	#define clean_errno() errno == NO_ERROR? "None" : strerror(errno)

	/* Print an error message to store as a log format */
	#define log_error(M, ...) 																	\
		fprintf(stderr, "\033[0;31m[ERROR]\033[0m \033[1m(%s:%d: errno: %s):\033[0m " M "\n", 	\
			__FILE__, __LINE__, clean_errno(), ##__VA_ARGS__)

	/* Assert a condition and print an error message if it fails.
	   It is possible to define variables to define the format as printf */
	#define assertf(A, M, ...) if (!(A)) { log_error(M, ##__VA_ARGS__); assert(A); }

	/* Assert a condition and print an error message if it fails.
	   It is not possible to define variables to define the format as printf */
	#define assertp(A, M) if (!(A)) { log_error(M); assert(A); }
#else
	/* Print an error message to store as a log format */
	#define log_error(M, ...) 																	\
		fprintf(stderr, "\033[0;31merror:\033[0m \033[1m%s\033[0m: " M ", error at line %d\n", 	\
			reader.file, ##__VA_ARGS__, reader.num_line - 1);

	/* Assert a condition and print an error message if it fails.
	   It is possible to define variables to define the format as printf */
	#define assertf(A, M, ...) if (!(A)) { log_error(M, ##__VA_ARGS__); /*assert(A);*/ exit(1); }

	/* Assert a condition and print an error message if it fails.
	   It is not possible to define variables to define the format as printf */
	#define assertp(A, M) if (!(A)) { log_error(M); /*assert(A);*/ exit(1); }

	/* Print passed error message to current screen and exit program */
	#define show_errorf(M, ...) if (1) { log_error(M, ##__VA_ARGS__); exit(1); }

	/* Print passed error message to current screen and exit program */
	#define show_errorp(M) if (1) { log_error(M); exit(1); }
#endif

#endif  // ASSERT_B_H
