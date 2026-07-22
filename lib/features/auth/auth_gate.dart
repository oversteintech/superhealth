import 'package:after_core/after_core.dart';
import 'package:after_consumer/after_consumer.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family/family_stores.dart';
import '../shell/main_shell.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(afterAuthSessionProvider);
    return sessionAsync.when(
      loading: () => const Scaffold(body: Center(child: AfterLoading())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
      data: (session) {
        if (session.isLoading) {
          return const Scaffold(body: Center(child: AfterLoading()));
        }
        if (!session.isAuthenticated) {
          return FamilyLoginScreen(
            config: healthChrome,
            authConfig: FamilyAuthChromeConfig(
              appName: healthChrome.appName,
              supportEmail: healthChrome.supportEmail,
              accent: healthChrome.accent,
              tagline: healthChrome.tagline,
              aiTitle: healthChrome.aiTitle,
            ),
          );
        }
        return const FamilySessionEffects(child: MainShell());
      },
    );
  }
}
