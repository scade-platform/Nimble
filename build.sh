#!/bin/sh

#######################################################################################
# Exit when any command fails
set -e
# Keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# Echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT
#######################################################################################

# Clean build directories
find ~/Library/Developer/Xcode/DerivedData -type d -name "Nimble-*" -exec rm -rf {}/Build \;

# Build project
xcodebuild -workspace Nimble.xcworkspace -scheme Nimble -configuration=Release -xcconfig build.xcconfig CURRENT_PROJECT_VERSION=$TAG_VERSION install

# Compress
hdiutil create -volname Nimble -srcfolder ./Applications -ov -format UDZO Nimble.dmg