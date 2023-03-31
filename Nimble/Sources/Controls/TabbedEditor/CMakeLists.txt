
target_sources(Nimble
    PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/TabbedEditor.swift
    ${CMAKE_CURRENT_LIST_DIR}/TabbedEditor.xib
    ${CMAKE_CURRENT_LIST_DIR}/TabbedEditorViewModel.swift
    )

include(${CMAKE_CURRENT_LIST_DIR}/HiddenScrollView/CMakeLists.txt)
include(${CMAKE_CURRENT_LIST_DIR}/EditorTab/CMakeLists.txt)    
