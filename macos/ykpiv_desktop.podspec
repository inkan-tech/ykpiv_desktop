#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ykpiv_desktop.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ykpiv_desktop'
  s.version          = '0.0.1'
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
    YKPIV_VERSION="2.5.2"
    YKPIV_DIR="../yubico-piv-tool"
    YKPIV_TARBALL="yubico-piv-tool-${YKPIV_VERSION}.tar.gz"
    YKPIV_URL="https://github.com/Yubico/yubico-piv-tool/archive/refs/tags/yubico-piv-tool-${YKPIV_VERSION}.tar.gz"
    
    # Create target directory structure
    mkdir -p target/lib
    mkdir -p target/include
    
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
      # Remove any incomplete directory
      rm -rf "${YKPIV_DIR}"
      curl -L ${YKPIV_URL} -o ${YKPIV_TARBALL}
      tar -xzf ${YKPIV_TARBALL}
      # The tarball extracts to yubico-piv-tool-yubico-piv-tool-VERSION
      mv "yubico-piv-tool-yubico-piv-tool-${YKPIV_VERSION}" "${YKPIV_DIR}"
      rm ${YKPIV_TARBALL}
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
            -DCMAKE_INSTALL_PREFIX=../target \
            -DBACKEND=macscard \
            -DOPENSSL_ROOT_DIR="${OPENSSL_ROOT_DIR}" \
            -DOPENSSL_LIBRARIES="${OPENSSL_ROOT_DIR}/lib"
    
    # Build and install to the target directory
    make install
    
    # Copy required headers for FFI
    mkdir -p ../Classes
    cp -R lib/*.h ../Classes/
    cp -R common/*.h ../Classes/
  CMD

  # Include necessary headers
  s.public_header_files = 'Classes/*.h', 'target/include/ykpiv/*.h'
  s.source_files = 'Classes/*.h'
  
  # Reference the built libraries - use wildcard pattern to handle version changes
  s.library = "ykpiv"
  s.vendored_libraries = 'target/lib/libykpiv.a', 'target/lib/libykpiv.dylib'
  s.preserve_paths = 'target/lib/*', 'target/include/*'
  
  # Define resources
  s.resources = 'target/lib/libykpiv*.dylib'
  
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
