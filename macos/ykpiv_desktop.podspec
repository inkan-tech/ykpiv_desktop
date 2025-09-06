#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ykpiv_desktop.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ykpiv_desktop'
  s.version          = '0.0.2'
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
    
    # Copy required headers for FFI
    mkdir -p Classes
    cp -R ${YKPIV_DIR}/lib/*.h Classes/ 2>/dev/null || true
    cp -R ${YKPIV_DIR}/common/*.h Classes/ 2>/dev/null || true
  CMD

  # Include necessary headers
  s.source_files = 'Classes/**/*.h'
  s.public_header_files = 'Classes/**/*.h'
  
  # Reference the built static library only
  s.vendored_libraries = 'target/lib/libykpiv.a'
  
  # Preserve paths for the build artifacts
  s.preserve_paths = 'target/**/*', 'Classes/**/*'
  
  # Bundle dynamic libraries as resources
  s.resource_bundles = {
    'ykpiv_desktop' => ['target/lib/*.dylib']
  }
  
  # Target macOS 10.15 (Catalina) or later for better compatibility
  s.platform = :osx, '10.15'
  
  # Additional build settings
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '-ObjC',
    'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/target/include $(PODS_TARGET_SRCROOT)/Classes'
  }
  
  s.swift_version = '5.0'
end
