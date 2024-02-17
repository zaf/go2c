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
example: example.c go2c.a
	cc -g -Wall -O3 -pthread -o $@ $^

# Build C benchmark
benchmark: benchmark.c go2c.a
	cc -g -Wall -O3 -pthread -o $@ $^

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

clean:
	go clean
	rm -f go2c.a go2c.so go2c.h example benchmark
	rm -rf _Inline

.PHONY: clean bench run
