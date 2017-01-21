#!/usr/bin/env python3

#
#	Example of interfacing between Go and Python programs.
#	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>
#
#	This program is free software, distributed under the terms of the MIT License.
#	See the LICENSE file at the top of the source tree.
#

from timeit import default_timer as timer
import ctypes

Go = ctypes.CDLL('./go2c.so')

runs = 1000000

# Native functions
def add (x, y):
	return x + y

def conCat(a, b):
	return a + b

print("Running add() {} times:".format(runs))
x = 10
y = 5

start = timer()
for i in range(runs):
	z = Go.add(x, y)
end = timer()
print("Go took:\t{:0.6f} sec, result: {}".format(end-start, z))

start = timer()
for i in range(runs):
	z = add(x, y)
end = timer()
print("Python took:\t{:0.6f} sec, result: {}".format(end-start, z))

print("Running conCat() {} times:".format(runs))
Go.conCat.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
Go.conCat.restype = ctypes.c_char_p
a = ctypes.c_char_p(b"Hello ")
b = ctypes.c_char_p(b"world!")

start = timer()
for i in range(runs):
	c = Go.conCat(a, b)
end = timer()
print("Go took:\t{:0.6f} sec, result: {}".format(end-start, c.decode('utf-8')))

a = "Hello "
b = "world!"
start = timer()
for i in range(runs):
	c = conCat(a, b)
end = timer()
print("Python took:\t{:0.6f} sec, result: {}".format(end-start, c))
