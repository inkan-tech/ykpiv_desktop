// made by codeGPT with model GPT-4 and prompt "fais des tests unitaire en utilsant les ASN1seq fournient en commentaire. Vérifie que les champs normaux d'un x509 sont présent Signature etc.."

// seq1: "Seq[Seq[ASN1Object(tag=a0 valueByteLength=3) startpos=2 bytes=[0xa0, 0x3, 0x2, 0x1, 0x2] ASN1Integer(9223372036854775807) Seq[ObjectIdentifier(1.3.101.112) ] Seq[Set[Seq[ObjectIdentifier(2.5.4.3) UTF8String(test) ] ] Set[Seq[ObjectIdentifier(2.5.4.11) UTF8String(sign) ] ] Set[Seq[ObjectIdentifier(2.5.4.10) UTF8String(sealf.ie) ] ] ] Seq[UtcTime(2024-08-15 14:13:03.000Z) UtcTime(2025-08-15 14:13:03.000Z) ] Seq[Set[Seq[ObjectIdentifier(2.5.4.3) UTF8String(test) ] ] Set[Seq[ObjectIdentifier(2.5.4.11) UTF8String(sign) ] ] Set[Seq[ObjectIdentifier(2.5.4.10) UTF8String(sealf.ie) ] ] ] Seq[Seq[ObjectIdentifier(1.3.101.112) ] BitString([66, 172, 56, 176, 10, 48, 185, 64, 210, 52, 1, 182, 27, 142, 68, 57, 163, 152, 87, 229, 103, 223, 12, 106, 150, 127, 169, 33, 212, 165, 112, 58]) ] ASN1Object(tag=a3 valueByteLength=61) startpos=2 bytes=[0xa3, 0x3d, 0x30, 0x3b, 0x30, 0x1d, 0x6, 0x3, 0x55, 0x1d, 0xe, 0x4, 0x16, 0x4, 0x14, 0xa3, 0xff, 0xea, 0x64, 0x3, 0x78, 0x47, 0x9, 0xe7, 0xff, 0xf5, 0x55, 0x3e, 0x7b, 0x63, 0x1e, 0x73, 0x35, 0x4d, 0x41, 0x30, 0x9, 0x6, 0x3, 0x55, 0x1d, 0x23, 0x4, 0x2, 0x30, 0x0, 0x30, 0xf, 0x6, 0x3, 0x55, 0x1d, 0x13, 0x1, 0x1, 0xff, 0x4, 0x5, 0x30, 0x3, 0x1, 0x1, 0xff] ] Seq[ObjectIdentifier(1.3.101.112) ] BitString([176, 4, 184, 165, 23, 209, 192, 135, 91, 85, 92, 91, 83, 236, 223, 50, 207, 228, 9, 8, 18, 232, 111, 62, 199, 159, 43, 163, 161, 124, 118, 139, 253, 4, 34, 153, 28, 110, 171, 97, 163, 86, 121, 43, 252, 57, 91, 252, 42, 76, 90, 44, 71, 250, 189, 97, 25, 53, 110, 218, 90, 226, 99, 6]) ]
// seq1: [48, 130, 1, 86, 48, 130, 1, 8, 160, 3, 2, 1, 2, 2, 9, 0, 169, 37, 75, 83, 77, 189, 173, 228, 48, 5, 6, 3, 43, 101, 112, 48, 49, 49, 13, 48, 11, 6, 3, 85, 4, 3, 12, 4, 116, 101, 115, 116, 49, 13, 48, 11, 6, 3, 85, 4, 11, 12, 4, 115, 105, 103, 110, 49, 17, 48, 15, 6, 3, 85, 4, 10, 12, 8, 115, 101, 97, 108, 102, 46, 105, 101, 48, 30, 23, 13, 50, 52, 48, 56, 49, 53, 49, 52, 49, 51, 48, 51, 90, 23, 13, 50, 53, 48, 56, 49, 53, 49, 52, 49, 51, 48, 51, 90, 48, 49, 49, 13, 48, 11, 6, 3, 85, 4, 3, 12, 4, 116, 101, 115, 116, 49, 13, 48, 11, 6, 3, 85, 4, 11, 12, 4, 115, 105, 103, 110, 49, 17, 48, 15, 6, 3, 85, 4, 10, 12, 8, 115, 101, 97, 108, 102, 46, 105, 101, 48, 42, 48, 5, 6, 3, 43, 101, 112, 3, 33, 0, 66, 172, 56, 176, 10, 48, 185, 64, 210, 52, 1, 182, 27, 142, 68, 57, 163, 152, 87, 229, 103, 223, 12, 106, 150, 127, 169, 33, 212, 165, 112, 58, 163, 61, 48, 59, 48, 29, 6, 3, 85, 29, 14, 4, 22, 4, 20, 163, 255, 234, 100, 3, 120, 71, 9, 231, 255, 245, 85, 62, 123, 99, 30, 115, 53, 77, 65, 48, 9, 6, 3, 85, 29, 35, 4, 2, 48, 0, 48, 15, 6, 3, 85, 29, 19, 1, 1, 255, 4, 5, 48, 3, 1, 1, 255, 48, 5, 6, 3, 43, 101, 112, 3, 65, 0, 176, 4, 184, 165, 23, 209, 192, 135, 91, 85, 92, 91, 83, 236, 223, 50, 207, 228, 9, 8, 18, 232, 111, 62, 199, 159, 43, 163, 161, 124, 118, 139, 253, 4, 34, 153, 28, 110, 171, 97, 163, 86, 121, 43, 252, 57, 91, 252, 42, 76, 90, 44, 71, 250, 189, 97, 25, 53, 110, 218, 90, 226, 99, 6]

// Information to see the values in CLi:
// ./yubico-piv-tool -aread-cert -s 8b -o 8b.pem
// openssl x509 -in 8b.pem -text
// Will see all the values.

import 'dart:convert';

import 'package:test/test.dart';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'dart:developer' as dev;
import '../../lib/certificate_info.dart'; // Assurez-vous que ce fichier contient les classes et fonctions définies précédemment

void main() {
  group('MyCertificate Tests', () {
    test('ED25519Certificate from ASN1Sequence', () {
      // Séquence ASN1 brute pour un certificat Ed25519

      String rawSequence =
          "MIIBVjCCAQigAwIBAgIJAKklS1NNva3kMAUGAytlcDAxMQ0wCwYDVQQDDAR0ZXN0MQ0wCwYDVQQLDARzaWduMREwDwYDVQQKDAhzZWFsZi5pZTAeFw0yNDA4MTUxNDEzMDNaFw0yNTA4MTUxNDEzMDNaMDExDTALBgNVBAMMBHRlc3QxDTALBgNVBAsMBHNpZ24xETAPBgNVBAoMCHNlYWxmLmllMCowBQYDK2VwAyEAQqw4sAowuUDSNAG2G45EOaOYV+Vn3wxqln+pIdSlcDqjPTA7MB0GA1UdDgQWBBSj/+pkA3hHCef/9VU+e2MeczVNQTAJBgNVHSMEAjAAMA8GA1UdEwEB/wQFMAMBAf8wBQYDK2VwA0EAsAS4pRfRwIdbVVxbU+zfMs/kCQgS6G8+x58ro6F8dov9BCKZHG6rYaNWeSv8OVv8KkxaLEf6vWEZNW7aWuJjBg==";
// PEM 8a from cli (= result)
      String pem8a = """-----BEGIN CERTIFICATE-----
MIIBVjCCAQigAwIBAgIJAKklS1NNva3kMAUGAytlcDAxMQ0wCwYDVQQDDAR0ZXN0
MQ0wCwYDVQQLDARzaWduMREwDwYDVQQKDAhzZWFsZi5pZTAeFw0yNDA4MTUxNDEz
MDNaFw0yNTA4MTUxNDEzMDNaMDExDTALBgNVBAMMBHRlc3QxDTALBgNVBAsMBHNp
Z24xETAPBgNVBAoMCHNlYWxmLmllMCowBQYDK2VwAyEAQqw4sAowuUDSNAG2G45E
OaOYV+Vn3wxqln+pIdSlcDqjPTA7MB0GA1UdDgQWBBSj/+pkA3hHCef/9VU+e2Me
czVNQTAJBgNVHSMEAjAAMA8GA1UdEwEB/wQFMAMBAf8wBQYDK2VwA0EAsAS4pRfR
wIdbVVxbU+zfMs/kCQgS6G8+x58ro6F8dov9BCKZHG6rYaNWeSv8OVv8KkxaLEf6
vWEZNW7aWuJjBg==
-----END CERTIFICATE-----""";
      // Remove the PEM header and footer
      String derString = pem8a
          .replaceAll(
              RegExp(r'-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----'),
              '')
          .replaceAll(RegExp(r'\n'), '');

      // Decode the DER string
      Uint8List derBytes = base64.decode(derString);

      // Create an ASN1Sequence from the DER bytes
      ASN1Sequence asn1Sequence = ASN1Sequence.fromBytes(derBytes);
      dev.log("result asn1seq is: $asn1Sequence");
      // Parse the raw sequence string into an ASN1Sequence
      ASN1Sequence sequence = ASN1Sequence();
      try {
        sequence = ASN1Sequence.fromBytes(base64Decode(rawSequence));
      } catch (e) {
        throwsFormatException;
      }
      MyCertificate certificate = myCertificatefromASN1(sequence);

      expect(certificate.serialNumber, 9223372036854775807);
      expect(certificate.issuer, 'Ed25519');
      expect(
          certificate.publicKey,
          Uint8List.fromList([
            66,
            172,
            56,
            176,
            10,
            48,
            185,
            64,
            210,
            52,
            1,
            182,
            27,
            142,
            68,
            57,
            163,
            152,
            87,
            229,
            103,
            223,
            12,
            106,
            150,
            127,
            169,
            33,
            212,
            165,
            112,
            58
          ]));
      expect(certificate.notAfter, DateTime.parse('2024-08-15 14:13:03.000Z'));
      expect(certificate.notBefore, DateTime.parse('2025-08-15 14:13:03.000Z'));
      expect(certificate.subject, 'sealf.ie');
    });
  });
}
