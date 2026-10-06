#!/usr/bin/env python3

#
#	Example of interfacing between Go and Python programs.
#	Copyright (C) 2017-2026, Lefteris Zafiris <zaf@fastmail.com>
#
#	This program is free software, distributed under the terms of the MIT License.
#	See the LICENSE file at the top of the source tree.
#

import ctypes

Go = ctypes.CDLL('./go2c.so')

# Go string-returning functions return malloc'd memory.
# ctypes copies c_char_p return values and loses the pointer, so we take the
# return value as a raw pointer, copy it ourselves and free it with libc's free().
libc = ctypes.CDLL(None)
libc.free.argtypes = [ctypes.c_void_p]

def goString(p):
	"""Copy a Go-allocated char* into a Python str and free it."""
	s = ctypes.string_at(p).decode('utf-8')
	libc.free(p)
	return s

print("\nCalling Go functions from Python:")

x = 10
y = 5

# By default functions are assumed to return the C int type
z = Go.add(x, y)
print("Running add({}, {}) returned: {}".format(x, y, z))

# square takes and returns a GoInt which is a 64 bit integer,
# so we must set argtypes and restype to avoid truncation to 32 bits
Go.square.argtypes = [ctypes.c_longlong]
Go.square.restype = ctypes.c_longlong
s = Go.square(x)
print("Running square({}) returned: {}".format(x, s))

print("Running printBits({}): ".format(x), end="")
Go.printBits(x) # Might be printed out of order. Oops.. Go actually uses threads!
print("Oops... Threads!")

# We have to set the the restype attribute when the return type is not int
Go.toBits.restype = ctypes.c_void_p
bits = Go.toBits(x)
print("Running toBits({}) returned: {}".format(x, goString(bits)))

# We can also set the argtypes attribute
Go.conCat.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
Go.conCat.restype = ctypes.c_void_p
a = ctypes.c_char_p(b"Hello ")
b = ctypes.c_char_p(b"world!")
c = Go.conCat(a, b)
print("Running conCat({}, {}) returned: {}".format(a.value.decode('utf-8'), b.value.decode('utf-8'), goString(c)))

# We can define structures
# GoString is struct { const char *p; ptrdiff_t n; } so n must be 64 bit
class GoString(ctypes.Structure):
	_fields_ = [("p", ctypes.c_char_p), ("n",  ctypes.c_ssize_t)]

Go.toUpper.argtypes = [GoString]
Go.toUpper.restype = ctypes.c_void_p

str = GoString(b, len(b.value))
upper = Go.toUpper(str)
print("Running toUpper({}) returned: {}".format(str.p.decode('utf-8'), goString(upper)))

class toString_return(ctypes.Structure):
	_fields_ = [("s", ctypes.c_void_p), ("n",  ctypes.c_void_p)]

Go.toString.argtypes = [ctypes.c_longlong]
Go.toString.restype = toString_return

s = Go.toString(x)
print("Running toString({}) returned: {} {}".format(x, goString(s.s), goString(s.n)))

# getBuf() returns a raw pointer to pinned Go memory, not a malloc'd C string:
# it must not be freed and stays valid only until Go.releaseBuf() is called.
Go.getBuf.restype = ctypes.c_void_p
pinned = Go.getBuf()
print("Running getBuf() returned: {}".format(ctypes.string_at(pinned).decode('utf-8')))
ctypes.memmove(pinned, b"X", 1)  # Writing into Go memory from Python
Go.showBuf() # Might be printed out of order. Oops.. Go actually uses threads!
Go.releaseBuf()
