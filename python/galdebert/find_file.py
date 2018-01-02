#!/usr/bin/env python3

import sys
import os
import subprocess
import argparse
from itertools import chain
from . import utils

def print_(files, _args):
    for p in files:
        print(p)

def vscode(files, args):
    cmd = ['code', '-n']
    cmd.extend(files)
    if args.verbose:
        print(' '.join(cmd))
    subprocess.run(cmd, shell=True) # shell=True required for code


desc = '''
Find files matching a glob expression in multiple rootdirs. Can print them or open them in vscode.
Files and directories starting with '.' require the '.' to be in the glob expr, ex: -g .vscode/settings.json
'''

if __name__ == '__main__':
    main_parser = argparse.ArgumentParser(add_help=True, formatter_class=argparse.RawDescriptionHelpFormatter, description=desc)
    command_choices = ['print', 'vscode']
    main_parser.add_argument('command', nargs='?', choices=command_choices, help=utils.help_str(command_choices), metavar='command')
    main_parser.add_argument('rootdirs', nargs='*', help='rootdir')
    main_parser.add_argument('-g', dest='globexpr', default='*', help='glob expression', metavar='<g>')
    main_parser.add_argument('-v', dest='verbose', action='store_true', help='verbose')

    argv = sys.argv[1:]
    args = main_parser.parse_args(argv)

    globexprs = []
    for rootdir in args.rootdirs:
        rootdir = utils.abspath(os.getcwd(), rootdir)
        globexprs.append(f'{rootdir}/**/{args.globexpr}')

    if args.verbose:
        print('globexprs:')
        for expr in globexprs:
            print(f'  {expr}')

    files = chain(*[utils.glob_abs(expr) for expr in globexprs])

    if args.command == 'print':
        print_(files, args)

    if args.command == 'vscode':
        vscode(files, args)
