// made by codeGPT with model GPT-4 and prompt "fais des tests unitaire en utilsant les ASN1seq fournient en commentaire. Vérifie que les champs normaux d'un x509 sont présent Signature etc.."

// seq1: [48, 130, 1, 86, 48, 130, 1, 8, 160, 3, 2, 1, 2, 2, 9, 0, 169, 37, 75, 83, 77, 189, 173, 228, 48, 5, 6, 3, 43, 101, 112, 48, 49, 49, 13, 48, 11, 6, 3, 85, 4, 3, 12, 4, 116, 101, 115, 116, 49, 13, 48, 11, 6, 3, 85, 4, 11, 12, 4, 115, 105, 103, 110, 49, 17, 48, 15, 6, 3, 85, 4, 10, 12, 8, 115, 101, 97, 108, 102, 46, 105, 101, 48, 30, 23, 13, 50, 52, 48, 56, 49, 53, 49, 52, 49, 51, 48, 51, 90, 23, 13, 50, 53, 48, 56, 49, 53, 49, 52, 49, 51, 48, 51, 90, 48, 49, 49, 13, 48, 11, 6, 3, 85, 4, 3, 12, 4, 116, 101, 115, 116, 49, 13, 48, 11, 6, 3, 85, 4, 11, 12, 4, 115, 105, 103, 110, 49, 17, 48, 15, 6, 3, 85, 4, 10, 12, 8, 115, 101, 97, 108, 102, 46, 105, 101, 48, 42, 48, 5, 6, 3, 43, 101, 112, 3, 33, 0, 66, 172, 56, 176, 10, 48, 185, 64, 210, 52, 1, 182, 27, 142, 68, 57, 163, 152, 87, 229, 103, 223, 12, 106, 150, 127, 169, 33, 212, 165, 112, 58, 163, 61, 48, 59, 48, 29, 6, 3, 85, 29, 14, 4, 22, 4, 20, 163, 255, 234, 100, 3, 120, 71, 9, 231, 255, 245, 85, 62, 123, 99, 30, 115, 53, 77, 65, 48, 9, 6, 3, 85, 29, 35, 4, 2, 48, 0, 48, 15, 6, 3, 85, 29, 19, 1, 1, 255, 4, 5, 48, 3, 1, 1, 255, 48, 5, 6, 3, 43, 101, 112, 3, 65, 0, 176, 4, 184, 165, 23, 209, 192, 135, 91, 85, 92, 91, 83, 236, 223, 50, 207, 228, 9, 8, 18, 232, 111, 62, 199, 159, 43, 163, 161, 124, 118, 139, 253, 4, 34, 153, 28, 110, 171, 97, 163, 86, 121, 43, 252, 57, 91, 252, 42, 76, 90, 44, 71, 250, 189, 97, 25, 53, 110, 218, 90, 226, 99, 6]

// X25519 seq: Seq[Seq[ASN1Object(tag=a0 valueByteLength=3) startpos=2 bytes=[0xa0, 0x3, 0x2, 0x1, 0x2] ASN1Integer(9223372036854775807) Seq[ObjectIdentifier(1.2.840.113549.1.1.11) ASN1Object(tag=5 valueByteLength=0) startpos=2 bytes=[0x5, 0x0] ] Seq[Set[Seq[ObjectIdentifier(2.5.4.6) PrintableString(IE) ] ] Set[Seq[ObjectIdentifier(2.5.4.8) UTF8String(France) ] ] Set[Seq[ObjectIdentifier(2.5.4.7) UTF8String(Crolles) ] ] Set[Seq[ObjectIdentifier(2.5.4.10) UTF8String(Inkan.link) ] ] Set[Seq[ObjectIdentifier(2.5.4.11) UTF8String(Server Research Department) ] ] Set[Seq[ObjectIdentifier(2.5.4.3) UTF8String(Test CA) ] ] Set[Seq[ObjectIdentifier(1.2.840.113549.1.9.1) IA5String(test@example.com) ] ] ] Seq[UtcTime(2024-08-15 15:53:48.000Z) UtcTime(2034-08-16 15:53:48.000Z) ] Seq[Set[Seq[ObjectIdentifier(2.5.4.3) UTF8String(test) ] ] Set[Seq[ObjectIdentifier(2.5.4.11) UTF8String(crypt) ] ] Set[Seq[ObjectIdentifier(2.5.4.10) UTF8String(sealf.ie) ] ] ] Seq[Seq[ObjectIdentifier(1.3.101.110) ] BitString([157, 131, 82, 137, 157, 158, 97, 251, 201, 116, 246, 123, 34, 101, 56, 246, 206, 133, 0, 123, 229, 7, 205, 223, 133, 201, 161, 68, 160, 42, 165, 52]) ] ASN1Object(tag=a3 valueByteLength=66) startpos=2 bytes=[0xa3, 0x42, 0x30, 0x40, 0x30, 0x1d, 0x6, 0x3, 0x55, 0x1d, 0xe, 0x4, 0x16, 0x4, 0x14, 0xac, 0x4e, 0xb4, 0xb1, 0x85, 0x15, 0x78, 0x84, 0x83, 0xc5, 0xad, 0x92, 0x26, 0x19, 0x2a, 0x35, 0xfa, 0x81, 0x78, 0xa6, 0x30, 0x1f, 0x6, 0x3, 0x55, 0x1d, 0x23, 0x4, 0x18, 0x30, 0x16, 0x80, 0x14, 0x87, 0xdb, 0x82, 0xb5, 0x81, 0x96, 0xca, 0xc, 0x3a, 0xe8, 0x8e, 0x6, 0xb5, 0x37, 0x6b, 0x83, 0xb4, 0xc9, 0x42, 0xaa] ] Seq[ObjectIdentifier(1.2.840.113549.1.1.11) ASN1Object(tag=5 valueByteLength=0) startpos=2 bytes=[0x5, 0x0] ] BitString([180, 108, 207, 114, 185, 33, 23, 218, 245, 214, 39, 247, 213, 227, 27, 80, 22, 113, 22, 195, 101, 8, 211, 236, 2, 31, 202, 79, 168, 21, 132, 223, 25, 169, 41, 181, 62, 160, 35, 167, 186, 125, 247, 16, 144, 95, 127, 31, 93, 80, 132, 254, 44, 65, 127, 35, 94, 195, 183, 8, 164, 199, 132, 106, 190, 228, 186, 92, 251, 35, 225, 33, 123, 164, 144, 83, 241, 113, 215, 203, 193, 234, 47, 62, 74, 83, 248, 43, 54, 9, 203, 146, 198, 178, 86, 209, 68, 111, 11, 127, 90, 241, 241, 150, 148, 193, 96, 226, 135, 198, 4, 91, 23, 206, 12, 123, 49, 170, 24, 54, 168, 225, 87, 134, 97, 221, 209, 10, 88, 64, 247, 187, 31, 34, 235, 106, 64, 197, 183, 117, 185, 31, 15, 146, 100, 24, 182, 247, 116, 92, 4, 33, 155, 103, 166, 12, 110, 114, 194, 165, 217, 137, 247, 132, 126, 244, 60, 78, 15, 44, 189, 191, 65, 17, 207, 89, 46, 73, 249, 222, 220, 86, 216, 68, 209, 170, 60, 221, 242, 175, 98, 109, 115, 58, 12, 53, 236, 203, 4, 220, 153, 65, 55, 252, 130, 56, 163, 104, 103, 168, 99, 0, 75, 117, 190, 65, 36, 252, 61, 63, 117, 60, 39, 217, 12, 212, 7, 59, 14, 212, 152, 121, 254, 247, 22, 217, 66, 99, 42, 22, 106, 52, 161, 97, 232, 5, 28, 72, 183, 149, 114, 184, 192, 134, 214, 90, 219, 64, 27, 91, 238, 165, 202, 1, 212, 230, 237, 37, 219, 158, 96, 139, 174, 21, 200, 155, 28, 106, 241, 225, 54, 221, 219, 54, 70, 132, 70, 117, 23, 62, 145, 136, 152, 52, 50, 209, 24, 234, 203, 19, 105, 206, 86, 26, 117, 93, 220, 41, 147, 76, 11, 58, 49, 176, 157, 18, 225, 237, 143, 163, 155, 218, 143, 83, 113, 236, 165, 51, 103, 117, 108, 170, 20, 239, 67, 149, 73, 168, 203, 230, 226, 93, 222, 147, 239, 227, 60, 21, 48, 109, 205, 159, 87, 69, 111, 76, 237, 58, 126, 64, 109, 150, 54, 64, 92, 48, 34, 19, 79, 157, 95, 31, 201, 151, 248, 103, 87, 192, 124, 255, 240, 41, 212, 60, 166, 105, 20, 222, 65, 205, 54, 35, 221, 229, 207, 96, 211, 15, 231, 42, 137, 198, 132, 10, 35, 206, 193, 98, 143, 132, 254, 42, 198, 253, 66, 96, 195, 102, 204, 232, 248, 245, 9, 65, 8, 241, 42, 60, 55, 95, 139, 128, 226, 187, 39, 2, 10, 139, 234, 250, 158, 150, 20, 131, 253, 187, 178, 178, 133, 136, 151, 172, 146, 100, 118, 184, 119, 244, 177, 38, 126, 45, 70, 117, 113, 179, 234, 222, 14, 36, 6, 85, 134, 2, 26, 83, 116, 183, 38, 233, 252, 116, 213, 164, 213, 112, 248, 142, 124, 113, 233, 20, 239, 106, 224, 36, 168, 221, 147, 80, 244, 89, 64, 188, 185, 54, 223, 10, 51, 230, 104, 172]) ]
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
      // Parse the raw sequence string into an ASN1Sequence
      ASN1Sequence sequence = ASN1Sequence();
      try {
        sequence = ASN1Sequence.fromBytes(base64Decode(rawSequence));
      } catch (e) {
        throwsFormatException;
      }
      YkCertificate? certificate = myCertificatefromASN1(sequence);

      expect(certificate!.serialNumber, 9223372036854775807);
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
      expect(certificate.subject, 'CN=test, OU=sign, O=sealf.ie');
    });

    test('X25519Certificate from ASN1Sequence', () {
      // Séquence ASN1 brute pour unificat X25519

      String rawSequence =
          """MIIDpjCCAY6gAwIBAgIUPQA1xz0yUVUM91r6mto7rS0cZYwwDQYJKoZIhvcNAQELBQAwgZ0xCzAJBgNVBAYTAklFMQ8wDQYDVQQIDAZGcmFuY2UxEDAOBgNVBAcMB0Nyb2xsZXMxEzARBgNVBAoMCklua2FuLmxpbmsxIzAhBgNVBAsMGlNlcnZlciBSZXNlYXJjaCBEZXBhcnRtZW50MRAwDgYDVQQDDAdUZXN0IENBMR8wHQYJKoZIhvcNAQkBFhB0ZXN0QGV4YW1wbGUuY29tMB4XDTI0MDgxNTE1NTM0OFoXDTM0MDgxNjE1NTM0OFowMjENMAsGA1UEAwwEdGVzdDEOMAwGA1UECwwFY3J5cHQxETAPBgNVBAoMCHNlYWxmLmllMCowBQYDK2VuAyEAnYNSiZ2eYfvJdPZ7ImU49s6FAHvlB83fhcmhRKAqpTSjQjBAMB0GA1UdDgQWBBSsTrSxhRV4hIPFrZImGSo1+oF4pjAfBgNVHSMEGDAWgBSH24K1gZbKDDrojga1N2uDtMlCqjANBgkqhkiG9w0BAQsFAAOCAgEAtGzPcrkhF9r11if31eMbUBZxFsNlCNPsAh/KT6gVhN8ZqSm1PqAjp7p99xCQX38fXVCE/ixBfyNew7cIpMeEar7kulz7I+Ehe6SQU/Fx18vB6i8+SlP4KzYJy5LGslbRRG8Lf1rx8ZaUwWDih8YEWxfODHsxqhg2qOFXhmHd0QpYQPe7HyLrakDFt3W5Hw+SZBi293RcBCGbZ6YMbnLCpdmJ94R+9DxODyy9v0ERz1kuSfne3FbYRNGqPN3yr2JtczoMNezLBNyZQTf8gjijaGeoYwBLdb5BJPw9P3U8J9kM1Ac7DtSYef73FtlCYyoWajShYegFHEi3lXK4wIbWWttAG1vupcoB1ObtJdueYIuuFcibHGrx4Tbd2zZGhEZ1Fz6RiJg0MtEY6ssTac5WGnVd3CmTTAs6MbCdEuHtj6Ob2o9TceylM2d1bKoU70OVSajL5uJd3pPv4zwVMG3Nn1dFb0ztOn5AbZY2QFwwIhNPnV8fyZf4Z1fAfP/wKdQ8pmkU3kHNNiPd5c9g0w/nKonGhAojzsFij4T+Ksb9QmDDZszo+PUJQQjxKjw3X4uA4rsnAgqL6vqelhSD/buysoWIl6ySZHa4d/SxJn4tRnVxs+reDiQGVYYCGlN0tybp/HTVpNVw+I58cekU72rgJKjdk1D0WUC8uTbfCjPmaKw=""";

      // check this: https://oid-rep.orange-labs.fr/get/1.2.840.113549.1
      // Parse the raw sequence string into an ASN1Sequence
      ASN1Sequence sequence = ASN1Sequence();
      try {
        sequence = ASN1Sequence.fromBytes(base64Decode(rawSequence));
      } catch (e) {
        throwsFormatException;
      }
      YkCertificate? certificate = myCertificatefromASN1(sequence);

      expect(certificate!.serialNumber, 9223372036854775807);
      expect(certificate.issuer, 'X25519');
      expect(
          certificate.publicKey,
          Uint8List.fromList([
            157,
            131,
            82,
            137,
            157,
            158,
            97,
            251,
            201,
            116,
            246,
            123,
            34,
            101,
            56,
            246,
            206,
            133,
            0,
            123,
            229,
            7,
            205,
            223,
            133,
            201,
            161,
            68,
            160,
            42,
            165,
            52
          ]));
      expect(certificate.notAfter, DateTime.parse('2024-08-15 15:53:48.000Z'));
      expect(certificate.notBefore, DateTime.parse('2034-08-16 15:53:48.000Z'));
      expect(certificate.subject, 'CN=test, OU=crypt, O=sealf.ie');
    });
  });
}
// test ECC385 base64 Unit8List: "MIIBbTCB86ADAgECAhQXtN4fwguEMc2XZEiES1FRg9aMZjAKBggqhkjOPQQDAjAYMRYwFAYDVQQDDA1uaWNvbGFzdGhvbWFzMB4XDTI0MDgxNzA5NTEwN1oXDTI1MDgxNzAwMDAwMFowGDEWMBQGA1UEAwwNbmljb2xhc3Rob21hczB2MBAGByqGSM49AgEGBSuBBAAiA2IABK9RLq4iEd7IjzTB+f5ApoNDTWFbAkB43HN8IO1aYx3aqSHMVUKWClEYPWd6ZLV4BD93sDUQEokdFPHLuWt+CoAR8J1tG14HjtoLJXP88IH5eaAyKWLvwFBXqkIwYF1fizAKBggqhkjOPQQDAgNpADBmAjEAzAgEEpHQGj79R0NcnFVpcXxT8wVWT5hx7MODO/d4CilRPqh1wE+Kwi0MExdMhFEtAjEAzAC2ZjvOaQl+QdMML3+hzQiXRLEFqNnULEcuT/BfI9teH7cEkzLkNbR1kwcu3tK+"