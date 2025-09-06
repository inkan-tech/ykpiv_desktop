#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ykpiv_desktop.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ykpiv_desktop'
  s.version          = '0.0.6'
  s.summary          = 'A Flutter FFI plugin for yubico-piv-tool.'
  s.description      = <<-DESC
  A Flutter FFI plugin for yubico-piv-tool on desktop macOS and Windows only
  to use YubiKey with Flutter apps for PIV operations.
                       DESC
  s.homepage         = 'https://github.com/inkan-tech/ykpiv_desktop'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Inkan.link' => 'contact@inkan.link' }

  # This ensures the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin.
  s.source           = { :git => 'https://github.com/inkan-tech/ykpiv_desktop.git' }
  
  s.dependency 'FlutterMacOS'
  
  # Build the yubico-piv-tool from git submodule or download if not available
  s.prepare_command = <<-CMD
    set -e
    YKPIV_VERSION="2.7.2"
    YKPIV_DIR="../yubico-piv-tool"
    YKPIV_TARBALL="yubico-piv-tool-${YKPIV_VERSION}.tar.gz"
    YKPIV_URL="https://github.com/Yubico/yubico-piv-tool/archive/refs/tags/yubico-piv-tool-${YKPIV_VERSION}.tar.gz"
    
    # Create target directory structure
    mkdir -p target/lib
    mkdir -p target/include
    
    # Check current directory
    echo "Current directory: $PWD"
    
    # Try to use git submodule first, fallback to download
    if [ -d "${YKPIV_DIR}/.git" ]; then
      echo "Using yubico-piv-tool from git submodule..."
      cd ..
      git submodule update --init --recursive
      cd macos
    elif [ -d "${YKPIV_DIR}" ] && [ -f "${YKPIV_DIR}/CMakeLists.txt" ]; then
      echo "Using existing yubico-piv-tool directory..."
    else
      echo "Git submodule not available, downloading yubico-piv-tool version ${YKPIV_VERSION}..."
      cd ..
      # Remove any incomplete directory
      rm -rf "yubico-piv-tool"
      curl -L ${YKPIV_URL} -o ${YKPIV_TARBALL}
      tar -xzf ${YKPIV_TARBALL}
      # The tarball extracts to yubico-piv-tool-yubico-piv-tool-VERSION
      mv "yubico-piv-tool-yubico-piv-tool-${YKPIV_VERSION}" "yubico-piv-tool"
      rm ${YKPIV_TARBALL}
      cd macos
    fi
    
    # Now we should have yubico-piv-tool directory available
    if [ ! -d "${YKPIV_DIR}" ]; then
      echo "Error: yubico-piv-tool directory not found at ${YKPIV_DIR}"
      exit 1
    fi
    
    cd ${YKPIV_DIR}
    
    # Find OpenSSL using pkg-config or fallback to Homebrew
    if pkg-config --exists openssl; then
      OPENSSL_ROOT_DIR=$(pkg-config --variable=prefix openssl)
      echo "Found OpenSSL using pkg-config at ${OPENSSL_ROOT_DIR}"
    elif [ -x "$(command -v brew)" ]; then
      OPENSSL_ROOT_DIR=$(brew --prefix openssl)
      echo "Found OpenSSL using Homebrew at ${OPENSSL_ROOT_DIR}"
    else
      echo "Error: OpenSSL not found. Please install OpenSSL using brew or ensure it's in your pkg-config path."
      exit 1
    fi
    
    # Clean any previous build artifacts
    rm -f CMakeCache.txt
    
    # Configure and build
    cmake . -DOPENSSL_STATIC_LINK=ON \
            -DCMAKE_INSTALL_PREFIX=../macos/target \
            -DBACKEND=macscard \
            -DOPENSSL_ROOT_DIR="${OPENSSL_ROOT_DIR}" \
            -DOPENSSL_LIBRARIES="${OPENSSL_ROOT_DIR}/lib"
    
    # Build and install to the target directory
    make install
    
    # Go back to macos directory
    cd ..
    if [ "$PWD" != *"/macos" ]; then
      cd macos
    fi
    
    # Create symlinks for the dylib files in target/lib
    cd target/lib
    if [ -f "libykpiv.2.7.2.dylib" ]; then
      ln -sf libykpiv.2.7.2.dylib libykpiv.2.dylib
      ln -sf libykpiv.2.7.2.dylib libykpiv.dylib
      echo "Created symlinks in target/lib: libykpiv.2.dylib and libykpiv.dylib"
    elif [ -f "libykpiv.2.5.2.dylib" ]; then
      ln -sf libykpiv.2.5.2.dylib libykpiv.2.dylib
      ln -sf libykpiv.2.5.2.dylib libykpiv.dylib
      echo "Created symlinks in target/lib: libykpiv.2.dylib and libykpiv.dylib"
    fi
    cd ../..
    
    # Copy required headers for FFI
    mkdir -p Classes
    cp -R ${YKPIV_DIR}/lib/*.h Classes/ 2>/dev/null || true
    cp -R ${YKPIV_DIR}/common/*.h Classes/ 2>/dev/null || true
  CMD

  # Include necessary headers
  s.source_files = 'Classes/**/*.h'
  s.public_header_files = 'Classes/**/*.h'
  
  # Reference both static and dynamic libraries including symlinks
  s.vendored_libraries = 'target/lib/libykpiv.a', 'target/lib/libykpiv*.dylib'
  
  # Preserve paths for the build artifacts
  s.preserve_paths = 'target/**/*', 'Classes/**/*'
  
  # Target macOS 10.15 (Catalina) or later for better compatibility
  s.platform = :osx, '10.15'
  
  # Additional build settings
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '-ObjC -Wl,-rpath,@loader_path/../Frameworks',
    'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/target/include $(PODS_TARGET_SRCROOT)/Classes',
    'LIBRARY_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/target/lib',
    'LD_RUNPATH_SEARCH_PATHS' => '@loader_path/../Frameworks'
  }
  
  s.swift_version = '5.0'
  
  # Add a script phase to create symlinks after the frameworks are copied
  s.script_phases = [
    {
      :name => 'Create libykpiv symlinks',
      :script => <<-SCRIPT,
# Create symlinks for libykpiv in app frameworks directory
FRAMEWORKS_PATH="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
echo "[ykpiv_desktop] Creating libykpiv symlinks in: $FRAMEWORKS_PATH"
if [ -d "$FRAMEWORKS_PATH" ]; then
  cd "$FRAMEWORKS_PATH"
  # Find the versioned dylib and create symlinks
  for dylib in libykpiv.*.*.*.dylib; do
    if [ -f "$dylib" ]; then
      echo "[ykpiv_desktop] Found $dylib, creating symlinks..."
      # Extract version numbers
      VERSION_FULL=$(echo $dylib | sed 's/libykpiv\\.\\(.*\\)\\.dylib/\\1/')
      VERSION_MAJOR=$(echo $VERSION_FULL | cut -d. -f1)
      
      # Create symlinks
      ln -sf "$dylib" "libykpiv.${VERSION_MAJOR}.dylib"
      ln -sf "$dylib" "libykpiv.dylib"
      
      echo "[ykpiv_desktop] Created symlinks:"
      echo "  libykpiv.${VERSION_MAJOR}.dylib -> $dylib"
      echo "  libykpiv.dylib -> $dylib"
      break
    fi
  done
else
  echo "[ykpiv_desktop] Warning: Frameworks directory not found: $FRAMEWORKS_PATH"
fi
SCRIPT
      :execution_position => :after_compile,
      :shell_path => '/bin/sh'
    }
  ]
end
