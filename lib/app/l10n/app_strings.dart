import 'package:shared_preferences/shared_preferences.dart';
import 'package:after_core/after_core.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'string_catalog.dart';

final stringCatalogProvider = Provider<StringCatalog>((ref) {
  throw StateError('StringCatalog must be overridden at cold start');
});

final localeCodeProvider = NotifierProvider<LocaleCodeController, String>(
  LocaleCodeController.new,
);

class LocaleCodeController extends Notifier<String> {
  @override
  String build() => ref.watch(stringCatalogProvider).locale;

  void setLocale(String? code) {
    if (code == null) {
      return;
    }
    final catalog = ref.read(stringCatalogProvider);
    catalog.setLocale(code);
    state = catalog.locale;
    unawaited(_persist(code));
  }

  Future<void> _persist(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await AfterLocalePrefs.write(prefs, code, legacyKey: 'superhealth.locale');
  }
}

extension AppStringsX on WidgetRef {
  String tr(String key, {Map<String, String> args = const {}}) {
    watch(localeCodeProvider);
    return read(stringCatalogProvider).t(key, args: args);
  }
}