## 0.0.7

* Documented expected Xcode duplicate file reference warning
* Reverted to working vendored_libraries wildcard pattern
* Fixed build issues with overly specific dylib patterns
* Ensured plugin works correctly despite cosmetic warnings

## 0.0.6

* Fixed macOS libykpiv symlink creation script in podspec
* Corrected sed regex pattern for version extraction
* Added symlinks creation during prepare_command phase
* Improved script_phases configuration for reliable symlink generation
* Ensured libykpiv.2.dylib and libykpiv.dylib symlinks are properly created

## 0.0.5

* Added automatic yubico-piv-tool download for Windows builds
* Improved macOS libykpiv symlink creation in podspec
* Enhanced Windows CMake configuration with version management
* Added proper .gitignore entries for CMake build files
* Fixed Windows build compatibility for Git dependencies

## 0.0.4

* Fixed Windows build by using pre-built libraries
* Improved dylib symlink creation script in Podfile
* Various build system improvements

## 0.0.3

* Fixed macOS dylib loading issue by properly vendoring libykpiv.2.dylib
* Updated podspec to embed dynamic libraries in app bundle
* Added automatic symlink creation for library versions

## 0.0.2

* Previous release

## 0.0.1

* Initial release
