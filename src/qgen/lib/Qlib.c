// Qlib.c 3.7.3     Q LIBRARY

#include "Q.h"

/* Re-invert the order of Q strings in order to have
   compatibility to C libraries */
void reinv_str(unsigned char *p, unsigned char *r)
{
  while (p < r)
  {
    unsigned char t = *p;
    *p++ = (unsigned char)*r;
    *r-- = (unsigned char)t;
  }
}

/* Invert the order of Q strings in order to have
   compatibility to C libraries. */
unsigned char *inv_str(unsigned char *r)
{
  unsigned char *p = (unsigned char *)r;
  while (*p) p--;    // go to '\0'
  reinv_str(p,r);    // invert
  return p;
}


/* Routines for Q library
*****************************
*/

BEGINLIB

// void exit(int)
// Input: R0 = output code
L exit_: exit(R0);  // exit program with code R0

// void* new(int_size)
// Input: R0 = return label
//        R1 = size (>=0)
// Output: R0 = pointer to assigned memory trace
// R0 will be only be modified
L new_:
{
	int r=R0;
    IF(R1<0) GT(exit_);         // negative size are not valid
    NH(R1);                     // malloc memory trace at heap
    R0=HP;                      // return lower direction of the trace
    GT(r);                      // return
}

// void putf(const unsigned char*, int)
// Input:	R0=return label
//			R1=direction of the string format
//			R2=integer value to visualize (optional)
// Registers would not be modified and the same with format
L putf_:
{
	unsigned char *p=inv_str(&U(R1)); 	// invert: nva. dir. real 1er char
	printf((char*)p,R2);             	// translate
    reinv_str(p,&U(R1));   	    		// re-invert
	GT(R0);                             // return
}

ENDLIB
