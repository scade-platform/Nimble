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

# Build for every architecture
echo "Building for architectures: ${ARCHS}"
for arch in ${ARCHS}; do    
    swift build \
        --configuration $CONFIGURATION \
        --cache-path $PACKAGES_CACHE_DIR \
        --build-path $PACKAGE_BUILD_DIR \
        --triple ${arch}-apple-macosx
done


# Merge modules if there are more than one architecture
archs=(${ARCHS})
archs_len=${#archs[@]}

if [ $archs_len -gt 1 ]; then
    PACKAGE_PRODUCT_DIR=apple/${CONFIGURATION}
    mkdir -p ${PACKAGE_BUILD_DIR}/${PACKAGE_PRODUCT_DIR}

    echo "Create universal Swift modules"
    for arch in ${ARCHS}; do
        for mod_file in `ls ${PACKAGE_BUILD_DIR}/${arch}-apple-macosx/${CONFIGURATION}/*.swiftmodule`; do
            dst_dir=${PACKAGE_BUILD_DIR}/${PACKAGE_PRODUCT_DIR}/$(basename $mod_file)
            mkdir -p ${dst_dir}
            cp ${mod_file} ${dst_dir}/${arch}.swiftmodule
        done        
    done

    echo "Create universal dylibs"    
    for dylib_file in `ls ${PACKAGE_BUILD_DIR}/${archs[0]}-apple-macosx/${CONFIGURATION}/*.dylib`; do
        dylib_files=""
        for arch in ${archs[*]}; do
            dylib_files="${dylib_files} ${PACKAGE_BUILD_DIR}/${arch}-apple-macosx/${CONFIGURATION}/$(basename $dylib_file)"
        done
        dst_file=${PACKAGE_BUILD_DIR}/${PACKAGE_PRODUCT_DIR}/$(basename $dylib_file)
        lipo -create -output ${dst_file} ${dylib_files}
    done   
else
    PACKAGE_PRODUCT_DIR=${ARCHS}-apple-macosx/${CONFIGURATION}
fi

ln -sfn ${PACKAGE_PRODUCT_DIR} ${PACKAGE_BUILD_DIR}/${CONFIGURATION}
PACKAGE_PRODUCT_DIR=${PACKAGE_BUILD_DIR}/${PACKAGE_PRODUCT_DIR}



# Embed libraries
INSTALL_DIR="${BUILT_PRODUCT_CONTENTS_DIR}/Frameworks"
INSTALL_RESOURCES_DIR="${BUILT_PRODUCT_CONTENTS_DIR}/Resources"

mkdir -p $INSTALL_DIR
mkdir -p $INSTALL_RESOURCES_DIR

function embed_package {    
    local LIB_NAME="lib${1}.dylib"
    local LIB_PATH="${PACKAGE_PRODUCT_DIR}/${LIB_NAME}"
    if [ -f ${LIB_PATH} ]; then
        cp ${LIB_PATH} ${INSTALL_DIR}
        /usr/bin/codesign --force --sign "${CODE_SIGN_IDENTITY}" "${INSTALL_DIR}/${LIB_NAME}"
    fi
    
    # Copy target resources to the plugin directory
    local BUNDLE_PATH="${PACKAGE_PRODUCT_DIR}/${PACKAGE_NAME}_${1}.bundle"
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
