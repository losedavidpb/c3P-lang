#include "memlib.h"

#include "assertb.h"
#include <stdlib.h>

void *ml_malloc(size_t __size)
{
    void *__value = malloc(__size);
    assertf(__value != NULL, "memory could not be reserved");
    return __value;
}

void *ml_calloc(size_t __nmemb, size_t __size)
{
    void *__value = calloc(__nmemb, __size);
    assertf(__value != NULL, "memory could not be reserved");
    return __value;
}

void *ml_realloc(void *__value, size_t __size)
{
    __value = realloc(__value, __size);
    assertf(__value != NULL, "memory could not be reserved");
    return __value;
}

void ml_free(void * __value)
{
    free(__value); __value = NULL;
    assertf(__value == NULL, "memory could not be cleaned");
}