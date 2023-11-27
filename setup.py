from setuptools import setup
from Cython.Build import cythonize

from setuptools.extension import Extension

ext_modules = [
    Extension("example",
              sources=["example.pyx"],
              extra_compile_args=['-fopenmp'],
              extra_link_args=['-fopenmp'],
    ),
    Extension("hello1",
              sources=["hello1.pyx"],
              extra_compile_args=['-fopenmp'],
              extra_link_args=['-fopenmp'],
    ),
    Extension("hello",
              sources=["hello.pyx"],
              extra_compile_args=['-fopenmp'],
              extra_link_args=['-fopenmp'],
    )
]

# python setup.py build_ext --inplace
# --inplace  编译出的扩展模块直接放置在源代码所在的目录,而不是在 build 目录下
# setup(
#     ext_modules = cythonize("hello.pyx", compiler_directives={'language_level' : "3"})
# )

setup(
    ext_modules = cythonize(ext_modules)
)
