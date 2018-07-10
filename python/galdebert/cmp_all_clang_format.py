#!/usr/bin/env python3

# usage
# when PYTHONPATH is empty, from D:\dev\galdebert\scripts\python:
# py -3 -m galdebert.cmp_all_clang_format mydir

# when PYTHONPATH contains D:\dev\galdebert\scripts\python, from anywhere:
# py -3 -m galdebert.cmp_all_clang_format mydir

import sys

from . import araxis_cmp
# does work when there is a __init__.py in the dir, otherwise the error is: Attempted relative import beyond top-level package

paths = [r'C:\Dev\stingray\runtime\plugins\gwnav_plugin\_clang-format',
         r'C:\Dev\stingray\runtime\_clang-format',
         r'C:\Dev\stingray-navigation-samples\nav_test_plugin\src\_clang-format',
         r'C:\Dev\navigation\_clang-format']

try:
    src = sys.argv[1]
except IndexError:
    exit('cmd_all_clang_format.py requires 1 argument: the absolute path to the src file')

araxis_cmp.compare1toN(src, paths)
