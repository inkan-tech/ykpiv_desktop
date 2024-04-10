#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ykpiv_desktop.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ykpiv_desktop'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter FFI plugin for yubico-piv-tool .'
  s.description      = <<-DESC
  A Flutter FFI plugin for yubico-piv-tool on desktop macos and windows only
  To use yubikey with flutter apps.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = {  :type => 'MIT', :file => '../yubico-piv-tool/COPYING' }
  s.author           = { 'Inkan.link' => 'contact@inkan.link' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
 
  s.source           = { :git => 'https://github.com/Yubico/yubico-piv-tool.git'}
  #s.source_files  = 'Classes/lib/*.{c,h}' , 'Classes/common/*.{c,h}'
  s.dependency 'FlutterMacOS'
  s.prepare_command = <<-CMD
                        echo $PWD
                        cd ../yubico-piv-tool/
                        cmake  . -DOPENSSL_STATIC_LINK=ON -DCMAKE_INSTALL_PREFIX=../macos/target/ 
                        make install
                   CMD

  #s.public_header_files = 'target/include/ykpiv/*.h'
  s.library = "ykpiv"
  s.vendored_libraries = 'target/lib/libykpiv.a' ,'target/lib/libykpiv.dylib' , 'target/lib/libykpiv.2.dylib', 'target/lib/libykpiv.2.5.1.dylib'
  s.resources = 'target/lib/libykpiv*.dylib'
  s.preserve_paths = 'target/lib/libykpiv*'
  s.platform = :osx, '13.01'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
