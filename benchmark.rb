#!/usr/bin/env ruby

#
#	Example of interfacing between Go and Ruby programs.
#	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>
#
#	This program is free software, distributed under the terms of the MIT License.
#	See the LICENSE file at the top of the source tree.
#

require 'ffi'
require 'benchmark'

runs = 1_000_000

# Go string-returning functions return malloc'd memory,
# so we bind libc's free() to release it after copying.
module LibC
	extend FFI::Library
	ffi_lib FFI::Library::LIBC
	attach_function :free, [:pointer], :void
end

module Go
	extend FFI::Library
	ffi_lib './go2c.so'

	attach_function :add, [:int, :int], :int
	attach_function :conCat, [:string, :string], :pointer
end

# Native functions
def add(x, y)
	return x + y
end

def conCat(a, b)
	return a + b
end

x =10
y = 5

puts "Running add() #{runs} times:"
puts "Go takes:"
Benchmark.bm do |m|
	m.report { runs.times { z = Go.add(x, y) } }
end

puts "Ruby takes:"
Benchmark.bm do |m|
	m.report { runs.times { z = add(x, y) } }
end

a = "Hello "
b = "world!"

puts "Running conCat() #{runs} times:"
puts "Go takes:"
Benchmark.bm do |m|
	m.report { runs.times { p = Go.conCat(a, b); c = p.read_string; LibC.free(p) } }
end

puts "Ruby takes:"
Benchmark.bm do |m|
	m.report { runs.times { c = conCat(a, b) } }
end
