/*
	Example of interfacing between Go and C programs.
	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>

	This program is free software, distributed under the terms of the MIT License.
	See the LICENSE file at the top of the source tree.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "go2c.h"

int main() {
	printf("\nCalling Go functions from C:\n");
	// Ints
	int x = 10;
	int y = 5;
	int sum = Add(x,y);
	printf("Running Add(%d, %d) returned: %d\n", x, y, sum);

	GoInt sqr = Square((GoInt) x); // We can cast to and from Go Types
	printf("Running Square(%d) returned: %d\n", x, (int) sqr);

	printf("Running PrintBits(%d): ", x);
	PrintBits(x);  // Might be printed out of order. Oops.. Go actually uses threads!
	printf("Oops... Threads!\n");

	char *bits = ToBits(x);
	printf("Running ToBits(%d) returned: %s\n", x, bits);
	free(bits);

	// Strings
	char *a = "Hello ";
	char *b = "world!";
	char *c = ConCat(a,b);
	printf("Running ConCat(%s, %s) returned: %s\n", a, b, c);
	free(c);

	GoString gstr;
	gstr.p = b;
	gstr.n = (GoInt) strlen(gstr.p);
	char *upper = ToUpper(gstr);
	printf("Running ToUpper(%s) returned: %s\n", gstr.p, upper);
	free(upper);
	return 0;
}
