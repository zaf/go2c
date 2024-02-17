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
	int sum = add(x,y);
	printf("Running add(%d, %d) returned: %d\n", x, y, sum);

	GoInt sqr = square((GoInt) x); // We can cast to and from Go Types
	printf("Running square(%d) returned: %d\n", x, (int) sqr);

	printf("Running printBits(%d): ", x);
	printBits(x);  // Might be printed out of order. Oops.. Go actually uses threads!
	printf("Oops... Threads!\n");

	char *bits = toBits(x);
	printf("Running toBits(%d) returned: %s\n", x, bits);
	free(bits);

	// Strings
	char *a = "Hello ";
	char *b = "world!";
	char *c = conCat(a,b);
	printf("Running conCat(%s, %s) returned: %s\n", a, b, c);
	free(c);

	GoString gstr;
	gstr.p = b;
	gstr.n = (GoInt) strlen(gstr.p);
	char *upper = toUpper(gstr);
	printf("Running toUpper(%s) returned: %s\n", gstr.p, upper);
	free(upper);

	struct toString_return s = toString(x);
	printf("Running toString(%d) returned: %s, %s\n", x, s.r0, s.r1);
	free(s.r0);
	free(s.r1);

	return 0;
}
