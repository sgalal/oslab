# oslab

_My Experiments of Operating System_

| Lab | Motif | UI | Written in |
| :- | :- | :- | :- |
| 1 | [Round-Robin Scheduling Algorithm](#round-robin-scheduling-algorithm) | [Web Page](https://sgal.self.sugina.cc/oslab/lab1/) | C++ |
| 2 | [First Fit Algorithm](#first-fit-algorithm) | [Web Page](https://sgal.self.sugina.cc/oslab/lab2/) | PureScript |
| 3 | [Bitmap](#bitmap) | Console | C++ |
| 4 | [Banker's Algorithm](#bankers-algorithm) | [Web Page](https://sgal.self.sugina.cc/oslab/lab4/) | PureScript |
| 5 | [Page Table Illustration](#page-table-illustration) | Console | Python |

**LICENSE:** GNU General Public License v3.0

## Round-Robin Scheduling Algorithm

[![demo](lab1/demo.png)](lab1/)

### Requirements (Chinese)

设计一个按时间片轮转法实现处理器调度的程序

1. 假定系统有 5 个进程，每个进程用一个 PCB 来代表。PCB 的结构为：
    - 进程名——如 Q1~Q5
    - 指针——把 5 个进程连成队列，用指针指出下一个进程 PCB 的首地址
    - 要求运行时间——假设进程需要运行的单位时间数
    - 已运行时间——进程已运行的单位时间数，初始值为 0
    - 状态——假设两种状态，就绪和结束，用 R 表示就绪，用 E 表示结束。初始状态都为就绪状态
1. 每次运行之前，为每个进程任意确定它的“要求运行时间”
1. 把 5 个进程按顺序排成循环队列，用指针指出队列连接情况。用一个标志单元记录轮到运行的进程。处理器调度总是选择标志单元指示的进程运行，对所指的进程，将其“已运行时间”加 1
1. 进程运行一次后，若“要求运行时间”等于“已运行时间”，则将状态改为“结束”，退出队列，否则将继续轮转
1. 若就绪队列为空，结束，否则转到 3 重复

要求能接受键盘输入的进程要求运行时间，能显示每次进程调度的情况，如哪个进程在运行，哪些进程就绪，就绪进程的排列情况。

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

* [How do I efficiently remove_if only a single element from a forward_list?](https://stackoverflow.com/a/19375586)
* [Embind](http://kripken.github.io/emscripten-site/docs/porting/connecting_cpp_and_javascript/embind.html)

## First Fit Algorithm

[![demo](lab2/demo.png)](lab2/)

### Requirements (Chinese)

可变分区管理方式下采用首次适应算法实现主存分配和回收

1. 可变分区方式是按作业需要的主存空间大小来分割分区的。当要装入一个作业时，根据作业需要的主存容量查看是否有足够的空闲空间，若有，则按需分配，否则，作业无法装入。假定内存大小为 128K（可输入），空闲区说明表格式为：
    - 起始地址——指出空闲区的起始地址
    - 长度——一个连续空闲区的长度
    - 状态——有两种状态，一种是“未分配”状态；另一种是“空表目”状态，表示该表项目前没有使用
1. 采用首次适应算法分配回收内存空间。运行时，输入一系列分配请求和回收请求

要求能接受来自键盘的空间申请及释放请求，能显示分区分配及回收后的内存布局情况。

### Design

* A `Block` represents a space in the memory with a certain size, which could be `Idle`, that has one attribute `len`, or be `Allocated`, that has two attributes `len` and `pid`
* The `Block`s are saved in a linked list
* The allocate operation can be handled by [pattern matching](https://en.wikipedia.org/wiki/Pattern_matching): ![allocate patterns](https://latex.codecogs.com/gif.latex?allocate%20%28p%2C%20l%2C%20list%29%20%3D%20%5Cbegin%7Bcases%7D%20%5Cmathsf%7BAllocated%7D%20_%20%7B%20len%20%3D%20x%2C%20pid%20%3D%20p%20%7D%20%3A%20xs%26%20%5Cleft%28%20list%20%3D%20%5Cmathsf%7BIdle%7D%20_%20%7B%20len%20%3D%20x%20%7D%20%3A%20xs%2C%20x%20%3D%20l%20%5Cright%29%20%5C%5C%20%5Cmathsf%7BAllocated%7D%20_%20%7B%20len%20%3D%20l%2C%20pid%20%3D%20p%20%7D%20%3A%20%5Cmathsf%7BIdle%7D%20_%20%7B%20len%20%3D%20x%20-%20l%20%7D%20%3A%20xs%26%20%5Cleft%28%20list%20%3D%20%5Cmathsf%7BIdle%7D%20_%20%7B%20len%20%3D%20x%20%7D%20%3A%20xs%2C%20x%20%3E%20l%20%5Cright%29%20%5Cend%7Bcases%7D)<!--
allocate (p, l, list) =
\begin{cases}
\mathsf{Allocated} _ { len = x, pid = p } : xs& \left( list = \mathsf{Idle} _ { len = x } : xs, x = l \right) \\
\mathsf{Allocated} _ { len = l, pid = p } : \mathsf{Idle} _ { len = x - l } : xs& \left( list = \mathsf{Idle} _ { len = x } : xs, x > l \right)
\end{cases}
-->
* The retrieve operation can be handled by pattern matching: ![retrieve patterns](https://latex.codecogs.com/gif.latex?retrieve%20%28p%2C%20list%29%20%3D%20%5Cbegin%7Bcases%7D%20%5Cmathsf%7BIdle%7D%20_%20%7B%20len%20%3D%20x%20&plus;%20y%20&plus;%20z%20%7D%20%3A%20xs%26%20%5Cleft%28%20list%20%3D%20%5Cmathsf%7BIdle%7D%20_%20%7B%20len%20%3D%20x%20%7D%20%3A%20%5Cmathsf%7BAllocated%7D%20_%20%7B%20len%20%3D%20y%2C%20pid%20%3D%20p%27%20%7D%20%3A%20%5Cmathsf%7BIdle%7D%20_%20%7B%20len%20%3D%20z%20%7D%20%3A%20xs%2C%20p%20%3D%20p%27%20%5Cright%29%20%5C%5C%20%5Cmathsf%7BIdle%7D%20_%20%7B%20len%20%3D%20x%20&plus;%20y%20%7D%20%3A%20xs%26%20%5Cleft%28%20list%20%3D%20%5Cmathsf%7BIdle%7D%20_%20%7B%20len%20%3D%20x%20%7D%20%3A%20%5Cmathsf%7BAllocated%7D%20_%20%7B%20len%20%3D%20y%2C%20pid%20%3D%20p%27%20%7D%20%3A%20xs%2C%20p%20%3D%20p%27%20%5Cright%29%20%5C%5C%20%5Cmathsf%7BIdle%7D%20_%20%7B%20len%20%3D%20x%20&plus;%20y%20%7D%20%3A%20xs%26%20%5Cleft%28%20list%20%3D%20%5Cmathsf%7BAllocated%7D%20_%20%7B%20len%20%3D%20x%2C%20pid%20%3D%20p%27%20%7D%20%3A%20%5Cmathsf%7BIdle%7D%20_%20%7B%20len%20%3D%20y%20%7D%20%3A%20xs%2C%20p%20%3D%20p%27%20%5Cright%29%20%5C%5C%20%5Cmathsf%7BIdle%7D%20_%20%7B%20len%20%3D%20x%20%7D%20%3A%20xs%26%20%5Cleft%28%20list%20%3D%20%5Cmathsf%7BAllocated%7D%20_%20%7B%20len%20%3D%20x%2C%20pid%20%3D%20p%27%20%7D%20%3A%20xs%2C%20p%20%3D%20p%27%20%5Cright%29%20%5Cend%7Bcases%7D)<!--
retrieve (p, list) =
\begin{cases}
\mathsf{Idle} _ { len = x + y + z } : xs& \left( list = \mathsf{Idle} _ { len = x } : \mathsf{Allocated} _ { len = y, pid = p' } : \mathsf{Idle} _ { len = z } : xs, p = p' \right) \\
\mathsf{Idle} _ { len = x + y } : xs& \left( list = \mathsf{Idle} _ { len = x } : \mathsf{Allocated} _ { len = y, pid = p' } : xs, p = p' \right) \\
\mathsf{Idle} _ { len = x + y } : xs& \left( list = \mathsf{Allocated} _ { len = x, pid = p' } : \mathsf{Idle} _ { len = y } : xs, p = p' \right) \\
\mathsf{Idle} _ { len = x } : xs& \left( list = \mathsf{Allocated} _ { len = x, pid = p' } : xs, p = p' \right)
\end{cases}
-->

### Features

* Use [PureScript](http://www.purescript.org/), which is easy to do pattern matching
* Use Maybe Functor for error handling
* Compile PureScript to JavaScript to render UI in browser

### Source Files

* `src/Main.purs`  -- Core library for initializing, allocating and retrieving
* `index.html`  -- Web page
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

### References

* [実例によるPureScript](https://aratama.github.io/purescript/purescript-book-ja)

## Bitmap

![demo](lab3/demo.png)

### Requirements (Chinese)

用位示图管理磁盘存储空间

1. 为了提高磁盘存储空间的利用率，可在磁盘上组织成链接文件、索引文件，这类文件可以把逻辑记录存放在不连续的存储空间。为了表示哪些磁盘空间已被占用，哪些磁盘空间是空闲的，可用位示图来指出。位示图由若干字节构成，每一位与磁盘上的一块对应，“1”状态表示相应块已占用，“0”状态表示该块为空闲。位示图的形式与实习二中的位示图一样，但要注意，对于主存储空间和磁盘存储空间应该用不同的位示图来管理，绝不可混用
1. 申请一块磁盘空间时，由分配程序查位示图，找出一个为“0”的位，计算出这一位对应块的磁盘物理地址，且把该位置成占用状态“1”。假设现在有一个盘组共8个柱面，每个柱面有2个磁道（盘面），每个磁道分成4个物理记录。那么，当在位示图中找到某一字节的某一位为“0”时，这个空闲块对应的磁盘物理地址为：
    - 柱面号 = 字节号
    - 磁道号 = 位数 / 4
    - 物理记录号 = 位数 % 4
1. 归还一块磁盘空间时，由回收程序根据归还的磁盘物理地址计算出归还块在位示图中的对应位，把该位置成“0”。按照 2 中假设的盘组，归还块在位示图中的位置计算如下：
    - 字节号 = 柱面号
    - 位数 = 磁道号 \* 4 + 物理记录号
1. 设计申请磁盘空间和归还磁盘空间的程序

要求能接受来自键盘的空间申请及释放请求，要求能显示或打印程序运行前和运行后的位示图；分配时把分配到的磁盘空间的物理地址显示或打印出来，归还时把归还块对应于位示图的字节号和位数显示或打印出来。

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

Prerequisites: clang, make

``` sh
$ mingw32-make
```

**Run**

``` sh
$ ./bitmap.exe
```

## Banker's Algorithm

[![demo](lab4/demo.png)](lab4/)

### Requirements (Chinese)

银行家算法实现

初始状态下，设置数据结构存储可利用资源向量（Available），最大需求矩阵（MAX），分配矩阵（Allocation），需求矩阵（Need），输入待分配进程队列和所需资源。

设计安全性算法，设置工作向量表示系统可提供进程继续运行的可利用资源数目。

如果进程队列可以顺利执行打印输出资源分配情况，如果进程队列不能顺利执行打印输出分配过程，提示出现死锁位置。

### Features

* Use PureScript
* Compile PureScript to JavaScript to render UI in browser
* Use Free Monad
* Use combinators to build HTML tags directly while traversing the list

### Source Files

* `src/Main.purs`  -- Core operations and UI rendering
* `index.html`  -- Web page
* `banker.css`  -- Style sheet

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

### References

* [Banker's algorithm](https://en.wikipedia.org/wiki/Banker%27s_algorithm)
* [Monad Transformers](http://dev.stephendiehl.com/hask/#monad-transformers)
* [What does Free buy us?](https://www.parsonsmatt.org/2017/09/22/what_does_free_buy_us.html)

## Page Table Illustration

![demo](lab5/demo.png)

### Requirements (Chinese)

模拟页面地址重定位

1. 设计页表结构
1. 设计地址重定位算法
1. 有良好的人机对话界面

### Design

* Use a pre-defined list as the page table
* If the input is out of bound, then output an error message

### Features

* Use Python 3

### Source Files

* `paging.py`  -- Page table and its operations

### Run

``` sh
python paging.py
```
