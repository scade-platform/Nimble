
add_executable(Nimble MACOSX_BUNDLE)
target_compile_options(Nimble PRIVATE -fmodules)

# Add Nimble sources
include(Sources/CMakeLists.txt)

# Group sources by the folder hierarchy
get_target_property(Nimble_SOURCES Nimble SOURCES)
source_group(TREE "${CMAKE_CURRENT_LIST_DIR}" FILES ${Nimble_SOURCES})

# Select resources
get_target_property(Nimble_RESOURCES Nimble SOURCES)
list(FILTER Nimble_RESOURCES INCLUDE REGEX "^[^.]+\\.xib")

# Set properties
set_target_properties(Nimble PROPERTIES
  MACOSX_BUNDLE_BUNDLE_NAME "Nimble"
  MACOSX_BUNDLE_BUNDLE_VERSION "${NIMBLE_VERSION}"
  MACOSX_BUNDLE_GUI_IDENTIFIER "com.scade.Nimble"
  MACOSX_BUNDLE_COPYRIGHT "${NIMBLE_COPYRIGHT}"
  MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_LIST_DIR}/Nimble/Info.plist.cmake.in  
  RESOURCE "${Nimble_RESOURCES}"
  INSTALL_RPATH "@executable_path;@executable_path/../Frameworks;@loader_path/../Frameworks"
  BUILD_WITH_INSTALL_RPATH TRUE
)



