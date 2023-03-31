
target_sources(Nimble
    PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/WorkbenchArea.swift
    ${CMAKE_CURRENT_LIST_DIR}/BinaryFileDocument.swift
    ${CMAKE_CURRENT_LIST_DIR}/NimbleController.swift
    ${CMAKE_CURRENT_LIST_DIR}/ProjectDocument.swift
    ${CMAKE_CURRENT_LIST_DIR}/NimbleWorkbench.swift
    ${CMAKE_CURRENT_LIST_DIR}/AppDelegate.swift
    ${CMAKE_CURRENT_LIST_DIR}/WorkbenchContentView.swift
    ${CMAKE_CURRENT_LIST_DIR}/WorkbenchSettings.swift
    )

include(${CMAKE_CURRENT_LIST_DIR}/Extensions/CMakeLists.txt)
include(${CMAKE_CURRENT_LIST_DIR}/Controls/CMakeLists.txt)
include(${CMAKE_CURRENT_LIST_DIR}/Commands/CMakeLists.txt)
include(${CMAKE_CURRENT_LIST_DIR}/Controllers/CMakeLists.txt)    
