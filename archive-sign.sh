#!/bin/sh

#######################################################################################
# Exit when any command fails
set -e
# Keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# Echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' ERR
#######################################################################################

WORKSPACE_NAME=$1      # Nimble
SCHEME_NAME=$2         # Nimble-Archive
APP_NAME=$3            # Nimble
PLUGINS_SCHEME_NAME=$4 # NimblePlugins-Archive
EXPORT_PLIST_PATH=$5   # ./Nimble/Nimble/exportOptionsPlist.plist
APP_ENTITLEMENTS=$6    # ./Nimble/Nimble/Nimble.entitlements

WORKING_DIR=ArchiveDir
TOOLS_ENTITLEMENTS="${WORKING_DIR}/tools.entitlements"

#Environment variables
#DEVELOPER_ID - environment variable with Apple Developer ID with format "Developer ID Application: uuu"
#AC_USERNAME - Apple Developer Account user name (email)
#AC_PASSWORD - App-specific password for altool
#PROVIDER_SHORTNAME - to get it use command `xcrun altool --list-providers -u AC_USERNAME -p AC_PASSWORD`

# Archive and export app
xcodebuild clean archive -workspace ${WORKSPACE_NAME}.xcworkspace -scheme ${SCHEME_NAME} -archivePath ./${WORKING_DIR}/${APP_NAME} MARKETING_VERSION=$TAG_VERSION
xcodebuild -exportArchive -archivePath ./${WORKING_DIR}/${APP_NAME}.xcarchive  -exportPath ./${WORKING_DIR}/ExportedArchives -exportOptionsPlist ${EXPORT_PLIST_PATH}

# Archive and export plugins
xcodebuild clean archive -workspace ${WORKSPACE_NAME}.xcworkspace -scheme ${PLUGINS_SCHEME_NAME} -archivePath ./${WORKING_DIR}/Plugins
ditto ./${WORKING_DIR}/Plugins.xcarchive/Products ./${WORKING_DIR}/ExportedArchives

#Move app and plugins to according places
mkdir -p ./${WORKING_DIR}/App
mv ./${WORKING_DIR}/ExportedArchives/${APP_NAME}.app ./${WORKING_DIR}/App
mv ./${WORKING_DIR}/ExportedArchives/Plugins/* ./${WORKING_DIR}/App/${APP_NAME}.app/Contents/Plugins


#Remove invalid signatures

#App
codesign --remove-signature "./${WORKING_DIR}/App/${APP_NAME}.app"

#Plugins
for plugin in `find ./${WORKING_DIR}/App/${APP_NAME}.app/Contents/Plugins -name "*.plugin" -type d`; do
    PLUGIN_NAME="${plugin##*/}"
    PLUGIN_NAME="${PLUGIN_NAME%.*}"
    #Plugin binary if exist
    if [ -d "$plugin/Contents/MacOS/${PLUGIN_NAME}" ]; then
        codesign --remove-signature "$plugin/Contents/MacOS/${PLUGIN_NAME}"
    fi
    #Plugins build-in frameworks and dylibs
    if [ -d "$plugin/Contents/Frameworks" ]; then
        for framework in `find $plugin/Contents/Frameworks -name "*.framework" -type d`; do
            FRAMEWORK_NAME="${framework##*/}"
            FRAMEWORK_NAME="${FRAMEWORK_NAME%.*}"
            codesign --remove-signature "$framework/Versions/A/${FRAMEWORK_NAME}"
        done
        for dylib in `find $plugin/Contents/Frameworks -name "*.dylib" -type f`; do
            codesign --remove-signature "$dylib"
        done
    fi
    codesign --remove-signature "$plugin"
done

#Create entitlements files to sign executables binary files
#Resource https://developer.apple.com/documentation/security/hardened_runtime
cat > ${TOOLS_ENTITLEMENTS} <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.cs.disable-executable-page-protection</key>
	<true/>
	<key>com.apple.security.cs.disable-library-validation</key>
	<true/>
</dict>
</plist>
EOF


# Sign plugins
for plugin in `find ./${WORKING_DIR}/App/${APP_NAME}.app/Contents/Plugins -name "*.plugin" -type d`; do
    PLUGIN_NAME="${plugin##*/}"
    PLUGIN_NAME="${PLUGIN_NAME%.*}"
    #Plugin binary if exist
    if [ -d "$plugin/Contents/MacOS/${PLUGIN_NAME}" ]; then
        echo "Signing: $plugin/Contents/MacOS/${PLUGIN_NAME}"
        codesign -s "${DEVELOPER_ID}" -f --timestamp "$plugin/Contents/MacOS/${PLUGIN_NAME}"
    fi
    #Plugins build-in frameworks and dylibs
    if [ -d "$plugin/Contents/Frameworks" ]; then
        for framework in `find $plugin/Contents/Frameworks -name "*.framework" -type d`; do
            FRAMEWORK_NAME="${framework##*/}"
            FRAMEWORK_NAME="${FRAMEWORK_NAME%.*}"
            echo "Signing: $framework/Versions/A/${FRAMEWORK_NAME}"
            codesign -s "${DEVELOPER_ID}" -f --timestamp "$framework/Versions/A/${FRAMEWORK_NAME}"
        done
        for dylib in `find $plugin/Contents/Frameworks -name "*.dylib" -type f`; do
            echo "Signing: $dylib"
            codesign -s "${DEVELOPER_ID}" -f --timestamp "$dylib"
        done
    fi
    if [ -d "$plugin/Contents/Resources" ]; then
        for bin in `find $plugin/Contents/Resources -perm +111 -type f`; do
                echo "Signing: $bin"
                codesign -s "${DEVELOPER_ID}" -f --timestamp -o runtime --entitlements ${TOOLS_ENTITLEMENTS} "$bin"
        done
    fi
    echo "Signing: $plugin"
    codesign -s "${DEVELOPER_ID}" -f --timestamp "$plugin"
done

#Sign app
codesign -s "${DEVELOPER_ID}" -f --timestamp -o runtime --entitlements ${APP_ENTITLEMENTS} "./${WORKING_DIR}/App/${APP_NAME}.app"

#Compress
hdiutil create -srcFolder ./${WORKING_DIR}/App -o ./${WORKING_DIR}/${APP_NAME}.dmg
codesign -s "${DEVELOPER_ID}" --timestamp "./${WORKING_DIR}/${APP_NAME}.dmg"

#Notarize
xcrun notarytool submit ./ArchiveDir/Nimble.dmg --apple-id "${AC_USERNAME}" --password "${AC_PASSWORD}" --team-id ${PROVIDER_SHORTNAME} --wait

# Staple Notarize ticket
xcrun stapler staple ./${WORKING_DIR}/${APP_NAME}.dmg

