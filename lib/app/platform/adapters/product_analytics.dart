import 'package:after_core/after_core.dart';

/// Product analytics adapter — logs events through After logger until a store
/// SDK (Firebase Analytics, etc.) is wired behind the same port.
class ProductAnalytics implements AfterAnalytics {
  ProductAnalytics(this._logger);

  final AfterLogger _logger;
  final List<Map<String, Object?>> events = [];

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    events.add({'name': name, ...parameters});
    _logger.i('analytics:$name', extras: parameters);
  }

  @override
  Future<void> setUserId(String? userId) async {
    _logger.i('analytics:setUserId', extras: {'userId': userId});
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    _logger.i(
      'analytics:setUserProperty',
      extras: {'name': name, 'value': value},
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