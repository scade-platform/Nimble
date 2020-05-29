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
xcodebuild build -workspace Nimble.xcworkspace -scheme Nimble-Release -xcconfig build.xcconfig CURRENT_PROJECT_VERSION=$TAG_VERSION

# Move Nimble.app
mkdir -p Applications
mv $HOME/Library/Developer/Xcode/DerivedData/Nimble-*/Build/Products/Release/Nimble.app ./Applications/Nimble.app

# Compress
hdiutil create -volname Nimble -srcfolder ./Applications -ov -format UDZO Nimble.dmg

# Clean apps
rm -rf ./Applications/Nimble.app