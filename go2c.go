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

// add adds two integers.
//
//export add
func add(x, y C.int) C.int { // This function when used in C takes as input int and returns int
	return x + y
}

// We can either use C types directly or use Go types that are mapped to C types.
// GoInt is a such a mapping defined in go2c.h

// square returns the square of an integer.
//
//export square
func square(x int) int { // This function when used in C takes as input GoInt and returns GoInt
	return x * x
}

// printBits prints an integer in binary format.
//
//export printBits
func printBits(x C.int) { // This function when used in C takes as input int and returns void
	fmt.Println(strconv.FormatInt(int64(x), 2))
}

// negate returns the logical negation of a boolean.
//
//export negate
func negate(b bool) bool { // This function when used in C takes as input GoUint8 and returns GoUint8
	return !b
}

// toBits returns a string with the binary representation of an integer
// Returned value must be freed with free() from C or with C.free() from Go.
//
//export toBits
func toBits(x C.int) *C.char { // This function when used in C takes as input int and returns char*
	return C.CString(fmt.Sprint(strconv.FormatInt(int64(x), 2)))
}

// conCat concatenates 2 strings.
// Returned value must be freed with free() from C or with C.free() from Go.
//
//export conCat
func conCat(a, b *C.char) *C.char { // This function when used in C takes as input char* and returns char*
	return C.CString(C.GoString(a) + C.GoString(b))
}

// join concatenates a slice of strings.
// Returned value must be freed with free() from C or with C.free() from Go.
//
//export join
func join(s []string) *C.char { // This function when used in C takes as input a GoString slice and returns char*
	return C.CString(strings.Join(s, ""))
}

// toUpper converts a string to upper case
// Returned value must be freed with free() from C or with C.free() from Go.
//
//export toUpper
func toUpper(a string) *C.char { // This function when used in C takes as input a GoString struct and returns char*
	return C.CString(strings.ToUpper(a))
}

// toString takes an integer and returns its sign and absolute value as strings.
// Multiple return values are represented in C as stuctures.
// Returned values must be freed with free() from C or with C.free() from Go.
//
//export toString
func toString(x int) (*C.char, *C.char) { // This function when used in C takes as input GoInt and returns a structure.
	var sign, num *C.char
	if x < 0 {
		sign = C.CString("-")
		x = -x
	} else {
		sign = C.CString("+")
	}
	num = C.CString(strconv.Itoa(x))
	return sign, num
}

// toUpper2 converts a string to upper case
// We cannot use this function from C safely, Go will panic at runtime unless
// we disable cgo runtime checks. The checks can be disabled by setting the environment
// variable GODEBUG=cgocheck=0, but it's not advised to. A Go function called by C code
// may not return a Go pointer.
//
//export toUpper2
func toUpper2(a string) string { // This function when used in C takes as input a GoString struct and returns a GoString
	return strings.ToUpper(a)
}

// ToUpper3 converts a string to upper case
// This beats the above restrictions, but it is really a recipe for disaster :)
// Don't write or use code similar to this!
//
//export toUpper3
func toUpper3(a string) unsafe.Pointer { // This function when used in C returns a void* that points to a Go string
	s := strings.ToUpper(a)
	return unsafe.Pointer(&s)
}
