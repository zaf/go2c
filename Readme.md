# Examples of interfacing with Go using the C API.

How Go functions can be exported and used via the C API.
It contains examples for C, Perl, Python 3 and Ruby.

`make` will compile the Go code, generate the header, lib and object files,
and compile the C example

`make run` will run both the C, Perl, Python 3 and Ruby examples.

`make bench` will run benchmarks and measure runtime performance.
These benchmarks measure the function call overhead.

For the Perl example Inline::C module is needed

Still WIP, see source files for comments and details.
