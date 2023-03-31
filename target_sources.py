#!/usr/bin/env python3

import sys
import fnmatch
import pathlib
import argparse

parser = argparse.ArgumentParser(description='Generate CMakeLists from sources')
parser.add_argument('path', type=str, help='Path to the sources directory')
parser.add_argument('--target', type=str, help='Target name to which sources should be added')
args = parser.parse_args()

root = pathlib.Path(args.path)

if not root.is_dir():
  print('Provide a directory path')

dirs = [root]

ignore = [
  '*.txt'
]

while dirs:
  d = dirs.pop()
  
  files = []
  subdirs = []

  for p in d.iterdir():
    if p.is_dir():
      subdirs.append(p)
    else:
      if not any(fnmatch.fnmatch(p.name, pat) for pat in ignore):
        files.append(p.name)
  
  dirs.extend(subdirs)
  
  files = "\n".join([f"    ${{CMAKE_CURRENT_LIST_DIR}}/{fname}" for fname in files])
  subdirs = "\n".join([f"include(${{CMAKE_CURRENT_LIST_DIR}}/{subdir.name}/CMakeLists.txt)" for subdir in subdirs])

  with (d / 'CMakeLists.txt').open('w') as fp:
    fp.write(f'''
target_sources({args.target}
    PRIVATE
{files}
    )

{subdirs}    
''')


