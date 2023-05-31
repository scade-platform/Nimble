add_library(NimbleCore SHARED)
#target_compile_options(NimbleCore PRIVATE -fmodules)

# Add sources
include(Sources/CMakeLists.txt)

# Group sources
get_target_property(NimbleCore_SOURCES NimbleCore SOURCES)
source_group(TREE "${CMAKE_CURRENT_LIST_DIR}" FILES ${NimbleCore_SOURCES})

# Set properties
set_target_properties(NimbleCore PROPERTIES
  FRAMEWORK TRUE  
  MACOSX_BUNDLE_BUNDLE_NAME "NimbleCore"
  MACOSX_FRAMEWORK_IDENTIFIER "com.scade.NimbleCore"
  MACOSX_BUNDLE_BUNDLE_VERSION "${NIMBLE_VERSION}"
  MACOSX_BUNDLE_COPYRIGHT "${NIMBLE_COPYRIGHT}"
  INSTALL_RPATH "@executable_path;@executable_path/../Frameworks;@loader_path/../Frameworks"
  BUILD_WITH_INSTALL_RPATH TRUE 
)

# External dependencies

# Yams
FetchContent_Declare(Yams
  GIT_REPOSITORY https://github.com/jpsim/Yams.git
  GIT_TAG 5.0.3
)
FetchContent_MakeAvailable(Yams)

set_property(TARGET Yams PROPERTY FOLDER "NimbleCore/Dependencies")
set_property(TARGET CYaml PROPERTY FOLDER "NimbleCore/Dependencies")

# SPM dependencies

swift_add_spm(SCOPE NimbleCore
              URLS "https://github.com/mxcl/Path.swift.git#version=0.16.3"
                   "https://github.com/gr-markin/SwiftSVG#branch=master"
                   "https://github.com/1024jp/WFColorCode.git#version=2.8.0")

#swift_add_spm_url("https://github.com/mxcl/Path.swift.git" "1.4.0")
#swift_add_spm_url("https://github.com/gr-markin/SwiftSVG")
#swift_add_spm_url("https://github.com/1024jp/WFColorCode.git" "2.8.0")
#set_property(TARGET ColorCode-spm PROPERTY FOLDER "NimbleCore/Dependencies")

target_link_libraries(NimbleCore PUBLIC Yams)
target_link_libraries(NimbleCore PUBLIC NimbleCore::Path NimbleCore::ColorCode NimbleCore::SwiftSVG)
