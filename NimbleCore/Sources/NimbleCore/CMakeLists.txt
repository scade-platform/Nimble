
target_sources(NimbleCore
    PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/Icon.swift
    ${CMAKE_CURRENT_LIST_DIR}/CreationWizard.swift
    ${CMAKE_CURRENT_LIST_DIR}/Console.swift
    ${CMAKE_CURRENT_LIST_DIR}/Folder.swift
    ${CMAKE_CURRENT_LIST_DIR}/Diagnostic.swift
    ${CMAKE_CURRENT_LIST_DIR}/Command.swift
    ${CMAKE_CURRENT_LIST_DIR}/Project.swift
    ${CMAKE_CURRENT_LIST_DIR}/File.swift
    ${CMAKE_CURRENT_LIST_DIR}/Settings.swift
    ${CMAKE_CURRENT_LIST_DIR}/Document.swift
    ${CMAKE_CURRENT_LIST_DIR}/Editor.swift
    ${CMAKE_CURRENT_LIST_DIR}/Theme.swift
    ${CMAKE_CURRENT_LIST_DIR}/Workbench.swift
    ${CMAKE_CURRENT_LIST_DIR}/Plugin.swift
    )

include(${CMAKE_CURRENT_LIST_DIR}/Impl/CMakeLists.txt)
include(${CMAKE_CURRENT_LIST_DIR}/UI/CMakeLists.txt)
include(${CMAKE_CURRENT_LIST_DIR}/PropertyWrappers/CMakeLists.txt)
include(${CMAKE_CURRENT_LIST_DIR}/Utils/CMakeLists.txt)
include(${CMAKE_CURRENT_LIST_DIR}/Extensions/CMakeLists.txt)    
