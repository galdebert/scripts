#!/usr/bin/env python3

import os
from pathlib import Path
import glob
import shutil
from typing import List
from contextlib import contextmanager

def norm_path(path: str) -> str:
    return Path(os.path.normpath(os.path.expanduser(os.path.expandvars(path)))).as_posix()


def relpath(abspath: str, base_absdir: str) -> str:
    return Path(abspath).relative_to(base_absdir).as_posix()


def abspath(base_absdir: str, relpath: str) -> str:
    return norm_path(os.path.join(base_absdir, relpath))


def containing_dir(path: str) -> str:
    return norm_path(os.path.dirname(os.path.abspath(path)))


def glob_abs(glob_expr: str) -> str:
    for p in glob.iglob(glob_expr, recursive='**' in glob_expr):
        yield norm_path(p)


def glob_rel(glob_expr: str, base_absdir: str) -> str:
    base_absdir = norm_path(base_absdir)
    for p in glob.iglob(glob_expr, recursive='**' in glob_expr):
        yield relpath(p, base_absdir)


def glob_abs_if_file(glob_expr: str) -> str:
    for p in glob.iglob(glob_expr, recursive='**' in glob_expr):
        if os.path.isfile(p):
            yield norm_path(p)


def copy_file(src_abspath: str, dst_abspath: str) -> str:
    os.makedirs(os.path.dirname(dst_abspath), exist_ok=True)
    shutil.copyfile(src_abspath, dst_abspath)

# str_list('str1', 1, None, ['str2', 2, None]) = ['str1', '1', 'str2', '2']
def str_list(*args) -> List[str]:
    lst = []
    for a in args:
        if isinstance(a, (list, tuple)):
            for b in a:
                if b is not None:
                    lst.append(str(b))
        elif a is not None:
            lst.append(str(a))
    return lst


def help_str(choices: List[str], default: str=None) -> str:
    default_str = f' default={default}' if default is not None else ''
    return f'[{", ".join(choices)}]{default_str}'

#usage: with utils.chg_cwd('my/dir'):
@contextmanager
def chg_cwd(path: str):
    old_cwd = os.getcwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(old_cwd)
