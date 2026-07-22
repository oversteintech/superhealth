import 'package:after_core/after_core.dart';
import 'package:flutter/foundation.dart';

/// Crash reporting facade. Records errors via After logger; swap body for
/// Crashlytics / Sentry without changing call sites.
abstract final class CrashReporting {
  static AfterLogger _logger = const ConsoleAfterLogger();
  static var _installed = false;

  static void install(AfterLogger logger) {
    _logger = logger;
    if (_installed) return;
    _installed = true;
    FlutterError.onError = (details) {
      recordFlutterError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack, fatal: true);
      return true;
    };
  }

  static void recordFlutterError(FlutterErrorDetails details) {
    _logger.e(
      'flutter_error',
      error: details.exception,
      stackTrace: details.stack,
    );
  }

  static void recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) {
    _logger.e(
      fatal ? 'fatal_error' : 'non_fatal_error',
      error: error,
      stackTrace: stack,
    );
  }
}