/* Created by "go tool cgo" - DO NOT EDIT. */

/* package command-line-arguments */

/* Start of preamble from import "C" comments.  */


#line 12 "/home/zaf/src/go2c/go2c.go"

// Example of interfacing between Go and C programs.

#line 1 "cgo-generated-wrapper"


/* End of preamble from import "C" comments.  */


/* Start of boilerplate cgo prologue.  */
#line 1 "cgo-gcc-export-header-prolog"

#ifndef GO_CGO_PROLOGUE_H
#define GO_CGO_PROLOGUE_H

typedef signed char GoInt8;
typedef unsigned char GoUint8;
typedef short GoInt16;
typedef unsigned short GoUint16;
typedef int GoInt32;
typedef unsigned int GoUint32;
typedef long long GoInt64;
typedef unsigned long long GoUint64;
typedef GoInt32 GoInt;
typedef GoUint32 GoUint;
typedef __SIZE_TYPE__ GoUintptr;
typedef float GoFloat32;
typedef double GoFloat64;
typedef float _Complex GoComplex64;
typedef double _Complex GoComplex128;

/*
  static assertion to make sure the file is being used on architecture
  at least with matching size of GoInt.
*/
typedef char _check_for_32_bit_pointer_matching_GoInt[sizeof(void*)==32/8 ? 1:-1];

typedef struct { const char *p; GoInt n; } GoString;
typedef void *GoMap;
typedef void *GoChan;
typedef struct { void *t; void *v; } GoInterface;
typedef struct { void *data; GoInt len; GoInt cap; } GoSlice;

#endif

/* End of boilerplate cgo prologue.  */

#ifdef __cplusplus
extern "C" {
#endif


// add adds two integers

extern int add(int p0, int p1);

// square returns the square of an integer

extern GoInt square(GoInt p0);

// printBits prints an integer in binary format

extern void printBits(int p0);

// toBits returns a string with the binary representation of an integer
// Returned value must be freed with free() from C or with C.free() from Go.

extern char* toBits(int p0);

// conCat concatenates 2 strings.
// Returned value must be freed with free() from C or with C.free() from Go.

extern char* conCat(char* p0, char* p1);

// toUpper converts a string to upper case
// Returned value must be freed with free() from C or with C.free() from Go.

extern char* toUpper(GoString p0);

// toUpper2 converts a string to upper case
// We cannot use this function from C safely, Go will panic at runtime unless
// we disable cgo runtime checks. The checks can be disabled by setting the environment
// variable GODEBUG=cgocheck=0, but it's not advised to. A Go function called by C code
// may not return a Go pointer.

extern GoString toUpper2(GoString p0);

// ToUpper3 converts a string to upper case
// This beats the above restrictions, but it is really a recipe for disaster :)
// Don't write or use code similar to this!

extern void* toUpper3(GoString p0);

#ifdef __cplusplus
}
#endif
