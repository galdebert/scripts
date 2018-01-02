#!/usr/bin/env python3

import sys
import os
import subprocess
# from typing import List
import argparse
import distutils.dir_util
from . import utils
#import galdebert.utils as ga_utils

# we have scripts_dir in our PYTHONPATH
#scripts_dir = os.environ['GA_SCRIPTS']
#sys.path.insert(0, scripts_dir)


class Build:
    def __init__(self, root_absdir: str, build_str: str, verbose: bool):
        self.verbose = verbose
        self.platform = self.parse_platform(build_str)
        self.arch_bits = self.parse_arch_bits(build_str)
        self.msvcrt = self.parse_msvcrt(build_str)
        self.toolchain = self.parse_toolchain(build_str)

        self.complete_build_str = self.get_complete_build_str()
        self.generator = self.get_cmake_generator()
        self.root_absdir = root_absdir
        self.generate_dir = f'{root_absdir}/build/{self.complete_build_str}'
        os.makedirs(self.generate_dir, exist_ok=True)

    def parse_platform(self, build_str: str) -> str:
        if 'win' in build_str:
            return 'win'
        if 'linux' in build_str:
            return 'linux'
        if 'osx' in build_str:
            return 'osx'
        if 'android' in build_str:
            return 'android'
        if 'ios' in build_str:
            return 'ios'
        return 'win'  # should be the platform running the script

    def parse_arch_bits(self, build_str: str) -> str:
        if '32' in build_str:
            return '32'
        if '64' in build_str:
            return '64'
        return '64'

    def parse_msvcrt(self, build_str: str) -> str:
        if self.platform == 'win':
            if 'md' in build_str:
                return 'md'
            else:
                return 'mt'
        else:
            return ''

    def parse_toolchain(self, build_str: str) -> str:
        if 'vc14' in build_str:
            return 'vc14'
        if 'clang' in build_str:
            return 'clang'
        if 'gcc' in build_str:
            return 'gcc'
        return 'vc14'  # should depend on the platform

    def get_complete_build_str(self) -> str:
        return f'{self.platform}{self.arch_bits}{self.msvcrt}_{self.toolchain}'

    def get_cmake_generator(self) -> str:
        if self.toolchain == 'vc14':
            if self.arch_bits == '64':
                return 'Visual Studio 15 2017 Win64'
            else:
                return 'Visual Studio 15 2017'
        else:
            return 'Ninja'

    # Visual Studio Version          MSVC Toolset Version              _MSC_VER
    # VS2015 and updates 1, 2, & 3   v140 in VS; version 14.00         1900
    # VS2017, version 15.1 & 15.2    v141 in VS; version 14.10         1910
    # VS2017, version 15.3 & 15.4    v141 in VS; version 14.11         1911
    # VS2017, version 15.5           v141 in VS; version 14.12         1912

    def generate(self):
        with utils.chg_cwd(self.generate_dir):
            print(f'cmake_generate_dir = "{self.generate_dir}"')
            cmd = ['cmake', '-G', self.generator, '-D', f'PM_BUILD={self.complete_build_str}', '-D', f'PM_ROOT={self.root_absdir}']
            if self.verbose:
                cmd.extend(['-D', 'PM_VERBOSE=1'])
            cmd.append(self.root_absdir) # source_dir must be the last arg

            print(' '.join(cmd))
            rc = subprocess.run(cmd).returncode
            return rc

    def build(self, config: str = '', target: str = ''):
        with utils.chg_cwd(self.generate_dir):
            cmd = ['cmake', '--build', self.generate_dir]
            if config:
                cmd.extend(['--config', config])
            if target:
                cmd.extend(['--target', target])
            print(' '.join(cmd))
            rc = subprocess.run(cmd).returncode
            return rc

    def clean(self):
        distutils.dir_util.remove_tree(self.generate_dir)

desc = '''
TODO
'''

def make(root_absdir):
    main_parser = argparse.ArgumentParser(add_help=True, formatter_class=argparse.RawDescriptionHelpFormatter, description=desc)
    command_choices = ['make', 'generate', 'build', 'clean']
    main_parser.add_argument('command', nargs='?', choices=command_choices, help=utils.help_str(command_choices), metavar='command')
    main_parser.add_argument('--build-str', '-b', dest='build_str', default='', help='TODO', metavar='<b>')
    main_parser.add_argument('--verbose', '-v', action='store_true', help='')

    argv = sys.argv[1:]
    args = main_parser.parse_args(argv)

    build = Build(root_absdir, args.build_str, args.verbose)

    rc = 0

    if args.command == 'make':
        rc = build.generate()
        if rc == 0:
            build.build()

    elif args.command == 'generate':
        rc = build.generate()

    elif args.command =='build':
        rc = build.build()

    elif args.command =='clean':
        rc = build.clean()

    sys.exit(rc)
