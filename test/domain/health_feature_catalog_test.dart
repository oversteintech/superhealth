import 'package:flutter_test/flutter_test.dart';
import 'package:super_health/domain/entities/health_feature.dart';

void main() {
  test('catalog covers SuperHealth P0+P1 core features', () {
    expect(HealthFeatureCatalog.all, hasLength(21));
    expect(
      HealthFeatureCatalog.all.map((f) => f.id).toSet(),
      HealthFeatureId.values.toSet(),
    );
  });
}