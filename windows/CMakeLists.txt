# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "ykpiv_desktop")
project(${PROJECT_NAME} LANGUAGES CXX C) # Added C language

# Skip vcpkg dependency search - use pre-built libraries from example directory
message(STATUS "Using pre-built libraries - skipping vcpkg dependencies")

# Use pre-built libraries from example directory
set(EXAMPLE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../example")
message(STATUS "Using pre-built libraries from: ${EXAMPLE_DIR}")

# Set yubico-piv-tool directory
set(YUBICO_PIV_TOOL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../yubico-piv-tool")

# Read version from version file if it exists
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../YUBICO_VERSION")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/../YUBICO_VERSION" YUBICO_PIV_TOOL_VERSION)
    string(STRIP "${YUBICO_PIV_TOOL_VERSION}" YUBICO_PIV_TOOL_VERSION)
else()
    set(YUBICO_PIV_TOOL_VERSION "2.7.2")
endif()

set(YUBICO_PIV_TOOL_URL
    "https://developers.yubico.com/yubico-piv-tool/Releases/yubico-piv-tool-${YUBICO_PIV_TOOL_VERSION}.tar.gz")
set(YUBICO_PIV_TOOL_ARCHIVE "${CMAKE_CURRENT_SOURCE_DIR}/../yubico-piv-tool-${YUBICO_PIV_TOOL_VERSION}.tar.gz")

# Check if cmdline.c exists, if not download official release
if(NOT EXISTS "${YUBICO_PIV_TOOL_DIR}/tool/cmdline.c")
    message(STATUS "cmdline.c not found, downloading official Yubico release package...")
    
    # Download official release if not already present
    if(NOT EXISTS "${YUBICO_PIV_TOOL_ARCHIVE}")
        message(STATUS "Downloading from: ${YUBICO_PIV_TOOL_URL}")
        file(DOWNLOAD "${YUBICO_PIV_TOOL_URL}" "${YUBICO_PIV_TOOL_ARCHIVE}"
             SHOW_PROGRESS
             STATUS download_status)
        list(GET download_status 0 download_code)
        if(NOT download_code EQUAL 0)
            message(FATAL_ERROR "Failed to download yubico-piv-tool release package")
        endif()
    endif()
    
    # Extract the archive, replacing the existing directory
    message(STATUS "Extracting yubico-piv-tool release package...")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${YUBICO_PIV_TOOL_DIR}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/.."
        RESULT_VARIABLE remove_result
    )
    
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf "${YUBICO_PIV_TOOL_ARCHIVE}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/.."
        RESULT_VARIABLE extract_result
    )
    
    if(NOT extract_result EQUAL 0)
        message(FATAL_ERROR "Failed to extract yubico-piv-tool release package")
    endif()
    
    # Rename extracted directory to expected name
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E rename
                "yubico-piv-tool-${YUBICO_PIV_TOOL_VERSION}"
                "yubico-piv-tool"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/.."
        RESULT_VARIABLE rename_result
    )
    
    if(NOT rename_result EQUAL 0)
        message(FATAL_ERROR "Failed to rename extracted directory")
    endif()
    
    message(STATUS "Successfully extracted official yubico-piv-tool release with pre-generated files")
endif()

# Verify critical files exist after setup
set(REQUIRED_FILES
    "${YUBICO_PIV_TOOL_DIR}/tool/cmdline.c"
    "${YUBICO_PIV_TOOL_DIR}/tool/cmdline.h"
    "${YUBICO_PIV_TOOL_DIR}/CMakeLists.txt"
)

foreach(file ${REQUIRED_FILES})
    if(NOT EXISTS "${file}")
        message(FATAL_ERROR "Required file missing: ${file}")
    endif()
endforeach()

message(STATUS "All required yubico-piv-tool files verified")

# Create imported library target for libykpiv
add_library(ykpiv SHARED IMPORTED)
set_target_properties(ykpiv PROPERTIES
  IMPORTED_LOCATION "${EXAMPLE_DIR}/libykpiv.dll"
  IMPORTED_IMPLIB "${EXAMPLE_DIR}/libykpiv.dll" # Fallback if no .lib file
)

# Invoke the build for the (currently unused) native code shared with other platforms.
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

# Define the plugin library target for Flutter
add_library(${PROJECT_NAME}_plugin SHARED IMPORTED)
set_target_properties(${PROJECT_NAME}_plugin PROPERTIES
  IMPORTED_LOCATION "${EXAMPLE_DIR}/libykpiv.dll"
  IMPORTED_IMPLIB "${EXAMPLE_DIR}/libykpiv.dll"
)

# Ensure dependent DLLs (OpenSSL, ZLIB, getopt) are copied to the output directory
# where the Flutter runner executable will be.
# CMake install rules or custom commands can achieve this.
# A simpler approach for development is to ensure they are in the PATH or copied manually/by script.
# For a more robust solution, use install rules.

# Example of copying DLLs to the runner directory (adjust paths as needed)
# This assumes a standard Flutter build output structure.
# Note: This might run every configure, consider adding checks or using install rules.
# get_property(FLUTTER_RUNNER_OUTPUT_DIRECTORY TARGET ${PROJECT_NAME}_plugin PROPERTY ?) # Need a way to get runner output dir

# A simpler, less robust way for local runs: add build dir to PATH (often handled by IDEs)
# Or copy manually for now. Let's rely on CMake/vcpkg placing them correctly for find_package first.

# List of libraries to bundle - copy the DLLs from example directory
set(ykpiv_desktop_bundled_libraries
  "${EXAMPLE_DIR}/libykpiv.dll"
  "${EXAMPLE_DIR}/libcrypto-3-x64.dll"
  "${EXAMPLE_DIR}/getopt.dll"
  "${EXAMPLE_DIR}/zlib1.dll"
  "${EXAMPLE_DIR}/libykcs11.dll"
  PARENT_SCOPE
)

# Set environment variable for ffigen (can be used in ffigen-windows.yaml)
# Requires CMake 3.14+ for generator expressions in environment variables,
# but setting it directly might work for immediate use.
# A better approach is to pass it via the build command or a wrapper script.
# For now, let's assume the user sets VCPKG_INSTALLED_DIR manually or we update ffigen config later.
# set(ENV{FFIGEN_OPENSSL_INCLUDE} "${OpenSSL_INCLUDE_DIRS}") # Example
