import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family/family_stores.dart';
import '../shell/main_shell.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FamilyAuthGate(
      appName: healthChrome.appName,
      appId: 'super_health',
      chrome: healthChrome,
      authConfig: FamilyAuthChromeConfig(
        appName: healthChrome.appName,
        supportEmail: healthChrome.supportEmail,
        accent: healthChrome.accent,
        headerTitle: healthChrome.headerTitle,
        tagline: healthChrome.tagline,
        aiTitle: healthChrome.aiTitle,
      ),
      home: const MainShell(),
    );
  }
}
