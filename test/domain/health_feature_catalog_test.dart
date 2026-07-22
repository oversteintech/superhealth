import 'package:flutter_test/flutter_test.dart';
import 'package:super_health/domain/entities/health_feature.dart';

void main() {
  test('catalog covers all eleven SuperHealth core features', () {
    expect(HealthFeatureCatalog.all, hasLength(11));
    expect(
      HealthFeatureCatalog.all.map((f) => f.id).toSet(),
      HealthFeatureId.values.toSet(),
    );
  });
}