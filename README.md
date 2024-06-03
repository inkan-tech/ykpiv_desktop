# ykpiv-desktop

Flutter plugin to use the yubico-piv-tool library in windows/macos

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

## Build on windows (new version)

First download source code of Yubico Piv Tool on https://developers.yubico.com/yubico-piv-tool/Releases/

Place it in the yubico-piv-tool folder

Install vcpkg : https://learn.microsoft.com/fr-fr/vcpkg/get_started/get-started-msbuild?pivots=shell-cmd

Install cmake : https://cmake.org/download/

Install dependencies with vcpkg : 

```
./vcpkg.exe install openssl:x64-windows
./vcpkg.exe install getopt:x64-windows
./vcpkg.exe install zlib:x64-windows
./vcpkg.exe install openssl:x64-windows
```

add this to your env : 

- VCPKG_ROOT : "path/to/vcpkg/root/directory"

To generate the binding with ffi you have to edit the ffigen-windows.yaml and edit the compileropt with your path to openssl include :

```
compiler-opts:
  - '-I path/to/vcpkg/packages/openssl_x64-windows/include'
```

And run : 

```
flutter pub run ffigen --config ffigen-windows.yaml
```

After that you can run the example with 

```
cd example
flutter run
```

## Build on windows (old version)

First download source code of Yubico Piv Tool on https://developers.yubico.com/yubico-piv-tool/Releases/

Place it in the yubico-piv-tool folder

Install vcpkg : https://learn.microsoft.com/fr-fr/vcpkg/get_started/get-started-msbuild?pivots=shell-cmd

Install cmake : https://cmake.org/download/

Install dependencies with vcpkg : 

```
./vcpkg.exe install openssl:x64-windows
./vcpkg.exe install getopt:x64-windows
./vcpkg.exe install zlib:x64-windows
./vcpkg.exe install openssl:x64-windows
```

add this env : 

```
$env:OPENSSL_ROOT_DIR = "C:\Users\pvhug\vcpkg\packages\openssl_x64-windows"
```

Create build dir and execute this (with your path to dependencies) : 

```
mkdir build;
cd build;

cmake -A x64 -DGETOPT_LIB_DIR="path\to\vcpkg\packages\getopt-win32_x64-windows\lib" -DGETOPT_INCLUDE_DIR="path\to\vcpkg\packages\getopt-win32_x64-windows\include" -DZLIB="path\to\vcpkg\packages\zlib_x64-windows\lib\zlib.lib" -DZLIB_LIBRARY="path\to\vcpkg\installed\x64-windows\lib\zlib.lib" -DZLIB_INCLUDE_DIR="path\to\vcpkg\installed\x64-windows\include" -DOPENSSL_STATIC_LINK=ON ..

```

Next build this with : 

```
cmake --build .
```

You can try it with (with your path) : 

```
$dllPath = "path\to\the\yubico\piv\tool\directory\build\lib\Debug"
$env:PATH += ";$dllPath"
cd .\tool\Debug\
.\yubico-piv-tool.exe -a status
```

After that you can move the content of build directory in the windows/target/ directory

To generate the binding with ffi you have to edit the ffigen-windows.yaml and edit the compileropt with your path to openssl include :

```
compiler-opts:
  - '-I path/to/vcpkg/packages/openssl_x64-windows/include'
```

And run : 

```
flutter pub run ffigen --config ffigen-windows.yaml
```


After that you can run the example with 

```
cd example
flutter run
```