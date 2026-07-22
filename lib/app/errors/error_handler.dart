import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';

import '../platform/crash_reporting.dart';

/// Central error presentation + reporting for SuperHealth.
abstract final class ErrorHandler {
  static void report(
    Object error,
    StackTrace? stack, {
    AfterLogger? logger,
  }) {
    CrashReporting.recordError(error, stack);
    logger?.e('handled_error', error: error, stackTrace: stack);
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static String userMessage(Object error) {
    if (error is AfterException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}