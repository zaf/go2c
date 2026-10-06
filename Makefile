#
#	Example of interfacing between Go and C programs.
#	Copyright (C) 2017-2026, Lefteris Zafiris <zaf@fastmail.com>
#

all: go2c.a go2c.so example benchmark

# Build object file (this also generates go2c.h)
go2c.a: go2c.go
	go build -buildmode=c-archive -o $@ $<

# Build shared lib.
# c-shared rewrites go2c.h too, so it must not run concurrently with the
# archive build or the C compiles below when using make -j.
go2c.so: go2c.go go2c.a
	go build -buildmode=c-shared -o $@ $<

# Build C example (order-only go2c.so: its build rewrites go2c.h)
example: example.c go2c.a | go2c.so
	cc -g -Wall -O3 -pthread -o $@ $< go2c.a

# Build C benchmark
benchmark: benchmark.c go2c.a | go2c.so
	cc -g -Wall -O3 -pthread -o $@ $< go2c.a

run: all
	@echo "=== Running the C example code ==="
	./example
	@echo "=== Running the Perl example code ==="
	perl example.pl
	@echo "=== Running the Python example code ==="
	python3 example.py
	@echo "=== Running the Ruby example code ==="
	ruby example.rb

bench: all
	@echo "=== Running the C benchmark ==="
	./benchmark
	@echo "=== Running the Perl benchmark ==="
	perl benchmark.pl
	@echo "=== Running the Python benchmark ==="
	python3 benchmark.py
	@echo "=== Running the Ruby benchmark ==="
	ruby benchmark.rb

# go2c.h is kept: it is tracked in git so the examples can be built without Go
clean:
	go clean
	rm -f go2c.a go2c.so example benchmark
	rm -rf _Inline

.PHONY: clean bench run
