#! /usr/bin/env perl

#
#	Example of interfacing between Go and Perl programs.
#	Copyright (C) 2017-2026, Lefteris Zafiris <zaf@fastmail.com>
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
	typemaps     => 'go.typemap',
	ccflagsex    => '-Wall -g -pthread',
	optimize     => '-march=native -O3',
	auto_include => '#include "go2c.h"',
	myextlib     => $dir . '/go2c.so',
);

use Inline C => <<'END_OF_C_CODE';
	extern int add(int p0, int p1);
	extern GoInt square(GoInt p0);
	extern void printBits(int p0);
	extern char* toBits(int p0);
	extern char* conCat(char* p0, char* p1);
	extern char* toUpper(GoString p0);
	extern void* getBuf();
	extern void showBuf();
	extern void releaseBuf();

	// Helpers to access pinned Go memory from Perl: void* arrives as a plain
	// integer address and Perl cannot dereference it. peekStr() returns a
	// copy as a fresh SV: its refcount 1 is handed to the caller, so it
	// must not be mortal (T_SV passes RETVAL through as-is). It also must
	// NOT return char*: the GO_PV output typemap would free() the pinned
	// Go pointer and corrupt the heap.
	SV* peekStr(void *p) {
	    return newSVpv((const char *)p, 0);
	}
	void poke(void *p, int off, unsigned char val) {
	    ((unsigned char *)p)[off] = val;
	}
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

print "Running toUpper($b) returned: ", Go::toUpper($b), "\n";

# getBuf() returns a raw pointer to pinned Go memory as a plain integer
# address. It must not be freed and stays valid only until Go::releaseBuf().
my $addr = Go::getBuf();
print "Running getBuf() returned: ", Go::peekStr($addr), "\n";
Go::poke($addr, 0, ord('X')); # writing into Go memory from Perl
Go::showBuf(); # Might be printed out of order. Oops.. Go actually uses threads!
Go::releaseBuf(); # The pointer must not be used anymore after this
