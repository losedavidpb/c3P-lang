#include "../../../include/arrcopy.h"

#include "../../../include/memlib.h"
#include "../../../include/assertb.h"
#include <string.h>
#include <stdbool.h>

int *intcopy(int *src, size_t num_elems)
{
	if (src == NULL) return NULL;
    assertf(num_elems > 0, "%lu is not valid for num_elems", (unsigned long)num_elems);

    int *dest = (int *)(ml_malloc(num_elems * sizeof(int)));
    for (int i = 0; i < num_elems; i++) *(dest + i) = *(src + i);
    return dest;
}

bool *boolcopy(bool *src, size_t num_elems)
{
	if (src == NULL) return NULL;
    assertf(num_elems > 0, "%lu is not valid for num_elems", (unsigned long)num_elems);

    bool* dest = (bool *)(ml_malloc(num_elems * sizeof(bool)));
    for (int i = 0; i < num_elems; i++) *(dest + i) = *(src + i);
    return dest;
}

float *floatcopy(float *src, size_t num_elems)
{
	if (src == NULL) return NULL;
    assertf(num_elems > 0, "%lu is not valid for num_elems", (unsigned long)num_elems);

    float* dest = (float *)(ml_malloc(num_elems * sizeof(float)));
    for (int i = 0; i < num_elems; i++) *(dest + i) = *(src + i);
    return dest;
}

double *doublecopy(double *src, size_t num_elems)
{
	if (src == NULL) return NULL;
    assertf(num_elems > 0, "%lu is not valid for num_elems", (unsigned long)num_elems);

    double* dest = (double *)(ml_malloc(num_elems * sizeof(double)));
    for (int i = 0; i < num_elems; i++) *(dest + i) = *(src + i);
    return dest;
}

char *strcopy(char *src)
{
	if (src == NULL) return NULL;
    assertp(src != NULL, "passed pointer must be not null");
	if (strlen(src) < 0) return NULL;

    if (strlen(src) == 0)
	{
		char *dest = (char*)(ml_malloc(sizeof(char)));
		return dest;
	}

    char* dest = strdup(src);
	assertp(dest != NULL, "copy could not be executed because of internal errors");
    return dest;
}

int *intsub(int *src, natural_t ini_dx, natural_t end_dx)
{
	if (src == NULL) return NULL;
	assertf(end_dx >= ini_dx, "invalid index, %d must be greater than %d", (int)end_dx, (int)ini_dx);

	natural_t new_size = (end_dx - ini_dx);
	int *dest = (int*)(ml_malloc(new_size * sizeof(int)));
	for (int i = 0, j = ini_dx; i < new_size; i++, j++) *(dest + i) = *(src + j);

	return dest;
}

bool *boolsub(bool *src, natural_t ini_dx, natural_t end_dx)
{
	if (src == NULL) return NULL;
	assertf(end_dx >= ini_dx, "invalid index, %d must be greater than %d", (int)end_dx, (int)ini_dx);

	natural_t new_size = (end_dx - ini_dx);
	bool *dest = (bool*)(ml_malloc(new_size * sizeof(bool)));
	for (int i = 0, j = ini_dx; i < new_size; i++, j++) *(dest + i) = *(src + j);

	return dest;
}

float *floatsub(float *src, natural_t ini_dx, natural_t end_dx)
{
	if (src == NULL) return NULL;
	assertf(end_dx >= ini_dx, "invalid index, %d must be greater than %d", (int)end_dx, (int)ini_dx);

	natural_t new_size = (end_dx - ini_dx);
	float *dest = (float*)(ml_malloc(new_size * sizeof(float)));
	for (int i = 0, j = ini_dx; i < new_size; i++, j++) *(dest + i) = *(src + j);

	return dest;
}

double *doublesub(double *src, natural_t ini_dx, natural_t end_dx)
{
	if (src == NULL) return NULL;
	assertf(end_dx >= ini_dx, "invalid index, %d must be greater than %d", (int)end_dx, (int)ini_dx);

	natural_t new_size = (end_dx - ini_dx);
	double *dest = (double*)(ml_malloc(new_size * sizeof(double)));
	for (int i = 0, j = ini_dx; i < new_size; i++, j++) *(dest + i) = *(src + j);

	return dest;
}

char *strsub(char *src, natural_t ini_dx, natural_t end_dx)
{
	if (src == NULL) return NULL;
	assertf(end_dx >= ini_dx, "invalid index, %d must be greater than %d", (int)end_dx, (int)ini_dx);
	assertf(end_dx <= strlen(src), "invalid index, %d must be less than %d", (int)end_dx, (int)strlen(src));

	natural_t new_size = (end_dx - ini_dx);
	char *dest = (char*)(ml_malloc(new_size * sizeof(char)));
	for (int i = 0, j = ini_dx; i < new_size; i++, j++) *(dest + i) = *(src + j);

	return dest;
}
