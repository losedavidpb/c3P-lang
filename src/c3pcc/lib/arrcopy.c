// arrcopy.c -*- C -*-
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
 *	ISO C99 Standard: Array copy implementation
 */

#include "../include/arrcopy.h"

#include "../include/memlib.h"
#include <string.h>

int *intcopy(int *src, size_t num_elems)
{
	if (src == NULL) return NULL;
    int *dest = (int *)(ml_malloc(num_elems * sizeof(int)));
    for (int i = 0; i < num_elems; i++) *(dest + i) = *(src + i);
    return dest;
}

bool *boolcopy(bool *src, size_t num_elems)
{
	if (src == NULL) return NULL;
    bool* dest = (bool *)(ml_malloc(num_elems * sizeof(bool)));

    for (int i = 0; i < num_elems; i++)
	{
		if (*(src + i) >= 1) *(src + i) = true;
		*(dest + i) = *(src + i);
	}

    return dest;
}

float *floatcopy(float *src, size_t num_elems)
{
	if (src == NULL) return NULL;
    float* dest = (float *)(ml_malloc(num_elems * sizeof(float)));
    for (int i = 0; i < num_elems; i++) *(dest + i) = *(src + i);
    return dest;
}

double *doublecopy(double *src, size_t num_elems)
{
	if (src == NULL) return NULL;
    double* dest = (double *)(ml_malloc(num_elems * sizeof(double)));
    for (int i = 0; i < num_elems; i++) *(dest + i) = *(src + i);
    return dest;
}

char *strcopy(char *src)
{
	if (src == NULL) return NULL;

    if (strlen(src) <= 0)
	{
		char *dest = (char*)(ml_malloc(sizeof(char)));
		for (int i = 0; i < strlen(src); i++) *(dest + i) = 0;
		return dest;
	}

	char *dest = (char*)(ml_malloc(strlen(src) * sizeof(char)));
	for (int i = 0; i < strlen(src); i++) *(dest + i) = *(src + i);
	*(dest + strlen(src)) = '\0';
    return dest;
}

int *intsub(int *src, natural_t ini_dx, natural_t end_dx)
{
	if (src == NULL) return NULL;
	natural_t new_size = (end_dx - ini_dx);
	int *dest = (int*)(ml_malloc(new_size * sizeof(int)));
	for (int i = 0, j = ini_dx; i < new_size; i++, j++) *(dest + i) = *(src + j);

	return dest;
}

bool *boolsub(bool *src, natural_t ini_dx, natural_t end_dx)
{
	if (src == NULL) return NULL;
	natural_t new_size = (end_dx - ini_dx);
	bool *dest = (bool*)(ml_malloc(new_size * sizeof(bool)));
	for (int i = 0, j = ini_dx; i < new_size; i++, j++) *(dest + i) = *(src + j);

	return dest;
}

float *floatsub(float *src, natural_t ini_dx, natural_t end_dx)
{
	if (src == NULL) return NULL;
	natural_t new_size = (end_dx - ini_dx);
	float *dest = (float*)(ml_malloc(new_size * sizeof(float)));
	for (int i = 0, j = ini_dx; i < new_size; i++, j++) *(dest + i) = *(src + j);

	return dest;
}

double *doublesub(double *src, natural_t ini_dx, natural_t end_dx)
{
	if (src == NULL) return NULL;
	natural_t new_size = (end_dx - ini_dx);
	double *dest = (double*)(ml_malloc(new_size * sizeof(double)));
	for (int i = 0, j = ini_dx; i < new_size; i++, j++) *(dest + i) = *(src + j);

	return dest;
}

char *strsub(char *src, natural_t ini_dx, natural_t end_dx)
{
	if (src == NULL) return NULL;
	natural_t new_size = (end_dx - ini_dx);
	char *dest = (char*)(ml_malloc(new_size * sizeof(char)));
	strncpy(dest, src + ini_dx, new_size);
    *(dest + (end_dx-1) )= '\0';

	return dest;
}

void intcat(int *dest, int *src, natural_t ini_dx, natural_t len)
{
	if (dest == NULL || src == NULL) return;
	for (int i = ini_dx, j = 0; i < (len - ini_dx); i++, j++) *(dest + i) = *(src + j);
}

void boolcat(bool *dest, bool *src, natural_t ini_dx, natural_t len)
{
	if (dest == NULL || src == NULL) return;
	for (int i = ini_dx, j = 0; i < (len - ini_dx); i++, j++) *(dest + i) = *(src + j);
}

void floatcat(float *dest, float *src, natural_t ini_dx, natural_t len)
{
	if (dest == NULL || src == NULL) return;
	for (int i = ini_dx, j = 0; i < (len - ini_dx); i++, j++) *(dest + i) = *(src + j);
}

void doublecat(double *dest, double *src, natural_t ini_dx, natural_t len)
{
	if (dest == NULL || src == NULL) return;
	for (int i = ini_dx, j = 0; i < (len - ini_dx); i++, j++) *(dest + i) = *(src + j);
}

void stringcat(char *dest, char *src)
{
	if (dest == NULL || src == NULL) return;
	strcat(dest, src);
}

int *intappend(int *dest, int *src, natural_t len1, natural_t len2)
{
	if (dest == NULL || src == NULL) return NULL;
	int * res = (int*)(ml_malloc(sizeof(int) * (len1 + len2)));
	for (int i = 0; i < len1; i++) *(res + i) = *(dest + i);
	for (int i = len1, j = 0; i < (len1 + len2); i++, j++) *(res + i) = *(src + j);
	return res;
}

bool *boolappend(bool *dest, bool *src, natural_t len1, natural_t len2)
{
	if (dest == NULL || src == NULL) return NULL;
	bool * res = (bool*)(ml_malloc(sizeof(bool) * (len1 + len2)));
	for (int i = 0; i < len1; i++) *(res + i) = *(dest + i);
	for (int i = len1, j = 0; i < (len1 + len2); i++, j++) *(res + i) = *(src + j);
	return res;
}

float *floatappend(float *dest, float *src, natural_t len1, natural_t len2)
{
	if (dest == NULL || src == NULL) return NULL;
	float * res = (float*)(ml_malloc(sizeof(float) * (len1 + len2)));
	for (int i = 0; i < len1; i++) *(res + i) = *(dest + i);
	for (int i = len1, j = 0; i < (len1 + len2); i++, j++) *(res + i) = *(src + j);
	return res;
}

double *doubleappend(double *dest, double *src, natural_t len1, natural_t len2)
{
	if (dest == NULL || src == NULL) return NULL;
	double * res = (double*)(ml_malloc(sizeof(double) * (len1 + len2)));
	for (int i = 0; i < len1; i++) *(res + i) = *(dest + i);
	for (int i = len1, j = 0; i < (len1 + len2); i++, j++) *(res + i) = *(src + j);
	return res;
}

char *strappend(char *dest, char *src)
{
	if (dest == NULL || src == NULL) return NULL;
	char * res = (char*)(ml_malloc(sizeof(char) * (strlen(dest) + strlen(src))));
	for (int i = 0; i < strlen(dest); i++) *(res + i) = *(dest + i);
	for (int i = strlen(dest), j = 0; i < (strlen(dest) + strlen(src)); i++, j++) *(res + i) = *(src + j);
	*(res + strlen(dest) + strlen(src)) = '\0';
	return res;
}
