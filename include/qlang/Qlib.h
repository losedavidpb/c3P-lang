// Qlib.h 3.7.1 - 3.7.3

// Optional definitions of macros
// It is possible to modify them, as well as Qlib.c.
// These definitions could be used at Q code and Qlib.c,
// but only if the interpreter and compiler of Q work from
// the output of the preprocessor of C (cpp)

// Reconfiguration of base directions of Q machine
// It is important to notice that H > Z > 0 must be true and both must be multiples of 4
//#define H   0x00200000 // base+1 of the heap (1 MB max until Z=0x00100000)
//#define Z   0x00100000 // base+1 of the static zone and stack (1 MB max until 0x00000000)
#define LLL -9999      // last label available at Qlib (LLL < -10)

// For the rest of macros, use _ at the start of the name to
// avoid conflicts with Q.h definitions

// If we want to use this named instead of numeric values
#define __ini	 0    // start
#define __brk    -1   // breakpoint "manual" at IQ
#define __fin    -2   // normal exit
#define __abo    -3   // error exit

// For Qlib functions (labels greater than -10)
#define exit_    -10    // NOTE: deprecated but just for compatibility
#define new_     -11    // assign and free space at heap
#define putf_    -12    // show string or integer
#define pow_	 -13	// pow operation for numbers
#define mod_	 -14	// mod operation for numbers
