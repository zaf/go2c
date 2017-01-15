#! /usr/src/env perl

use strict;
use warnings;

package Go;

use Inline (C => Config =>
    enable       => "autowrap",
    ccflagsex    => '-pthread',
    auto_include => '#include "go2c.h"',
    myextlib     => '/home/zaf/src/go2c/go2c.so', # Change me!!
);
#use Inline C => 'extern GoInt Add(GoInt p0, GoInt p1);';
#use Inline C => 'extern GoInt Square(GoInt p0);';
use Inline C => 'extern void PrintBits(int p0);';
use Inline C => 'extern char* ToBits(int p0);';
use Inline C => 'extern char* ConCat(char* p0, char* p1);';

package main;

print "\nCalling Go fuctions from Perl:\n";

my ($x, $y) = (10, 5);
#print "Running Add($x, $y) returned: ", Go::Add($x, $y), "\n";
#print "Running Square($x) returned: ", Go::Square($x), "\n";
print "Running PrintBits($x): ";
Go::PrintBits($x); # Might be printed out of order. Oops.. Go actually uses threads!
print "Oops... Threads!\n";

print "Running ToBits($x) returned: ", Go::ToBits($x), "\n";

my $a = "Hello ";
my $b = "world!";
print "Running ConCat($a, $b) returned: ", Go::ConCat($a,$b), "\n";
