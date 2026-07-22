import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family/family_stores.dart';

/// Garage-parity membership: Free / Silver / Gold / Business.
class MembershipScreen extends ConsumerWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(healthMembershipProvider);
    return FamilyMembershipPlansScreen(
      config: healthChrome,
      membership: membership,
      onSetPlan: (plan) => ref.read(healthMembershipProvider.notifier).setPlan(plan),
    );
  }
}
