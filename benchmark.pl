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
	#include <string.h>

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
		strcat(str, b);
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
my $r;

# Testing Add functions
print "Running Add() $runs times:\n";
my $t0 = Benchmark->new;
for (1..$runs) {
	$r = Go::Add($x, $y);
}
my $t1 = Benchmark->new;
print "Go took:\t", timestr(timediff($t1, $t0));
print " result: $r\n";
$r = '';

$t0 = Benchmark->new;
for (1..$runs) {
	$r = Go::CAdd($x, $y);
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
	$r = Go::ConCat($a, $b);
}
$t1 = Benchmark->new;
print "Go took:\t", timestr(timediff($t1, $t0));
print " result: $r\n";
$r = '';

$t0 = Benchmark->new;
for (1..$runs) {
	$r = Go::CConCat($a, $b);
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
