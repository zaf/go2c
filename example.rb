#!/usr/bin/env ruby -w

#
#	Example of interfacing between Go and Ruby programs.
#	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>
#
#	This program is free software, distributed under the terms of the MIT License.
#	See the LICENSE file at the top of the source tree.
#

require 'fiddle'
require 'fiddle/import'

module Go
	extend Fiddle::Importer
	dlload './go2c.so'

	typealias "GoInt", "int"
	typealias "GoString", "struct { const char *; GoInt; }"

	GoString = struct ['const char * p', 'GoInt n']

	extern 'int Add(int, int)'
	extern 'GoInt Square(GoInt)'
	extern 'void PrintBits(int)'
	extern 'char* ToBits(int)'
	extern 'char* ConCat(char*, char*)'
	extern 'char* ToUpper(GoString)'
end

print "\nCalling Go functions from Ruby:\n"

x = 10
y = 5
z = Go.Add(x, y)
puts "Running Add(#{x}, #{y}) returned: #{z}"

s = Go.Square(x)
puts "Running Square(#{x}) returned: #{s}"

print "Running PrintBits(#{x}): "
Go.PrintBits(x) # Might be printed out of order. Oops.. Go actually uses threads!

bits = Go.ToBits(x)
puts "Running ToBits(#{x}) returned: #{bits}"

a = "Hello "
b = "world!"
c = Go.ConCat(a, b)
puts "Running ConCat(#{a}, #{b}) returned: #{c}"

str = Go::GoString.malloc
str.p = b
str.n = b.length

upper = Go.ToUpper(str)
puts "Running ToUpper(#{str.p}) returned: #{upper}"
