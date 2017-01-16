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

char* CConCat(char *a, char *b) {
	char *str = malloc (sizeof (char) * 256);
	strcpy(str, a);
	strcat(str, b);
	return str;
}

int main() {
	int x = 10;
	int y = 5;
	int i, r;
	int runs = 2000000;

	printf("Running Add() %d times:\n", runs);
	double t0 = get_time();
	for (i=0; i<runs; i++) {
		r = Add(x,y);
	}
	double t1 = get_time();
	printf("Go took:\t%f sec, result: %d\n", t1-t0, r);

	t0 = get_time();
	for (i=0; i<runs; i++) {
		r = CAdd(x,y);
	}
	t1 = get_time();
	printf("C took: \t%f sec, result: %d\n", t1-t0, r);

	char *a = "Hello ";
	char *b = "world!";
	char *c;
	printf("Running ConCat() %d times:\n", runs);
	t0 = get_time();
	for (i=0; i<runs; i++) {
		 c = ConCat(a,b);
	}
	t1 = get_time();
	printf("Go took:\t%f sec, result: %s\n", t1-t0, c);
	free(c);

	t0 = get_time();
	for (i=0; i<runs; i++) {
		c = CConCat(a,b);
	}
	t1 = get_time();
	printf("C took: \t%f sec, result: %s\n", t1-t0, c);
	free(c);

	return 0;
}
