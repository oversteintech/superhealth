import 'dart:convert';
import 'dart:io';

import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readLocale(String languageCode) {
  final file = File('assets/l10n/$languageCode.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  test('After Framework locale pack is complete', () {
    final languageCodes = AfterSupportedLocales.languageCodes;
    expect(languageCodes, hasLength(20));
    expect(languageCodes, containsAll(<String>['ar', 'ur']));

    final english = _readLocale('en');
    for (final languageCode in languageCodes) {
      final file = File('assets/l10n/$languageCode.json');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'Missing locale asset for $languageCode',
      );

      final locale = _readLocale(languageCode);
      expect(
        locale.keys,
        unorderedEquals(english.keys),
        reason: '$languageCode must have exactly the English key set',
      );

      var englishIdenticalCount = 0;
      for (final entry in locale.entries) {
        expect(entry.value, isA<String>());
        final value = (entry.value as String).trim();
        expect(
          value,
          isNotEmpty,
          reason: '$languageCode.${entry.key} must not be empty',
        );
        expect(
          value,
          isNot(entry.key),
          reason: '$languageCode.${entry.key} must not equal its key',
        );
        expect(
          value.startsWith('['),
          isFalse,
          reason: '$languageCode.${entry.key} must not be a stub',
        );
        if (languageCode != 'en' && value == english[entry.key]) {
          englishIdenticalCount++;
        }
      }

      if (languageCode != 'en') {
        final maximumEnglishOverlap = (english.length * 0.15).floor();
        expect(
          englishIdenticalCount,
          lessThanOrEqualTo(maximumEnglishOverlap),
          reason:
              '$languageCode has $englishIdenticalCount English-identical '
              'values; expected at most $maximumEnglishOverlap for brands '
              'and intentional loanwords',
        );
      }
    }
  });
}
