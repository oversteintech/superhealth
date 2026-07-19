import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';

abstract final class SuperHealthTheme {
  static ThemeData light() {
    final base = AfterThemeData.light();
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF34D399),
        secondary: const Color(0xFF38BDF8),
      ),
    );
  }

  static ThemeData dark() {
    final base = AfterThemeData.dark();
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF34D399),
        secondary: const Color(0xFF38BDF8),
      ),
    );
  }
}
