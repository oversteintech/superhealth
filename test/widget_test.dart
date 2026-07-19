import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/app/platform/after_framework.dart';
import 'package:super_health/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SuperHealth home renders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    AfterFramework.ensureConfigured();

    await tester.pumpWidget(
      ProviderScope(
        overrides: AfterFramework.createSuperHealthAfterOverrides(prefs),
        child: const SuperHealthApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SuperHealth'), findsOneWidget);
    expect(find.textContaining('After Framework'), findsWidgets);
  });
}
