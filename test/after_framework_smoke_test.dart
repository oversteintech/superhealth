import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/app/platform/after_framework.dart';
import 'package:super_health/app/platform/manifest.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ensureConfigured sets SuperHealth manifest', () {
    AfterFramework.ensureConfigured();
    expect(PlatformConfig.current.appId, superHealthManifest.appId);
    expect(
      PlatformConfig.current.packageName,
      'com.overstein.superhealth',
    );
  });

  test('createSuperHealthAfterOverrides returns non-empty list', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final overrides = AfterFramework.createSuperHealthAfterOverrides(prefs);
    expect(overrides, isNotEmpty);
  });
}