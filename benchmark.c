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

// Hi-Res timer
double get_time() {
    struct timeval t;
    struct timezone tzp;
    gettimeofday(&t, &tzp);
    return t.tv_sec + t.tv_usec*1e-6;
}

// Native C functions
int CAdd( int x, int y) {
	return x + y;
}

const char* CConCat(char *a, char *b) {
	char *str = malloc (sizeof (char) * 256);
	strcpy(str, a);
	strcpy(str, b);
	return str;
}

int main() {
	int x = 10;
	int y = 5;
	int i;
	int runs = 2000000;

	printf("Running Add() %d times:\n", runs);
	double t0 = get_time();
	for (i=0; i<runs; i++) {
		Add(x,y);
	}
	double t1 = get_time();
	printf("Go took:\t%f\n", t1-t0);

	t0 = get_time();
	for (i=0; i<runs; i++) {
		CAdd(x,y);
	}
	t1 = get_time();
	printf("C took: \t%f\n", t1-t0);

	char *a = "Hello ";
	char *b = "world!";
	printf("Running ConCat() %d times:\n", runs);
	t0 = get_time();
	for (i=0; i<runs; i++) {
		ConCat(a,b);
	}
	t1 = get_time();
	printf("Go took:\t%f\n", t1-t0);

	t0 = get_time();
	for (i=0; i<runs; i++) {
		CConCat(a,b);
	}
	t1 = get_time();
	printf("C took: \t%f\n", t1-t0);

	return 0;
}
