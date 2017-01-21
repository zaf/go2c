#!/usr/bin/env ruby

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

	extern 'int add(int, int)'
	extern 'GoInt square(GoInt)'
	extern 'void printBits(int)'
	extern 'char* toBits(int)'
	extern 'char* conCat(char*, char*)'
	extern 'char* toUpper(GoString)'
end

print "\nCalling Go functions from Ruby:\n"

x = 10
y = 5
z = Go.add(x, y)
puts "Running add(#{x}, #{y}) returned: #{z}"

s = Go.square(x)
puts "Running square(#{x}) returned: #{s}"

print "Running printBits(#{x}): "
Go.printBits(x) # Might be printed out of order. Oops.. Go actually uses threads!

bits = Go.toBits(x)
puts "Running toBits(#{x}) returned: #{bits}"

a = "Hello "
b = "world!"
c = Go.conCat(a, b)
puts "Running conCat(#{a}, #{b}) returned: #{c}"

str = Go::GoString.malloc
str.p = b
str.n = b.length

upper = Go.toUpper(str)
puts "Running toUpper(#{str.p}) returned: #{upper}"
