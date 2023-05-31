
include(SwiftPM)


add_library(LSPClient SHARED)

# Set properties
set_target_properties(LSPClient PROPERTIES
  MACOSX_BUNDLE TRUE
  MACOSX_BUNDLE_BUNDLE_NAME "LSPClient"
  MACOSX_BUNDLE_BUNDLE_VERSION "${NIMBLE_VERSION}"
#  MACOSX_BUNDLE_GUI_IDENTIFIER "com.scade.Nimble"
  MACOSX_BUNDLE_COPYRIGHT "${NIMBLE_COPYRIGHT}"
  MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist  
#  RESOURCE "${Nimble_RESOURCES}"
  INSTALL_RPATH "@executable_path;@executable_path/../Frameworks;@loader_path/../Frameworks"
#  BUILD_WITH_INSTALL_RPATH TRUE
)

set(package_sources
    LSPServer.swift
    LSPConnector.swift
    Extensions/CodeAction.swift
    Extensions/LSPClient+Capabilities.swift
    Extensions/String+Position.swift
    LSPClient.swift
    LSPTypes.swift
    Settings.swift)

set(plugin_sources
    Plugin.swift)

foreach(source ${package_sources})
    target_sources(LSPClient PRIVATE
                   ${CMAKE_CURRENT_SOURCE_DIR}/../../Packages/LSPClient/Sources/LSPClient/${source})
endforeach()

foreach(source ${plugin_sources})
  target_sources(LSPClient PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Sources/${source})
endforeach()

swift_add_spm(SCOPE LSPClientSPM
              URLS "git@github.com:FLORG1/sourcekit-lsp.git#branch=release/5.8")

target_link_libraries(LSPClient PRIVATE LSPClientSPM::_SourceKitLSP)
target_link_libraries(LSPClient PUBLIC NimbleCore BuildSystem CodeEditorPlugin)
