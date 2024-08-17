import 'dart:ffi';

import 'dart:io';
import 'dart:developer' as dev;

import 'package:asn1lib/asn1lib.dart';
import 'package:cryptography/cryptography.dart';
import 'package:ffi/ffi.dart' as ffi;

import 'package:flutter/foundation.dart';

import 'package:x509/x509.dart';

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
  // Getter function for algorithm numbers
  static int getAlgoNumber(String algoName) {
    switch (algoName.toUpperCase()) {
      case '3DES':
        return YKPIV_ALGO_3DES;
      case 'AES128':
        return YKPIV_ALGO_AES128;
      case 'AES192':
        return YKPIV_ALGO_AES192;
      case 'AES256':
        return YKPIV_ALGO_AES256;
      case 'RSA1024':
        return YKPIV_ALGO_RSA1024;
      case 'RSA2048':
        return YKPIV_ALGO_RSA2048;
      case 'RSA3072':
        return YKPIV_ALGO_RSA3072;
      case 'RSA4096':
        return YKPIV_ALGO_RSA4096;
      case 'ECCP256':
        return YKPIV_ALGO_ECCP256;
      case 'ECCP384':
        return YKPIV_ALGO_ECCP384;
      case 'ED25519':
        return YKPIV_ALGO_ED25519;
      case 'X25519':
        return YKPIV_ALGO_X25519;
      default:
        throw ArgumentError('Unknown algorithm: $algoName');
    }
  }

  late Pointer<ykpiv_state> statePtr = ffi.calloc<ykpiv_state>();
  late Pointer<ykpiv_allocator> allocator = ffi.calloc<ykpiv_allocator>();

// Custom allocator functions

  static Pointer<Void> alloc(Pointer<Void> allocData, int size) {
    return ffi.calloc<Uint8>(size).cast();
  }

  static Pointer<Void> realloc(
      Pointer<Void> allocData, Pointer<Void> ptr, int size) {
    final newPtr = ffi.calloc<Uint8>(size);
    final oldPtr = ptr.cast<Uint8>();
    for (var i = 0; i < size; i++) {
      newPtr[i] = oldPtr[i];
    }
    ffi.calloc.free(ptr);
    return newPtr.cast();
  }

  static void free(Pointer<Void> allocData, Pointer<Void> ptr) {
    ffi.calloc.free(ptr);
  }

  void initYubikeyPIV() {
    allocator.ref.pfn_alloc =
        Pointer.fromFunction<ykpiv_pfn_allocFunction>(alloc);
    allocator.ref.pfn_realloc =
        Pointer.fromFunction<ykpiv_pfn_reallocFunction>(realloc);
    allocator.ref.pfn_free = Pointer.fromFunction<ykpiv_pfn_freeFunction>(free);
    allocator.ref.alloc_data = nullptr;

    ykpiv_rc res = _bindings.ykpiv_init_with_allocator(
        Pointer.fromAddress(statePtr.address), 255, allocator);

    checkErrorCode(res);
    if (res != ykpiv_rc.YKPIV_OK) {
      throw Exception(
          'Failed to initialize YubiKey PIV: ${ykCodeToError(res)}');
    } else {
      if (kDebugMode) {
        dev.log('Initialized ykpiv with allocators');
      }
      int deviceModel = _bindings.ykpiv_util_devicemodel(statePtr);

      dev.log(" util_devicemodel at init  $deviceModel");
    }
  }

  Uint8List ecdh(Uint8List publicKey, int slot) {
    // Allocate memory for the public key
    Pointer<Uint8> publicKeyPointer = ffi.calloc<Uint8>(publicKey.length);

    publicKeyPointer.asTypedList(publicKey.length).setAll(0, publicKey);

    // Allocate memory for the shared secret
    final sharedSecretPointer = ffi.calloc<UnsignedChar>(32);
    final sharedSecretLengthPointer = ffi.calloc<Size>();
    sharedSecretLengthPointer.value = 32;

    // Perform the ECDH key exchange
    ykpiv_rc result = _bindings.ykpiv_decipher_data(
        statePtr,
        publicKeyPointer as Pointer<UnsignedChar>,
        publicKey.length,
        sharedSecretPointer,
        sharedSecretLengthPointer,
        YKPIV_ALGO_X25519,
        slot);

    // Check if the result is OK
    if (result != ykpiv_rc.YKPIV_OK) {
      // Free allocated memory
      ffi.calloc.free(publicKeyPointer);
      ffi.calloc.free(sharedSecretPointer);
      ffi.calloc.free(sharedSecretLengthPointer);
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
    ffi.calloc.free(publicKeyPointer);
    ffi.calloc.free(sharedSecretPointer);
    ffi.calloc.free(sharedSecretLengthPointer);

    // Return the result of the operation
    return share;
  }

  Uint8List sign(Uint8List dataToSign, int slot, int algorithm) {
    // Allouer de la mémoire pour les données à signer
    Pointer<Uint8> dataToSignPointer = ffi.calloc<Uint8>(dataToSign.length);
    dataToSignPointer.asTypedList(dataToSign.length).setAll(0, dataToSign);

    // Allouer de la mémoire pour la signature
    final signaturePointer = ffi.calloc<UnsignedChar>(2048);
    final signatureLengthPointer = ffi.calloc<Size>();
    signatureLengthPointer.value = 2048;

    // Effectuer la signature
    ykpiv_rc result = _bindings.ykpiv_sign_data(
        statePtr,
        dataToSignPointer as Pointer<UnsignedChar>,
        dataToSign.length,
        signaturePointer,
        signatureLengthPointer,
        algorithm,
        slot);

    // Vérifier si le résultat est OK
    if (result != ykpiv_rc.YKPIV_OK) {
      // Libérer la mémoire allouée
      ffi.calloc.free(dataToSignPointer);
      ffi.calloc.free(signaturePointer);
      ffi.calloc.free(signatureLengthPointer);
      throw Exception('La signature a échoué avec le code d\'erreur : $result');
    }

    dev.log("Signature calculée : $signaturePointer");

    // Copier la signature dans un Uint8List Dart
    Uint8List signature = Uint8List(signatureLengthPointer.value);
    for (var i = 0; i < signatureLengthPointer.value; i++) {
      signature[i] = signaturePointer[i];
    }

    // Libérer la mémoire allouée
    ffi.calloc.free(dataToSignPointer);
    ffi.calloc.free(signaturePointer);
    ffi.calloc.free(signatureLengthPointer);

    // Retourner le résultat de l'opération
    return signature;
  }

  Map<String, dynamic> readcert(int slot) {
    // Step 1: Get the object ID for the given slot
    int objectId = _bindings.ykpiv_util_slot_object(slot);
    if (objectId == -1) {
      throw Exception('Invalid slot entered');
    }
    // Step 2: Allocate memory for the certificate data
    final dataPtr = ffi.calloc<UnsignedChar>(CB_OBJ_MAX);
    final lenPtr = ffi.calloc<UnsignedLong>();
    lenPtr.value = CB_OBJ_MAX;
    // Step 4: Use ykpiv_util_get_certdata to decompress if necessary
    final certDataPtr = ffi.calloc<Uint8>(CB_OBJ_MAX);
    final certDataLenPtr = ffi.calloc<Size>();
    certDataLenPtr.value = CB_OBJ_MAX;
    try {
      // Step 3: Fetch the object (certificate) data
      ykpiv_rc result = _bindings.ykpiv_fetch_object(
        statePtr,
        objectId,
        dataPtr,
        lenPtr,
      );
      dev.log("Read certificate buffer length: ${lenPtr.value}");
      if (result != ykpiv_rc.YKPIV_OK) {
        throw Exception(
            'Failed to fetch certificate: ${ykCodeToError(result)}');
      }

      result = _bindings.ykpiv_util_get_certdata(
        dataPtr as Pointer<Uint8>,
        lenPtr.value,
        certDataPtr,
        certDataLenPtr,
      );

      if (result != ykpiv_rc.YKPIV_OK) {
        throw Exception(
            'Failed to get certificate data: ${ykCodeToError(result)}');
      }

      // Step 4: Convert the raw data to a Uint8List

      // Copier la data dans un Uint8List Dart
      Uint8List certRead = Uint8List(certDataLenPtr.value);
      for (var i = 0; i < certDataLenPtr.value; i++) {
        certRead[i] = certDataPtr[i];
      }

      // Parse the ASN.1 data
      ASN1Sequence asn1Seq = ASN1Sequence.fromBytes(certRead);
      dev.log("asn1Seq to String : ${asn1Seq.toString()}");
      // Manually parse the certificate structure as X509 does not work for (ed|x)25519
      Map<String, dynamic> certInfo = {};
      if (asn1Seq.elements.length == 3) {
        ASN1Sequence tbsCertificate = asn1Seq.elements[0] as ASN1Sequence;
        ASN1Sequence signatureAlgorithm = asn1Seq.elements[1] as ASN1Sequence;
        ASN1BitString signatureValue = asn1Seq.elements[2] as ASN1BitString;

        // Extract information from tbsCertificate
        for (var element in signatureAlgorithm.elements) {
          if (element is ASN1Sequence) {
            for (var subElement in element.elements) {
              if (subElement is ASN1ObjectIdentifier) {
                dev.log("Found OID: ${subElement.identifier}");
                if (subElement.identifier == "1.3.101.112") {
                  certInfo['algorithm'] = "Ed25519";
                }
              }
            }
          }
        }

        SimplePublicKey pubkey = SimplePublicKey(signatureValue.encodedBytes,
            type: KeyPairType.ed25519);
        dev.log("The pubkey is ${pubkey.toString()}");
        certInfo['signatureAlgorithm'] =
            signatureAlgorithm.elements.first.toString();
        certInfo['signatureValue'] = signatureValue.stringValue;
      }

      return certInfo;
    } finally {
      // Free allocated memory
      ffi.calloc.free(dataPtr);
      ffi.calloc.free(lenPtr);
      ffi.calloc.free(certDataPtr);
      ffi.calloc.free(certDataLenPtr);
    }
  }

  String connect() {
    initYubikeyPIV();
    String arg = "Yubikey";
    final Pointer<ffi.Utf8> argUtf8 =
        arg.toNativeUtf8(); // Allocate memory for the string buffer

    dev.log("The argument to connect is :${argUtf8.toDartString()}");

    ykpiv_rc res = _bindings.ykpiv_connect(statePtr, argUtf8.cast<Char>());
    int deviceModel = _bindings.ykpiv_util_devicemodel(statePtr);
    dev.log(" util_devicemodel after connect  $deviceModel");
    if (res != ykpiv_rc.YKPIV_OK) {
      throw Exception('Failed to Connect');
    }
    ffi.malloc.free(argUtf8);
    String reader = arrayCharToString(statePtr.ref.reader, 2048);

    dev.log("Before list devices state reader is $reader");
    Pointer<Uint32> serialPtr = ffi.malloc<Uint32>();

    ykpiv_rc resSerial = _bindings.ykpiv_get_serial(statePtr, serialPtr);

    dev.log(" Result of get serial  ${resSerial.value}");

    dev.log("serial from State :  ${statePtr.ref.serial}");

    dev.log('Logging stateptr parameters:');
    dev.log('card: ${statePtr.ref.card}');
    dev.log('context: ${statePtr.ref.context}');
    dev.log('verbose: ${statePtr.ref.card}');
    dev.log('model: ${statePtr.ref.model}');
    dev.log(
        'pin: ${statePtr.ref.pin == nullptr ? 'null' : statePtr.ref.pin.toString()}');

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

    ykpiv_rc resultSignData = _bindings.ykpiv_sign_data(statePtr, bufferIn,
        stringToSign.length, bufferOut, sizePointer, YKPIV_ALGO_ED25519, 0x9a);

    dev.log("return code string is : ${ykCodeToError(resultSignData)}");

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
    ykpiv_rc resultDecipher = _bindings.ykpiv_decipher_data(statePtr, bufferOut,
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
        "Ykpiv fonction return code $ykpivRc meaning: ${ykCodeToError(ykpivRc)}");
  }

  String ykCodeToError(ykpiv_rc ykpivRc) {
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
    statePtr.ref.pin = pinUtf8.cast<Char>();
    int statepin = statePtr.ref.pin.value;
    dev.log("pin after: $statepin");
    ykpiv_rc resultVerify =
        _bindings.ykpiv_verify(statePtr, pinUtf8.cast(), numOfTriesPtr);
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
    ffi.malloc.free(statePtr);
  }

  Pointer<Int> numOfTriesPtr = ffi.calloc<Int>()..value = 3;
}
