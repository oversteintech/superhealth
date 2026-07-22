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

  void setLocale(String code) {
    final catalog = ref.read(stringCatalogProvider);
    catalog.setLocale(code);
    state = catalog.locale;
  }
}

extension AppStringsX on WidgetRef {
  String tr(String key, {Map<String, String> args = const {}}) {
    watch(localeCodeProvider);
    return read(stringCatalogProvider).t(key, args: args);
  }
}