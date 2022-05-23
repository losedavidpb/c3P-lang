/* Utilities to copy arrays into new referencies
   using dynamic memory reservation. */
#ifndef COPY_H
#define COPY_H

#include <stdbool.h>
#include <stdlib.h>

/* Natural numbers */
typedef unsigned long natural_t;

/* Copy passed array of integers into a new one.
   Null would be returned whether passed parameters are not valid */
int *intcopy(int *src, size_t num_elems);

/* Copy passed array of bools into a new one
   Null would be returned whether passed parameters are not valid */
bool *boolcopy(bool *src, size_t num_elems);

/* Copy passed array of floats into a new one
   Null would be returned whether passed parameters are not valid */
float *floatcopy(float *src, size_t num_elems);

/* Copy passed array of doubles into a new one
   Null would be returned whether passed parameters are not valid */
double *doublecopy(double *src, size_t num_elems);

/* Copy passed string into a new one
   Null would be returned whether passed parameters are not valid */
char *strcopy(char *src);

/* Copy passed source from start index to end index
   Operation won't be executed if parameters are invalid,
   except the case on which source does not have enough
   space for passed indexes. */
int *intsub(int *src, natural_t ini_dx, natural_t end_dx);

/* Copy passed source from start index to end index
   Operation won't be executed if parameters are invalid,
   except the case on which source does not have enough
   space for passed indexes. */
bool *boolsub(bool *src, natural_t ini_dx, natural_t end_dx);

/* Copy passed source from start index to end index
   Operation won't be executed if parameters are invalid,
   except the case on which source does not have enough
   space for passed indexes. */
float *floatsub(float *src, natural_t ini_dx, natural_t end_dx);

/* Copy passed source from start index to end index
   Operation won't be executed if parameters are invalid,
   except the case on which source does not have enough
   space for passed indexes. */
double *doublesub(double *src, natural_t ini_dx, natural_t end_dx);

/* Copy passed source from start index to end index
   Null would be returned whether passed parameters are not valid */
char *strsub(char *src, natural_t ini_dx, natural_t end_dx);

#endif  // COPY_H
