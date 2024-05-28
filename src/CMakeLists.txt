# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(ykpiv_desktop_library VERSION 0.0.1 LANGUAGES C)

add_library(ykpiv_desktop SHARED
  "ykpiv_desktop.c"
)

set_target_properties(ykpiv_desktop PROPERTIES
  PUBLIC_HEADER ykpiv_desktop.h
  OUTPUT_NAME "ykpiv_desktop"
)

target_compile_definitions(ykpiv_desktop PUBLIC DART_SHARED_LIB)
