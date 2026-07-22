/// Compile-time and runtime configuration for SuperHealth.
abstract final class AppConfig {
  static const String appName = 'SuperHealth';
  static const String versionName = '0.1.0';
  static const int versionCode = 1;
  static const String supportEmail = 'superhealth@overstein.com';
  static const String privacyUrl =
      'https://www.overstein.com/legal/privacy';
  static const String termsUrl = 'https://www.overstein.com/legal/terms';
  static const String apiBaseUrl = 'https://api.afterartificial.com/v1/health';
  static const Duration splashMinDuration = Duration(milliseconds: 1400);
  static const Duration remoteConfigTtl = Duration(hours: 1);
  static const bool offlineCacheEnabled = true;
}