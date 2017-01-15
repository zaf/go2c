#! /usr/src/env perl

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

use Inline (C => Config =>
    enable       => "autowrap",
    ccflagsex    => '-pthread',
    auto_include => '#include "go2c.h"',
    myextlib     => '/home/zaf/src/go2c/go2c.so', # Change me!!
);

use Inline C => <<'END_OF_C_CODE';
	#include <stdlib.h>

// Exported Go Functions
	extern int Add(int p0, int p1);
	extern char* ConCat(char* p0, char* p1);

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

my $runs = 2_000_000;

my $x = 10;
my $y = 5;
my $a = "Hello ";
my $b = "world!";

# Testing Add functions
print "Running Add() $runs times:\n";
my $t0 = Benchmark->new;
for (1..$runs) {
	Go::Add($x, $y);
}
my $t1 = Benchmark->new;
print "Go took:\t", timestr(timediff($t1, $t0)), "\n";

$t0 = Benchmark->new;
for (1..$runs) {
	Go::CAdd($x, $y);
}
$t1 = Benchmark->new;
print "C  took:\t", timestr(timediff($t1, $t0)), "\n";

$t0 = Benchmark->new;
for (1..$runs) {
	add($x, $y);
}
$t1 = Benchmark->new;
print "Perl took:\t", timestr(timediff($t1, $t0)), "\n\n";


# Testing concat functions
print "Running ConCat() $runs times:\n";
$t0 = Benchmark->new;
for (1..$runs) {
	Go::ConCat($a, $b);
}
$t1 = Benchmark->new;
print "Go took:\t", timestr(timediff($t1, $t0)), "\n";

$t0 = Benchmark->new;
for (1..$runs) {
	Go::CConCat($a, $b);
}
$t1 = Benchmark->new;
print "C  took:\t", timestr(timediff($t1, $t0)), "\n";

$t0 = Benchmark->new;
for (1..$runs) {
	concat($a, $b);
}
$t1 = Benchmark->new;
print "Perl took:\t", timestr(timediff($t1, $t0)), "\n\n";
