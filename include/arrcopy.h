/* Utilities to copy array into new referencies */
#ifndef COPY_H
#define COPY_H

#include <stdbool.h>
#include <stdlib.h>

/* Copy passed array of integers into a new one */
int *intcopy(int *src, size_t num_elems);

/* Copy passed array of bools into a new one */
bool *boolcopy(bool *src, size_t num_elems);

/* Copy passed array of floats into a new one */
float *floatcopy(float *src, size_t num_elems);

/* Copy passed array of doubles into a new one */
double *doublecopy(double *src, size_t num_elems);

/* Copy passed string into a new one */
char *strcopy(char *src);

#endif  // COPY_H
