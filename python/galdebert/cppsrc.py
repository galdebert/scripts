#!/usr/bin/env python3

import os
import sys
import subprocess
from typing import List
import argparse
import shutil
from . import utils


def src_iter(abspath: str) -> List[str]:
    for p in utils.glob_abs(f'{abspath}/**/*.h'):
        yield p
    for p in utils.glob_abs(f'{abspath}/**/*.hpp'):
        yield p
    for p in utils.glob_abs(f'{abspath}/**/*.inl'):
        yield p
    for p in utils.glob_abs(f'{abspath}/**/*.cpp'):
        yield p

def print_list(title: str, lst: List[str]):
    if lst:
        print(f'{title}:')
        for p in lst:
            print(f'  {p}')


def fmt(abspath: str, _args):
    clang_format_exe = shutil.which('clang-format')
    if clang_format_exe is None:
        print('clang-format is not in the PATH')
        return -1
    print(f'format cpp: using {clang_format_exe}')

    for p in src_iter(abspath):
        print(p)
        subprocess.run([clang_format_exe, p, '-style=file', '-i'])
    return 0


desc = '''
pysrc lint path    lint python packages, modules in path
pysrc format path  format python packages, modules in path
'''

if __name__ == '__main__':
    main_parser = argparse.ArgumentParser(add_help=True, formatter_class=argparse.RawDescriptionHelpFormatter, description=desc)
    command_choices = ['fmt']
    main_parser.add_argument('command', nargs='?', choices=command_choices, help=utils.help_str(command_choices), metavar='command')
    main_parser.add_argument('path', nargs='?', help='dir or path to process')
    main_parser.add_argument('--clang-format', '-f', help='path to the clang-format file', metavar='<p>')
    main_parser.add_argument('--verbose', '-v', action='store_true', help='')

    argv = sys.argv[1:]
    # args, command_argv = main_parser.parse_known_args(argv) # use when other parsers are used in each command
    args = main_parser.parse_args(argv)

    abspath = utils.abspath(os.getcwd(), args.path)

    clang_format = args.clang_format
    if not clang_format:
        python_format = utils.norm_path(f'{os.environ["GA_SCRIPTS"]}/cpp/_clang-format')

    if args.verbose:
        print(f'abspath      = {abspath}')
        print(f'clang_format = {clang_format}')

    rc = 0
    if args.command == 'fmt':
        rc = fmt(abspath, args)

    sys.exit(rc)



















def run(args):
    parser = argparse.ArgumentParser()
    parser.add_argument("rootdir", nargs="*")
    parser.add_argument("--style", nargs="?", default="Google")
    parser.add_argument("--verbose", action="store_true")
    parsed_args = parser.parse_args(args)

    def find_files(directory, pattern):
        for root, dirs, files in os.walk(directory):
            for basename in files:
                if fnmatch.fnmatch(basename, pattern):
                    filename = os.path.join(root, basename)
                    yield filename

    call_args = ["clang-format.exe", "-i", "--style={}".format(parsed_args.style)]

    for rootdir in parsed_args.rootdir:
        for filename in find_files(rootdir, "*.cpp"):
            call_args.append(filename)

    if parsed_args.verbose:
        print(call_args)

    subprocess.call(call_args)

if __name__ == "__main__":
    run(sys.argv)