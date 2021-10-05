#!/usr/bin/env python
# -*- coding: utf-8 -*-

# updates the header for all .swift files

import os
import sys

def update_source(filename, header):
    reader = open(filename,"r") 
    fileLines = reader.readlines()
    reader.close()
    fileContent = ''.join(fileLines)
    oldHeader = ""
    oldHeaderSize = 0
    for line in fileLines:
        if line.startswith("import"):
            break
        if line == "\n":
            continue
        if line.find("Created by") != -1:
            # skip lines with authors 
            oldHeaderSize += len(line)
            continue
        if line.find("Copyright") != -1:
            oldHeaderSize += len(line)
            oldHeader += "//  Copyright © 2021 SCADE Inc. All rights reserved.\n"
            continue
        oldHeader += line
        oldHeaderSize += len(line)
    if oldHeader.find(header) != -1:
        #file already has needed header
        return
    print("updating " + filename)
    fileBody = fileContent[oldHeaderSize:]
    newFileContent = oldHeader + header + fileBody
    open(filename, "w").write(newFileContent)

        

def recursive_traversal(dir, header):
    fns = os.listdir(dir)
    # print("listing " + dir)
    for fn in fns:
        #skip all files starts with . (.build, .git, etc.)
        if fn.startswith("."):
            continue
        fullfn = os.path.join(dir,fn)
        if os.path.isdir(fullfn):
            recursive_traversal(fullfn, header)
        else:
            if fullfn.endswith(".swift"):
                update_source(fullfn, header)
    


def main(args):
    pathToProject = args[0]
    headerFile = args[1]
    with open(headerFile, "r") as reader:
        header = reader.read()
        recursive_traversal(pathToProject, header)

if __name__ == "__main__":
  main(sys.argv[1:])
exit()