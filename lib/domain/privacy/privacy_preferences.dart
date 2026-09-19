import 'package:shared_preferences/shared_preferences.dart';

/// App privacy preferences. Biometric unlock is a flag + PIN in secure storage;
/// OS biometric prompt wires later behind the same keys.
class PrivacyPreferences {
  PrivacyPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const lockEnabledKey = 'super_health.privacy.lock_enabled';
  static const hideNotificationBodyKey =
      'super_health.privacy.hide_notification_body';
  static const blockScreenshotsKey = 'super_health.privacy.block_screenshots';
  static const clearOnSignOutKey = 'super_health.privacy.clear_on_sign_out';
  static const remindersEnabledKey = 'super_health.privacy.reminders_enabled';
  static const cloudClarityAckKey = 'super_health.privacy.cloud_clarity_ack';
  static const pinHashKey = 'superhealth.secret.app_lock_pin';

  bool get lockEnabled => _prefs.getBool(lockEnabledKey) ?? false;
  bool get hideNotificationBody =>
      _prefs.getBool(hideNotificationBodyKey) ?? true;
  bool get blockScreenshots => _prefs.getBool(blockScreenshotsKey) ?? false;
  bool get clearOnSignOut => _prefs.getBool(clearOnSignOutKey) ?? true;
  bool get remindersEnabled => _prefs.getBool(remindersEnabledKey) ?? false;
  bool get cloudClarityAcknowledged =>
      _prefs.getBool(cloudClarityAckKey) ?? false;

  Future<void> setLockEnabled(bool value) =>
      _prefs.setBool(lockEnabledKey, value);
  Future<void> setHideNotificationBody(bool value) =>
      _prefs.setBool(hideNotificationBodyKey, value);
  Future<void> setBlockScreenshots(bool value) =>
      _prefs.setBool(blockScreenshotsKey, value);
  Future<void> setClearOnSignOut(bool value) =>
      _prefs.setBool(clearOnSignOutKey, value);
  Future<void> setRemindersEnabled(bool value) =>
      _prefs.setBool(remindersEnabledKey, value);
  Future<void> setCloudClarityAcknowledged(bool value) =>
      _prefs.setBool(cloudClarityAckKey, value);
}
