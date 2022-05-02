#include "../../../include/arrcopy.h"

#include "../../../include/memlib.h"
#include "../../../include/assertb.h"
#include <string.h>
#include <stdbool.h>

int *intcopy(int *src, size_t num_elems)
{
    int *dest = NULL;
    assertp(src != NULL, "passed pointer must be not null");
    assertf(num_elems > 0, "%lu is not valid for num_elems", (unsigned long)num_elems);

    dest = (int *)(ml_malloc(num_elems * sizeof(int)));
    for (int i = 0; i < num_elems; i++) *(dest + i) = *(src + i);
    return dest;
}

bool *boolcopy(bool *src, size_t num_elems)
{
    bool *dest = NULL;
    assertp(src != NULL, "passed pointer must be not null");
    assertf(num_elems > 0, "%lu is not valid for num_elems", (unsigned long)num_elems);

    dest = (bool *)(ml_malloc(num_elems * sizeof(bool)));
    for (int i = 0; i < num_elems; i++) *(dest + i) = *(src + i);
    return dest;
}

float *floatcopy(float *src, size_t num_elems)
{
    float *dest = NULL;
    assertp(src != NULL, "passed pointer must be not null");
    assertf(num_elems > 0, "%lu is not valid for num_elems", (unsigned long)num_elems);

    dest = (float *)(ml_malloc(num_elems * sizeof(float)));
    for (int i = 0; i < num_elems; i++) *(dest + i) = *(src + i);
    return dest;
}

double *doublecopy(double *src, size_t num_elems)
{
    double *dest = NULL;
    assertp(src != NULL, "passed pointer must be not null");
    assertf(num_elems > 0, "%lu is not valid for num_elems", (unsigned long)num_elems);

    dest = (double *)(ml_malloc(num_elems * sizeof(double)));
    for (int i = 0; i < num_elems; i++) *(dest + i) = *(src + i);
    return dest;
}

char *strcopy(char *src)
{
    char *dest = NULL;
    assertp(src != NULL, "passed pointer must be not null");
    assertf(strlen(src) > 0, "%lu is not valid for num_elems", (unsigned long)strlen(src));

    dest = strdup(src);
	assertp(dest != NULL, "copy could not be executed because of internal errors");
    return dest;
}
