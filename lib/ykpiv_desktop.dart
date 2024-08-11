import 'dart:ffi';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';

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
    return DynamicLibrary.open('libykpiv.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final YkpivDesktopBindings _bindings = YkpivDesktopBindings(_dylib);

class YkDestop {
  void init() {
    ykpiv_rc res =
        _bindings.ykpiv_init(Pointer.fromAddress(stateptr.address), 12);
    checkErrorCode(res);
    if (res != ykpiv_rc.YKPIV_OK) {
      throw Exception('Failed to initialize ykpiv');
    } else {
      print('Initialized ykpiv');
      int deviceModel = _bindings.ykpiv_util_devicemodel(stateptr);

      print(" util_devicemodel at init  $deviceModel");
    }
  }

  String connect() {
    init();
    String result = "X";
    if (FlutterEcdh.p256().isSupportedPlatform) {
      print("ECDH is supported");
    }
    var newkey = FlutterEcdh.p256();
    String arg = "Yubikey";
    final Pointer<ffi.Utf8> argUtf8 =
        arg.toNativeUtf8(); // Allocate memory for the string buffer

    print(argUtf8.toDartString());

    ykpiv_rc res = _bindings.ykpiv_connect(stateptr, argUtf8.cast<Char>());

    if (res == ykpiv_rc.YKPIV_OK) {
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

    ykpiv_rc resSerial = _bindings.ykpiv_get_serial(stateptr, serialPtr);

    print(" Get serial  ${serialPtr.value}");

    print(" State serial  ${stateptr.ref.serial}");

    logWithPIN("117334");

    ////////////////////////////////////////////

    Pointer<ykpiv_key> dataPtr = ffi.calloc<ykpiv_key>();

    int bufferOutSize = 128;
    Pointer<Size> sizePointer = ffi.malloc<Size>()..value = bufferOutSize;

    String stringToSign = "Hello";
    var buffer_in = stringToSign.toNativeUtf8().cast<UnsignedChar>();
    // Allocate memory for the unsigned char buffer

    Pointer<UnsignedChar> buffer_out =
        ffi.calloc<Uint8>(bufferOutSize) as Pointer<UnsignedChar>;

    ykpiv_rc resultSignData = _bindings.ykpiv_sign_data(stateptr, buffer_in,
        stringToSign.length, buffer_out, sizePointer, YKPIV_ALGO_ED25519, 0x9a);

    print("return code string is : ${ykcodeToError(resultSignData)}");

    if (resultSignData == ykpiv_rc.YKPIV_OK) {
      result = "";
      for (var i = 0; i < sizePointer.value; i++) {
        // Get the element at the current index
        var char = buffer_out[i];
        result = result + String.fromCharCode(char);
      }

      print(" result is: ${result}");
    } else {
      ffi.malloc.free(dataPtr);
      ffi.malloc.free(sizePointer);
      ffi.malloc.free(buffer_in);
      // must do that way to free the buffer before exiting.
      checkErrorCode(resultSignData);

      print('Failed to sign data num: $resultSignData');
    }

    print('');
    print('###    decipher  ####');
    ////// Try to decipher now
    logWithPIN("117334");

    Pointer<UnsignedChar> buffer_out2 =
        ffi.calloc<Uint8>(bufferOutSize) as Pointer<UnsignedChar>;
    Pointer<Size> sizePointer2 = ffi.malloc<Size>()..value = bufferOutSize;

    // Allocate memory for the unsigned char buffer
    ykpiv_rc resultDecipher = _bindings.ykpiv_decipher_data(stateptr,
        buffer_out, 512, buffer_out2, sizePointer2, YKPIV_ALGO_ED25519, 0x9a);

    checkErrorCode(resultDecipher);
    ffi.malloc.free(dataPtr);
    ffi.malloc.free(buffer_out);
    ffi.malloc.free(buffer_in);
    ffi.malloc.free(sizePointer);
    return reader;
  }

  void checkErrorCode(ykpiv_rc ykpiv_rc) {
    print(
        "Ykpiv fonction return code $ykpiv_rc meaning: ${ykcodeToError(ykpiv_rc)}");
  }

  String ykcodeToError(ykpiv_rc ykpiv_rc) {
    Pointer<Char> resultPtr = _bindings.ykpiv_strerror(ykpiv_rc);
    String result = "";
    for (var i = 0; i < 2048; i++) {
      // Get the element at the current index
      final char = resultPtr[i];
      if (char == 0) {
        break;
      }
      result = result + String.fromCharCode(char);
    }
    //ffi.malloc.free(resultPtr);
    return result;
  }

  void logWithPIN(String pin) {
    final Pointer<ffi.Utf8> pinUtf8 = pin.toNativeUtf8();
    stateptr.ref.pin = pinUtf8.cast<Char>();
    int statepin = stateptr.ref.pin.value;
    print("pin after: $statepin");
    ykpiv_rc resultVerify =
        _bindings.ykpiv_verify(stateptr, pinUtf8.cast(), numOfTriesPtr);
    checkErrorCode(resultVerify);
  }

  void dispose() {
    stateptr = nullptr;
  }

  Pointer<Int> numOfTriesPtr = ffi.calloc<Int>()..value = 3;
  late Pointer<ykpiv_state> stateptr = ffi.calloc<ykpiv_state>();
}
