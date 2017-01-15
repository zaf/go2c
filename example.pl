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

package Go;

use Inline (C => Config =>
    enable       => "autowrap",
    ccflagsex    => '-pthread',
    auto_include => '#include "go2c.h"',
    myextlib     => '/home/zaf/src/go2c/go2c.so', # Change me!!
);

use Inline C => <<'END_OF_C_CODE';
	extern int Add(int p0, int p1);
//	extern GoInt Square(GoInt p0);  // Missing typemap for GoInt
	extern void PrintBits(int p0);
	extern char* ToBits(int p0);
	extern char* ConCat(char* p0, char* p1);
END_OF_C_CODE

package main;

print "\nCalling Go functions from Perl:\n";

my ($x, $y) = (10, 5);
print "Running Add($x, $y) returned: ", Go::Add($x, $y), "\n";
#print "Running Square($x) returned: ", Go::Square($x), "\n";
print "Running PrintBits($x): ";
Go::PrintBits($x); # Might be printed out of order. Oops.. Go actually uses threads!
print "Oops... Threads!\n";

print "Running ToBits($x) returned: ", Go::ToBits($x), "\n";

my $a = "Hello ";
my $b = "world!";
print "Running ConCat($a, $b) returned: ", Go::ConCat($a,$b), "\n";
