import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';

import 'app/bootstrap/cold_start_app.dart';
import 'app/platform/after_framework.dart';
import 'app/platform/crash_reporting.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AfterFramework.ensureConfigured();
    CrashReporting.install(const ConsoleAfterLogger());
    runApp(const SuperHealthColdStart());
  }, (error, stack) {
    CrashReporting.recordError(error, stack, fatal: true);
  });
}