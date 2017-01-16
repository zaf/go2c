/*
	Example of interfacing between Go and C programs.
	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>

	This program is free software, distributed under the terms of the MIT License.
	See the LICENSE file at the top of the source tree.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <sys/resource.h>
#include "go2c.h"

#define RUNS 2000000

// Hi-Res timer
double get_time() {
    struct timeval t;
    struct timezone tzp;
    gettimeofday(&t, &tzp);
    return t.tv_sec + t.tv_usec*1e-6;
}

// Native C functions
int CAdd(int x, int y) {
	return x + y;
}

char * CConCat(const char *a, const char *b) {
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

	printf("Running Add() %d times:\n", RUNS);
	int x = 10;
	int y = 5;
	int i, sum;

	start = get_time();
	for (i=0; i<RUNS; i++) {
		sum = Add(x,y);
	}
	end = get_time();
	printf("Go took:\t%f sec, result: %d\n", end-start, sum);

	start = get_time();
	for (i=0; i<RUNS; i++) {
		sum = CAdd(x,y);
	}
	end = get_time();
	printf("C took: \t%f sec, result: %d\n", end-start, sum);

	printf("Running ConCat() %d times:\n", RUNS);
	char *a = "Hello ";
	char *b = "world!";
	char *c = NULL;

	start = get_time();
	for (i=0; i<RUNS; i++) {
		if (c) free(c);
		c = ConCat(a,b);
	}
	end = get_time();
	printf("Go took:\t%f sec, result: %s\n", end-start, c);
	free(c);
	c = NULL;

	start = get_time();
	for (i=0; i<RUNS; i++) {
		if (c) free(c);
		c = CConCat(a,b);
	}
	end = get_time();
	printf("C took: \t%f sec, result: %s\n", end-start, c);
	free(c);

	return 0;
}
