# encoding=utf-8
# filename.pyx
cpdef say_hello_to(str name):
    print("Hello %s!" % name)

cpdef double pythagoras(double a, double b):
    return (a**2 + b**2)**0.5
