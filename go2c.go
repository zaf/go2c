/*
	Example of interfacing between Go and C programs.
	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>

	This program is free software, distributed under the terms of the MIT License.
	See the LICENSE file at the top of the source tree.
*/

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

// All exported functions must have a '//export [name]' comment.

//export Add
func Add(x, y C.int) C.int { // This function when used in C takes as input int and returns int
	return x + y
}

//export Square
func Square(x int) int { // This function when used in C takes as input GoInt and returns GoInt
	return x * x
}

//export PrintBits
func PrintBits(x C.int) { // This function when used in C takes as input int and returns void
	fmt.Println(strconv.FormatInt(int64(x), 2))
}

//export ToBits
func ToBits(x C.int) *C.char { // This function when used in C takes as input int and returns char*
	// Returned value must be freed with free() from C or with C.free() from Go.
	return C.CString(fmt.Sprintf(strconv.FormatInt(int64(x), 2)))
}

//export ConCat
func ConCat(a, b *C.char) *C.char { // This function when used in C takes as input char* and returns char*
	// Returned value must be freed with free() from C or with C.free() from Go.
	return C.CString(C.GoString(a) + C.GoString(b))
}

//export ToUpper
func ToUpper(a string) *C.char { // This function when used in C takes as input a GoString struct and returns char*
	// Returned value must be freed with free() from C or with C.free() from Go.
	return C.CString(strings.ToUpper(a))
}

//export ToUpper2
func ToUpper2(a string) string { // This function when used in C takes as input a GoString struct and returns a GoString
	// We cannot use this function from C safely, Go will panic at runtime unless we disable cgo runtime checks.
	// The checks can be disabled by setting the environment variable GODEBUG=cgocheck=0, but it's not advised to.
	// A Go function called by C code may not return a Go pointer.
	return strings.ToUpper(a)
}

//export ToUpper3
func ToUpper3(a string) unsafe.Pointer { // This function when used in C returns a void* that points to a Go string
	// This beats the above restrictions, but it is really a recipe for disaster :)
	// Don't write or use code similar to this!
	s := strings.ToUpper(a)
	return unsafe.Pointer(&s)
}

// A main function must be present, even if empty.
func main() {}
