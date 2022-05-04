/* Expansion of assert for beautiful style */
#ifndef ASSERT_B_H
#define ASSERT_B_H

/* Uncomment this flag whether assertb would be used
   at a Flex scanner for end users */
#define FLEX_ENABLE

/* Uncomment this flag whether assertb would be used
   at a Bison parser for end users */
#define BISON_ENABLE

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <assert.h>
#include <stddef.h>

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

/* Assert a condition and print an error message if it fails with no exit.
   It is possible to define variables to define the format as printf */
#define assertf_no_exit(A, M, ...) if (!(A)) { log_error(M, ##__VA_ARGS__); }

/* Assert a condition and print an error message if it fails.
   It is not possible to define variables to define the format as printf */
#define assertp(A, M) if (!(A)) { log_error(M); assert(A); }

/* Assert a condition and print an error message if it fails with no exit.
   It is not possible to define variables to define the format as printf */
#define assertp_no_exit(A, M) if (!(A)) { log_error(M); }

/* Print passed error message to current screen and exit program */
#define show_error(M, ...) if (1) { log_error(M, ##__VA_ARGS__); exit(1); }

/* Print passed error message to current screen */
#define show_error_no_exit(M, ...) log_error(M, ##__VA_ARGS__)

/* Utilities for Bison and Flex */
#ifdef FLEX_ENABLE
	#ifdef BISON_ENABLE
		/* Assert a condition and print an error message if it fails for Flex/Bison.
   		   It is not possible to define variables to define the format as printf */
		#define fyassertp(cond, m_name, message, n_line) \
			if (!(cond)) { fyerrorp(m_name, message, n_line); assert(cond); }

		/* Assert a condition and print an error message if it fails for Flex/Bison.
   		   It is not possible to define variables to define the format as printf */
		#define fyassertf(cond, m_name, format, n_line, ...) \
			if (!(cond)) { fyerrorf(m_name, format, n_line, ##__VA_ARGS__); assert(cond); }

		/* Print Flex/Bison error for current c3P file */
		#define fyerrorp(m_name, message, n_line)	\
			if (1) { fprintf(stderr, "%s: %s at line %d\n", m_name, message, n_line); exit(1); }

		/* Print Flex/Bison error for current c3P file */
		#define fyerrorf(m_name, format, n_line, ...)	\
			if (1) { fprintf(stderr, "%s: " format "at line %d\n", m_name, n_line, ##__VA_ARGS__); exit(1); }
	#else
		/* Assert a condition and print an error message if it fails for Flex.
   		   It is not possible to define variables to define the format as printf */
		#define fyassert(cond, message, n_line) \
			if (!(cond)) { fyerror(message, n_line); assert(cond); }

		/* Print Flex error for current c3P file */
		#define fyerror(message, n_line)	\
			if (1) { fprintf(stderr, "flex: %s at line %d\n", m_name, message, n_line); exit(1); }
	#endif
#else
	#ifdef BISON_ENABLE
		/* Assert a condition and print an error message if it fails for Bison.
   		   It is not possible to define variables to define the format as printf */
		#define fyassert(cond, message, n_line) \
			if (!(cond)) { fyerror(message, n_line); assert(cond); }

		/* Print Bison error for current c3P file */
		#define fyerror(message, n_line)	\
			if (1) { fprintf(stderr, "bison: %s at line %d\n", m_name, message, n_line); exit(1); }
	#endif
#endif

#endif  // ASSERT_B_H
