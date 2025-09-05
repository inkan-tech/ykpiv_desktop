import 'package:cryptography_plus/cryptography_plus.dart' as cryptodart;
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:x509/x509.dart';
import 'package:ykpiv_desktop/certificate_info.dart';
import 'package:ykpiv_desktop/ykpiv_desktop.dart';
import 'ecdh.dart'; // Import the ECDH test page
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YubiKey PIV Test',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const YubiKeyTestPage(),
    );
  }
}

class YubiKeyTestPage extends StatefulWidget {
  const YubiKeyTestPage({super.key});

  @override
  _YubiKeyTestPageState createState() => _YubiKeyTestPageState();
}

class _YubiKeyTestPageState extends State<YubiKeyTestPage> {
  final YkDesktop _ykDesktop = YkDesktop();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _dataToSignController = TextEditingController();
  final TextEditingController _slotController = TextEditingController();

  String _result = '';
  // List of available slots
  final List<int> _slots = [0x8a, 0x8b, 0x9a, 0x9c, 0x01];

  @override
  void dispose() {
    _ykDesktop.dispose();
    _pinController.dispose();
    _dataToSignController.dispose();
    _slotController.dispose();
    super.dispose();
  }

  void _connect() {
    try {
      String reader = _ykDesktop.connect();
      setState(() {
        _result = 'Connected to: $reader';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
      });
    }
  }

  void _logWithPIN() {
    if (_pinController.text.isNotEmpty) {
      _ykDesktop.logWithPIN(_pinController.text);
      setState(() {
        _result = 'Logged in with PIN';
      });
    } else {
      setState(() {
        _result = 'Please enter a PIN';
      });
    }
  }

  Future<void> _signData() async {
    if (_dataToSignController.text.isNotEmpty) {
      Uint8List signature = Uint8List(0);
      try {
        Uint8List dataToSign =
            Uint8List.fromList(_dataToSignController.text.codeUnits);
        signature = _ykDesktop.sign(
            dataToSign, 0x8a, YkDesktop.getAlgoNumber("ED25519"));
        setState(() {
          _result =
              'Signature: ${signature.map((e) => e.toRadixString(16).padLeft(2, '0')).join()}';
        });
      } catch (e) {
        setState(() {
          _result = 'Error signing data: ${e.toString()}';
        });
      }
      // now verify using the slot choosed in the gui
      int slot = int.parse(_slotController.text, radix: 16);
      Either<YkCertificate, X509Certificate>? certRead =
          _ykDesktop.readcert(slot) as Either<YkCertificate, X509Certificate>?;
      var cert;
      if (certRead!.isLeft) {
        cert = certRead.left;
      } else {
        cert = certRead.right;
      }
      final publicKey = cryptodart.SimplePublicKey(cert.publicKey,
          type: cryptodart.KeyPairType.ed25519);
      final verifier = cryptodart.Ed25519();
      final dataBytes =
          Uint8List.fromList(_dataToSignController.text.codeUnits);
      final signatureToVerify =
          cryptodart.Signature(signature, publicKey: publicKey);
      final isVerified =
          await verifier.verify(dataBytes, signature: signatureToVerify);
      setState(() {
        _result += '\nSignature verification: $isVerified';
      });
    } else {
      setState(() {
        _result = 'Please enter data to sign';
      });
    }
  }

  void _readCertificate() {
    if (_slotController.text.isNotEmpty) {
      try {
        int slot = int.parse(_slotController.text, radix: 16);
        Either<YkCertificate, X509Certificate>? certReader = _ykDesktop
            .readcert(slot) as Either<YkCertificate, X509Certificate>?;
        if (certReader!.isLeft) {
          YkCertificate cert = certReader!.left;
          setState(() {
            _result = 'Certificate Subject: ${cert.subject}\n';
            _result += 'Algo: ${cert.issuer}';
          });
        } else {
          X509Certificate cert = certReader!.right;
          setState(() {
            _result = 'Certificate Subject: ${cert.tbsCertificate.subject}\n';
            _result += 'Algo: ${cert.tbsCertificate.issuer}';
          });
        }
      } catch (e) {
        setState(() {
          _result = 'Error reading certificate: ${e.toString()}';
        });
      }
    } else {
      setState(() {
        _result = 'Please select a slot';
      });
    }
  }

  void _navigateToEcdhPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EcdhTestPage()),
    );
  }

  Future<bool> verifySignature(cryptodart.SimplePublicKey publicKey,
      Uint8List signature, Uint8List data) async {
    try {
      final verifier = cryptodart.Ed25519();
      return await verifier.verify(
        data,
        signature: cryptodart.Signature(signature, publicKey: publicKey),
      );
    } catch (e) {
      print('Error verifying signature: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YubiKey PIV Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _connect,
              child: const Text('Connect'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
              onSubmitted: (_) => _logWithPIN(),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _logWithPIN,
              child: const Text('Log with PIN'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dataToSignController,
              decoration:
                  const InputDecoration(labelText: 'Enter data to sign'),
              onSubmitted: (_) => _signData(),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _signData,
              child: const Text('Sign Data'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _slots[0],
              items: _slots.map((int slot) {
                return DropdownMenuItem<int>(
                  value: slot,
                  child: Text('0x${slot.toRadixString(16)}'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  _slotController.text = newValue.toRadixString(16);
                }
              },
              decoration: const InputDecoration(labelText: 'Select Slot'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _readCertificate,
              child: const Text('Read Certificate'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToEcdhPage,
              child: const Text('Go to ECDH Test Page'),
            ),
            const SizedBox(height: 16),
            const Text('Result:'),
            Text(_result, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
