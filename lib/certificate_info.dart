// made by codeGPT with model GPT-4 and prompt "fais des tests unitaire en utilsant les ASN1seq fournient en commentaire. Vérifie que les champs normaux d'un x509 sont présent Signature etc.."
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:x509/x509.dart';
import 'dart:developer' as dev;

import 'package:either_dart/either.dart';

class YkCertificate {
  int serialNumber;
  final String issuer;
  final DateTime notBefore;
  final DateTime notAfter;
  final String subject;
  final Uint8List publicKey;

  YkCertificate({
    required this.serialNumber,
    required this.issuer,
    required this.notBefore,
    required this.notAfter,
    required this.subject,
    required this.publicKey,
  });
}

Either<YkCertificate, X509Certificate> myCertificatefromASN1(
    ASN1Sequence sequence) {
  int serialNumber = 0;
  String issuer = '';
  DateTime notBefore = DateTime.now();
  DateTime notAfter = DateTime.now();
  String subject = '';
  Uint8List publicKey = Uint8List(0);
  String oid = '';

  Map<String, String> extractOidAndString(ASN1Set asn1Set) {
    Map<String, String> oidAndString = {};

    // Iterate over the elements of the SET
    for (ASN1Object element in asn1Set.elements) {
      // Check if the element is a SEQUENCE
      if (element is ASN1Sequence) {
        // Get the elements of the SEQUENCE
        List<ASN1Object> seqElements = element.elements;

        // Iterate over the elements of the SEQUENCE
        for (ASN1Object seqElement in seqElements) {
          // Check if the element is an OBJECT IDENTIFIER
          if (seqElement is ASN1ObjectIdentifier) {
            // Get the OID
            String? oid = (seqElement as ASN1ObjectIdentifier).identifier;

            // Add the OID to the map
            oidAndString['oid'] = oid!;
          } else if (seqElement is ASN1UTF8String) {
            // Get the string
            String string = (seqElement as ASN1UTF8String).utf8StringValue;

            // Add the string to the map
            oidAndString['string'] = string;
          }
        }
      }
    }

    return oidAndString;
  }

  if (sequence.elements.length == 3) {
    ASN1Sequence tbsCertificate = sequence.elements[0] as ASN1Sequence;
    ASN1Sequence signatureAlgorithm = sequence.elements[1] as ASN1Sequence;
    ASN1BitString signatureValue = sequence.elements[2] as ASN1BitString;
    String? algoForSignature =
        (signatureAlgorithm.elements[0] as ASN1ObjectIdentifier).identifier;
    dev.log("signatureAlgo : ${signatureAlgorithm.toString()}");
    dev.log("signatureValue : ${signatureValue.toString()}");
    // Extract information from tbsCertificate
    // Structure is a seq
    serialNumber = (tbsCertificate.elements[1] as ASN1Integer).intValue;
    // NotBefore Notafter is [4]
    ASN1Sequence timeSeq = (tbsCertificate.elements[4] as ASN1Sequence);
    for (var subElement in timeSeq.elements) {
      if (subElement is ASN1UtcTime) {
        if (subElement.dateTimeValue.isAfter(DateTime.now())) {
          notBefore = subElement.dateTimeValue;
        } else {
          notAfter = subElement.dateTimeValue;
        }
      }
    }

    // pubKey is on [6]
    // if self-sign there is [[oid], bytes] . If it is signed [ [oidSigned, oidpubkey], bytes]
    ASN1Sequence pubKeySeq = (tbsCertificate.elements[6] as ASN1Sequence);

    ASN1Object oidSeq = pubKeySeq.elements[0];
    if (oidSeq is ASN1Sequence) {
      oid = (oidSeq.elements.last as ASN1ObjectIdentifier).identifier!; //
    } else {
      oid = (oidSeq as ASN1ObjectIdentifier).identifier!; //
    }
    publicKey = Uint8List.fromList(
        (pubKeySeq.elements[1] as ASN1BitString).stringValue);

    String subjectString = "";

    // PubKey description is [5]
    for (ASN1Object stringElement
        in (tbsCertificate.elements[5] as ASN1Sequence).elements) {
      Map<String, String> Oid_Value =
          extractOidAndString(stringElement as ASN1Set);
      // Check if the element is an OBJECT IDENTIFIER

      // Get the OID
      String? oid = Oid_Value["oid"];
      String oidString = Oid_Value["string"]!;
      subjectString += subjectString.isNotEmpty ? ', ' : '';
      // Check if the OID is a known OID
      switch (oid) {
        case '2.5.4.6':
          // Country
          subjectString += 'C=${oidString}';
          break;
        case '2.5.4.8':
          // State
          subjectString += 'ST=${oidString}';
          break;
        case '2.5.4.7':
          // Locality
          subjectString += 'L=${oidString}';
          break;
        case '2.5.4.10':
          // Organization
          subjectString += 'O=$oidString';
          break;
        case '2.5.4.11':
          // Organization Unit
          subjectString += 'OU=${oidString}';
          break;
        case '2.5.4.3':
          // Common Name
          subjectString += 'CN=${oidString}';
          break;
        case '1.2.840.113549.1.9.1':
          // Email
          subjectString += 'EMAIL=${oidString}';
          break;
        default:
          // Unknown OID
          subjectString += 'UNKNOWN=${oidString}';
          break;
      }
    }
    subject = subjectString;

    if (oid == "1.3.101.110") {
      issuer = "X25519";
    } else if (oid == "1.3.101.112") {
      issuer = "Ed25519";
    }

    dev.log("The pubkey is ${publicKey.toString()}");

    if (oid == '1.3.101.110' || oid == '1.3.101.112') {
      return Left(YkCertificate(
        serialNumber: serialNumber,
        issuer: issuer,
        notBefore: notBefore,
        notAfter: notAfter,
        subject: subject,
        publicKey: publicKey,
      ));
    }
    return Right(X509Certificate.fromAsn1(sequence));
  } // Handle the case where sequence.elements.length is not 3 or other cases
  throw Exception('Invalid ASN1Sequence');
}
