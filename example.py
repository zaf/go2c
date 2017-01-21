#!/usr/bin/env python

#
#	Example of interfacing between Go and Python programs.
#	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>
#
#	This program is free software, distributed under the terms of the MIT License.
#	See the LICENSE file at the top of the source tree.
#

import ctypes

Go = ctypes.CDLL('./go2c.so')

print("\nCalling Go functions from Python:")

x = 10
y = 5

# By default functions are assumed to return the C int type
z = Go.add(x, y)
print("Running add({}, {}) returned: {}".format(x, y, z))

s = Go.square(x)
print("Running square({}) returned: {}".format(x, s))

print("Running printBits({}): ".format(x), end="")
Go.printBits(x) # Might be printed out of order. Oops.. Go actually uses threads!
print("Oops... Threads!")

# We have to set the the restype attribute when the return type is not int
Go.toBits.restype = ctypes.c_char_p
bits = Go.toBits(x)
print("Running toBits({}) returned: {}".format(x, bits.decode('utf-8')))

# We can also set the argtypes attribute
Go.conCat.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
Go.conCat.restype = ctypes.c_char_p
a = ctypes.c_char_p(b"Hello ")
b = ctypes.c_char_p(b"world!")
c = Go.conCat(a, b)
print("Running conCat({}, {}) returned: {}".format(a.value.decode('utf-8'), b.value.decode('utf-8'), c.decode('utf-8')))

# We can define structures
class GoString(ctypes.Structure):
	_fields_ = [("p", ctypes.c_char_p), ("n",  ctypes.c_int)]

Go.toUpper.argtypes = [GoString]
Go.toUpper.restype = ctypes.c_char_p

str = GoString(a, len(a.value))
upper = Go.toUpper(str)
print("Running toUpper({}) returned: {}".format(str.p.decode('utf-8'), upper.decode('utf-8')))
