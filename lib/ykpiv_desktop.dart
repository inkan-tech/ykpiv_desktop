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

//Init
int init(Pointer<ykpiv_state> state) =>
    _bindings.ykpiv_init(Pointer.fromAddress(state.address), 1);
// TODO implement: ykpiv_list_readers

class YkDestop {
  YkDesktop() {
    // initialize an hopefully populate state structure
    int res = _bindings.ykpiv_init(Pointer.fromAddress(stateptr.address), 1);
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
      print("State after: ${realstate.cast<ykpiv_state>()}");
      print("pointer after: ${argUtf8.toDartString()}");
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
      reader = reader + String.fromCharCode(char);
    }
    print("Before list devices state reader is ${reader}");

    ////////////////////////////////////////////
    // Now list_readers as a return

    final Pointer<Char> resultPtr = ffi.calloc<Char>(2048);
    final sizePointer = ffi.calloc<Size>();

    int resList = _bindings.ykpiv_list_readers(
        stateptr, resultPtr.cast<Char>(), sizePointer);

    if (resList == ykpiv_rc.YKPIV_OK) {
      var length = sizePointer.value;
      String result = "";
      
      for (var i = 0; i < length; i++) {
        // Get the element at the current index
        final char = Pointer<Char>.fromAddress(resultPtr.address)[i];
        result = result + String.fromCharCode(char);
      }

      print("list result is: ${result}");
      print("list size is: ${length}");
      ffi.malloc.free(resultPtr);
    } else {
      ffi.malloc.free(resultPtr);
      // must do that way to free the buffer before exiting.
      throw Exception('Failed to list devices');
    }

    return result;
  }

  void dispose() {
    stateptr = nullptr;
  }

  final realstate = ffi.calloc<ykpiv_state>();
  late Pointer<ykpiv_state> stateptr = Pointer.fromAddress(realstate.address);
}
