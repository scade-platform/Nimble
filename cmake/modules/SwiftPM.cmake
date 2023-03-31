
include(FetchContent)


# saving path to this script
set(SWIFTPM_SCRIPT_PATH "${CMAKE_CURRENT_LIST_DIR}")


# checking that swift compiler is set
if("${CMAKE_Swift_COMPILER}" STREQUAL "")
    message(FATAL_ERROR "Path to Swift compiler is not set")
endif()


# getting path to swift interpreter
get_filename_component(swiftc_path "${CMAKE_Swift_COMPILER}" DIRECTORY)
if("${swiftc_path}" STREQUAL "")
    # looking for swift interpreter in PATH
    find_program(SWIFTPM_SWIFT_PATH "swift")
else()
    # looking for swift interpreter in same directory as swiftc
    find_program(SWIFTPM_SWIFT_PATH "swift" PATHS "${swiftc_path}" NO_DEFAULT_PATH)
endif()

if("${SWIFTPM_SWIFT_PATH}" STREQUAL "SWIFTPM_SWIFT_PATH-NOTFOUND")
    message(FATAL_ERROR "Can't find swift interpreter for swift compiler: ${CMAKE_Swift_COMPILER}")
else()
    message(STATUS "Using swift interpreter for parsing SPM manifests: ${SWIFTPM_SWIFT_PATH}")
endif()


# detecting swift triple target processor
if(NOT "${CMAKE_OSX_ARCHITECTURES}" STREQUAL "")
    # for now only single architecture is supported
    list(LENGTH CMAKE_OSX_ARCHITECTURES narches)
    if("${narches}" GREATER 1)
        set(msg "Multiarch build for Macos is not supported yet.")
        set(msg "${msg} Please set single architecture in the CMAKE_OSX_ARCHITECTURES variable.")
        set(msg "${msg} Current CMAKE_OSX_ARCHITECTURES value: ${CMAKE_OSX_ARCHITECTURES}")
        message(FATAL_ERROR "${msg}")
    endif()

    if("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "x86_64")
        set(SWIFTPM_TARGET_PROCESSOR "x86_64")
    elseif("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "arm64")
        set(SWIFTPM_TARGET_PROCESSOR "arm64")
    else()
        message(FATAL_ERROR "Unsupported OSX architecture: ${CMAKE_OSX_ARCHITECTURES}")
    endif()
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "amd64|x86_64")
    if("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
        set(SWIFTPM_TARGET_PROCESSOR "x86_64")
    else()
        set(SWIFTPM_TARGET_PROCESSOR "i686")
    endif()
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "x86|i386|i586|i686")
    set(SWIFTPM_TARGET_PROCESSOR "i686")
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "armv7")
    set(SWIFTPM_TARGET_PROCESSOR "armv7")
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "arm64" OR "${CMAKE_SYSTEM_PROCESSOR}" MATCHES "aarch64")
    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        set(SWIFTPM_TARGET_PROCESSOR "arm64")
    else()
        set(SWIFTPM_TARGET_PROCESSOR "aarch64")
    endif()
else()
    message(FATAL_ERROR "Unknown swift target processor: ${CMAKE_SYSTEM_PROCESSOR}")
endif()


# detecting swift target OS and ABI
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    set(SWIFTPM_TARGET_OS "linux")
    set(SWIFTPM_TARGET_TRIPLE_OS "unknown-linux")

    if("${SWIFTPM_TARGET_PROCESSOR}" STREQUAL "armv7")
        set(SWIFTPM_TARGET_TRIPLE_ABI "gnueabihf")
    else()
        set(SWIFTPM_TARGET_TRIPLE_ABI "gnu")
    endif()

    set(SWIFTPM_TARGET_TRIPLE_ABI_NO_VERSION "${SWIFTPM_TARGET_TRIPLE_ABI}")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
    set(SWIFTPM_TARGET_OS "android")
    set(SWIFTPM_TARGET_TRIPLE_OS "none-linux")
    set(SWIFTPM_TARGET_TRIPLE_ABI_NO_VERSION "android")
    set(SWIFTPM_TARGET_TRIPLE_ABI "android")

    # Use android API version in triple for new NDKs with unified sysroot
    if(ANDROID_USE_UNIFIED_SYSROOT)
        set(SWIFTPM_TARGET_TRIPLE_ABI "${SWIFTPM_TARGET_TRIPLE_ABI}${ANDROID_NATIVE_API_LEVEL}")
    endif()
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    if(IOS)
      set(SWIFTPM_TARGET_OS "${XCODE_IOS_PLATFORM}")
      set(SWIFTPM_TARGET_TRIPLE_OS "apple")
      set(SWIFTPM_TARGET_TRIPLE_ABI_NO_VERSION "ios")
      set(SWIFTPM_TARGET_TRIPLE_ABI "ios${IOS_DEPLOYMENT_TARGET}")
      if("${IOS_PLATFORM}" STREQUAL "SIMULATOR" OR "${IOS_PLATFORM}" STREQUAL "SIMULATOR64")
        set(SWIFTPM_TARGET_TRIPLE_ABI "${SWIFTPM_TARGET_TRIPLE_ABI}-simulator")
      endif()
    else()
      set(SWIFTPM_TARGET_OS "macosx")
      set(SWIFTPM_TARGET_TRIPLE_OS "apple")
      set(SWIFTPM_TARGET_TRIPLE_ABI_NO_VERSION "macosx")
      set(SWIFTPM_TARGET_TRIPLE_ABI "macosx${OSX_DEPLOYMENT_TARGET}")
    endif()

else()
    message(FATAL_ERROR "Unknown swift target OS")
endif()


set(SWIFTPM_TARGET_TRIPLE_NO_VERSION
    "${SWIFTPM_TARGET_PROCESSOR}-${SWIFTPM_TARGET_TRIPLE_OS}-${SWIFTPM_TARGET_TRIPLE_ABI_NO_VERSION}")
set(SWIFTPM_TARGET_TRIPLE
    "${SWIFTPM_TARGET_PROCESSOR}-${SWIFTPM_TARGET_TRIPLE_OS}-${SWIFTPM_TARGET_TRIPLE_ABI}")

message(STATUS "SwiftPM target triple: ${SWIFTPM_TARGET_TRIPLE}")


# Adds SPM v5 package into build
function(swift_add_spm_v5 path desc)
    # parsing options
    set(options)
    set(one_args)
    set(multi_args LIBRARIES SWIFT_FLAGS)
    cmake_parse_arguments(SWIFT_ADD_SPM_V5 "${options}" "${one_args}" "${multi_args}" ${ARGN})

    # splitting lines in description
    string(REPLACE "\n" ";" lines "${desc}")

    set(line_idx 0)
    list(LENGTH lines lines_count)

    # parsing package name
    list(GET lines "${line_idx}" package_name)
    math(EXPR line_idx "${line_idx} + 1")
    message(STATUS "SwiftPM Package name: ${package_name}")

    # parsing package dependencies
    set(package_deps)
    while(TRUE)
        if("${line_idx}" EQUAL "${lines_count}")
            break()
        endif()

        list(GET lines "${line_idx}" line)
        math(EXPR line_idx "${line_idx} + 1")

        if("${line}" STREQUAL "TARGETS")
            break()
        endif()

        message(STATUS "Package dependency: ${line}")
        list(APPEND package_deps "${line}-package")
    endwhile()

    # Parsing targets
    set(targets)
    while(TRUE)
        if("${line_idx}" EQUAL "${lines_count}")
            break()
        endif()

        list(GET lines "${line_idx}" line)
        math(EXPR line_idx "${line_idx} + 1")

        if("${line}" STREQUAL "PRODUCTS")
            break()
        endif()

        # splitting target line into list
        string(REPLACE " " ";" line_items "${line}")
        list(LENGTH line_items line_items_count)

        # getting target name
        list(GET line_items 0 target_name)

        # getting target sources path
        list(GET line_items 1 target_path)
        if("${target_path}" STREQUAL "<empty>")
            set(target_path "")
        else()
            set(target_path "${path}/${target_path}")
            if(NOT EXISTS "${target_path}")
                message(FATAL_ERROR "Source path fot target '${target_name}' does not exist: '${target_path}'")
            endif()
        endif()

        # getting target dependencies
        set(line_item_idx "2")
        set(target_deps)
        while("${line_item_idx}" LESS "${line_items_count}")
            list(GET line_items "${line_item_idx}" dep)
            list(APPEND target_deps "${dep}")
            math(EXPR line_item_idx "${line_item_idx} + 1")
        endwhile()

        list(APPEND targets "${target_name}")
        set("swift_add_spm_target_dependencies_${target_name}" ${target_deps})

        # looking for target source directory if not set
        if("${target_path}" STREQUAL "")
            set(source_dirs_names "Sources" "Source" "srcs" "src")
            set(target_path)
            foreach(source_dir ${source_dirs_names})
                if(EXISTS "${path}/${source_dir}/${target_name}" AND
                   IS_DIRECTORY "${path}/${source_dir}/${target_name}")
                    set(target_path "${path}/${source_dir}/${target_name}")
                    break()
                endif()
            endforeach()
        endif()

        if("${target_path}" STREQUAL "")
            message(FATAL_ERROR "Can't find source path for target '${target_name}'")
        endif()

        set("swift_add_spm_target_path_${target_name}" "${target_path}")
#        message(STATUS "Target: ${target_name}: ${target_path}, DEPENDENCIES: ${target_deps}")
    endwhile()

    # Parsing products
    set(products)
    set(libraries)
    set(executables)
    while(TRUE)
        if("${line_idx}" EQUAL "${lines_count}")
            break()
        endif()

        list(GET lines "${line_idx}" line)
        math(EXPR line_idx "${line_idx} + 1")

        # splitting product line into list
        string(REPLACE " " ";" line_items "${line}")
        list(LENGTH line_items line_items_count)

        # getting product name
        list(GET line_items 0 product_name)

        # getting product type
        list(GET line_items 1 product_type)

        if("${product_type}" STREQUAL "EXECUTABLE")
            list(APPEND executables "${product_name}")
        elseif("${product_type}" STREQUAL "STATIC_LIBRARY")
            list(APPEND libraries "${product_name}")
            set("swift_add_spm_library_type_${product_name}" "STATIC")
        elseif("${product_type}" STREQUAL "DYNAMIC_LIBRARY")
            list(APPEND libraries "${product_name}")
            set("swift_add_spm_library_type_${product_name}" "SHARED")
        endif()

        # getting product targets
        set(line_item_idx "2")
        set(product_targets)
        while("${line_item_idx}" LESS "${line_items_count}")
            list(GET line_items "${line_item_idx}" targ)
            list(APPEND product_targets "${targ}")
            math(EXPR line_item_idx "${line_item_idx} + 1")
        endwhile()

        message(STATUS "Product: ${product_name} ${product_type}: ${product_targets}")
        list(APPEND products "${product_name}")
        set("swift_add_spm_product_type_${product_name}" ${product_type})
        set("swift_add_spm_product_targets_${product_name}" ${product_targets})
    endwhile()


    ##################################################
    # cmake targets generation

    set(spm_scratch_path "${CMAKE_CURRENT_BINARY_DIR}/${package_name}-spm-build")

    # detecting path to SPM build directories
    string(TOLOWER "${CMAKE_BUILD_TYPE}" build_type_lowercase)
    set(build_path "${spm_scratch_path}/${SWIFTPM_TARGET_TRIPLE}/${build_type_lowercase}")
    set(build_path_debug "${spm_scratch_path}/${SWIFTPM_TARGET_TRIPLE}/debug")
    set(build_path_release "${spm_scratch_path}/${SWIFTPM_TARGET_TRIPLE}/release")

    # creating build paths if not exist because cmake requires that INTERFACE_INCLUDE_DIRECTORIES
    # property is set to existing directories only
    if(NOT EXISTS "${build_path}")
        file(MAKE_DIRECTORY "${build_path}")
    endif()

    # collecting paths to all include directories in all targets
    set(all_include_paths)
    foreach(targ ${targets})
        set(targ_path "${swift_add_spm_target_path_${targ}}")
        if(EXISTS "${targ_path}/include")
            list(APPEND all_include_paths "${targ_path}")
        endif()
    endforeach()


    # creating targets for libraries
    set(libraries_outputs_debug)
    set(libraries_outputs_release)
    foreach(lib ${libraries})
        set(lib_type "${swift_add_spm_library_type_${product_name}}")
        add_library("${package_name}-${lib}" "${lib_type}" IMPORTED)

        if("${lib_type}" STREQUAL "SHARED")
            set(lib_name "${CMAKE_SHARED_LIBRARY_PREFIX}${lib}${CMAKE_SHARED_LIBRARY_SUFFIX}")
        else()
            set(lib_name "${CMAKE_STATIC_LIBRARY_PREFIX}${lib}${CMAKE_STATIC_LIBRARY_SUFFIX}")
        endif()

        set(lib_output_debug "${build_path_debug}/${lib_name}")
        set(lib_output_release "${build_path_release}/${lib_name}")

        list(APPEND libraries_outputs_debug "${lib_output_debug}")
        list(APPEND libraries_outputs_release "${lib_output_release}")

        set_property(TARGET "${package_name}-${lib}"
                     PROPERTY IMPORTED_LOCATION "${lib_output_debug}")
        set_property(TARGET "${package_name}-${lib}"
                     PROPERTY IMPORTED_LOCATION_DEBUG "${lib_output_debug}")
        set_property(TARGET "${package_name}-${lib}"
                     PROPERTY IMPORTED_LOCATION_RELEASE "${lib_output_release}")

        set_property(TARGET "${package_name}-${lib}"
                     PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${build_path}" ${all_include_paths})

        # creating alias
        add_library("${package_name}::${lib}" ALIAS "${package_name}-${lib}")
    endforeach()


    # creating rules for executing SPM build

    set(swift_build_conf_flags)
    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Release")
        list(APPEND swift_build_conf_flags "-c" "release")
    endif()

    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        set(libraries_outputs ${libraries_outputs_debug})
    else()
        set(libraries_outputs ${libraries_outputs_release})
    endif()

    add_custom_command(OUTPUT ${libraries_outputs}
                       COMMAND "${SWIFTPM_SWIFT_PATH}" "build"
                               "--scratch-path" "${spm_scratch_path}"
                               ${swift_build_conf_flags}
                       WORKING_DIRECTORY "${path}")

    add_custom_target("${package_name}-spm"
                      COMMAND "${SWIFTPM_SWIFT_PATH}" "build"
                              "--scratch-path" "${spm_scratch_path}"
                              ${swift_build_conf_flags}
                      BYPRODUCTS ${libraries_outputs}
                      WORKING_DIRECTORY "${path}")

    # creating interface library for all libraries
    add_library("${package_name}-all" INTERFACE)
    add_library("${package_name}::All" ALIAS "${package_name}-all")


    # adding dependencies for each library
    foreach(lib ${libraries})
        # adding depencency for all libraries interface library
        target_link_libraries("${package_name}-all" INTERFACE "${package_name}-${lib}")

        add_dependencies("${package_name}-${lib}" "${package_name}-spm")
    endforeach()
endfunction()


# Adds all targets from SPM Package
function(swift_add_spm)
    # checking if we have single package in list of packages (for compatibility version)
    list(LENGTH ARGN count)
    set(is_single_package FALSE)
    if("${count}" EQUAL "1")
        set(is_single_package TRUE)
        set(packages_orig ${ARGN})
    else()
        set(options)
        set(one_args)
        set(multi_args PACKAGES SWIFT_FLAGS
                       LIBRARIES LIBRARIES_MACOS LIBRARIES_IPHONEOS LIBRARIES_IPHONESIMULATOR
                       LIBRARIES_ANDROID-X86 LIBRARIES_ANDROID-ARMEABI-V7A)
        cmake_parse_arguments(SWIFT_ADD_SPM "${options}" "${one_args}" "${multi_args}" ${ARGN})
        set(packages_orig ${SWIFT_ADD_SPM_PACKAGES})
    endif()

    set(libraries ${SWIFT_ADD_SPM_LIBRARIES})
    string(TOUPPER "${SCADESDK_ARCH_TARGET}" SCADESDK_ARCH_TARGET_UPPER)
    list(APPEND libraries ${SWIFT_ADD_SPM_LIBRARIES_${SCADESDK_ARCH_TARGET_UPPER}})

    # replacing relative paths in package list
    set(packages)
    foreach(path_orig ${packages_orig})
        if(IS_ABSOLUTE "${path_orig}")
            set(path "${path_orig}")
        else()
            set(path "${CMAKE_CURRENT_SOURCE_DIR}/${path_orig}")
        endif()

        list(APPEND packages "${path}")
    endforeach()

    # dumping all packages
    foreach(path ${packages})
        # checking that package path exists
        if(NOT EXISTS "${path}")
            message(FATAL_ERROR "Package path does not exist: '${path}'")
        endif()

        # checking that package path is a directory
        if(NOT IS_DIRECTORY "${path}")
            message(FATAL_ERROR "Package path is not a directory: '${path}'")
        endif()

        get_filename_component(path_name "${path}" NAME)

        # getting version of package manager for specified package
        set(swift_tool_path "${SWIFTPM_SWIFT_PATH}")
        execute_process(COMMAND "${swift_tool_path}" "package" "tools-version"
                        WORKING_DIRECTORY "${path}"
                        RESULT_VARIABLE res
                        OUTPUT_VARIABLE out
                        ERROR_VARIABLE out
                        OUTPUT_STRIP_TRAILING_WHITESPACE
                        ERROR_STRIP_TRAILING_WHITESPACE)
        if(NOT "${res}" EQUAL "0")
            message(FATAL_ERROR "Can't detect swift tools version for package located in '${path}':\n${out}")
        endif()

        # detecting tools version for package
        string(SUBSTRING "${out}" 0 1 v)
        if("${v}" STREQUAL "5")
            set(tools_version_${path_name} "5")
            message(STATUS "Found SPM 5 package in '${path}'")
        elseif("${v}" STREQUAL "4")
            message(FATAL_ERROR "swift-tools-version 4 is not supported in SwiftPM module")
        elseif("${v}" STREQUAL "3")
            message(FATAL_ERROR "swift-tools-version 3 is not supported in SwiftPM module")
        else()
            message(FATAL_ERROR "Unknown swift tools version for package '${path}': ${out}")
        endif()

        set(package_json "${CMAKE_CURRENT_BINARY_DIR}/dump_package-${path_name}.json")
        set(package_out "${CMAKE_CURRENT_BINARY_DIR}/dump_package-${path_name}.out")

        set(dump_script_name "dump_package_v${tools_version_${path_name}}")
        set(dump_script_path "${SWIFTPM_SCRIPT_PATH}/../scripts/dump_package_v${tools_version_${path_name}}.swift")

        # dumping package only if .out file does not exist or older than Pacakge.swift,
        # or if .out file is older than dump script
        set(do_dump TRUE)
        if(EXISTS "${package_out}")
            file(TIMESTAMP "${package_out}" out_timestamp "%s")
            file(TIMESTAMP "${path}/Package.swift" package_swift_timestamp "%s")
            file(TIMESTAMP "${dump_script_path}" dump_script_timestamp "%s")

            if(NOT "${out_timestamp}" STREQUAL "" AND
               NOT "${package_swift_timestamp}" STREQUAL "" AND
               NOT "${dump_script_timestamp}" STREQUAL "")
                if("${package_swift_timestamp}" LESS "${out_timestamp}" AND
                   "${dump_script_timestamp}" LESS "${out_timestamp}")
                    set(do_dump FALSE)
                endif()
            endif()
        endif()

        set(dump_cmd "${swift_tool_path}" "${dump_script_path}")

        if("${do_dump}")
            # dumping package JSON description using swift package dump-package
            message(STATUS "Dumping package '${path}' json using swift tool '${swift_tool_path}'...")
            execute_process(COMMAND "${swift_tool_path}" "package" "dump-package"
                            WORKING_DIRECTORY "${path}"
                            RESULT_VARIABLE res
                            ERROR_VARIABLE err
                            OUTPUT_FILE "${package_json}"
                            OUTPUT_STRIP_TRAILING_WHITESPACE
                            ERROR_STRIP_TRAILING_WHITESPACE)
            if(NOT "${res}" EQUAL "0")
                file(REMOVE "${package_json}")
                message(FATAL_ERROR "Can't dump package located in '${path}':\n${err}")
            endif()

            # dumping package from JSON description
            message(STATUS "Converting package '${path}' json dump using command '${dump_cmd}'...")
            execute_process(COMMAND ${dump_cmd}
                            WORKING_DIRECTORY "${path}"
                            RESULT_VARIABLE res
                            ERROR_VARIABLE err
                            INPUT_FILE "${package_json}"
                            OUTPUT_FILE "${package_out}"
                            OUTPUT_STRIP_TRAILING_WHITESPACE
                            ERROR_STRIP_TRAILING_WHITESPACE)
            if(NOT "${res}" EQUAL "0")
                file(REMOVE "${package_out}")
                message(FATAL_ERROR "Can't convert JSON description for package located at '${package_json}':\n${err}")
            endif()
        else()
            message(STATUS "Skipping SPM package dump step")
        endif()
    endforeach()

    if("${is_single_pacakge}")
        # always add single package (for compatibility mode)
        get_filename_component(path_name "${path}" NAME)

        file(READ "${CMAKE_CURRENT_BINARY_DIR}/dump_package-${path_name}.out" out)
        string(STRIP "${out}" out)

        swift_add_spm_v5("${path}" "${out}" LIBRARIES ${SWIFT_ADD_SPM_LIBRARIES} SWIFT_FLAGS ${SWIFT_ADD_SPM_SWIFT_FLAGS})
    else()
        foreach(path ${packages})
            get_filename_component(path_name "${path}" NAME)
            file(READ "${CMAKE_CURRENT_BINARY_DIR}/dump_package-${path_name}.out" out)
            string(STRIP "${out}" out)

            swift_add_spm_v5("${path}" "${out}" LIBRARIES ${SWIFT_ADD_SPM_LIBRARIES} SWIFT_FLAGS ${SWIFT_ADD_SPM_SWIFT_FLAGS})
        endforeach()
    endif()
endfunction()


# Adds all targets from SPM Package with URL
function(swift_add_spm_url url tag)
    # extracting project name from URL
    get_filename_component(package_name "${url}" NAME_WE)

    set(package_src_dir "${CMAKE_CURRENT_BINARY_DIR}/spm-build/checkouts/${package_name}")

    # declaring package
    FetchContent_Declare("${package_name}"
                         GIT_REPOSITORY "${url}"
                         GIT_TAG "${tag}"
                         SOURCE_DIR "${package_src_dir}")

    # fetching package
    FetchContent_MakeAvailable("${package_name}")

    # adding spm package
    swift_add_spm("${package_src_dir}")
endfunction()
