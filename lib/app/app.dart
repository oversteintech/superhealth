import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family/family_stores.dart';
import 'l10n/app_strings.dart';
import 'offline/offline_controller.dart';

class SuperHealthApp extends ConsumerWidget {
  const SuperHealthApp({required this.home, super.key});

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeStyle = ref.watch(familyThemeStyleProvider);
    final locale = ref.watch(localeCodeProvider);
    final connectivity = ref.watch(connectivityStatusProvider);
    final accent = healthChrome.accent;

    return MaterialApp(
      title: 'SuperHealth',
      debugShowCheckedModeBanner: false,
      theme: FamilyTheme.forStyle(themeStyle, accent: accent),
      darkTheme: FamilyTheme.forStyle(
        themeStyle == AfterThemeStyle.system
            ? AfterThemeStyle.dark
            : themeStyle,
        accent: accent,
      ),
      themeMode: FamilyTheme.themeModeFor(themeStyle),
      locale: Locale(locale),
      supportedLocales: AfterSupportedLocales.locales,
      localeResolutionCallback: AfterSupportedLocales.resolutionCallback,
      localizationsDelegates: AfterSupportedLocales.localizationsDelegates,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        final shelled = AfterPremiumAppShell.wrap(
          style: themeStyle,
          child: content,
        );
        if (connectivity != ConnectivityStatus.offline) {
          return shelled;
        }
        return Stack(
          children: [
            shelled,
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Material(
                color: Colors.orange.shade800,
                child: const SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      'OFFLINE — showing cached data',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      home: home,
    );
  }
}
