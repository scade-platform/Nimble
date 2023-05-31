
# Settings variables:
# CMAKE_SPM_PREBUILT_PATH - Optional path to external prebuilt cmake-spm utility. 
#                           If not set then cmake-spm utility will be built from sources
#                           during configure phase
# CMAKE_SPM_SOURCE_PATH   - Optional path to cmake-spm sources. If not set then cmake-spm
#                           sources will be checked out from default repository
# CMAKE_SPM_BRANCH        - Name of branch to checkout from default cmake-spm repository.
#                           If not set then master branch will be used.

include(FetchContent)

# saving path to this script
set(SWIFTPM_SCRIPT_PATH "${CMAKE_CURRENT_LIST_DIR}")


# checking that swift compiler is set
if("${CMAKE_Swift_COMPILER}" STREQUAL "")
    message(FATAL_ERROR "Path to Swift compiler is not set")
endif()


# getting path to swift executable
get_filename_component(swiftc_path "${CMAKE_Swift_COMPILER}" DIRECTORY)
if("${swiftc_path}" STREQUAL "")
    # looking for swift executable in PATH
    find_program(SWIFTPM_SWIFT_PATH "swift")
else()
    # looking for swift executable in same directory as swiftc
    find_program(SWIFTPM_SWIFT_PATH "swift" PATHS "${swiftc_path}" NO_DEFAULT_PATH)
endif()

if("${SWIFTPM_SWIFT_PATH}" STREQUAL "SWIFTPM_SWIFT_PATH-NOTFOUND")
    message(FATAL_ERROR "Can't find swift executable for swift compiler: ${CMAKE_Swift_COMPILER}")
else()
    message(STATUS "Using swift executable for building SPM: ${SWIFTPM_SWIFT_PATH}")
endif()


# # detecting swift triple target processor
# if(NOT "${CMAKE_OSX_ARCHITECTURES}" STREQUAL "")
#     # for now only single architecture is supported
#     list(LENGTH CMAKE_OSX_ARCHITECTURES narches)
#     if("${narches}" GREATER 1)
#         set(msg "Multiarch build for Macos is not supported yet.")
#         set(msg "${msg} Please set single architecture in the CMAKE_OSX_ARCHITECTURES variable.")
#         set(msg "${msg} Current CMAKE_OSX_ARCHITECTURES value: ${CMAKE_OSX_ARCHITECTURES}")
#         message(FATAL_ERROR "${msg}")
#     endif()

#     if("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "x86_64")
#         set(SWIFTPM_TARGET_PROCESSOR "x86_64")
#     elseif("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "arm64")
#         set(SWIFTPM_TARGET_PROCESSOR "arm64")
#     else()
#         message(FATAL_ERROR "Unsupported OSX architecture: ${CMAKE_OSX_ARCHITECTURES}")
#     endif()
# elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "amd64|x86_64")
#     if("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
#         set(SWIFTPM_TARGET_PROCESSOR "x86_64")
#     else()
#         set(SWIFTPM_TARGET_PROCESSOR "i686")
#     endif()
# elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "x86|i386|i586|i686")
#     set(SWIFTPM_TARGET_PROCESSOR "i686")
# elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "armv7")
#     set(SWIFTPM_TARGET_PROCESSOR "armv7")
# elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "arm64" OR "${CMAKE_SYSTEM_PROCESSOR}" MATCHES "aarch64")
#     if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
#         set(SWIFTPM_TARGET_PROCESSOR "arm64")
#     else()
#         set(SWIFTPM_TARGET_PROCESSOR "aarch64")
#     endif()
# else()
#     message(FATAL_ERROR "Unknown swift target processor: ${CMAKE_SYSTEM_PROCESSOR}")
# endif()


# # detecting swift target OS and ABI
# if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
#     set(SWIFTPM_TARGET_OS "linux")
#     set(SWIFTPM_TARGET_TRIPLE_OS "unknown-linux")

#     if("${SWIFTPM_TARGET_PROCESSOR}" STREQUAL "armv7")
#         set(SWIFTPM_TARGET_TRIPLE_ABI "gnueabihf")
#     else()
#         set(SWIFTPM_TARGET_TRIPLE_ABI "gnu")
#     endif()

#     set(SWIFTPM_TARGET_TRIPLE_ABI_NO_VERSION "${SWIFTPM_TARGET_TRIPLE_ABI}")
# elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
#     set(SWIFTPM_TARGET_OS "android")
#     set(SWIFTPM_TARGET_TRIPLE_OS "none-linux")
#     set(SWIFTPM_TARGET_TRIPLE_ABI_NO_VERSION "android")
#     set(SWIFTPM_TARGET_TRIPLE_ABI "android")

#     # Use android API version in triple for new NDKs with unified sysroot
#     if(ANDROID_USE_UNIFIED_SYSROOT)
#         set(SWIFTPM_TARGET_TRIPLE_ABI "${SWIFTPM_TARGET_TRIPLE_ABI}${ANDROID_NATIVE_API_LEVEL}")
#     endif()
# elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
#     if(IOS)
#       set(SWIFTPM_TARGET_OS "${XCODE_IOS_PLATFORM}")
#       set(SWIFTPM_TARGET_TRIPLE_OS "apple")
#       set(SWIFTPM_TARGET_TRIPLE_ABI_NO_VERSION "ios")
#       set(SWIFTPM_TARGET_TRIPLE_ABI "ios${IOS_DEPLOYMENT_TARGET}")
#       if("${IOS_PLATFORM}" STREQUAL "SIMULATOR" OR "${IOS_PLATFORM}" STREQUAL "SIMULATOR64")
#         set(SWIFTPM_TARGET_TRIPLE_ABI "${SWIFTPM_TARGET_TRIPLE_ABI}-simulator")
#       endif()
#     else()
#       set(SWIFTPM_TARGET_OS "macosx")
#       set(SWIFTPM_TARGET_TRIPLE_OS "apple")
#       set(SWIFTPM_TARGET_TRIPLE_ABI_NO_VERSION "macosx")
#       set(SWIFTPM_TARGET_TRIPLE_ABI "macosx${OSX_DEPLOYMENT_TARGET}")
#     endif()

# else()
#     message(FATAL_ERROR "Unknown swift target OS")
# endif()


# set(SWIFTPM_TARGET_TRIPLE_NO_VERSION
#     "${SWIFTPM_TARGET_PROCESSOR}-${SWIFTPM_TARGET_TRIPLE_OS}-${SWIFTPM_TARGET_TRIPLE_ABI_NO_VERSION}")
# set(SWIFTPM_TARGET_TRIPLE
#     "${SWIFTPM_TARGET_PROCESSOR}-${SWIFTPM_TARGET_TRIPLE_OS}-${SWIFTPM_TARGET_TRIPLE_ABI}")

# message(STATUS "SwiftPM target triple: ${SWIFTPM_TARGET_TRIPLE}")

# Path to cmake-spm build directory
set(CMAKE_SPM_BUILD_PATH "${CMAKE_BINARY_DIR}/cmake-spm-build")

# Path to cmake-spm source directory
# if("${CMAKE_SPM_SOURCE_PATH}" STREQUAL "")
#     set(CMAKE_SPM_SOURCE_PATH "${CMAKE_BINARY_DIR}/cmake-spm")
# endif()

# detecting path to cmake-spm tool
if("${CMAKE_SPM_PREBUILT_PATH}")
    set(CMAKE_SPM_PATH "${CMAKE_SPM_PREBUILT_PATH}")
else()
    set(CMAKE_SPM_PATH "${CMAKE_BINARY_DIR}/cmake-spm-build/debug/cmake-spm")
endif()


# Builds cmake-spm utility from sources. Returns path to cmake-spm executable
function(build_cmake_spm result_path)
    if(NOT "${CMAKE_SPM_PREBUILT_PATH}" STREQUAL "")
        # using prebuilt cmake-spm
        set(${result_path} "${CMAKE_SPM_PREBUILT_PATH}" PARENT_SCOPE)
        return()
    endif()

    # checking out sources from remote repository
    set(src_path "${CMAKE_SPM_SOURCE_PATH}")
    if("${src_path}" STREQUAL "")
        set(branch "${CMAKE_SPM_BRANCH}")
        if("${branch}" STREQUAL "")
            set(branch "main")
        endif()

        # checking out cmake-spm from remote repository
        FetchContent_Declare(cmake-spm
                             GIT_REPOSITORY "git@github.com:scade-platform/cmake-spm.git"
                             GIT_TAG "${branch}")

        FetchContent_Populate(cmake-spm)
        message(STATUS "Checked out cmake-spm to: ${cmake-spm_SOURCE_DIR}")
        set(src_path "${cmake-spm_SOURCE_DIR}")
    else()
        message(STATUS "Using cmake-spm sources from:  ${src_path}")
    endif()

    # building cmake-spm from sources
    message(STATUS "Building cmake-spm utlity in ${CMAKE_SPM_BUILD_PATH}...")
    file(MAKE_DIRECTORY "${CMAKE_SPM_BUILD_PATH}")
    message(STATUS "WORK DIR: ${src_path}")
    execute_process(COMMAND "${SWIFTPM_SWIFT_PATH}" "build" "--scratch-path" "${CMAKE_SPM_BUILD_PATH}"
                    RESULT_VARIABLE res
                    COMMAND_ECHO STDOUT
                    WORKING_DIRECTORY "${src_path}")
    if(NOT "${res}" EQUAL "0")
        message(FATAL_ERROR "Can't build cmake-spm utitlity")
    endif()

    set(${result_path} "${CMAKE_SPM_BUILD_PATH}/debug/cmake-spm" PARENT_SCOPE)
endfunction()


# Recursively iterates through source tree and creates symlinks for source files with bad
# characters (only '>' for now) in names
function(creeate_symlinks_for_bad_chars path)
    file(GLOB_RECURSE files RELATIVE "${path}" "${path}/*.swift")

    foreach(file ${files})
        get_filename_component(file_name "${file}" NAME)
        get_filename_component(file_dir "${file}" DIRECTORY)

        string(REPLACE ">" "_" file_name_replaced "${file_name}")
        if(NOT "${file_name_replaced}" STREQUAL "${file_name}")
            set(symlink_file "${path}/${file_dir}/${file_name_replaced}")
            if (NOT EXISTS "${symlink_file}")
                execute_process(COMMAND "${CMAKE_COMMAND}" "-E" "create_symlink"
                                        "${file_name}" ${symlink_file}
                                RESULT_VARIABLE res)
                if("${res}" EQUAL "0")
                    message(STATUS "Creating symling ${symlink_file} for ${file_name}...")
                else()
                    message(FATAL_ERROR "Can't create symlink ${symlink_file}")
                endif()
            endif()
        endif()
    endforeach()
endfunction()


# Adds SPM package into project
function(swift_add_spm)
    # parsing options
    set(options)
    set(one_args SCOPE)
    set(multi_args URLS BRANCH COMMIT VERSION)
    cmake_parse_arguments(SWIFT_ADD_SPM "${options}" "${one_args}" "${multi_args}" ${ARGN})

    build_cmake_spm(cmake_spm_path)

    set(wporkspace_dir "${CMAKE_BINARY_DIR}/spm-workspace")
    if(NOT "${SWIFT_ADD_SPM_SCOPE}" STREQUAL "")
        set(wporkspace_dir "${wporkspace_dir}-${SWIFT_ADD_SPM_SCOPE}")
    endif()

    if("${SWIFT_ADD_SPM_URLS}" STREQUAL "")
        message(FATAL_ERROR "URLS parameter is not set for swift_add_spm")
    endif()

    # Executing cmake-spm to generate cmake project
    file(MAKE_DIRECTORY "${wporkspace_dir}")
    execute_process(COMMAND "${cmake_spm_path}"
                            "--workspace" "${wporkspace_dir}"
                            "--output" "${wporkspace_dir}"
                            "--scope" "${SWIFT_ADD_SPM_SCOPE}"
                            ${SWIFT_ADD_SPM_URLS}
                            RESULT_VARIABLE res
                            COMMAND_ECHO STDOUT)
    if(NOT "${res}" EQUAL "0")
        message(FATAL_ERROR "cmake-spm utility failed")
    endif()

    set(build_subdir "spm-workspace-build")
    if(NOT "${SWIFT_ADD_SPM_SCOPE}" STREQUAL "")
        set(build_subdir "${build_subdir}-${SWIFT_ADD_SPM_SCOPE}")
    endif()

    # creating symlinks with files
    creeate_symlinks_for_bad_chars("${wporkspace_dir}")

    # creating empty.swift stub source for dynamic library products
    file(TOUCH "${wporkspace_dir}/empty.swift")

    # including generated CMakeLists.txt
    add_subdirectory("${wporkspace_dir}" "${CMAKE_BINARY_DIR}/${build_subdir}")
endfunction()
