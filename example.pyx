# encoding=utf-8

from libc.math cimport pow,floor,sqrt,ceil
from libc.stdio cimport printf
from cython.parallel cimport prange, parallel
cimport openmp as mp
import numpy as np

cdef double work(double[:] arr) nogil:
    cdef:
        int i
        double result = 0.0
    for i in range(arr.shape[0]):  # 使用 range 替代 prange
        result += pow(arr[i], 2)
    return result

def parallel_sum_of_squares(double[:] arr, int num_threads):
    cdef:
        int i
        # 创建大小为num_threads 的浮点数组
        numpy_array = np.zeros(num_threads, dtype=np.float64)
        double[:] results = numpy_array

    # Divide the array into num_threads segments and create threads
    for i in prange(num_threads, nogil=True):
        # 每隔num_threads元素取一个
        results[i] = work(arr[i::num_threads])

    # Sum up the results of all threads
    return sum(results)