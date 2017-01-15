#
#	Example of interfacing between Go and C programs.
#	Copyright (C) 2017, Lefteris Zafiris <zaf@fastmail.com>
#

all: go2c.a go2c.so example benchmark

# Build object file
go2c.a: go2c.go
	go build -buildmode=c-archive -o $@ $^

# Build shared lib
go2c.so: go2c.go
	go build -buildmode=c-shared -o $@ $^

# Build C example
example: example.c
	cc -g -Wall -pthread -o $@ $^ go2c.a

# Build C benchmark
benchmark: benchmark.c
	cc -g -Wall -pthread -o $@ $^ go2c.a

run: all
	@echo "=== Running the C example code ==="
	./example
	@echo "=== Running the Perl example code ==="
	perl example.pl

bench: all
	@echo "=== Running the C benchmark ==="
	./benchmark
	@echo "=== Running the Perl benchmark ==="
	perl benchmark.pl

clean:
	go clean
	rm -f go2c.a go2c.so go2c.h example benchmark
	rm -rf _Inline
