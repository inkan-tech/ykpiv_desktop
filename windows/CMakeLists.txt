# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "ykpiv_desktop")
project(${PROJECT_NAME} LANGUAGES CXX)

# Invoke the build for native code shared with the other target platforms.
# This can be changed to accommodate different builds.
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

# Variables for external tool setup
set(YUBICO_PIV_TOOL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../yubico-piv-tool")

# Utilisation de la variable d'environnement VCPKG_ROOT
if(NOT DEFINED ENV{VCPKG_ROOT})
    message(FATAL_ERROR "VCPKG_ROOT is not defined. Please set the VCPKG_ROOT environment variable to the root directory of your vcpkg installation.")
endif()

set(VCPKG_ROOT $ENV{VCPKG_ROOT})
set(OPENSSL_ROOT_DIR "${VCPKG_ROOT}/packages/openssl_x64-windows")
set(OPENSSL_INCLUDE_DIR "${OPENSSL_ROOT_DIR}/include")
set(OPENSSL_CRYPTO_LIBRARY "${OPENSSL_ROOT_DIR}/lib/libcrypto.lib")
set(GETOPT_LIB_DIR "${VCPKG_ROOT}/packages/getopt-win32_x64-windows/lib")
set(GETOPT_INCLUDE_DIR "${VCPKG_ROOT}/packages/getopt-win32_x64-windows/include")
set(ZLIB_LIB_DIR "${VCPKG_ROOT}/packages/zlib_x64-windows/lib/zlib.lib")
set(ZLIB_LIBRARY "${VCPKG_ROOT}/packages/zlib_x64-windows/lib/zlib.lib")
set(ZLIB_INCLUDE_DIR "${VCPKG_ROOT}/packages/zlib_x64-windows/include")

# Ensure the yubico-piv-tool directory is not empty
file(GLOB YUBICO_PIV_TOOL_FILES "${YUBICO_PIV_TOOL_DIR}/*")
if(YUBICO_PIV_TOOL_FILES STREQUAL "")
    message(FATAL_ERROR "Yubico PIV tool directory is empty. Please download and extract the files manually.")
else()
    message(STATUS "Yubico PIV tool directory is not empty. Proceeding with the build.")
endif()

# Set environment variable for OpenSSL
set(ENV{OPENSSL_ROOT_DIR} "${OPENSSL_ROOT_DIR}")

# Build the yubico-piv-tool
execute_process(
    COMMAND ${CMAKE_COMMAND} -E make_directory build
    WORKING_DIRECTORY ${YUBICO_PIV_TOOL_DIR}
)

execute_process(
    COMMAND ${CMAKE_COMMAND} -A x64 
        -DGETOPT_LIB_DIR=${GETOPT_LIB_DIR} 
        -DGETOPT_INCLUDE_DIR=${GETOPT_INCLUDE_DIR} 
        -DZLIB=${ZLIB_LIB_DIR} 
        -DZLIB_LIBRARY=${ZLIB_LIBRARY} 
        -DZLIB_INCLUDE_DIR=${ZLIB_INCLUDE_DIR} 
        -DOPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR} 
        -DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_CRYPTO_LIBRARY} 
        -DOPENSSL_STATIC_LINK=ON ..
    WORKING_DIRECTORY ${YUBICO_PIV_TOOL_DIR}/build
)

execute_process(
    COMMAND ${CMAKE_COMMAND} --build .
    WORKING_DIRECTORY ${YUBICO_PIV_TOOL_DIR}/build
)

# Define target directories
set(WINDOWS_TARGET_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../windows/target")
set(WINDOWS_LIBS_DIR "${WINDOWS_TARGET_DIR}/lib/Debug")
set(WINDOWS_TOOL_DIR "${WINDOWS_TARGET_DIR}/tool/Debug")
set(WINDOWS_YKCS11_DIR "${WINDOWS_TARGET_DIR}/ykcs11/Debug")

# Copy the contents of the build directory to the target directory
file(GLOB BUILD_CONTENTS "${YUBICO_PIV_TOOL_DIR}/build/*")
foreach(file ${BUILD_CONTENTS})
    file(COPY ${file} DESTINATION ${WINDOWS_TARGET_DIR})
endforeach()

# Check if the build output exists in the target directory before proceeding
if(EXISTS "${WINDOWS_LIBS_DIR}/libykpiv.dll" AND EXISTS "${WINDOWS_LIBS_DIR}/libcrypto-3-x64.dll" AND EXISTS "${WINDOWS_LIBS_DIR}/zlib1.dll" AND EXISTS "${WINDOWS_TOOL_DIR}/getopt.dll" AND EXISTS "${WINDOWS_YKCS11_DIR}/libykcs11.dll")
    message(STATUS "All required build files have been successfully copied to the target directory.")
else()
    message(FATAL_ERROR "Required build files not found in the target directory. Build might have failed.")
endif()

# Chemin de destination des bibliothèques dans le projet Flutter (racine du dossier example)
set(EXAMPLE_DIR "${CMAKE_CURRENT_BINARY_DIR}/../../../../../")

# Copier les bibliothèques Windows dans le répertoire example
file(COPY "${WINDOWS_LIBS_DIR}/libykpiv.dll"
     DESTINATION "${EXAMPLE_DIR}")
file(COPY "${WINDOWS_LIBS_DIR}/libcrypto-3-x64.dll"
     DESTINATION "${EXAMPLE_DIR}")
file(COPY "${WINDOWS_LIBS_DIR}/zlib1.dll"
     DESTINATION "${EXAMPLE_DIR}")
file(COPY "${WINDOWS_TOOL_DIR}/getopt.dll"
     DESTINATION "${EXAMPLE_DIR}")
file(COPY "${WINDOWS_YKCS11_DIR}/libykcs11.dll"
     DESTINATION "${EXAMPLE_DIR}")

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(ykpiv_desktop_bundled_libraries
  # Defined in ../src/CMakeLists.txt.
  # This can be changed to accommodate different builds.
  $<TARGET_FILE:ykpiv_desktop>
  PARENT_SCOPE
)