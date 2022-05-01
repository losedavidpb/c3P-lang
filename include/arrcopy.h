/* Utilities to copy array into new referencies */
#ifndef COPY_H
#define COPY_H

#include <stdbool.h>

/* Copy passed array of integers into a new one */
int *intcopy(int *src, int num_elems);

/* Copy passed array of bools into a new one */
bool *boolcopy(bool *src, int num_elems);

/* Copy passed array of floats into a new one */
float *floatcopy(float *src, int num_elems);

/* Copy passed array of doubles into a new one */
double *doublecopy(double *src, int num_elems);

/* Copy passed string into a new one */
char *strcopy(char *src);

#endif  // COPY_H
