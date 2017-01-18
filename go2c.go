/*
	Example of interfacing between Go and C programs.
	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>

	This program is free software, distributed under the terms of the MIT License.
	See the LICENSE file at the top of the source tree.
*/

// Package should be called main and 'C' should always be imported
package main

/*
// Example of interfacing between Go and C programs.
*/
import (
	"C"
)
import (
	"fmt"
	"strconv"
	"strings"
	"unsafe"
)

// A main function must be present, even if empty.
func main() {}

// All exported functions must have a '//export [name]' comment.

//export add
// add adds two integers
func add(x, y C.int) C.int { // This function when used in C takes as input int and returns int
	return x + y
}

// We can either use C types directly or use Go types that are mapped to C types.
// GoInt is a such a mapping defined in go2c.h

//export square
// square returns the square of an integer
func square(x int) int { // This function when used in C takes as input GoInt and returns GoInt
	return x * x
}

//export printBits
// printBits prints an integer in binary format
func printBits(x C.int) { // This function when used in C takes as input int and returns void
	fmt.Println(strconv.FormatInt(int64(x), 2))
}

//export toBits
// toBits returns a string with the binary representation of an integer
// Returned value must be freed with free() from C or with C.free() from Go.
func toBits(x C.int) *C.char { // This function when used in C takes as input int and returns char*
	return C.CString(fmt.Sprintf(strconv.FormatInt(int64(x), 2)))
}

//export conCat
// conCat concatenates 2 strings.
// Returned value must be freed with free() from C or with C.free() from Go.
func conCat(a, b *C.char) *C.char { // This function when used in C takes as input char* and returns char*
	return C.CString(C.GoString(a) + C.GoString(b))
}

//export toUpper
// toUpper converts a string to upper case
// Returned value must be freed with free() from C or with C.free() from Go.
func toUpper(a string) *C.char { // This function when used in C takes as input a GoString struct and returns char*
	return C.CString(strings.ToUpper(a))
}

//export toUpper2
// toUpper2 converts a string to upper case
// We cannot use this function from C safely, Go will panic at runtime unless
// we disable cgo runtime checks. The checks can be disabled by setting the environment
// variable GODEBUG=cgocheck=0, but it's not advised to. A Go function called by C code
// may not return a Go pointer.
func toUpper2(a string) string { // This function when used in C takes as input a GoString struct and returns a GoString
	return strings.ToUpper(a)
}

//export toUpper3
// ToUpper3 converts a string to upper case
// This beats the above restrictions, but it is really a recipe for disaster :)
// Don't write or use code similar to this!
func toUpper3(a string) unsafe.Pointer { // This function when used in C returns a void* that points to a Go string
	s := strings.ToUpper(a)
	return unsafe.Pointer(&s)
}
