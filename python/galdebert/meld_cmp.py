#!/usr/bin/env python3

#import os
import subprocess
from typing import List

meld_exe = r'C:\Program Files (x86)\Meld\Meld.exe'

def compare(a: str, b: str):
    # compare 2 files using python
    cmd = [meld_exe, '/closeIfNoChanges', '/2', a, b]
    print(' '.join(cmd))
    subprocess.run(cmd)


def compare1toN(master: str, slaves: List[str]):
    for s in slaves:
        compare(master, s)
