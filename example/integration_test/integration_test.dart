import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ykpiv_desktop/ykpiv_desktop.dart';
import 'package:ykpiv_desktop/ykpiv_desktop_bindings_generated.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('YkDesktop Integration Tests', () {
    late YkDesktop ykpiv;

    setUp(() {
      ykpiv = YkDesktop();
      ykpiv.init();
      ykpiv.connect();
    });

    tearDown(() {
      ykpiv.dispose();
    });

    testWidgets('Initialize YkDesktop', (WidgetTester tester) async {
      expect(() => ykpiv.init(), returnsNormally);
    });

    testWidgets('Connect to YubiKey', (WidgetTester tester) async {
      String result = ykpiv.connect();
      expect(result, isNotEmpty);
    });

    testWidgets('Log with PIN', (WidgetTester tester) async {
      expect(() => ykpiv.logWithPIN("117334"), returnsNormally);
    });

    testWidgets('Check error code', (WidgetTester tester) async {
      expect(() => ykpiv.checkErrorCode(ykpiv_rc.YKPIV_ALGORITHM_ERROR),
          returnsNormally);
    });

    testWidgets('ECDH key exchange using slot 8b', (WidgetTester tester) async {
      SimpleKeyPair keyPair = await FlutterX25519(X25519()).newKeyPair();
      SimplePublicKey publicKey = await keyPair.extractPublicKey();

      expect(() {
        ykpiv.connect();
        ykpiv.logWithPIN("117334");
        final sharedSecret =
            ykpiv.ecdh(Uint8List.fromList(publicKey.bytes), 0x8b);
        expect(sharedSecret, isNotNull);
        expect(sharedSecret.length, equals(32));
      }, returnsNormally);
    });

    testWidgets('ECDH key exchange with invalid public key',
        (WidgetTester tester) async {
      final invalidPublicKey = Uint8List(31); // Should be 32 bytes for X25519

      expect(() => ykpiv.ecdh(invalidPublicKey, 0x8b),
          throwsException);
    });

    testWidgets('ECDH key exchange with invalid slot',
        (WidgetTester tester) async {
      SimpleKeyPair keyPair = await X25519().newKeyPair();
      final publicKey = await keyPair.extractPublicKey();

      expect(() => ykpiv.ecdh(Uint8List.fromList(publicKey.bytes), 0x81),
          throwsException);
    });
    testWidgets('Convert YK code to error string', (WidgetTester tester) async {
      String errorString = ykpiv.ykcodeToError(ykpiv_rc.YKPIV_OK);
      expect(errorString, isNotEmpty);
    });
  });
}
