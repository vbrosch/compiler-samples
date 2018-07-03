# binary converter

A simple grammar implemented in bison and flex that returns the integer representation of a binary number and vice versa.

**binary to decimal conversion (prefix b)**
e.g.
* b101010
* b-1110 (it is also possible to return a negative number)
* b+1111

**decimal to binary conversion (prefix d)**
e.g.
* d20
* d-10
* d+5

Please install bison, flex and gcc **before** execution of make!

## Usage
```
  make && ./converter
```
