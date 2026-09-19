import 'package:after_core/after_core.dart';

import '../../domain/entities/health_feature.dart';

/// Free / Silver / Gold / Business matrix for Super Health.
///
/// **Non-negotiable:** personal health records (timeline, measurements, habits,
/// medications, appointments, documents, emergency card, profile) are never
/// paywalled. Paid tiers unlock polish, sharing extras, care circle depth,
/// unlimited Mate, and cloud sync — not the diary itself.
abstract final class HealthEntitlementMatrix {
  static const consentPolicyVersion = 'health-entitlement-p3-1';

  static const AfterEntitlementPolicy policy = AfterEntitlementPolicy(
    matrix: {
      AfterUserPlan.free: {
        AfterPlanFeature.aiLimited,
        AfterPlanFeature.cloudSyncBasic,
      },
      AfterUserPlan.premium: {
        // Silver
        AfterPlanFeature.aiLimited,
        AfterPlanFeature.unlimitedEntities,
        AfterPlanFeature.premiumThemes,
        AfterPlanFeature.cloudSyncBasic,
        AfterPlanFeature.adFree,
        AfterPlanFeature.pdfExport,
      },
      AfterUserPlan.superPlan: {
        // Gold / Overstein Membership
        AfterPlanFeature.aiLimited,
        AfterPlanFeature.aiUnlimited,
        AfterPlanFeature.unlimitedEntities,
        AfterPlanFeature.premiumThemes,
        AfterPlanFeature.cloudSync,
        AfterPlanFeature.cloudSyncBasic,
        AfterPlanFeature.familyShare,
        AfterPlanFeature.pdfExport,
        AfterPlanFeature.liveData,
        AfterPlanFeature.adFree,
      },
      AfterUserPlan.business: {
        AfterPlanFeature.aiLimited,
        AfterPlanFeature.aiUnlimited,
        AfterPlanFeature.unlimitedEntities,
        AfterPlanFeature.premiumThemes,
        AfterPlanFeature.cloudSync,
        AfterPlanFeature.cloudSyncBasic,
        AfterPlanFeature.familyShare,
        AfterPlanFeature.pdfExport,
        AfterPlanFeature.liveData,
        AfterPlanFeature.fleetDashboard,
        AfterPlanFeature.adFree,
        AfterPlanFeature.tracking,
      },
      AfterUserPlan.superadmin: {
        ...AfterPlanFeature.values,
      },
    },
  );

  /// Features that stay available on Free (and every higher plan).
  static const freePersonalRecords = <HealthFeatureId>{
    HealthFeatureId.timeline,
    HealthFeatureId.observations,
    HealthFeatureId.habits,
    HealthFeatureId.medication,
    HealthFeatureId.appointments,
    HealthFeatureId.documents,
    HealthFeatureId.profile,
    HealthFeatureId.emergencyCard,
    HealthFeatureId.trends,
    HealthFeatureId.sharing,
    HealthFeatureId.wearableImport,
    HealthFeatureId.medicalRecords,
    HealthFeatureId.doctorVisits,
    HealthFeatureId.labResults,
    HealthFeatureId.vaccinations,
    HealthFeatureId.heartRate,
    HealthFeatureId.weight,
    HealthFeatureId.sleep,
    HealthFeatureId.nutrition,
    HealthFeatureId.healthAi,
  };

  static bool isPersonalRecordFeature(HealthFeatureId id) =>
      freePersonalRecords.contains(id);

  /// Gate for UI. Personal records always open; gated extras use plan matrix.
  static bool canOpenFeature({
    required AfterUserPlan plan,
    required HealthFeatureId id,
  }) {
    if (isPersonalRecordFeature(id)) return true;
    return switch (id) {
      HealthFeatureId.caregivers =>
        plan.isAtLeast(AfterUserPlan.superPlan), // Gold+
      _ => true,
    };
  }

  static AfterEntitlement entitlementFor(AfterUserPlan plan) => AfterEntitlement(
        effectivePlan: plan,
        storedPlan: plan,
        policy: policy,
      );

  static String tierLabel(AfterUserPlan plan) =>
      AfterMembershipBadge.forPlan(plan);
}
