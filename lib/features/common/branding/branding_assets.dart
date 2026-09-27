/// Canonical branding asset paths for SuperHealth.
///
/// Approved mark: chrome S monogram with anatomical heart and ECG pulse.
abstract final class BrandingAssets {
  /// In-app monogram — S + heart + ECG.
  static const monogram = 'assets/branding/super_health_monogram.png';

  /// Adaptive icon foreground.
  static const monogramForeground =
      'assets/branding/super_health_monogram_foreground.png';

  /// Store / launcher icon.
  static const monogramStore =
      'assets/branding/super_health_monogram_store.png';

  /// Primary in-app mark alias (monogram).
  static const appIcon = monogram;

  /// Store launcher alias.
  static const storeIcon = monogramStore;

  /// Adaptive foreground alias.
  static const appIconForeground = monogramForeground;
}
