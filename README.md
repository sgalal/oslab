# oslab

_My Experiments of Operating System_

| Lab | Motif | UI | Written in |
| :- | :- | :- | :- | :- |
| 1 | [Round-Robin Scheduling Algorithm](#round-robin-scheduling-algorithm) | [Web Page](https://chromezh.github.io/oslab/lab1/rr.html) | C++ |
| 2 | [First Fit Algorithm](#first-fit-algorithm) | [Web Page](https://chromezh.github.io/oslab/lab2/ff.html) | PureScript |
| 3 | [Bitmap](#bitmap) | Console | C++ |
| 4 | [Banker's Algorithm](#bankers-algorithm) | [Web Page](https://chromezh.github.io/oslab/lab4/banker.html) | PureScript |
| 5 | [Page Table Illustration](#page-table-illustration) | Console | Python |

## Round-Robin Scheduling Algorithm

[![demo](lab1/demo.png)](lab1/)

### Design

* `State` field in PCB is redundant because:
  - Processes in state R are all in Running List
  - Processes in state E are all in Ending List
* The circular queue can be replaced by a circular linked list because:
  - A queue can be implemented by a linked list
  - Linked lists additionally support insert operation at a designated position, thus a newly inserted process can be run at once
* A circular linked list can be repalced by a single linked list because:
  - They provide the same access and modify operations
  - When iterating the single linked list, if the iterator reaches the end of the list, we can changed it to the front of the list to provide the same iteration behaviour as a circular linked list
* The fields `Time Needed` and `Time Elapsed` can be replaced by `Time Needed` and `Time Remain` because:
  - There is a simple relationship between them -- `Time Needed` = `Time Elapsed` + `Time Remain`
  - If we use `Time Remain`, we can easily know whether a process is ended by checking `Time Remain` = 0

### Features

* Use C++17 standard
* Use `std::forward_list` in STL as the circular queue
* Compile C++ to JavaScript to render UI in browser
* Add a kill process option

### Source Files

* `src/main.cpp`  -- PCB and its operations
* `index.html`  -- Web page for visualization
* `rr.css`  -- Stylesheet for HTML
* `rr.js` -- JavaScript code to operate and display PCB

### Build

Prerequisite: [Emscripten](http://emscripten.org/)

``` sh
$ em++ -Wall -Werror -std=c++17 -O --bind -o main.js src/main.cpp
```

### References

* https://stackoverflow.com/a/19375586
* http://kripken.github.io/emscripten-site/docs/porting/connecting_cpp_and_javascript/embind.html

## First Fit Algorithm

[![demo](lab2/demo.png)](lab2/)

### Design

* A `Block` represents a space in the memory with a certain size, which could be `Idle`, that has one attribute `len`, or be `Allocated`, that has two attributes `len` and `pid`
* The `Block`s are saved in a linked list
* The allocating and retrieving are handled by [pattern matching](https://en.wikipedia.org/wiki/Pattern_matching)

### Features

* Use [PureScript](http://www.purescript.org/) and pattern matching
* Compile PureScript to JavaScript to render UI in browser

### Source Files

* `src/Main.purs`  -- Core library for initializing, allocating and retrieving
* `ff.html`  -- Web page
* `ff.css`  -- Style sheet
* `ff.js`  -- JavaScript code to operate and display

### Build

Prerequisite: PureScript

``` sh
$ npm install -g purescript
$ npm install -g pulp bower
```

Once:

``` sh
$ bower install
```

Many times:

``` sh
$ pulp build --skip-entry-point --no-check-main -O --to main.js
```

## Bitmap

![demo](lab3/demo.png)

### Design

* The bitmap is stored as a "3-dimensional array" of `bool`. 0 for free and 1 for used
* When allocating, first checks whether there is enough space to allocate. If true, then allocate from the beginning
* When retrieving, finds the corresponding bit in the array and set it to 0
* Implements a simple text user interface and use regular expressions to recognize the commands

### Features

* Use C++17 standard
* Use regular expressions to recognize commands
* Use Makefile as the build tool

### Source File

* `bitmap.cpp`  -- Bitmap and its operations

### Build and Run

**Build**

Prerequisite: clang, make

``` sh
$ mingw32-make
```

**Run**

``` sh
$ ./bitmap.exe
```

## Banker's Algorithm

[![demo](lab4/demo.png)](lab4/)

### Features

* Use PureScript
* Compile PureScript to JavaScript to render UI in browser
* Use Free Monad
* Build HTML tags in a functional way (combinators in [purescript-smolder](https://pursuit.purescript.org/packages/purescript-smolder))

### Source Files

* `src/Main.purs`  -- Core library for initializing, allocating and retrieving
* `ff.html`  -- Web page
* `ff.css`  -- Style sheet
* `ff.js`  -- JavaScript code to operate and display

### Build

Prerequisite: [PureScript](http://www.purescript.org/)

``` sh
$ npm install -g purescript
$ npm install -g pulp bower
```

Once:

``` sh
$ bower install
```

Many times:

``` sh
$ pulp build --skip-entry-point --no-check-main -O --to main.js
```

## Page Table Illustration

![demo](lab5/demo.png)

### Features

* Use Python

### Source Files

* `paging.py`

### Run

``` sh
python paging.py
```
