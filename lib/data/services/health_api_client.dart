import 'package:after_core/after_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/app_config.dart';

/// Networking facade over After Dio — ready for real health APIs.
class HealthApiClient {
  HealthApiClient(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getHealthSummary() {
    return _dio.get<dynamic>('${AppConfig.apiBaseUrl}/summary');
  }

  Future<Response<dynamic>> syncVitals(Map<String, Object?> payload) {
    return _dio.post<dynamic>(
      '${AppConfig.apiBaseUrl}/vitals/sync',
      data: payload,
    );
  }
}

final healthApiClientProvider = Provider<HealthApiClient>((ref) {
  return HealthApiClient(ref.watch(afterDioProvider));
});