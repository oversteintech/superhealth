import 'dart:convert';
import 'dart:io';

void main() {
  final dir = Directory('assets/l10n');
  final en = jsonDecode(File('assets/l10n/en.json').readAsStringSync())
      as Map<String, dynamic>;
  final enKeys = en.keys.toSet();
  stdout.writeln('en keys: ${enKeys.length}');
  for (final f in dir.listSync().whereType<File>()) {
    final name = f.uri.pathSegments.last;
    if (!name.endsWith('.json') || name == 'meta.json') continue;
    final map = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    final keys = map.keys.toSet();
    final missing = enKeys.difference(keys);
    final extra = keys.difference(enKeys);
    stdout.writeln(
      '${name.padRight(12)} ${keys.length.toString().padLeft(4)} '
      'missing=${missing.length} extra=${extra.length}',
    );
    if (missing.isNotEmpty && missing.length <= 30) {
      stdout.writeln('  missing: ${missing.join(', ')}');
    } else if (missing.isNotEmpty) {
      stdout.writeln('  missing sample: ${missing.take(15).join(', ')}...');
    }
  }
}
