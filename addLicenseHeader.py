#!/usr/bin/env python

# updates the header for all .swift files

import os
import sys

def update_source(filename, header):
    reader = open(filename,"r") 
    fileLines = reader.readlines()
    reader.close()
    fileContent = ''.join(fileLines)
    oldHeader = ""
    for line in fileLines:
        if (line.startswith("import")):
            break
        if line == "\n":
            continue
        oldHeader += line
    print("updating " + filename)
    fileBody = fileContent[len(oldHeader):]
    newFileContent = oldHeader + header + fileBody
    open(filename, "w").write(newFileContent)

        

def recursive_traversal(dir, header):
    global excludedir
    fns = os.listdir(dir)
    # print("listing " + dir)
    for fn in fns:
        #skip all files starts with . (.build, .git, etc.)
        if (fn.startswith(".")):
            continue
        fullfn = os.path.join(dir,fn)
        if (os.path.isdir(fullfn)):
            recursive_traversal(fullfn, header)
        else:
            if (fullfn.endswith(".swift")):
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