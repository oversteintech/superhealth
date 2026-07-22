import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  static const _key = 'superhealth.theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(afterSharedPreferencesProvider);
    return _decode(prefs.getString(_key));
  }

  Future<void> setMode(ThemeMode mode) async {
    final prefs = ref.read(afterSharedPreferencesProvider);
    await prefs.setString(_key, mode.name);
    state = mode;
  }

  ThemeMode _decode(String? raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}