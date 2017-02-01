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
require 'benchmark'

runs = 1_000_000

module Go
	extend Fiddle::Importer
	dlload './go2c.so'

	extern 'int add(int, int)'
	extern 'char* conCat(char*, char*)'
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
	m.report { runs.times { c = Go.conCat(a, b) } }
end

puts "Ruby takes:"
Benchmark.bm do |m|
	m.report { runs.times { c = conCat(a, b) } }
end
