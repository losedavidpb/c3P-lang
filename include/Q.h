/***************************************************** *******************

Q.h v3.7.2 - 3.7.3 (c) 2002..2009 Jose Fortes Galvez

Header file for Q code, intermediate language in
quadruples compileable in C. It declares the macros and functions that
make up the "Q machine".

This file should NOT be modified. In contrast, Qlib.h and Qlib.c
are designed to be modified thereby extending the library of
system routines.

Description
-----------

(See user manual Qman.txt first)

A machine model is used that includes (implemented in the heap
with realloc) a virtual static zone and a virtual stack for frames
of stack managed by the code itself. In this virtual stack
can store and manage all types of data and structures,
including virtual data and code addresses. Equally
supported by realloc, a virtual heap is implemented (with a management
initially trivial in Qlib.c). These implementations allow
all virtual addresses are implemented as integers, in
actually indices in the corresponding structures named ze_stack
and heap.

All quantities refer to virtual memory size or location
in the generated code they are in bytes, that is, an allocation of b
indicates b bytes.

The C code obtained from the expansion of the macros corresponding to
instructions Q is inside a switch whose values
Integers of the different cases serve as jump addresses.

************************************************** ******************/

#ifndef DEP
#define DEP 0
#endif

#ifndef STDQ
#define STDQ stdout
#endif

// necessary for C++ (GCC g++)
#ifdef USEextern
#define EXTERN extern
#else
#define EXTERN
#endif

#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>  // NULL
#include <signal.h>
#include <string.h>
#include <setjmp.h>

#include "Qlib.h"

// System labels
// extern (only numbers are for the definition of Q)
#define INI   0	        // start the code of the user program
#define BP   -1         // breakpoint (whether interactive mode)
#define FIN  -2         // exit execution: go out with exit(R0);
#define ABO  -3         // abort execution: go out with exit(1);
// intern
#define NOE COM         // invalid label
#define COM  -4         // truly start (intern) of the execution (whether compiled)
#define DEF  -5         // default label
#define LIB  -10        // first label valid at Qlib

#define PTR unsigned int        // what type corresponds to pointer
#define sPTR int                // pointer with sign
#define UC unsigned char        // ud. addersing = byte (no sign)

// types
#define Pt PTR
#define Ut UC
#define St short
#define It int
#define Jt long int
#define Ft float
#define Dt double
#define Et long double
#

// types sizes
// (note: sizeof return unsigned int, so it is not possible -4*IS<0)
#define PS (int)sizeof(Pt)
#define US (int)sizeof(Ut) // 1 byte ANSI C
#define SS (int)sizeof(St) // 2 bytes gcc i386
#define IS (int)sizeof(It) // 4 bytes gcc i386
#define JS (int)sizeof(Jt) // 4 bytes gcc i386
#define FS (int)sizeof(Ft) // 4 bytes gcc i386
#define DS (int)sizeof(Dt) // 8 bytes gcc i386
#define ES (int)sizeof(Et) // 12 bytes gcc i386
#
#define AS 4               // size at bytes for max alignment

/************ OBJECT ARCHITECTURE ************************/
#define tR It
#define tRR Dt

#define clR I
#define clRR D

#define NR 8
EXTERN tR R[NR];               // integer registers of the CPU
#define R(i) R[(i)]            // in case they are indexables
#define R0 R[0]
#define R1 R[1]
#define R2 R[2]
#define R3 R[3]
#define R4 R[4]
#define R5 R[5]
#define R6 R[6]
#define R7 R[7]
#define NRR 4
EXTERN tRR RR[NRR];            // registers with float type of the CPU
#define RR(i) RR[(i)]          // in case they are indexables
#define RR0 RR[0]
#define RR1 RR[1]
#define RR2 RR[2]
#define RR3 RR[3]

// virtual zones of the memory
EXTERN UC * ze_pila;              // (background of) static zone and stack
EXTERN UC * heap;                 // (background of) heap

// Definition of virtual base addresses (addresses numerically
// largest, multiples of AS) of memory zones, all of which
// grow in numerically decreasing directions. The stack is
// will automatically position after the bottom address of the zone
// static. Check H >> Z >> 0

// #define Z 0x00100000         // base+1 of the static zone (1 MB max)
// #define Z 0x00112000         // base+1 of the static zone (1096 KB max)
#ifndef Z
#define Z 0x00012000            // base+1 of the static zone (72 KB max)
#endif
// #define P TE                 // of the stack (implicit)
// #define H 0x00200000         // base+1 of the heap (1 MB max); it has to be true H>>Z
// #define H 0x00224000         // base+1 of the heap (1096 KB max); it has to be true H>>Z
#ifndef H
#define H 0x00024000            // base+1 of the heap (72 KB max); it has to be true H>>Z
#endif

#define CP R7                   // address (virtual**2) from the top of ze_pila
EXTERN Pt CPX;                  // address virt. of the last pos. actually assigned
EXTERN Pt HP;                   // address, virt. of the last pos. actually assigned
// !!!! in the code it is assumed that b multiple of AS bytes is used !!!
// Since realloc grows towards numerically higher addresses,
// this is how the stack has to do it, otherwise, we would change the "endian"

// !!!! when locating data take into account the required alignments !!
#define MAS(x) ((x)/AS)*AS  // convierte a multiplo de AS hacia dir. num�r. inferiores
// MORE(x) (((x)-AS+1)/AS)*AS /* id. superiors
// effectively extend the static zone to position MAS(e) (from Z+1)
unsigned char u_wall; // evita aviso -Wall
#define ZE(e) if ((Pt)(e)<CP) {CP=(Pt)MAS(e); u_wall=U((Pt)MAS(e)); /* fuerza asignaci�n */ }

// has the same effect as the old NC (b>0 increases stack size: _de_increase CP
#define nvo_NC(b) CP-=(b);      // if before NC(+n), now R7=R7-n and further access

#define BSX 0x10000 // 64 KB: maximum block size to allocate 1 time

//PTR tmp;

#define BS  0x00100 // 256 B: stack allocation unit
#define DMS (d+s) // will read or write to dir. virt. d..DMS-1

#define QF                                                                           \
                                                                                     \
void errxit(int cod) {                                                               \
char *mens[]=                                                                        \
 {/* 0 */ "" /* not appropriate 0 as longjmp code */ \
   /* 1 */ , "Attempt to free a section larger than the heap in heap" \
   /* 2 */ , "Memory access out of bounds" \
   /* 3 */ , "Memory block to allocate too large" \
   /* 4 */ , "Exceeded the maximum size of static zone plus stack, or heap" \
   /* 5 */ , "The system does not supply more memory" \
   /* 6 */ , "Static memory allocation at address not less than Z" \
   /* 7 */ , "END reached" \
   /* 8 */ , "ENDLIB reached" \
   /* 9 */ , "Jump to nonexistent label"                                         \
 };                                                                                 \
 fflush(stdout);                                                                    \
 fprintf(stderr,"\nQ.h: %s (error %i)\n",mens[cod],cod);                            \
 longjmp(env,cod); /* jump to exception handler */                            		\
 /* unreachable */ printf("\nQ.h: error interno\n"); raise(SIGABRT);               \
}                                                                                   \
                                                                                    \
/* Increase the size of the heap by b bytes (or decrement it if b<0) 				\
Modify (and return) the HP value accordingly */                        \
void NH(tR b) {                                                                      \
  Pt nvoHP;                                                                          \
  if ((b)>BSX) errxit(3); /* block to allocate too big */                   		\
  else if ((nvoHP=HP-(b))>H) errxit(1); /* attempt to release more heap than there is */\
  else if (nvoHP<Z) errxit(4); /* maximum heap size exceeded */                     \
  else if (!(heap = (UC*)realloc(heap, H-nvoHP))) errxit(5); /* realloc error */  \
  HP=nvoHP;                                                                          \
}                                                                                    \
                                                                                     \
UC *DIR(PTR d, UC s) {                                                               \
  /* Convert virtual address d to z.e., stack or heap to address \
    real. We reverse the order of memory addresses, so that stack \
    --and thus heap-- grow (virtually) towards \ addresses
    numerically lower, while realloc, and the \ operations
    multibyte read/write (e.g. 4-byte int) do it to \
    numerically higher addresses. We can't make the heap \
    grow in the opposite direction, because then there would be different endians \
    on stack and heap. The virtual machine is therefore big endian, and the \
    strings are stored to address. virt. superior --but really \
    towards direction lower so you have to reorder them \
    temporarily for i/o with libC. */                                      \
  Pt bloq /* extent size */ , nvoCPX;                                     \
  if (d<=Z-s) /* avoid DMS>=0 when (signed)d<0 */                                  \
    if (d>=CPX) return ze_pila+Z-DMS; /* even if >=CP (user pgm error) */  \
    else {                                                                           \
      nvoCPX=CPX-(bloq=(CPX-CP+BS-1)/BS*BS); /* calculate according to CP, not according to d! */ \
      if (bloq>BSX) errxit(3); /* block to allocate too big */               \
      else if (nvoCPX>Z) errxit(4); /* (better than >=) maximum stack size exceeded */ \
      else if (d>=nvoCPX)                                                            \
	if (!(ze_pila = (UC *)realloc(ze_pila, Z-nvoCPX)))                           \
	  errxit(5); /* realloc error */                                          \
	else {CPX=nvoCPX; return ze_pila+Z-DMS;}                                     \
      else errxit(2); /* access below stack mapped zone */            \
    }                                                                                \
  else if (d<=H-s && d>=HP) return heap+H-DMS;                                       \
  else errxit(2); /* top access to stack outside zone assigned to heap */    \
  return 0; /* avoid warning if -Wall */                                               \
}                                                                                    \
                                                                                     \
/* load a string (C format: '\0' trailing mark) */                             \
void STR(Pt p, const char *r) {	                                                     \
    if (p+strlen(r)+1>Z) errxit(6); /* static zone must be less than Z */    \
    ZE(p); 			                                                     \
    do U(p++)=*r; while (*r++);                                                      \
  }                                                                                  \

// Access to virtual memory address d, according to data type. Note:
// it is necessary to write it like this to be able to apply the & operator,
// e.g. &P(d), (so that & and * cancel each other, according to
// definition of & in standard C); So if it were written
// (Pt)*DIR(d,PS), even though the value is obviously the same,
// &P(d) would not work.
#define P(d) *(Pt*)DIR(d,PS)
#define U(d) *(Ut*)DIR(d,US)
#define S(d) *(St*)DIR(d,SS)
#define I(d) *(It*)DIR(d,IS)
#define J(d) *(Jt*)DIR(d,JS)
#define F(d) *(Ft*)DIR(d,FS)
#define D(d) *(Dt*)DIR(d,DS)
#define E(d) *(Et*)DIR(d,ES)

// Memory allocations and static constants and strings to load

// just allocate memory in static zone from p (to and through
// Z) supposedly for b bytes in p..p+b-1
#define MEM(p,b) 								 \
  do { if (DEP>=10) printf(">>MEM(%i,%i)\n",(int)p,(int)b); 			 	 \
  if ((p)+(b)>Z) errxit(6); /* the static zone must be less than Z */        \
  ZE(p); } while (0)	 							 \

// assign and fill with fixed value (normally 0)
#define FIL(p,b,v) 							    \
  do {int i;                                                                \
    if (DEP>=10) printf(">>FIL(%i,%i,%i)\n",(int)p,(int)b,(int)v); 			    \
    if ((p)+(b)>Z) errxit(6); /*the static zone must be less than Z */ \
    ZE(p); 								    \
    for (i=0;i<(b);i+=US) U((p)+i)=(v);                                     \
  } while (0)			                                            \

// load a numeric constant
#define DAT(p,c,v)   								 \
	do {if (DEP>=10) printf(">>DAT(%i,%s,%i)\n",(int)p,# c,(int)v); 			 \
  	if ((p)+c##S>Z) errxit(6); /* the static zone must be less than Z */ \
	ZE(p); 									 \
	c(p)=v; /* load v */ } while (0)					 \

// labels and jumps
EXTERN int etiq;                    // label where to jump to

#define L case                      // confuse less */
#define T(e) (e)                    // make it easier for the assembler to locate pattern "T("
#define OLDGT(e) if ((e)!=BP) {     /* "go to" */               \
                etiq = (e);                                     \
                break;                                          \
              }

#define GT(e) do if ((e)!=BP) {                                 \
                etiq = (e);         /* "go to" */               \
                goto GT_switch;                                 \
               }                                                \
               while(0) /* by using do-while I get GT() to be a
                            instruction and need ";"
                         */

#define IF(e) if(e)                 // if we want to use uppercase

EXTERN jmp_buf env;

#define BEGIN                                                                            \
QF                                                                                       \
main() {                                                                                 \
/*  register int tmp;  */                                                                \
  int i, cod;  /* aux */                                                                 \
  enum {carg, ejec} est=carg;		                                                 \
  if (cod=setjmp(env)) {                                                                 \
    if (cod==ABO) printf("\nEjecuci�n abortada por salto a %i\n",ABO);                   \
    raise(SIGABRT);  /*exit(cod);*/                                                      \
  }                                                                                      \
  ze_pila=NULL;                                                                          \
  heap=NULL;                                                                             \
  CPX=Z;				                                                 \
  HP=H;                                                                                  \
  etiq=COM;                                                                              \
  do {                                                                                   \
    if (DEP) printf("etiq==%i\n",etiq);                                                  \
GT_switch:                                                                               \
    switch (etiq)                                                                        \
      {                                                                                  \
/* a tag here prevents warning of unreachable code if BEGIN follows STAT(0) */     \
L COM:   CP = Z;                          /* boot with empty stack */                   \
         GT(LLL-1);                       /* "load" static zone */                   \

#ifndef LLL
#define LLL -999  // Default value of the last usable tag in Qlib
#endif

// pairs of declarations and instructions
#define STAT(i)                                                           \
         GT(LLL-2*(i)-2);  /* jump to the first statement of CODE(i) */\
L LLL-2*(i)-1:             /* first statement of STAT(i) */           \

#define CODE(i)                                                               \
         GT(LLL-2*(i+1)-1);  /* jump to the first statement of STAT(i+1) */\
L LLL-2*(i)-2:               /* first statement of CODE(i) */             \

#define END                               /* the last piece of code would "fall" here */  \
	 if (est==carg) GT(DEF);  		                                         \
	 errxit(7); 								         \
L ABO:   longjmp(env,-3);                                                                \
L FIN:   exit(R0);                        /* normal is GT(END); */                    \
/* start of execution: initializations and invocation of user code */            \
L DEF:                                                                                   \
default:                    							         \
	 if (est==carg) {							         \
	   est=ejec;   			  /* we go to execute */		         \
           GT(INI);                       /* start compile execution */           \
	 } else if (etiq >= 0 || etiq < LLL)  errxit(9);                                 \
         else {                                                                          \
	   Qlib(etiq);                                                                   \
	   GT(etiq);                                                                     \
	 }                                                                               \
      }                                                                                  \
  } while (1); /* since the jumps are all with GT(), which goes to GT_switch, \
                 already the while is useless */                                                \
}                                                                                        \

#define BEGINLIB                                      	\
extern void NH(tR b); /* avoid  GCC warning (C++) */  	\
extern UC *DIR(PTR d, UC s); /* idem */               	\
extern void errxit(int cod); /* idem */               	\
int constZ=Z, constH=H, constLLL=LLL;                 	\
void Qlib(int etilib) {                               	\
  switch (etilib)                                     	\
    {                                                 	\
       default: errxit(9); /* label <0 non-existent */ 	\

#define ENDLIB                                                  \
    }                                                           \
    errxit(8); /* ENDLIB reached; execution finished */      	\
GT_switch:  return;                                             \
}                                                               \

// Q.h end
