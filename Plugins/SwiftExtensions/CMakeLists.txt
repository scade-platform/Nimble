
add_library(SwiftExtensions SHARED)

# Set properties
set_target_properties(SwiftExtensions PROPERTIES
  MACOSX_BUNDLE TRUE
  MACOSX_BUNDLE_BUNDLE_NAME "SwiftExtensions"
  MACOSX_BUNDLE_BUNDLE_VERSION "${NIMBLE_VERSION}"
#  MACOSX_BUNDLE_GUI_IDENTIFIER "com.scade.Nimble"
  MACOSX_BUNDLE_COPYRIGHT "${NIMBLE_COPYRIGHT}"
  MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist  
#  RESOURCE "${Nimble_RESOURCES}"
  INSTALL_RPATH "@executable_path;@executable_path/../Frameworks;@loader_path/../Frameworks"
#  BUILD_WITH_INSTALL_RPATH TRUE
)

set(package_sources
    AndroidToolchain.swift
    Settings.swift
    SwiftToolchain.swift
    AppleToolchain.swift
    SKLocalServer.swift
    SwiftLanguageService.swift
    SwiftVariant.swift)

foreach(source ${package_sources})
    target_sources(SwiftExtensions PRIVATE
                   ${CMAKE_CURRENT_SOURCE_DIR}/../../Packages/SwiftExtensions/Sources/SwiftExtensions/${source})
endforeach()

target_link_libraries(SwiftExtensions PUBLIC NimbleCoreLSP::_SourceKitLSP)
target_link_libraries(SwiftExtensions PUBLIC NimbleCore LSPClient)
