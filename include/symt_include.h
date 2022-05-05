/* Utilities for imports */
#ifndef SYMT_INCLUDE_H
#define SYMT_INCLUDE_H

#include "symt_type.h"

/* List of includes to avoid cyclic imports */
typedef struct symt_include_t
{
	symt_name_t* list_add;
	int num_elems, capacity;
} symt_include_t;

/* Get the directory path of passed path */
symt_name_t symt_include_get_dir_path(symt_name_t path);

/* Return the string representation of a library path */
symt_name_t symt_include_parse_add_path(symt_name_t root, symt_name_t src);

/* Create a new list of includes */
symt_include_t *symt_include_new();

/* Check if passed path exists as an include */
bool symt_include_exists(symt_include_t *includes, symt_name_t path);

/* Add a new include at current list of includes */
symt_include_t *symt_include_add(symt_include_t *includes, symt_name_t path);

/* Delete all content for passed list of includes */
symt_include_t* symt_include_clean(symt_include_t *includes);

#endif	// SYMT_ADD_H
