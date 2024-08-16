import 'dart:ffi';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:ffi/ffi.dart' as ffi;
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

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

class YkDesktop {
  late Pointer<ykpiv_state> stateptr = ffi.calloc<ykpiv_state>();

  void init() {
    ykpiv_rc res = _bindings.ykpiv_init(Pointer.fromAddress(stateptr.address),
        12); // the int second param is the verbosity
    checkErrorCode(res);
    if (res != ykpiv_rc.YKPIV_OK) {
      throw Exception('Failed to initialize ykpiv');
    } else {
      if (kDebugMode) {
        dev.log('Initialized ykpiv');
      }
      int deviceModel = _bindings.ykpiv_util_devicemodel(stateptr);

      dev.log(" util_devicemodel at init  $deviceModel");
    }
  }

  Uint8List ecdh(Uint8List publicKey, int slot) {
    // Allocate memory for the public key
    Pointer<Uint8> publicKeyPointer = calloc<Uint8>(publicKey.length);

    publicKeyPointer.asTypedList(publicKey.length).setAll(0, publicKey);

    // Allocate memory for the shared secret
    final sharedSecretPointer = calloc<UnsignedChar>(32);
    final sharedSecretLengthPointer = calloc<Size>();
    sharedSecretLengthPointer.value = 32;

    // Perform the ECDH key exchange
    ykpiv_rc result = _bindings.ykpiv_decipher_data(
        stateptr,
        publicKeyPointer as Pointer<UnsignedChar>,
        publicKey.length,
        sharedSecretPointer,
        sharedSecretLengthPointer,
        YKPIV_ALGO_X25519,
        slot);

    // Check if the result is OK
    if (result != ykpiv_rc.YKPIV_OK) {
      // Free allocated memory
      calloc.free(publicKeyPointer);
      calloc.free(sharedSecretPointer);
      calloc.free(sharedSecretLengthPointer);
      throw Exception('ECDH key exchange failed with error code: $result');
    }
    dev.log("computed ecdh share is $sharedSecretPointer");
    // Copy the shared secret to a Dart Uint8List

    Uint8List share = Uint8List(sharedSecretLengthPointer.value);
    for (var i = 0; i < sharedSecretLengthPointer.value; i++) {
      // Get the element at the current index
      share[i] = (sharedSecretPointer[i]);
    }

    // Free allocated memory
    calloc.free(publicKeyPointer);
    calloc.free(sharedSecretPointer);
    calloc.free(sharedSecretLengthPointer);

    // Return the result of the operation
    return share;
  }

  String connect() {
    init();
    String arg = "Yubikey";
    final Pointer<ffi.Utf8> argUtf8 =
        arg.toNativeUtf8(); // Allocate memory for the string buffer

    dev.log("The argument to connect is :${argUtf8.toDartString()}");

    ykpiv_rc res = _bindings.ykpiv_connect(stateptr, argUtf8.cast<Char>());
    int deviceModel = _bindings.ykpiv_util_devicemodel(stateptr);
    dev.log(" util_devicemodel after connect  $deviceModel");
    if (res != ykpiv_rc.YKPIV_OK) {
      throw Exception('Failed to Connect');
    }
    ffi.malloc.free(argUtf8);
    String reader = arrayCharToString(stateptr.ref.reader, 2048);

    dev.log("Before list devices state reader is $reader");
    Pointer<Uint32> serialPtr = ffi.malloc<Uint32>();

    ykpiv_rc resSerial = _bindings.ykpiv_get_serial(stateptr, serialPtr);

    dev.log(" Result of get serial  ${resSerial.value}");

    dev.log("serial from State :  ${stateptr.ref.serial}");

    dev.log('Logging stateptr parameters:');
    dev.log('card: ${stateptr.ref.card}');
    dev.log('context: ${stateptr.ref.context}');
    dev.log('verbose: ${stateptr.ref.card}');
    dev.log('model: ${stateptr.ref.model}');
    dev.log(
        'pin: ${stateptr.ref.pin == nullptr ? 'null' : stateptr.ref.pin.cast<Utf8>().toDartString()}');

    return reader;
  }

  ////////////////////////////////////////////
  misc() {
    String result;

    Pointer<ykpiv_key> dataPtr = ffi.calloc<ykpiv_key>();

    int bufferOutSize = 128;
    Pointer<Size> sizePointer = ffi.malloc<Size>()..value = bufferOutSize;

    String stringToSign = "Hello";
    var bufferIn = stringToSign.toNativeUtf8().cast<UnsignedChar>();
    // Allocate memory for the unsigned char buffer

    Pointer<UnsignedChar> bufferOut =
        ffi.calloc<Uint8>(bufferOutSize) as Pointer<UnsignedChar>;

    ykpiv_rc resultSignData = _bindings.ykpiv_sign_data(stateptr, bufferIn,
        stringToSign.length, bufferOut, sizePointer, YKPIV_ALGO_ED25519, 0x9a);

    dev.log("return code string is : ${ykcodeToError(resultSignData)}");

    if (resultSignData == ykpiv_rc.YKPIV_OK) {
      result = "";
      for (var i = 0; i < sizePointer.value; i++) {
        // Get the element at the current index
        var char = bufferOut[i];
        result = result + String.fromCharCode(char);
      }

      dev.log(" result is: $result");
    } else {
      ffi.malloc.free(dataPtr);
      ffi.malloc.free(sizePointer);
      ffi.malloc.free(bufferIn);
      // must do that way to free the buffer before exiting.
      checkErrorCode(resultSignData);

      dev.log('Failed to sign data num: $resultSignData');
    }

    dev.log('');
    dev.log('###    decipher  ####');
    ////// Try to decipher now
    logWithPIN("117334");

    Pointer<UnsignedChar> bufferOut2 =
        ffi.calloc<Uint8>(bufferOutSize) as Pointer<UnsignedChar>;
    Pointer<Size> sizePointer2 = ffi.malloc<Size>()..value = bufferOutSize;

    // Allocate memory for the unsigned char buffer
    ykpiv_rc resultDecipher = _bindings.ykpiv_decipher_data(stateptr, bufferOut,
        512, bufferOut2, sizePointer2, YKPIV_ALGO_ED25519, 0x9a);

    checkErrorCode(resultDecipher);
    ffi.malloc.free(dataPtr);
    ffi.malloc.free(bufferOut);
    ffi.malloc.free(bufferIn);
    ffi.malloc.free(sizePointer);
    return resultDecipher;
  }

  void checkErrorCode(ykpiv_rc ykpivRc) {
    dev.log(
        "Ykpiv fonction return code $ykpivRc meaning: ${ykcodeToError(ykpivRc)}");
  }

  String ykcodeToError(ykpiv_rc ykpivRc) {
    Pointer<Char> resultPtr = _bindings.ykpiv_strerror(ykpivRc);
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
    dev.log("pin after: $statepin");
    ykpiv_rc resultVerify =
        _bindings.ykpiv_verify(stateptr, pinUtf8.cast(), numOfTriesPtr);
    checkErrorCode(resultVerify);
  }

  String arrayCharToString(Array<Char> arrayChar, int maxLength) {
    String result = "";
    for (var i = 0; i < maxLength; i++) {
      final char = arrayChar[i];
      if (char == 0) {
        break;
      }
      result += String.fromCharCode(char);
    }
    return result;
  }

  void dispose() {
    ffi.malloc.free(stateptr);
  }

  Pointer<Int> numOfTriesPtr = ffi.calloc<Int>()..value = 3;
}
