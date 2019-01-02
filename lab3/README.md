# Bitmap

![demo](demo.png)

## Design

* The bitmap is stored as a "3-dimensional array" of `bool`. 0 for free and 1 for used
* When allocating, first checks whether there is enough space to allocate. If true, then allocate from the beginning
* When retrieving, finds the corresponding bit in the array and set it to 0
* Implements a simple text user interface and use regular expressions to recognize the commands

## Features

* Use C++17 standard
* Use regular expressions to recognize commands
* Use Makefile as the build tool

## Source File

* `bitmap.cpp`  -- Bitmap and its operations

## Build and Run

**Build**

Prerequisite: clang, make

``` sh
$ mingw32-make
```

**Run**

``` sh
$ ./bitmap.exe
```
