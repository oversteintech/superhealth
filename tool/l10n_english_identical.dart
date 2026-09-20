import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final en = _load('en');
  final codes = args.isEmpty
      ? [
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
        ]
      : args;
  for (final code in codes) {
    final loc = _load(code);
    var same = 0;
    final samples = <String>[];
    for (final e in en.entries) {
      if (loc[e.key] == e.value) {
        same++;
        if (samples.length < 8) samples.add(e.key);
      }
    }
    stdout.writeln('$code identical-to-en=$same/${en.length} e.g. ${samples.join(', ')}');
  }
}

Map<String, String> _load(String code) {
  final raw = jsonDecode(File('assets/l10n/$code.json').readAsStringSync())
      as Map<String, dynamic>;
  return raw.map((k, v) => MapEntry(k, '$v'));
}
