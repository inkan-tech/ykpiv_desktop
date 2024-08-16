import 'package:flutter/material.dart';
import 'package:ykpiv_desktop/ykpiv_desktop.dart' as ykpiv_desktop;
import 'ecdh.dart'; // Import the ECDH test page

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
  final ykpiv_desktop.YkDesktop _ykDesktop = ykpiv_desktop.YkDesktop();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _dataToSignController = TextEditingController();
  String _result = '';

  @override
  void dispose() {
    _ykDesktop.dispose();
    _pinController.dispose();
    _dataToSignController.dispose();
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
      // This is a placeholder. You'll need to implement the actual signing logic
      setState(() {
        _result = 'Signed: ${_dataToSignController.text}';
      });
    } else {
      setState(() {
        _result = 'Please enter data to sign';
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
              decoration: const InputDecoration(labelText: 'Enter data to sign'),
              onSubmitted: (_) => _signData(),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _signData,
              child: const Text('Sign Data'),
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
