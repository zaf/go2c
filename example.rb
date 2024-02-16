#!/usr/bin/env ruby

#
#	Example of interfacing between Go and Ruby programs.
#	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>
#
#	This program is free software, distributed under the terms of the MIT License.
#	See the LICENSE file at the top of the source tree.
#

require 'ffi'

module Go
	extend FFI::Library
	ffi_lib './go2c.so'

	# define class String to map:
	# C type struct { const char *p; GoInt n; }
	class String < FFI::Struct
		layout	:p,     :pointer,
				:len,   :long_long

		def self.value
			return self.val
		end

		def initialize(str)
			self[:p] = FFI::MemoryPointer.from_string(str)
			self[:len] = str.bytesize
			return self
		end
	end

	attach_function :add, [:int, :int], :int
	attach_function :square, [:int], :int
	attach_function :printBits, [:int], :void
	attach_function :toBits, [:int], :string
	attach_function :conCat, [:string, :string], :string
	attach_function :toUpper, [String.value], :string
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

gostr = Go::String.new(b)
upper = Go.toUpper(gostr)
puts "Running toUpper(#{b}) returned: #{upper}"
