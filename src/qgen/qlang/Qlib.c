// Qlib.c 3.7.3     Q LIBRARY

#include "../../../include/qlang/Q.h"

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

/* Pow operation */
double pow(double num1, double num2)
{
	while (num2-- > 0) num1 += num1;
	return num1;
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

// void pow_(int num, int exp)
// Input:	R0=return label
//			R1=number on which operation would be applied
//			R2=exponent value for pow operation
// Registers would not be modified except R1 that has the result
L pow_:
{
	R1=pow(R1,R2);
	GT(R0);
}

// void mod_(int num1, int num2)
// Input:	R0=return label
//			R1=first number
//			R2=second number
// Registers would not be modified except R1 that has the result
L mod_:
{
	IF(R2==0) GT(exit_);
	R1=R1%R2;
	GT(R0);
}

ENDLIB
