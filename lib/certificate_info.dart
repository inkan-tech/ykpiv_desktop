// made by codeGPT with model GPT-4 and prompt "fais des tests unitaire en utilsant les ASN1seq fournient en commentaire. Vérifie que les champs normaux d'un x509 sont présent Signature etc.."
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:cryptography/cryptography.dart';
import 'dart:developer' as dev;

abstract class MyCertificate {
  int serialNumber;
  final String issuer;
  final DateTime notBefore;
  final DateTime notAfter;
  final String subject;
  final Uint8List publicKey;

  MyCertificate({
    required this.serialNumber,
    required this.issuer,
    required this.notBefore,
    required this.notAfter,
    required this.subject,
    required this.publicKey,
  });

  SimplePublicKey getPublicKey();
}

class X25519Certificate extends MyCertificate {
  X25519Certificate({
    required super.serialNumber,
    required super.issuer,
    required super.notBefore,
    required super.notAfter,
    required super.subject,
    required super.publicKey,
  });

  factory X25519Certificate.fromAsn1Sequence(ASN1Sequence sequence) {
    return myCertificatefromASN1(sequence) as X25519Certificate;
  }

  @override
  SimplePublicKey getPublicKey() {
    return SimplePublicKey(publicKey, type: KeyPairType.x25519);
  }
}

class Ed25519Certificate extends MyCertificate {
  Ed25519Certificate({
    required super.serialNumber,
    required super.issuer,
    required super.notBefore,
    required super.notAfter,
    required super.subject,
    required super.publicKey,
  });

  factory Ed25519Certificate.fromAsn1Sequence(ASN1Sequence sequence) {
    return myCertificatefromASN1(sequence) as Ed25519Certificate;
  }

  @override
  SimplePublicKey getPublicKey() {
    return SimplePublicKey(publicKey, type: KeyPairType.ed25519);
  }
}

MyCertificate myCertificatefromASN1(ASN1Sequence sequence) {
  int serialNumber = 0;
  String issuer = '';
  DateTime notBefore = DateTime.now();
  DateTime notAfter = DateTime.now();
  String subject = '';
  Uint8List publicKey = Uint8List(0);
  String oid = '';

  if (sequence.elements.length == 3) {
    ASN1Sequence tbsCertificate = sequence.elements[0] as ASN1Sequence;
    ASN1Sequence signatureAlgorithm = sequence.elements[1] as ASN1Sequence;
    ASN1BitString signatureValue = sequence.elements[2] as ASN1BitString;

    // Extract information from tbsCertificate
    for (var element in tbsCertificate.elements) {
      Type elementType = element.runtimeType;
      dev.log("element types $elementType");
      if (element is ASN1Integer) {
        serialNumber = element.intValue;
      } else if (element is ASN1Sequence) {
        for (var subElement in element.elements) {
          if (subElement is ASN1ObjectIdentifier) {
            oid = subElement.identifier!;
            dev.log("Found OID: $oid");
            if (oid == "1.3.101.110") {
              issuer = "X25519";
            } else if (oid == "1.3.101.112") {
              issuer = "Ed25519";
            }
          } else if (subElement is ASN1Set) {
            for (var setElement in subElement.elements) {
              if (setElement is ASN1Sequence) {
                for (var seqElement in setElement.elements) {
                  if (seqElement is ASN1UTF8String) {
                    subject = seqElement.utf8StringValue;
                  }
                }
              }
            }
          } else if (subElement is ASN1UtcTime) {
            if (subElement.dateTimeValue.isAfter(DateTime.now())) {
              notBefore = subElement.dateTimeValue;
            } else {
              notAfter = subElement.dateTimeValue;
            }
          } else if (subElement is ASN1BitString) {
            publicKey = Uint8List.fromList(subElement.stringValue);
          }
        }
      }
    }

    SimplePublicKey(publicKey,
        type: oid == "1.3.101.110" ? KeyPairType.x25519 : KeyPairType.ed25519);
    dev.log("The pubkey is ${publicKey.toString()}");

    if (oid == '1.3.101.110') {
      return X25519Certificate(
        serialNumber: serialNumber,
        issuer: issuer,
        notBefore: notBefore,
        notAfter: notAfter,
        subject: subject,
        publicKey: publicKey,
      );
    } else if (oid == '1.3.101.112') {
      return Ed25519Certificate(
        serialNumber: serialNumber,
        issuer: issuer,
        notBefore: notBefore,
        notAfter: notAfter,
        subject: subject,
        publicKey: publicKey,
      );
    } else {
      throw UnsupportedError('Unsupported type with OID: $oid');
    }
  } else {
    throw const FormatException('Invalid ASN1 sequence format');
  }
}
