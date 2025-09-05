import 'package:cryptography_flutter_plus/cryptography_flutter_plus.dart';
import 'package:flutter/material.dart';
import 'package:cryptography_plus/cryptography_plus.dart';
import 'dart:typed_data';
import 'package:ykpiv_desktop/ykpiv_desktop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YkDesktop ECDH Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EcdhTestPage(),
    );
  }
}

class EcdhTestPage extends StatefulWidget {
  const EcdhTestPage({super.key});

  @override
  _EcdhTestPageState createState() => _EcdhTestPageState();
}

class _EcdhTestPageState extends State<EcdhTestPage> {
  final YkDesktop ykDesktop = YkDesktop(); // Initialize YkDesktop
  int selectedSlot = 0x8b;
  Uint8List? publicKey;
  Uint8List? sharedSecret;

  @override
  void initState() {
    super.initState();
    _generateX25519KeyPair();
  }

  Future<void> _generateX25519KeyPair() async {
    final algorithm = FlutterX25519(X25519());
    final keyPair = await algorithm.newKeyPair();
    publicKey = Uint8List.fromList((await keyPair.extractPublicKey()).bytes);
    setState(() {});
  }

  void _testEcdh() {
    if (publicKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Public key not generated yet')),
      );
      return;
    }

    try {
      ykDesktop.connect();
      ykDesktop.logWithPIN("117334");
      sharedSecret = ykDesktop.ecdh(publicKey!, selectedSlot);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ECDH Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Slot:'),
            DropdownButton<int>(
              value: selectedSlot,
              items: [0x8a, 0x8b, 0x9a, 0x9b].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('0x${value.toRadixString(16)}'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedSlot = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testEcdh,
              child: const Text('Test ECDH'),
            ),
            const SizedBox(height: 20),
            const Text('Public Key:'),
            Text(publicKey?.toString() ?? 'Not generated'),
            const SizedBox(height: 20),
            const Text('Shared Secret:'),
            Text(sharedSecret?.toString() ?? 'Not calculated'),
          ],
        ),
      ),
    );
  }
}
