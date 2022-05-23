// arrcopy.h -*- C -*-
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
 *	ISO C99 Standard: Utilities to copy arrays into new pointers
 */

#ifndef ARR_COPY_H
#define ARR_COPY_H

#include <stdbool.h>
#include <stdlib.h>

/* Natural numbers */
typedef unsigned long natural_t;

/* Copy passed array of integers into a new one.
   Null would be returned whether passed parameters are not valid */
int *intcopy(int *src, natural_t num_elems);

/* Copy passed array of bools into a new one
   Null would be returned whether passed parameters are not valid */
bool *boolcopy(bool *src, natural_t num_elems);

/* Copy passed array of floats into a new one
   Null would be returned whether passed parameters are not valid */
float *floatcopy(float *src, natural_t num_elems);

/* Copy passed array of doubles into a new one
   Null would be returned whether passed parameters are not valid */
double *doublecopy(double *src, natural_t num_elems);

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

/* Cat passed source into destiny from passed number. This
   would not be possible whether there are not enough space
   to include all elements at destiny */
void intcat(int *dest, int *src, natural_t ini_dx, natural_t len);

/* Cat passed source into destiny from passed number. This
   would not be possible whether there are not enough space
   to include all elements at destiny */
void boolcat(bool *dest, bool *src, natural_t ini_dx, natural_t len);

/* Cat passed source into destiny from passed number. This
   would not be possible whether there are not enough space
   to include all elements at destiny */
void floatcat(float *dest, float *src, natural_t ini_dx, natural_t len);

/* Cat passed source into destiny from passed number. This
   would not be possible whether there are not enough space
   to include all elements at destiny */
void doublecat(double *dest, double *src, natural_t ini_dx, natural_t len);

/* Cat passed source into destiny from passed number. This
   would not be possible whether there are not enough space
   to include all elements at destiny */
void stringcat(char *dest, char *src);

/* Append passed source into a new variable which would be
   the result of the concatenation of destiny and source */
int *intappend(int *dest, int *src, natural_t len1, natural_t len2);

/* Append passed source into a new variable which would be
   the result of the concatenation of destiny and source */
bool *boolappend(bool *dest, bool *src, natural_t len1, natural_t len2);

/* Append passed source into a new variable which would be
   the result of the concatenation of destiny and source */
float *floatappend(float *dest, float *src, natural_t len1, natural_t len2);

/* Append passed source into a new variable which would be
   the result of the concatenation of destiny and source */
double *doubleappend(double *dest, double *src, natural_t len1, natural_t len2);

/* Append passed source into a new variable which would be
   the result of the concatenation of destiny and source */
char *strappend(char *dest, char *src);

#endif  // ARR_COPY_H
