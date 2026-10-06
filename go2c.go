/*
	Example of interfacing between Go and C programs.
	Copyright (C) 2017-2026, Lefteris Zafiris <zaf@fastmail.com>

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
	"runtime"
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
// When called from C pass strictly 0 or 1: the GoUint8 argument is
// reinterpreted as a Go bool, so other values are invalid.
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
func join(s []string) *C.char { // This function when used in C takes as input a GoSlice of GoString elements and returns char*
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
	// Negating MinInt64 overflows, so format first and strip the sign instead of using -x.
	num := strconv.FormatInt(int64(x), 10)
	if x < 0 {
		return C.CString("-"), C.CString(num[1:])
	}
	return C.CString("+"), C.CString(num)
}

// toUpper2 converts a string to upper case
// From https://pkg.go.dev/cmd/cgo#hdr-Passing_pointers:
// A Go function called by C code may return a Go pointer to pinned memory (which implies that it may not return a string, slice, channel, and so forth).
// Pointers to pinned memory can be returned to C, see getBuf() below.
//
//export toUpper2
func toUpper2(a string) string { // We cannot use this function from C, Go will panic at runtime.
	return strings.ToUpper(a)
}

// runtime.Pinner is the one exception to the cgo pointer rules: it lets C
// keep a pointer to Go memory after the call returns, for as long as the
// memory stays pinned. The Pinner must stay reachable while C uses the
// pointer, so it lives in a global here. Real code would need to guard it
// with a mutex, since cgo calls from different threads run concurrently.

var (
	pinner runtime.Pinner
	buf    = new([16]byte)
)

// getBuf returns a pointer to Go memory that C may keep and access after
// the call returns, because runtime.Pinner pins it in place.
// Strings and slices can never be pinned, so this works only for memory
// that contains no Go pointers.
// The pointer is valid until releaseBuf() is called: it must not be freed
// with free() and must not be used afterwards.
//
//export getBuf
func getBuf() unsafe.Pointer { // This function when used in C takes no input and returns void*
	copy(buf[:], "Go pinned bytes") // 15 bytes, the trailing NUL at buf[15] is kept
	pinner.Pin(buf)
	return unsafe.Pointer(buf)
}

// showBuf prints the buffer contents as seen from Go, including any
// changes C made through the pointer.
//
//export showBuf
func showBuf() { // This function when used in C takes no input and returns void
	s := string(buf[:])
	if i := strings.IndexByte(s, 0); i >= 0 {
		s = s[:i]
	}
	fmt.Println("Go reads buf:", s)
}

// releaseBuf unpins the buffer. Pointers obtained from getBuf() must not
// be used after this: the GC is then free to move or reclaim the memory.
//
//export releaseBuf
func releaseBuf() { // This function when used in C takes no input and returns void
	pinner.Unpin()
}
