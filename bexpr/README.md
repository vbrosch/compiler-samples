# bexpr

A simple grammar implemented in bison and flex that calculates the result of boolean expressions.
It's based on an exercise in the book 'Compilers' from Aho et al.

**Examples**
e.g.
* true
* true and false
* true and not false
* (false) and not true

Please install bison, flex and gcc **before** execution of make!

## Usage
```
  make && ./bexpr
```
