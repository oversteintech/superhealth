import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/health_repository.dart';
import '../repositories/mock_health_repository.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return MockHealthRepository();
});