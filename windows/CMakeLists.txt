# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "ykpiv_desktop")
project(${PROJECT_NAME} LANGUAGES CXX C) # Added C language

# Ensure vcpkg toolchain is used if specified
if(DEFINED CMAKE_TOOLCHAIN_FILE AND EXISTS "${CMAKE_TOOLCHAIN_FILE}")
  include("${CMAKE_TOOLCHAIN_FILE}")
  message(STATUS "Using vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")
else()
  message(WARNING "CMAKE_TOOLCHAIN_FILE is not defined or does not exist. Vcpkg dependencies might not be found correctly.")
endif()

# Find required dependencies using vcpkg
find_package(OpenSSL REQUIRED)
find_package(ZLIB REQUIRED)
# Note: getopt is often header-only or part of libc on non-Windows,
# but vcpkg provides getopt-win32 for Windows.
# We might need specific handling if find_package doesn't work directly.
# For now, assume find_package works or handle it later if needed.
find_package(getopt CONFIG) # Try finding config first
if(NOT getopt_FOUND)
  find_package(Getopt) # Fallback to standard find module if config fails
endif()
if(NOT getopt_FOUND)
  message(WARNING "Could not find getopt using find_package. Manual configuration might be needed if yubico-piv-tool requires it.")
  # Add manual hints if necessary, e.g., based on VCPKG_ROOT
  # set(GETOPT_INCLUDE_DIR "${VCPKG_ROOT}/packages/getopt-win32_x64-windows/include")
  # set(GETOPT_LIBRARY "${VCPKG_ROOT}/packages/getopt-win32_x64-windows/lib/getopt.lib")
endif()

# Use the git submodule instead of FetchContent
# Initialize submodules if not already done
execute_process(
  COMMAND git submodule update --init --recursive
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/..
  RESULT_VARIABLE GIT_SUBMOD_RESULT
)
if(NOT GIT_SUBMOD_RESULT EQUAL "0")
  message(WARNING "git submodule update --init --recursive failed with ${GIT_SUBMOD_RESULT}")
endif()

# Add the yubico-piv-tool subdirectory from the submodule
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../yubico-piv-tool" "${CMAKE_CURRENT_BINARY_DIR}/yubico-piv-tool")

# The yubico-piv-tool build should now provide targets like 'ykpiv'
# Check the yubico-piv-tool CMakeLists.txt for exact target names if needed.

# Invoke the build for the (currently unused) native code shared with other platforms.
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

# Define the plugin library target (even if it's just a placeholder)
# This target is referenced by the Flutter build process.
add_library(${PROJECT_NAME}_plugin SHARED IMPORTED)
set_target_properties(${PROJECT_NAME}_plugin PROPERTIES
  IMPORTED_LOCATION "${CMAKE_BINARY_DIR}/lib/libykpiv.dll" # Point to the actual DLL location
  IMPORTED_IMPLIB "${CMAKE_BINARY_DIR}/lib/libykpiv.lib" # Point to the import library
)
# Ensure ykpiv target is built before trying to use its output
add_dependencies(${PROJECT_NAME}_plugin ykpiv)

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

# List of libraries to bundle (placeholder, actual bundling handled by Flutter build)
set(ykpiv_desktop_bundled_libraries
  # The actual library needed at runtime is libykpiv.dll and its dependencies.
  # The target defined in src/CMakeLists.txt (ykpiv_desktop) is currently not used.
  # We reference the IMPORTED target we created for the Flutter tooling.
  ${PROJECT_NAME}_plugin
  PARENT_SCOPE
)

# Set environment variable for ffigen (can be used in ffigen-windows.yaml)
# Requires CMake 3.14+ for generator expressions in environment variables,
# but setting it directly might work for immediate use.
# A better approach is to pass it via the build command or a wrapper script.
# For now, let's assume the user sets VCPKG_INSTALLED_DIR manually or we update ffigen config later.
# set(ENV{FFIGEN_OPENSSL_INCLUDE} "${OpenSSL_INCLUDE_DIRS}") # Example
