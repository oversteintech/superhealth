import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/platform/after_framework.dart';
import 'app/theme/app_theme.dart';
import 'features/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AfterFramework.ensureConfigured();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: AfterFramework.createSuperHealthAfterOverrides(prefs),
      child: const SuperHealthApp(),
    ),
  );
}

class SuperHealthApp extends ConsumerWidget {
  const SuperHealthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SuperHealth',
      debugShowCheckedModeBanner: false,
      theme: SuperHealthTheme.light(),
      darkTheme: SuperHealthTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
