import 'dart:convert';
import 'dart:io';

const _languageCodes = <String>[
  'zh',
  'hi',
  'es',
  'fr',
  'ar',
  'bn',
  'pt',
  'ru',
  'ur',
  'id',
  'de',
  'ja',
  'sw',
  'mr',
  'te',
  'ta',
  'vi',
  'ko',
];

final _stubPrefix = RegExp(r'^\[[^\]]+\]\s*');
const _encoder = JsonEncoder.withIndent('  ');

Map<String, String> _readStringMap(String path) {
  final decoded =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return decoded.map((key, value) => MapEntry(key, value as String));
}

void main() {
  final english = _readStringMap('assets/l10n/en.json');

  for (final languageCode in _languageCodes) {
    final localePath = 'assets/l10n/$languageCode.json';
    final translationsPath = 'tool/l10n/health_i18n/$languageCode.json';
    final existing = _readStringMap(localePath);
    final translations = _readStringMap(translationsPath);
    final synced = <String, String>{};

    for (final entry in english.entries) {
      final current = existing[entry.key]?.trim() ?? '';
      if (current.isNotEmpty) {
        final withoutStub = current.replaceFirst(_stubPrefix, '').trim();
        if (withoutStub.isNotEmpty) {
          synced[entry.key] = withoutStub;
          continue;
        }
      }

      final translated = translations[entry.key]?.trim() ?? '';
      if (translated.isEmpty) {
        throw StateError(
          'Missing translation for $languageCode: ${entry.key}',
        );
      }
      synced[entry.key] = translated;
    }

    File(localePath).writeAsStringSync('${_encoder.convert(synced)}\n');
    stdout.writeln('$languageCode: ${synced.length} keys');
  }
}
