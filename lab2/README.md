# First Fit Algorithm

![demo](demo.png)

## Features

* Use PureScript
* Compile PureScript to JavaScript to render UI in browser

## Source Files

* `src/Main.purs`  -- Core library for initializing, allocating and retrieving
* `ff.html`  -- Web page
* `ff.css`  -- Style sheet
* `ff.js`  -- JavaScript code to operate and display

## Build

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
