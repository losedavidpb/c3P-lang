/* Expansion of malloc for internal check */
#ifndef MEM_LIB_H
#define MEM_LIB_H

#include <stdlib.h>

/* Allocate SIZE bytes of memory. The operation would be checked
   in order to stop execution if it does not succeed */
void *ml_malloc(size_t __size);

/* Allocate NMEMB elements of SIZE bytes each, all initialized to 0.
   The operation would be checked in order to stop execution if it
   does not succeed */
void *ml_calloc(size_t __nmemb, size_t __size);

/* Re-allocate the previously allocated block in __ptr, making
   the new block SIZE bytes long. The operation would be checked
   in order to stop execution if it does not succeed */
void *ml_realloc(void *__value, size_t __size);

/* Re-allocate the previosly allocated block whether current size is
   not enough for passed new size. This can be used for dynamic arrays */
void *ml_realloc_if(void *__value, size_t __curr_size, size_t __new_size);

/* Free a block allocated by `malloc', `realloc' or `calloc'.
   The operation would be checked in order to stop execution
   if it does not succeed */
void ml_free(void * __value);

#endif  // MEM_LIB_H
