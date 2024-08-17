import 'package:flutter/material.dart';
import 'package:x509/x509.dart';
import 'package:ykpiv_desktop/ykpiv_desktop.dart';
import 'ecdh.dart'; // Import the ECDH test page
import 'dart:typed_data';
import 'package:x509/x509.dart' as x509;

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

  void _signData() {
    if (_dataToSignController.text.isNotEmpty) {
      try {
        Uint8List dataToSign =
            Uint8List.fromList(_dataToSignController.text.codeUnits);
        Uint8List signature = _ykDesktop.sign(
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
        Map<String, dynamic> cert = _ykDesktop.readcert(slot);
        setState(() {
          _result = 'Certificate Subject: ${cert.toString()}';
        });
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
