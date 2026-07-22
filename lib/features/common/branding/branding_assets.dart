/// Canonical branding asset paths for SuperHealth.
///
/// SuperHealth ships the S+ monogram — the family-style interlocking
/// black/red→purple→blue mark that mirrors the SuperGarage SG monogram.
abstract final class BrandingAssets {
  /// Official S+ monogram — transparent background for in-app / splash.
  static const monogram = 'assets/branding/super_health_monogram.png';

  /// Adaptive icon foreground — S+ monogram with safe-area padding.
  static const monogramForeground =
      'assets/branding/super_health_monogram_foreground.png';

  /// Store launcher — S+ monogram on pure black.
  static const monogramStore =
      'assets/branding/super_health_monogram_store.png';

  /// Primary in-app mark alias (monogram).
  static const appIcon = monogram;

  /// Store launcher alias.
  static const storeIcon = monogramStore;

  /// Adaptive foreground alias.
  static const appIconForeground = monogramForeground;
}
