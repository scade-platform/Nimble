#!/bin/sh

# NOTE: SCRIPT CAN BE ONLY EXECUTED FROM THE XCODE

# PACKAGE_DIR is defined in the "plugin.xcconfig" root config
# BUILT_PRODUCT_CONTENTS_DIR is defined in the "build.xcconfig" root config

PACKAGE_NAME=$(basename $PACKAGE_DIR)

echo "Building $PACKAGE_NAME for ${CONFIGURATION}"


if [ -d "$PACKAGE_DIR" ]; then
    cd $PACKAGE_DIR
else
    echo "No package for the plugin found"
    exit 1
fi


if [ "$CONFIGURATION" = "Debug" ]; then
    CONFIGURATION="debug"
else
    CONFIGURATION="release"
fi


#swift build --product $PACKAGE_NAME --configuration $CONFIGURATION
swift build --configuration $CONFIGURATION

# Embed libraries
INSTALL_DIR="${BUILT_PRODUCT_CONTENTS_DIR}/Frameworks"
INSTALL_RESOURCES_DIR="${BUILT_PRODUCT_CONTENTS_DIR}/Resources"

mkdir -p $INSTALL_DIR
mkdir -p $INSTALL_RESOURCES_DIR

function embed_package {    
    local LIB_NAME="lib${1}.dylib"
    local LIB_PATH="${PACKAGE_BUILD_DIR}/${LIB_NAME}"
    if [ -f ${LIB_PATH} ]; then
        cp ${LIB_PATH} ${INSTALL_DIR}
        /usr/bin/codesign --force --sign "${CODE_SIGN_IDENTITY}" "${INSTALL_DIR}/${LIB_NAME}"
    fi
    
    # Copy target resources to the plugin directory
    local BUNDLE_PATH="${PACKAGE_BUILD_DIR}/${PACKAGE_NAME}_${1}.bundle"
    if [ -d ${BUNDLE_PATH} ]; then
        cp -R ${BUNDLE_PATH}/* ${INSTALL_RESOURCES_DIR}/
    fi
}

# Embed plugin's package
embed_package $PACKAGE_NAME


# Embed extra packages
while getopts e: flag
do
    case "${flag}" in
        e) EMBEDDED_PACKAGES="${EMBEDDED_PACKAGES} ${OPTARG}";;                
    esac
done


echo "Embedding packages: ${EMBEDDED_PACKAGES}"

for pkg in ${EMBEDDED_PACKAGES}; do
    embed_package ${pkg}    
done
