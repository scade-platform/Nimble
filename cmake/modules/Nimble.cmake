include(CMakeParseArguments)

function(add_nimble_application name)
    cmake_parse_arguments(
            ARG
            ""
            "INFO_PLIST"
            "RESOURCES"
            ${ARGN}
    )

    add_executable(${name} ${ARG_UNPARSED_ARGUMENTS} ${ARG_RESOURCES})
    target_compile_options(${name} PRIVATE -fmodules)
    
    if(ARG_INFO_PLIST)
        set_property(TARGET ${name} PROPERTY MACOSX_BUNDLE_INFO_PLIST ${ARG_INFO_PLIST})
    endif()

    #TODO: resources compilation for non-Xcode build

    set_target_properties(${name} PROPERTIES
        MACOSX_BUNDLE TRUE
        RESOURCE "${ARG_RESOURCES}"
        INSTALL_RPATH "@executable_path;@executable_path/../Frameworks;@loader_path/../Frameworks"
        BUILD_WITH_INSTALL_RPATH TRUE
        )
    
    # install(TARGETS ${name} BUNDLE DESTINATION ${CMAKE_INSTALL_PREFIX})
endfunction()