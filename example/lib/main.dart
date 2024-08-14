import 'package:flutter/material.dart';
import 'package:ykpiv_desktop/ykpiv_desktop.dart' as ykpiv_desktop;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YubiKey PIV Test',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: YubiKeyTestPage(),
    );
  }
}

class YubiKeyTestPage extends StatefulWidget {
  @override
  _YubiKeyTestPageState createState() => _YubiKeyTestPageState();
}

class _YubiKeyTestPageState extends State<YubiKeyTestPage> {
  final ykpiv_desktop.YkDestop _ykDesktop = ykpiv_desktop.YkDestop();
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
              child: Text('Connect'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: 'Enter PIN'),
              onSubmitted: (_) => _logWithPIN(),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _logWithPIN,
              child: Text('Log with PIN'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _dataToSignController,
              decoration: InputDecoration(labelText: 'Enter data to sign'),
              onSubmitted: (_) => _signData(),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _signData,
              child: Text('Sign Data'),
            ),
            SizedBox(height: 16),
            Text('Result:'),
            Text(_result, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
