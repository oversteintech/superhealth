import 'dart:async';

import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_gate.dart';
import '../app.dart';
import '../platform/after_framework.dart';
import 'app_runtime_bootstrap.dart';

/// Cold start: shared OVERSTEIN company splash → AuthGate.
///
/// Contract (identical to SuperGarage):
/// 1. Show [OversteinCompanySplash] immediately — no product branding.
/// 2. Bootstrap in parallel with the splash animation.
/// 3. After splash [onComplete], mount AuthGate when bootstrap is ready.
class SuperHealthColdStart extends StatefulWidget {
  const SuperHealthColdStart({super.key});

  @override
  State<SuperHealthColdStart> createState() => _SuperHealthColdStartState();
}

class _SuperHealthColdStartState extends State<SuperHealthColdStart> {
  late final Future<BootstrapSnapshot> _bootstrap;
  var _splashFinished = false;
  var _warmArmed = false;
  ProviderContainer? _container;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap = _resolveBootstrap();
  }

  @override
  void dispose() {
    _container?.dispose();
    super.dispose();
  }

  Future<BootstrapSnapshot> _resolveBootstrap() async {
    try {
      return await AppRuntimeBootstrap.load().timeout(
        const Duration(seconds: 12),
      );
    } on Object catch (error, stack) {
      debugPrint('SuperHealth cold start bootstrap failed: $error\n$stack');
      rethrow;
    }
  }

  void _onSplashComplete() {
    if (!mounted || _splashFinished) return;
    setState(() => _splashFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AfterLaunchShell(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'SuperHealth failed to start.\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      );
    }

    if (!_splashFinished) {
      return AfterLaunchShell(
        child: OversteinCompanySplash(
          key: const ValueKey<String>('overstein-company-splash'),
          onComplete: _onSplashComplete,
        ),
      );
    }

    return FutureBuilder<BootstrapSnapshot>(
      future: _bootstrap,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          _error = snapshot.error;
          return AfterLaunchShell(
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Text(
                  'SuperHealth failed to start.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const AfterLaunchShell(
            child: Scaffold(
              backgroundColor: Colors.black,
              body: SizedBox.expand(),
            ),
          );
        }

        final boot = snapshot.data!;
        _container ??= ProviderContainer(
          overrides: [
            ...AppRuntimeBootstrap.overrides(boot),
            ...AfterFramework.createSuperHealthAfterOverrides(boot.preferences),
          ],
        );
        if (!_warmArmed) {
          _warmArmed = true;
          unawaited(AppRuntimeBootstrap.warm(_container!));
        }

        return UncontrolledProviderScope(
          container: _container!,
          child: const SuperHealthApp(home: AuthGate()),
        );
      },
    );
  }
}
