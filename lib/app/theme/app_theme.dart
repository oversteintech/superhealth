import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';

/// SuperHealth accents on Garage-parity [AfterFrameworkTheme] (shared type scale).
abstract final class SuperHealthTheme {
  static const Color mint = Color(0xFF34D399);
  static const Color sky = Color(0xFF38BDF8);
  static const Color coral = Color(0xFFFB7185);

  static ThemeData light() => AfterFrameworkTheme.forStyle(
        AfterThemeStyle.light,
        accentOverride: mint,
      );

  static ThemeData dark() => AfterFrameworkTheme.forStyle(
        AfterThemeStyle.dark,
        accentOverride: mint,
      );
}
