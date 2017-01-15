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

//export Add
func Add(x, y int) int {
	return x + y
}

//export Square
func Square(x int) int {
	return x * x
}

//export PrintBits
func PrintBits(x int) {
	fmt.Println(strconv.FormatInt(int64(x), 2))
}

//export ToBits
func ToBits(x int) *C.char {
	return C.CString(fmt.Sprintf(strconv.FormatInt(int64(x), 2)))
}

//export ConCat
func ConCat(x, y *C.char) *C.char {
	return C.CString(C.GoString(x) + C.GoString(y))
}

func main() {}
