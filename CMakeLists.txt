cmake_minimum_required(VERSION 3.15.1)
project(Nimble LANGUAGES Swift CXX C ASM)

message(STATUS "CMAKE_OSX_SYSROOT = ${CMAKE_OSX_SYSROOT}")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

include(SwiftPM)
include(FetchContent)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(NIMBLE_VERSION "0.4")
set(NIMBLE_COPYRIGHT "Copyright © 2022 SCADE Inc. All rights reserved.")


swift_add_spm(SCOPE NimbleCoreLSP
              URLS "git@github.com:FLORG1/sourcekit-lsp.git#branch=release/5.8")


add_subdirectory(Nimble)
add_subdirectory(NimbleCore)
add_subdirectory(Plugins)
