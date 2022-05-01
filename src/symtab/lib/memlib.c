#include "../../../include/memlib.h"

#include "../../../include/assertb.h"
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
    if (__value != NULL)
    {
        __value = realloc(__value, __size);
        assertf(__value != NULL, "memory could not be reserved");
    }

    return __value;
}

void ml_free(void * __value)
{
    if (__value != NULL)
    {
        free(__value); __value = NULL;
        assertf(__value == NULL, "memory could not be cleaned");
    }
}
