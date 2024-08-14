import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ykpiv_desktop/ykpiv_desktop.dart';
import 'package:ykpiv_desktop/ykpiv_desktop_bindings_generated.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('YkDesktop Integration Tests', () {
    late YkDestop ykDesktop;

    setUp(() {
      ykDesktop = YkDestop();
    });

    tearDown(() {
      ykDesktop.dispose();
    });

    testWidgets('Initialize YkDesktop', (WidgetTester tester) async {
      expect(() => ykDesktop.init(), returnsNormally);
    });

    testWidgets('Connect to YubiKey', (WidgetTester tester) async {
      String result = ykDesktop.connect();
      expect(result, isNotEmpty);
    });

    testWidgets('Log with PIN', (WidgetTester tester) async {
      expect(() => ykDesktop.logWithPIN("117334"), returnsNormally);
    });

    testWidgets('Check error code', (WidgetTester tester) async {
      expect(() => ykDesktop.checkErrorCode(ykpiv_rc.YKPIV_ALGORITHM_ERROR), returnsNormally);
    });

    testWidgets('Convert YK code to error string', (WidgetTester tester) async {
      String errorString = ykDesktop.ykcodeToError(ykpiv_rc.YKPIV_OK);
      expect(errorString, isNotEmpty);
    });
  });
}
