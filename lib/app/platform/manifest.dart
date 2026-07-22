import 'package:after_core/after_core.dart';

/// SuperHealth product identity on After Framework.
const AppPlatformManifest superHealthManifest = AppPlatformManifest(
  appName: 'SuperHealth',
  appId: 'super_health',
  packageName: 'com.overstein.superhealth',
  androidWidgetProvider:
      'com.overstein.superhealth.SuperHealthWidgetProvider',
  iosAppGroupId: 'group.com.overstein.superhealth',
  supportEmail: 'superhealth@overstein.com',
);