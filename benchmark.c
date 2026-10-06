/*
	Example of interfacing between Go and C programs.
	Copyright (C) 2017-2026, Lefteris Zafiris <zaf@fastmail.com>

	This program is free software, distributed under the terms of the MIT License.
	See the LICENSE file at the top of the source tree.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <sys/resource.h>
#include "go2c.h"

#define RUNS 1000000

// Hi-Res timer
double get_time() {
    struct timeval t;
    struct timezone tzp;
    gettimeofday(&t, &tzp);
    return t.tv_sec + t.tv_usec*1e-6;
}

// Native C functions
// cAdd is noinline so the benchmark measures a real call: inlined at -O3
// it would fold into the loop as a plain add and measure nothing.
int __attribute__((noinline)) cAdd(int x, int y) {
	return x + y;
}

char * cConCat(const char *a, const char *b) {
    char *str = NULL;
    size_t n = 0;

    if ( a ) {
		n += strlen(a);
	}
    if ( b ) {
		n += strlen(b);
	}
    if ( ( a || b ) && ( str = malloc( n + 1 ) ) != NULL ) {
        *str = '\0';
        if ( a ) {
			strcpy(str, a);
		}
        if ( b ) {
			strcat(str, b);
		}
    }
    return str;
}

int main() {
	double start, end;

	printf("Running add() %d times:\n", RUNS);
	// x and y must be volatile: as plain ints the compiler can prove they
	// hold 10 and 5 and collapse the RUNS calls below into a single call,
	// even with cAdd() marked noinline.
	volatile int x = 10;
	volatile int y = 5;
	int i, sum = 0;

	start = get_time();
	for (i=0; i<RUNS; i++) {
		sum += add(x,y);
	}
	end = get_time();
	printf("Go took:\t%f sec, result: %d\n", end-start, sum);
	sum = 0;

	start = get_time();
	for (i=0; i<RUNS; i++) {
		sum += cAdd(x,y);
	}
	end = get_time();
	printf("C took: \t%f sec, result: %d\n", end-start, sum);

	printf("Running conCat() %d times:\n", RUNS);
	char *a = "Hello ";
	char *b = "world!";
	char *c = NULL;

	start = get_time();
	for (i=0; i<RUNS; i++) {
		if (c) free(c);
		c = conCat(a,b);
	}
	end = get_time();
	printf("Go took:\t%f sec, result: %s\n", end-start, c);
	free(c);
	c = NULL;

	start = get_time();
	for (i=0; i<RUNS; i++) {
		if (c) free(c);
		c = cConCat(a,b);
	}
	end = get_time();
	printf("C took: \t%f sec, result: %s\n", end-start, c);
	free(c);

	return 0;
}
