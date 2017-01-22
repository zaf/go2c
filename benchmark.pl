#! /usr/bin/env perl

#
#	Example of interfacing between Go and Perl programs.
#	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>
#
#	This program is free software, distributed under the terms of the MIT License.
#	See the LICENSE file at the top of the source tree.
#

use strict;
use warnings;
use Benchmark ':hireswallclock';

package Go;

my $dir;
BEGIN {
	use Cwd;
	$dir = getcwd();
}

use Inline (C => Config =>
	enable       => "autowrap",
	ccflagsex    => '-Wall -g -pthread',
	#optimize     => '-march=native -O3',
	auto_include => '#include "go2c.h"',
	myextlib     => $dir . '/go2c.so',
);

use Inline C => <<'END_OF_C_CODE';
#include <stdlib.h>
#include <string.h>

// Exported Go Functions
extern int add(int p0, int p1);
extern char* conCat(char* p0, char* p1);

// Native C functions
int cAdd( int x, int y) {
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
END_OF_C_CODE

package main;

sub add {
	my ($x, $y) = @_;
	return $x + $y;
}

sub concat {
	my ($a, $b) = @_;
	return $a . $b;
}

my $runs = 1_000_000;

my $x = 10;
my $y = 5;
my $a = "Hello ";
my $b = "world!";
my $r;

# Testing Add functions
print "Running add() $runs times:\n";
my $t0 = Benchmark->new;
for (1..$runs) {
	$r = Go::add($x, $y);
}
my $t1 = Benchmark->new;
print "Go took:\t", timestr(timediff($t1, $t0));
print " result: $r\n";
$r = '';

$t0 = Benchmark->new;
for (1..$runs) {
	$r = Go::cAdd($x, $y);
}
$t1 = Benchmark->new;
print "C  took:\t", timestr(timediff($t1, $t0));
print " result: $r\n";
$r = '';

$t0 = Benchmark->new;
for (1..$runs) {
	$r = add($x, $y);
}
$t1 = Benchmark->new;
print "Perl took:\t", timestr(timediff($t1, $t0));
print " result: $r\n";
$r = '';

# Testing concat functions
print "Running ConCat() $runs times:\n";
$t0 = Benchmark->new;
for (1..$runs) {
	$r = Go::conCat($a, $b);
}
$t1 = Benchmark->new;
print "Go took:\t", timestr(timediff($t1, $t0));
print " result: $r\n";
$r = '';

$t0 = Benchmark->new;
for (1..$runs) {
	$r = Go::cConCat($a, $b);
}
$t1 = Benchmark->new;
print "C  took:\t", timestr(timediff($t1, $t0));
print " result: $r\n";
$r = '';

$t0 = Benchmark->new;
for (1..$runs) {
	$r = concat($a, $b);
}
$t1 = Benchmark->new;
print "Perl took:\t", timestr(timediff($t1, $t0));
print " result: $r\n";
$r = '';
