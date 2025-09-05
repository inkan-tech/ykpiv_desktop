# ykpiv-desktop

Flutter plugin to use the yubico-piv-tool library in windows/macos

## Getting Started

### Clone the Repository

This project uses git submodules for the yubico-piv-tool dependency. When cloning the repository, make sure to initialize submodules:

```bash
git clone --recursive https://github.com/inkan-tech/ykpiv_desktop.git
```

Or if you've already cloned the repository:

```bash
git submodule update --init --recursive
```

## Good ref to build plugin

<https://codelabs.developers.google.com/codelabs/flutter-ffigen?hl=fr#4>
<https://medium.com/flutter-community/build-and-deploy-native-c-libraries-with-flutter-cc7531d590b5>

- samples <https://github.com/dart-lang/sdk/blob/a496692fa27c3035cfa1a56f2ef2870560df6cc3/samples/ffi/sample_ffi_structs.dart>

Of course <https://docs.flutter.dev/platform-integration/macos/c-interop> but not very explanatory

Check this for macos: <https://stackoverflow.com/questions/29972626/how-to-change-the-library-path-in-cmake-mac-osx>

Podspec reference: <https://guides.cocoapods.org/syntax/podspec.html#group_multi_platform_support>

## Validate podspec

To validate podspec use ```pod lib lint```

## Compile locally yubico-piv-tool

```cmake . -DOPENSSL_STATIC_LINK=ON -DCMAKE_INSTALL_PREFIX=./target/ 
make install
 ```

Explanation to statically link:
<https://github.com/dart-lang/sdk/issues/44126>

Or:
how to statically link a c library in flutter plugin on macos

CodeGPT Code Assistant

To statically link a C library in a Flutter plugin on macOS, you can follow these steps:

Open your Flutter plugin project in an IDE or a code editor.

Create a folder named "ios" at the root of your project if it doesn't already exist.

Inside the "ios" folder, create another folder named "cpp" or "c" (whichever suits your preference) to store the C/C++ code and library.

Copy the C library and any associated header files into the newly created "cpp" or "c" folder.

Open the "podspec" file for your Flutter plugin. This file is usually named "plugin_name.podspec" and can be found at the root of your project.

Find the line that starts with "s.preserve_paths". Add the library and header files to the array like this:

ruby
Copy code
Insert code
s.preserve_paths = 'ios/cpp/libname.a', 'ios/cpp/header.h'
Still in the "podspec" file, find the line that starts with "s.source_files". Modify it to include the path to the C/C++ code as well as any other necessary files:
ruby
Copy code
Insert code
s.source_files = 'ios/Classes/**/*.{h,m,c,cpp}', 'ios/cpp/**/*.cpp'
Save the "podspec" file.

Build the Flutter plugin using the following command:

bash
Copy code
Insert code
flutter build ios --no-codesign
After the build finishes, your C library should be statically linked in the Flutter plugin on macOS.
Remember to replace "plugin_name" with the actual name of your Flutter plugin, "libname.a" with the actual name of your C library, and "header.h" with the actual name of your header file.

## Build on Windows

### Prerequisites

1.  **Visual Studio:** Install Visual Studio with C++ development workload.
2.  **CMake:** Ensure CMake is installed and available in your PATH (usually included with Visual Studio).
3.  **vcpkg:** Install vcpkg and integrate it with your shell/environment. Follow the official vcpkg [Getting Started guide](https://learn.microsoft.com/en-us/vcpkg/get_started/get-started).
4.  **vcpkg Dependencies:** Install the required dependencies using vcpkg:
    ```bash
    ./vcpkg install openssl:x64-windows zlib:x64-windows getopt:x64-windows
    ```
5.  **Flutter SDK:** Ensure you have the Flutter SDK installed.

### Build Steps

The build process for the native `yubico-piv-tool` library and its dependencies is now automated using CMake and vcpkg.

1.  **Configure CMake with vcpkg Toolchain:** When building the Flutter plugin (or the example app), ensure CMake uses the vcpkg toolchain file. You can set this globally or pass it during the CMake configuration step used by Flutter.
    ```bash
    # Example: Setting environment variable for Flutter build
    $env:CMAKE_TOOLCHAIN_FILE="C:/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake" 
    # Or configure your IDE (like VS Code with CMake Tools extension) to use it.
    ```
2.  **Build the Flutter Project:** Run the standard Flutter build command for the example application:
    ```bash
    cd example
    flutter run -d windows
    ```
    During the build, CMake will:
    *   Use the vcpkg toolchain to find OpenSSL, zlib, and getopt.
    *   Use `FetchContent` to download the `yubico-piv-tool` source code (version 2.5.2).
    *   Build `yubico-piv-tool` and link it correctly.
    *   Ensure necessary runtime DLLs are available for the application.

### Generating FFI Bindings (If Needed)

The FFI bindings (`lib/ykpiv_desktop_bindings_generated.dart`) are pre-generated. If you need to regenerate them (e.g., after updating `yubico-piv-tool` or its headers):

1.  **Set Environment Variable:** Set the `FFIGEN_YKPIV_OPENSSL_INCLUDE` environment variable to point to your vcpkg OpenSSL include directory.
    ```powershell
    # Example using PowerShell:
    $env:FFIGEN_YKPIV_OPENSSL_INCLUDE="C:/path/to/vcpkg/installed/x64-windows/include" 
    ```
    ```bash
    # Example using bash/zsh:
    export FFIGEN_YKPIV_OPENSSL_INCLUDE="/path/to/vcpkg/installed/x64-windows/include"
    ```
    *(Replace `C:/path/to/vcpkg` with your actual vcpkg installation path)*
2.  **Run ffigen:**
    ```bash
    flutter pub run ffigen --config ffigen-windows.yaml
    ```

## Build on macOS

### Prerequisites

1.  **Xcode:** Install Xcode with Command Line Tools.
2.  **OpenSSL:** Install OpenSSL using Homebrew or another package manager.
    ```bash
    brew install openssl
    ```
3.  **CMake:** Install CMake (used by the build script internally).
    ```bash
    brew install cmake
    ```
4.  **Flutter SDK:** Ensure you have the Flutter SDK installed.

### Build Steps

The build process for macOS has been automated in the podspec file:

1.  **Set up CocoaPods (if not already set up):**
    ```bash
    sudo gem install cocoapods
    ```

2.  **Build the Flutter Project:** Run the standard Flutter build command for the example application:
    ```bash
    cd example
    flutter run -d macos
    ```
    
    During the build, CocoaPods will:
    *   Automatically download the yubico-piv-tool source code (version 2.5.2).
    *   Detect OpenSSL installation (using pkg-config or Homebrew).
    *   Build the yubico-piv-tool library with the correct configuration.
    *   Copy necessary headers and libraries to the right locations.

### Generating FFI Bindings (If Needed)

The FFI bindings for macOS use the same generated Dart file as Windows. If you need to regenerate them:

1.  **Run ffigen with the macOS configuration:**
    ```bash
    flutter pub run ffigen --config ffigen.yaml
    ```

### Troubleshooting macOS Build

If you encounter build issues on macOS:

1.  **OpenSSL Path Issues:**
    - Ensure OpenSSL is properly installed and accessible via pkg-config or Homebrew.
    - You can check the OpenSSL installation path with: `brew --prefix openssl`

2.  **Pod Install Errors:**
    - Try running the pod install manually to see detailed error messages:
      ```bash
      cd example/macos
      pod install
      ```

3.  **Permission Issues:**
    - The build process might need write access to various directories. If you see permission errors, you might need to adjust directory permissions.


## Examples of using yubico-piv-tool manually for verification

```
 ./bin/yubico-piv-tool -a verify-pin -P117334 --sign -s 9d -A ECCP256 -i data.txt -o data.sig -H SHA512
Successfully verified PIN.
Signature successful!

./bin/yubico-piv-tool -a read-cert   -s9d  -o 9d.pem 
nicolasthomas@MBP-de-Nicolas target % openssl x509 -in 9d.pem  -pubkey -noout > 9d-pub.pem
nicolasthomas@MBP-de-Nicolas target % openssl dgst -sha256 -verify 9d-pub.pem -signature data.sig data.txt   
```


## TODO

ykpiv_decipher_data seems to create the ECDH we need to encrypt/decrypt the sharedkeys.. 
sign might not work for ed25519 .. 


## Manually working on cert slot 8a

Generate signing key

./yubico-piv-tool -s8a -AED25519 -agenerate -o 8a.pub
./yubico-piv-tool -s8a -AED25519 -S'/CN=test/OU=sign/O=sealf.ie/' -averify-pin -aselfsign -P117334 -i 8a.pub -o 8a.pem

In one line: ./yubico-piv-tool -a generate -a verify-pin -a selfsign -a import-certificate -s8a -AED25519 -S'/CN=test/OU=sign/O=sealf.ie/' -P117334 -i 8a.pub 


./yubico-piv-tool -s8a -aimport-certificate -i 8a.pem

Generate crypting key



./yubico-piv-tool -s8b -AX25519 -agenerate -o 8b.pub


X509 default CSR mechanism won't work for X25519 must follow this:
https://www.reddit.com/r/AskNetsec/comments/182s8pj/creating_x25519_certificate_for_use_with_nginx_or/
especially the forced_pubkey but then it work !.

work if using a csr from the 8a slot
./yubico-piv-tool -a verify-pin -P117334 -a request-certificate -s 8a -S'/CN=test/OU=crypt/O=sealf.ie/'  -i 8a.pub -o 8a.crt
then:
openssl x509 -req -days 3653 \                                       
             -extensions server_cert \
-CA cacert.pem -CAkey cakey.pem \
-in 8a.crt \
             -force_pubkey 8b.pub \
             -out my-new-x25519.crt.pem


check https://stackoverflow.com/questions/21297139/how-do-you-sign-a-certificate-signing-request-with-your-certification-authority for cert auth.
Then import

Dummy csr from key 8a.
./yubico-piv-tool -a verify-pin -P117334 -a request-certificate -s 8a -S'/CN=test/OU=crypt/O=sealf.ie/'  -i 8a.pub -o 8a.crt



./yubico-piv-tool -s8b -aimport-certificate -i 8b.pem



## testing 
./yubico-piv-tool -s8a -averify-pin -P117334 -atest-signature -i 8a.pem -AED25519
./yubico-piv-tool -a read-certificate -a verify-pin -a test-signature -s 8a -o cert.pem -i cert.pem -AED25519 -P117334 


## Create a X25519 cert and import it 
/opt/homebrew/bin/openssl genpkey -algorithm X25519 -out x25519_private.key


## Check this for deployment

https://developers.yubico.com/yubico-piv-tool/YubiKey_PIV_introduction.html
