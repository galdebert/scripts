#!/usr/bin/env python3

import os
import sys
import subprocess
from typing import List
import importlib.util
import argparse
from . import utils


def packages_iter(abspath: str):
    for p in utils.glob_abs(f'{abspath}/**/__init__.py'):
        yield utils.norm_path(os.path.dirname(p))


def modules_iter(abspath: str, modules: List[str]):
    for p in utils.glob_abs(f'{abspath}/**/*.py'):
        if not any((p.startswith(m) for m in modules)):  # if not already in a module dir
            yield p


def print_list(title: str, lst: List[str]):
    if lst:
        print(f'{title}:')
        for p in lst:
            print(f'  {p}')


def packages_and_modules(abspath: str, verbose: bool) -> (List[str], List[str]):
    packages, modules = [], []
    if os.path.isdir(abspath):
        packages = [p for p in packages_iter(abspath)]
        modules = [p for p in modules_iter(abspath, packages)]
    elif os.path.isfile(abspath):
        modules = [abspath]

    if verbose:
        print_list('modules', modules)
        print_list('packages', packages)

    return packages, modules


def lint(abspath: str, args) -> int:
    # test that autopep8 module is installed
    if importlib.util.find_spec('pylint') is None:
        print(f'`pylint` not found. Try to run `{sys.executable} -m pip install -r {abspath}/requirements.txt`')
        return -1

    packages, modules = packages_and_modules(abspath, verbose=args.verbose)

    cmd = [sys.executable, '-m', 'pylint', f'--rcfile={python_format}', '--score=n']
    cmd.extend(packages)
    cmd.extend(modules)
    rc = subprocess.run(cmd).returncode

    if rc == 0:
        print('pylint detected no error')
    else:
        print('pylint detected some errors')
    return rc


def fmt(abspath: str, args) -> int:
    # test that autopep8 module is installed
    if importlib.util.find_spec('autopep8') is None:
        print(f'`autopep8` not found. Try to run `{sys.executable} -m pip install -r {abspath}/requirements.txt`')
        return -1

    packages, modules = packages_and_modules(abspath, verbose=args.verbose)

    cmd = [sys.executable, '-m', 'autopep8', '--global-config', 'python-format', '--recursive', '--in-place']
    cmd.extend(packages)
    cmd.extend(modules)
    rc = subprocess.run(cmd).returncode
    return rc


desc = '''
pysrc lint path    lint python packages, modules in path
pysrc format path  format python packages, modules in path
'''

if __name__ == '__main__':
    main_parser = argparse.ArgumentParser(add_help=True, formatter_class=argparse.RawDescriptionHelpFormatter, description=desc)
    command_choices = ['lint', 'fmt']
    main_parser.add_argument('command', nargs='?', choices=command_choices, help=utils.help_str(command_choices), metavar='command')
    main_parser.add_argument('path', nargs='?', help='dir or path to process')
    main_parser.add_argument('--python-format', '-f', help='path to the python-format', metavar='<p>')
    main_parser.add_argument('--verbose', '-v', action='store_true', help='')

    argv = sys.argv[1:]
    # args, command_argv = main_parser.parse_known_args(argv) # use when other parsers are used in each command
    args = main_parser.parse_args(argv)

    abspath = utils.abspath(os.getcwd(), args.path)

    python_format = args.python_format
    if not python_format:
        python_format = utils.norm_path(f'{os.environ["GA_SCRIPTS"]}/python/python-format')

    if args.verbose:
        print(f'abspath       = {abspath}')
        print(f'python_format = {python_format}')

    rc = 0
    if args.command == 'fmt':
        rc = fmt(abspath, args)
    if args.command == 'lint':
        rc = lint(abspath, args)

    sys.exit(rc)
