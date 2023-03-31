cmake_minimum_required(VERSION 3.15.1)
project(Nimble LANGUAGES Swift)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

include(SwiftPM)
include(FetchContent)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(NIMBLE_VERSION "0.4")
set(NIMBLE_COPYRIGHT "Copyright © 2022 SCADE Inc. All rights reserved.")

add_subdirectory(Nimble)
add_subdirectory(NimbleCore)