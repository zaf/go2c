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

package Go;

my $dir;
BEGIN {
	use Cwd;
	$dir = getcwd();
}

use Inline (C => Config =>
    enable       => 'autowrap',
    typemaps     => 'go.typemap',  # Here we define the missing typemaps for Go
    ccflagsex    => '-Wall -g -pthread',
    auto_include => '#include "go2c.h"',
    myextlib     => $dir . '/go2c.so',
);

use Inline C => <<'END_OF_C_CODE';
	extern int add(int p0, int p1);
	extern GoInt square(GoInt p0);
	extern void printBits(int p0);
	extern char* toBits(int p0);
	extern char* conCat(char* p0, char* p1);
END_OF_C_CODE

package main;

print "\nCalling Go functions from Perl:\n";

my ($x, $y) = (10, 5);
print "Running add($x, $y) returned: ", Go::add($x, $y), "\n";
print "Running square($x) returned: ", Go::square($x), "\n";
print "Running printBits($x): ";
Go::printBits($x); # Might be printed out of order. Oops.. Go actually uses threads!
print "Oops... Threads!\n";

print "Running toBits($x) returned: ", Go::toBits($x), "\n";

my $a = "Hello ";
my $b = "world!";
print "Running conCat($a, $b) returned: ", Go::conCat($a,$b), "\n";
