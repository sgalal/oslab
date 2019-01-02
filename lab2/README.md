# First Fit Algorithm

[![demo](demo.png)](ff.html)

## Design

* A `Block` represents a space in the memory with a certain size, which could be `Idle`, that has one attribute `len`, or be `Allocated`, that has two attributes `len` and `pid`
* The `Block`s are saved in a linked list
* The allocating and retrieving are handled by [pattern matching](https://en.wikipedia.org/wiki/Pattern_matching)

## Features

* Use [PureScript](http://www.purescript.org/) and pattern matching
* Compile PureScript to JavaScript to render UI in browser

## Source Files

* `src/Main.purs`  -- Core library for initializing, allocating and retrieving
* `ff.html`  -- Web page
* `ff.css`  -- Style sheet
* `ff.js`  -- JavaScript code to operate and display

## Build

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
