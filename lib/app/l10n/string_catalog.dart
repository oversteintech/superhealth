import 'dart:convert';

import 'package:after_core/after_core.dart';
import 'package:flutter/services.dart';

/// Runtime JSON string catalog for all [AfterSupportedLocales] (≥20).
///
/// Missing locale assets fall back to English at resolve time.
class StringCatalog {
  StringCatalog._(this._tables);

  /// Test-only constructor — avoids asset bundle dependency.
  factory StringCatalog.forTest(Map<String, Map<String, String>> tables) {
    return StringCatalog._(tables);
  }

  final Map<String, Map<String, String>> _tables;
  String locale = AfterSupportedLocales.fallbackLanguage;

  static Future<StringCatalog>? _cached;

  static Future<StringCatalog> load() async {
    final en = await _loadLocale(AfterSupportedLocales.fallbackLanguage);
    final tables = <String, Map<String, String>>{
      AfterSupportedLocales.fallbackLanguage: en,
    };
    for (final code in AfterSupportedLocales.languageCodes) {
      if (code == AfterSupportedLocales.fallbackLanguage) continue;
      try {
        tables[code] = await _loadLocale(code);
      } on Object {
        // Missing / invalid — English fallback in [t].
      }
    }
    return StringCatalog._(tables);
  }

  /// Cached [load] — safe to call from multiple bootstrap seams.
  static Future<StringCatalog> ensureLoaded() {
    return _cached ??= load();
  }

  static Future<Map<String, String>> _loadLocale(String code) async {
    final raw = await rootBundle.loadString('assets/l10n/$code.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, '$v'));
  }

  String t(String key, {Map<String, String> args = const {}}) {
    final table = _tables[locale] ??
        _tables[AfterSupportedLocales.fallbackLanguage] ??
        const <String, String>{};
    final fallback = _tables[AfterSupportedLocales.fallbackLanguage] ??
        const <String, String>{};
    var value = table[key] ?? fallback[key] ?? key;
    for (final entry in args.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }

  void setLocale(String? code) {
    if (code == null) {
      return;
    }
    if (AfterSupportedLocales.isSupported(code)) {
      locale = code;
    }
  }
}
