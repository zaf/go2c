/*
	Example of interfacing between Go and C programs.
	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>

	This program is free software, distributed under the terms of the MIT License.
	See the LICENSE file at the top of the source tree.
*/

package main

/*
// Example for interfacing between Go and C programs.
*/
import (
	"C"
)
import (
	"fmt"
	"strconv"
)

// All exported functions must have a '//export [name]' comment.

//export Add
func Add(x, y int) int { // This fuction when used in C takes as input GoInt and retuens GoInt
	return x + y
}

//export Square
func Square(x int) int { // This fuction when used in C takes as input GoInt and retuens GoInt
	return x * x
}

//export PrintBits
func PrintBits(x C.int) { // This fuction when used in C takes as input int and retuens void
	fmt.Println(strconv.FormatInt(int64(x), 2))
}

//export ToBits
func ToBits(x C.int) *C.char { // This fuction when used in C takes as input int and retuens char*
	return C.CString(fmt.Sprintf(strconv.FormatInt(int64(x), 2)))
}

//export ConCat
func ConCat(x, y *C.char) *C.char { // This fuction when used in C takes as input char* and retuens char*
	return C.CString(C.GoString(x) + C.GoString(y))
}

// A main function must be present, even if empty.
func main() {}
