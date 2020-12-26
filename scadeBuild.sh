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
find ~/Library/Developer/Xcode/DerivedData -type d -name "NimblePlugins-*" -exec rm -rf {}/Build \;

# Build project, archive with signing
xcodebuild archive -workspace NimblePlugins.xcworkspace -scheme Scade -xcconfig build.xcconfig -archivePath ./Applications/Scade CURRENT_PROJECT_VERSION=$TAG_VERSION

xcodebuild -exportArchive -archivePath ./Applications/Scade.xcarchive -exportOptionsPlist ./Nimble/Nimble/ScadeInfo.plist -exportPath ./Applications/Scade

# Create a ZIP archive suitable for altool.
ditto -c -k --keepParent ./Applications/Scade/Scade.app ./Applications/Scade.zip

xcrun altool --notarize-app --primary-bundle-id "com.scade.Nimble" --username "frank@frankjlangel.com" --password "tehh-zrzt-oquf-pqcq" --asc-provider "2ND78VA66X" --file ./Applications/Scade.zip
xcrun altool --notarization-history 0 -u "frank@frankjlangel.com" -p "tehh-zrzt-oquf-pqcq" --asc-provider "2ND78VA66X"
xcrun altool --notarization-info 1a9f5244-8a01-4a56-b04e-f255a9cfc7b6 -u "frank@frankjlangel.com" -p "tehh-zrzt-oquf-pqcq" --asc-provider "2ND78VA66X"

# Move Scade.app
# mkdir -p Applications
# mv $HOME/Library/Developer/Xcode/DerivedData/NimblePlugins-*/Build/Products/Release/Scade.app ./Applications/Scade.app

#Sign Scade.app
# codesign -f -s 'Developer ID Application: Frank Langel (2ND78VA66X)' -o runtime --entitlements ./Nimble/Nimble/Nimble.entitlements ./Applications/Scade.app 

#Notarization 


# Compress
hdiutil create -volname Scade -srcfolder ./Applications -ov -format UDZO Scade.dmg

# Clean apps
rm -rf ./Applications/Scade.app