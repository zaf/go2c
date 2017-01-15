/*
	Example of interfacing between Go and C programs.
	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>

	This program is free software, distributed under the terms of the MIT License.
	See the LICENSE file at the top of the source tree.
*/

#include "stdio.h"
#include "go2c.h"

int main() {
	printf("Calling Go functions from C:\n\n");
	// Ints
	int x = 10;
	int y = 5;
	printf("Running Add(%d, %d) returned: %d\n", x, y, Add(x,y));
	printf("Running Square(%d) returned: %d\n", x, Square(x));
	printf("Running PrintBits(%d): ", x);
	PrintBits(x);  // Might be printed out of order. Oops.. Go actually uses threads!
	printf("Oops... Threads!\n");

	printf("Running ToBits(%d) returned: %s\n", x, ToBits(x));

	// Strings
	char *a = "Hello ";
	char *b = "world!";
	printf("Running ConCat(%s, %s) returned: %s\n", a, b, ConCat(a,b));
	return 0;
}
