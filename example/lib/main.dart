import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:ykpiv_desktop/ykpiv_desktop.dart' as ykpiv_desktop;
import 'package:ykpiv_desktop/ykpiv_desktop_bindings_generated.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late String deviceList;

  @override
  void initState() {
    super.initState();
    deviceList = ykpiv_desktop.YkDestop().connect();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
          
                spacerSmall,
                Text(
                  'DeviceList = $deviceList',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
