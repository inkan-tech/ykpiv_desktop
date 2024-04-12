import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart' as ffi;

import 'ykpiv_desktop_bindings_generated.dart';

const String _libName = 'libykpiv.2';

/// The dynamic library in which the symbols for [YkpivDesktopBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.dylib');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final YkpivDesktopBindings _bindings = YkpivDesktopBindings(_dylib);

class YkDestop {
  YkDesktop() {
    // initialize an hopefully populate state structure
    int res = _bindings.ykpiv_init_with_allocator(
        Pointer.fromAddress(stateptr.address), 2, myallocator);
    if (res != ykpiv_rc.YKPIV_OK) {
      throw Exception('Failed to initialize ykpiv');
    } else {
      print('Initialized ykpiv');
    }
  }

  void init() {
    int res = _bindings.ykpiv_init(Pointer.fromAddress(stateptr.address), 1);
    if (res != ykpiv_rc.YKPIV_OK) {
      throw Exception('Failed to initialize ykpiv');
    } else {
      print('Initialized ykpiv');
      int deviceModel = _bindings.ykpiv_util_devicemodel(stateptr);

      print(" util_devicemodel at init  ${deviceModel}");
    }
  }

  String connect() {
    init();
    String result = "X";
    String arg = "Yubikey";
    final Pointer<ffi.Utf8> argUtf8 =
        arg.toNativeUtf8(); // Allocate memory for the string buffer

    print(argUtf8.toDartString());

    int res = _bindings.ykpiv_connect(stateptr, argUtf8.cast<Char>());
    if (res == ykpiv_rc.YKPIV_OK) {
      print("Protocol after: ${stateptr.ref.protocol}");

      ffi.malloc.free(argUtf8);
    } else {
      ffi.malloc.free(argUtf8);
      // must do that way to free the buffer before exiting.
      throw Exception('Failed to list devices');
    }
    int length = 2048;
    String reader = "";
    for (var i = 0; i < length; i++) {
      // Get the element at the current index
      final char = stateptr.ref.reader[i];
      if (char == 0) {
        break;
      }
      reader = reader + String.fromCharCode(char);
    }
    print("Before list devices state reader is ${reader}");
    int deviceModel = _bindings.ykpiv_util_devicemodel(stateptr);

    print(" util_devicemodel  ${deviceModel}");
    ////////////////////////////////////////////
    // Now list_keys as a return BUT HAVE MEMORY ALLOCATION ISSUES
    Pointer<Size> sizePointer = ffi.calloc<Size>();
    Pointer<ykpiv_key> keysdata = ffi.malloc<ykpiv_key>(30);
    Pointer<Pointer<ykpiv_key>> keysdataPtr =
        Pointer.fromAddress(keysdata.address);
    Pointer<Uint8> numOfKeysPtr = ffi.calloc<Uint8>();

    int resListKeys = _bindings.ykpiv_util_list_keys(
        stateptr, numOfKeysPtr, keysdataPtr, sizePointer);

    if (resListKeys == ykpiv_rc.YKPIV_OK) {
      print("Num of keys is ${numOfKeysPtr.value}");
      var length = sizePointer.value;
      print("lentgh is $length");

      for (var i = 0; i < length; i++) {
        // Get the element at the current index
        var char = keysdata[i];
        result = result + " || " + char.cert.toString();
      }

      print("list result is: ${result}");
      print("list size is: ${length}");
      ffi.malloc.free(sizePointer);
    } else {
      ffi.malloc.free(sizePointer);
      // must do that way to free the buffer before exiting.
      throw Exception('Failed to list devices with result: $resListKeys');
    }

    return reader;
  }

  void dispose() {
    stateptr = nullptr;
  }

  late Pointer<ykpiv_state> stateptr = ffi.malloc<ykpiv_state>();
  late Pointer<ykpiv_allocator> myallocator = ffi.malloc<ykpiv_allocator>();
}
