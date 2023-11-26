Cython程序如何调用外部C代码

扩展模块的方式
1：编写 C 代码
2：创建 Setup 脚本
3：编译扩展模块(生成一个 .so 文件)
4：import并使用模块

Cython的方式
1：编写 C 代码
2：编写 Cython 封装(cdef extern from "xxxx.h":)
3：创建 Setup 脚本(Extension("example", ["xxxx.pyx", "xxxxx.c"]))
4：构建模块

ctype的方式
1：编写 C 代码
2：gcc讲c编译成.so文件
3：使用 ctypes 调用 C 函数(lib = ctypes.CDLL('./xxxxx.so'))

Cpython的类
__ get __(self):当外部代码尝试读取Cython类的属性，该方法会被触发
__ set __(self):当外部代码尝试修改Cython类的属性，该方法会被触发
__ del __(self):当外部代码尝试删除Cython类的属性，该方法会被触发
__ cinit __(self, [...]) 和 __ dealloc __(self): 管理 Python 对象之外的资源，比如直接从 C 语言分配的内存。
__ repr __ 创建一个对象的字符串表示(return f"Point({self.x}, {self.y})")
算术符和比较运算符重载等，例如 __ add __(x,y)

Cython配合with nogil和openMP、prange这些手段实现复杂的多线程并行运算
cimport 可以访问在.pxd 中C API
import 访问 Python 层面的接口和对象

Cython中的字符串: python风格cdef str c风格 cdef char* c_string(手动管理内存) c++风格cdef string


OpenMP的核心语法

#pragma omp [构造名] [复合子句]

并行区域
#pragma omp parallel
{
    // 并行执行的代码
}



循环并行
将N个(外部定义)循环的迭代分配给多个线程，实现循环的并行化
适合任务可以独立执行而不需要彼此之间进行通信时使用
#pragma omp parallel for
for (int i = 0; i < N; i++) {
    // 循环体
}

schedule static子句
#pragma omp parallel for schedule(static[,chunk]):将chunk的迭代块静态分配给每个线程
~~ schedule(dynamic [,chunk]): 为多个并行的线程动态分配迭代量，这个迭代量保证并低于chunk指定的尺寸。
~~ schedule(guided [,chunk]):chunk的尺寸随着每个分派的迭代量以(接近)指数的方式递减。


同步指令
代码块在同一时刻只能被一个线程执行

#pragma omp critical
{
    // 临界区代码
    //critical区使线程实际上是按顺序运行的，这会降低线程并行性的能力
}


#pragma omp barrier
确保所有线程都到达这个点后才能继续执行。
#pragma omp master
仅由主线程执行的代码块。
#pragma omp single
代码块只由一个线程执行，但不指定是哪个线程。
#pragma omp atomic
被保护的原子操作,#pragma omp atomic 只能用于特定类型的操作，主要是算术运算和赋值操作#pragma omp critical多步骤操作



omp_set_num_threads(int):
设置用于执行后续并行区域的线程数量。
子句形式
#pragma omp parallel num_threads(4)
{
     // 临界区代码
}
omp_get_thread_num():
获取当前线程的编号。
omp_get_wtime()
计时函数

共享变量
并行区域外部声明的变量被视为共享变量,可以显式地使用 shared 子句来声明共享变量
私有变量
在 #pragma omp parallel 指令中，可以使用 private 子句来声明私有变量。 在并行区域内部声明的局部变量默认是私有的。

False Sharing
缓存行通常是 64 字节大小。
当两个或多个线程分别访问不同变量，但这些变量恰好位于同一缓存行内时，会发生 False Sharing。
如果一个线程修改了它所访问的变量，整个缓存行会被标记为“脏”（dirty），并在稍后写回主内存。
这个写回操作使得其他线程中缓存的同一缓存行失效（因为它们包含了旧的数据），迫使其他线程重新从主内存中加载这一缓存行。
它们却频繁地无效化彼此的缓存，导致了高昂的内存访问延迟和降低的性能。
解决 False Sharing
使得被不同线程访问的数据不会位于同一缓存行上。
比如在数据结构中加入额外的字节，以确保共享变量分布在不同的缓存行上。

openMP 归约子句
#pragma omp parallel for reduction(操作符:变量)
操作符: 如加法（+）、乘法（*）、逻辑与（&&）、逻辑或（||）、位与（&）、位或（|）等,归约支持各种赋值操作。
当使用归约子句时，OpenMP 会为每个线程创建该变量的私有副本。在并行区域内，每个线程对其私有副本进行操作。并行区域结束后，所有私有副本会根据指定的操作符合并到原始变量中(线程私有变量组合成一个全局变量)。

cython中使用C++ 标准库
使用 libcpp 的步骤
1.在.pyx 文件的开头添加# distutils: language=c++
2.导入 libcpp from libcpp.vector cimport vector
cython的泛型：
cdef vector[int] xxxx(int n)
内存通过析构函数自动释放

cython内存视图：高效访问内存数组数据的机制(如 C 数组、NumPy 数组等)
内存视图声明
cdef int[:] c_array_view c_array_view为内存视图，可以赋值c和numpy(动态数组类型和高级数组操作，性能不如静态类型内存视图，但是没有高级功能)

内存视图是对数组数据的引用，允许在不同数组之间安全、高效地共享数据 
避免数据复制:内存视图允许直接访问底层数据，而不需要复制数据，这对于处理大型数组非常重要。
底层优化:类型化和 Cython 的编译特性使得访问内存视图中的数据非常快。
当内存视图操作只涉及到原始数据（如整数、浮点数）且不涉及到 Python 对象的创建或修改时，这些操作可以不受 GIL 的限制，从而在多线程环境中获得更好的性能

初始化方案：
malloc的初始化方案(需要手动管理内存)和cpython.array的初始化方案。优先使用cpython.array初始化方案。
numpy 的初始化方式，如果在数量级规模在1000以下可以酌情使用。


cdef: 用于定义 C 函数。这些函数只能在 Cython 中调用 ,声明 C 类型的变量，包括基本类型（如 int, double 等）和更复杂的结构（如结构体和指针）
cpdef: cpdef 是 cdef 和 def 的结合体，用于定义既可以在 Cython 中以 C 函数的效率调用
def: 用于定义普通的 Python 函数
cython中取地址使用address()函数


cython中使用openmp
并行区内的所有变量为被自动推断为线程局部变量和归约变量(如果定义了外部定义了共享变量， 并且内部使用如+=的归约，则会判断为归约变量)。
外部的变量将会被推断为
fistprivate子句: 不同线程的该变量将初始化相同的原始值
lastprivate子句: 同个线程中该变量将包含上次迭代的值
shared子句： C级别的基本数据类型以外的其他数据类型。如C++的容器级别例如struct、vector,指针类型的char*、int*、float*、double* 和vector* 等

prange函数：
prange(
    start,
    stop, 
    step, 
    nogil=False, 
    schedule=None, 
    chunksize=None,
    num_threads=None
)

for i in prange(10, nogil=True):
    # 并行执行的代码
    # 要求循环内的代码是线程安全的，并且不会进行任何普通 Python 对象的操作。
    # 调用的函数原型最后一定要带nogil关键字


parallel()和with nogil
with nogil,parallel(num_threads=2):
   pass



https://www.zhihu.com/people/xie-zhu-93-61/posts?page=3