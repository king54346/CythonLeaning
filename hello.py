# import hello
# import hello
import hello1
import example
import numpy as np

print(hello1.another_function(1,2,3))
# print(hello.pythagoras(1, 2))
# hello.say_hello_to("World")
arr=[]
for i in range(100000):
    arr.append(i)
numpy_arr = np.array(arr, dtype=np.float64)
print(numpy_arr)

print(example.parallel_sum_of_squares(numpy_arr,4))