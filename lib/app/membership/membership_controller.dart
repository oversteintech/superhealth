import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Legacy alias — delegates to the same prefs key as FamilyMembershipController.
class MembershipState {
  const MembershipState({
    this.plan = AfterUserPlan.free,
  });

  final AfterUserPlan plan;

  AfterEntitlement get entitlement => AfterEntitlement(
        effectivePlan: plan,
        storedPlan: plan,
      );

  String get badge => AfterMembershipBadge.forPlan(plan);

  bool get isSuperAdmin => plan == AfterUserPlan.superadmin;

  MembershipState copyWith({AfterUserPlan? plan}) =>
      MembershipState(plan: plan ?? this.plan);
}

final membershipControllerProvider =
    NotifierProvider<MembershipController, MembershipState>(
  MembershipController.new,
);

class MembershipController extends Notifier<MembershipState> {
  static const _key = 'super_health.membership.plan';

  @override
  MembershipState build() {
    final prefs = ref.watch(afterSharedPreferencesProvider);
    final session = ref.watch(afterAuthSessionProvider).asData?.value;
    if (AfterSuperAdmin.isSuperAdminEmail(session?.user?.email)) {
      return const MembershipState(plan: AfterUserPlan.superadmin);
    }
    final plan = AfterUserPlanRank.fromStorage(prefs.getString(_key));
    if (plan == AfterUserPlan.superadmin) {
      return const MembershipState(plan: AfterUserPlan.free);
    }
    return MembershipState(plan: plan);
  }

  Future<void> setPlan(AfterUserPlan plan) async {
    if (state.isSuperAdmin) return;
    final prefs = ref.read(afterSharedPreferencesProvider);
    await prefs.setString(_key, plan.storageKey);
    state = state.copyWith(plan: plan);
    await ref.read(afterAnalyticsProvider).logEvent(
      'membership_plan_changed',
      parameters: {'plan': plan.storageKey},
    );
  }

  Future<void> upgradeToPremium() => setPlan(AfterUserPlan.premium);

  Future<void> upgradeToSuper() => setPlan(AfterUserPlan.superPlan);

  Future<void> upgradeToBusiness() => setPlan(AfterUserPlan.business);

  Future<void> downgradeToFree() => setPlan(AfterUserPlan.free);
}
