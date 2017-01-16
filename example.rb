#!/usr/bin/env ruby -w

#
#	Example of interfacing between Go and Ruby programs.
#	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>
#
#	This program is free software, distributed under the terms of the MIT License.
#	See the LICENSE file at the top of the source tree.
#

require 'fiddle'

go2c = Fiddle.dlopen('./go2c.so')

Add = Fiddle::Function.new(
	go2c['Add'],
	[Fiddle::TYPE_INT, Fiddle::TYPE_INT],
	Fiddle::TYPE_INT
)

Square = Fiddle::Function.new(
	go2c['Square'],
	[Fiddle::TYPE_INT],
	Fiddle::TYPE_INT
)

PrintBits = Fiddle::Function.new(
	go2c['PrintBits'],
	[Fiddle::TYPE_INT],
	Fiddle::TYPE_VOID
)

ToBits = Fiddle::Function.new(
	go2c['ToBits'],
	[Fiddle::TYPE_VOIDP],
	Fiddle::TYPE_VOIDP
)

ConCat = Fiddle::Function.new(
	go2c['ConCat'],
	[Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP],
	Fiddle::TYPE_VOIDP
)

print "\nCalling Go functions from Ruby:\n"

x = 10
y = 5
z = Add.call(x, y)
puts "Running Add(#{x}, #{y}) returned: #{z}"

s = Square.call(x)
puts "Running Square(#{x}) returned: #{s}"

print "Running PrintBits(#{x}): "
PrintBits.call(x) # Might be printed out of order. Oops.. Go actually uses threads!

bits = ToBits.call(x)
puts "Running ToBits(#{x}) returned: #{bits}"

a = "Hello "
b = "world!"
c = ConCat.call(a, b)
puts "Running ConCat(#{a}, #{b}) returned: #{c}"
