#
#	Example of interfacing between Go and C programs.
#	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>
#

all: go2c example

go2c: go2c.go
	go build -buildmode=c-archive $^

example: example.c
	cc -g -Wall -pthread $^ go2c.a -o $@

clean:
	go clean
	rm -f go2c.a go2c.h example
