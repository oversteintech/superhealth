import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/membership/health_entitlement_matrix.dart';
import '../family/family_stores.dart';

/// Bridges Family membership plan → Health entitlement policy.
AfterEntitlement healthEntitlementFromRef(Ref ref) {
  final membership = ref.watch(healthMembershipProvider);
  return HealthEntitlementMatrix.entitlementFor(membership.plan);
}
