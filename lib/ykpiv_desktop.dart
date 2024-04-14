import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

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
  void init() {
    int res = _bindings.ykpiv_init(Pointer.fromAddress(stateptr.address), 2);
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
      throw Exception('Failed to Connect');
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
    Pointer<Uint32> serialPtr = ffi.malloc<Uint32>();

    int resSerial = _bindings.ykpiv_get_serial(stateptr, serialPtr);

    print(" Get serial  ${serialPtr.value}");

    print(" State serial  ${stateptr.ref.serial}");

    ////////////////////////////////////////////
    // Now list_keys as a return BUT HAVE MEMORY ALLOCATION ISSUES

    int reqlength = 24;

    Array<Uint8> data = const Array<Uint8>.multi([1]);

    Pointer<ykpiv_key> dataPtr = ffi.malloc<ykpiv_key>();
    dataPtr.ref.cert = data;
    dataPtr.ref.cert_len = reqlength;
    dataPtr.ref.slot = YKPIV_KEY_AUTHENTICATION;

    Pointer<Size> sizePointer = ffi.calloc<Size>();
    sizePointer.value = reqlength;

    Pointer<Int> numOfTriesPtr = ffi.calloc<Int>();
    numOfTriesPtr.value = 3;
    String pin = "117334";
    final Pointer<ffi.Utf8> pinUtf8 = pin.toNativeUtf8();

    int resFetch09c =
        _bindings.ykpiv_verify(stateptr, pinUtf8.cast<Char>(), numOfTriesPtr);

    if (resFetch09c == ykpiv_rc.YKPIV_OK) {
      for (var i = 0; i < length; i++) {
        // Get the element at the current index
        var char = dataPtr[i];
        result = result + char.toString();
      }

      print("NumofTries result is: ${numOfTriesPtr.value}");
      print("list size is: ${length}");
      ffi.malloc.free(sizePointer);
      ffi.malloc.free(dataPtr);
    } else {
      ffi.malloc.free(sizePointer);
      ffi.malloc.free(dataPtr);
      // must do that way to free the buffer before exiting.
      throw Exception('Failed to list devices with result: $resFetch09c');
    }

    return reader;
  }

  void dispose() {
    stateptr = nullptr;
  }

  late Pointer<ykpiv_state> stateptr = ffi.calloc<ykpiv_state>();
  late Pointer<ykpiv_allocator> myallocator = ffi.calloc<ykpiv_allocator>();
}
