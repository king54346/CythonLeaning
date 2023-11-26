from setuptools import setup
from Cython.Build import cythonize

from setuptools.extension import Extension

ext_modules=[
    Extension("modulename",
              sources=["example.pyx"],
              extra_compile_args=['-fopenmp'],
              extra_link_args=['-fopenmp'],
             )

]


setup(
    ext_modules = cythonize("hello.pyx", compiler_directives={'language_level' : "3"})
)
