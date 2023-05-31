
add_library(BuildSystem SHARED)

# Set properties
set_target_properties(BuildSystem PROPERTIES
  FRAMEWORK TRUE
  MACOSX_BUNDLE_BUNDLE_NAME "BuildSystem"
  MACOSX_BUNDLE_BUNDLE_VERSION "${NIMBLE_VERSION}"
#  MACOSX_BUNDLE_GUI_IDENTIFIER "com.scade.Nimble"
  MACOSX_BUNDLE_COPYRIGHT "${NIMBLE_COPYRIGHT}"
  MACOSX_FRAMEWORK_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist  
#  RESOURCE "${Nimble_RESOURCES}"
  INSTALL_RPATH "@executable_path;@executable_path/../Frameworks;@loader_path/../Frameworks"
#  BUILD_WITH_INSTALL_RPATH TRUE
)

set(package_sources
    Automatic.swift
    BuildSystem.swift
    BuildSystemIcons.swift
    Target.swift)

set(plugin_sources
    Commands.swift
    Plugin.swift
    ShellBuildTool.swift
    UI/ToolbarTargetControl.swift)

foreach(source ${package_sources})
    target_sources(BuildSystem PRIVATE
                   ${CMAKE_CURRENT_SOURCE_DIR}/../../Packages/BuildSystem/Sources/BuildSystem/${source})
endforeach()

foreach(source ${plugin_sources})
  target_sources(BuildSystem PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Sources/${source})
endforeach()

target_link_libraries(BuildSystem PRIVATE NimbleCore)
