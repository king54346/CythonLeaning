# example.pyx
from libc.math cimport pow
from cython.parallel cimport prange, parallel
cimport openmp as mp



cdef double work(double[:] arr) nogil:
    cdef:
        int i
        double result = 0.0
    for i in prange(arr.shape[0], nogil=True):
        result += pow(arr[i], 2)
    return result

def parallel_sum_of_squares(double[:] arr, int num_threads):
    cdef:
        int i
        double[:] results = [0.0] * num_threads

    # Divide the array into num_threads segments and create threads
    for i in prange(num_threads, nogil=True):
        results[i] = work(arr[i::num_threads])

    # Sum up the results of all threads
    return sum(results)

