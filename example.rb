#!/usr/bin/env ruby

#
#	Example of interfacing between Go and Ruby programs.
#	Copyright (C) 2017-2026, Lefteris Zafiris <zaf@fastmail.com>
#
#	This program is free software, distributed under the terms of the MIT License.
#	See the LICENSE file at the top of the source tree.
#

require 'ffi'

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
	# define class String to map the exported C type
	# for Go strings: struct { const char *p; GoInt n; }
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
	# define class StringReturn to map the exported C type
	# struct toString_return { char* r0; char* r1; };
	class StringReturn < FFI::Struct
		layout	:r0,     :pointer,
				:r1,     :pointer
		def self.value
			return self.val
		end
	end
	# Returned char* are mapped to :pointer so we can free() them ourselves,
	# square and toString use :long_long to match GoInt (64 bit).
	attach_function :add, [:int, :int], :int
	attach_function :square, [:long_long], :long_long
	attach_function :printBits, [:int], :void
	attach_function :toBits, [:int], :pointer
	attach_function :conCat, [:string, :string], :pointer
	attach_function :toUpper, [String.value], :pointer
	attach_function :toString, [:long_long], StringReturn.value
	attach_function :getBuf, [], :pointer
	attach_function :showBuf, [], :void
	attach_function :releaseBuf, [], :void
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
puts "Oops... Threads!"

bits = Go.toBits(x)
puts "Running toBits(#{x}) returned: #{bits.read_string}"
LibC.free(bits)

a = "Hello "
b = "world!"
c = Go.conCat(a, b)
puts "Running conCat(#{a}, #{b}) returned: #{c.read_string}"
LibC.free(c)

gostr = Go::String.new(b)
upper = Go.toUpper(gostr)
puts "Running toUpper(#{b}) returned: #{upper.read_string}"
LibC.free(upper)

s = Go.toString(x)
puts "Running toString(#{x}) returned: #{s[:r0].read_string} #{s[:r1].read_string}"
LibC.free(s[:r0])
LibC.free(s[:r1])

# getBuf() returns a raw pointer to pinned Go memory, not a malloc'd C
# string: it must not be freed and stays valid only until Go.releaseBuf().
pinned = Go.getBuf()
puts "Running getBuf() returned: #{pinned.read_string}"
pinned.put_bytes(0, 'X') # Writing into Go memory from Ruby
Go.showBuf() # Might be printed out of order. Oops.. Go actually uses threads!
Go.releaseBuf()
