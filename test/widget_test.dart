import 'package:flutter_test/flutter_test.dart';
import 'package:super_health/app/platform/manifest.dart';

void main() {
  test('SuperHealth manifest identity is stable', () {
    expect(superHealthManifest.appName, 'SuperHealth');
    expect(superHealthManifest.appId, 'super_health');
    expect(
      superHealthManifest.packageName,
      'com.overstein.superhealth',
    );
  });
}