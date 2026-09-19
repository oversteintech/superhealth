import 'package:after_core/after_core.dart';

import '../../../domain/privacy/sensitive_payload_filter.dart';

/// Product analytics — never forwards clinical values or free-text health notes.
class ProductAnalytics implements AfterAnalytics {
  ProductAnalytics(this._logger);

  final AfterLogger _logger;
  final List<Map<String, Object?>> events = [];

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    final safe = SensitivePayloadFilter.sanitize(parameters);
    events.add({'name': name, ...safe});
    _logger.i('analytics:$name', extras: safe);
  }

  @override
  Future<void> setUserId(String? userId) async {
    // Opaque id only — do not log email.
    _logger.i(
      'analytics:setUserId',
      extras: {'has_user': userId != null && userId.isNotEmpty},
    );
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    if (SensitivePayloadFilter.containsSensitive({name: value})) return;
    _logger.i(
      'analytics:setUserProperty',
      extras: SensitivePayloadFilter.sanitize({name: value}),
    );
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) {
    final parameters = <String, Object?>{
      'screen_name': screenName,
    };
    if (screenClass != null) {
      parameters['screen_class'] = screenClass;
    }
    return logEvent('screen_view', parameters: parameters);
  }
}
