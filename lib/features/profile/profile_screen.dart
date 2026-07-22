import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../app/membership/membership_controller.dart';
import '../../data/providers/infrastructure_providers.dart';
import '../emergency_card/emergency_card_screen.dart';
import '../membership/membership_screen.dart';
import '../settings/settings_screen.dart';

final healthProfileProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getProfile();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(healthProfileProvider);
    final session = ref.watch(afterAuthRepositoryProvider);
    final membership = ref.watch(membershipControllerProvider);
    final authSession = ref.watch(afterAuthSessionProvider).asData?.value;
    final signedInEmail = authSession?.user?.email;
    final isSuperAdmin = membership.isSuperAdmin ||
        AfterSuperAdmin.isSuperAdminEmail(signedInEmail);

    return AfterScaffoldBody(
      child: ListView(
        children: [
          profileAsync.when(
            loading: () => const AfterLoading(),
            error: (e, _) => Text('$e'),
            data: (profile) => AfterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (signedInEmail != null && signedInEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      signedInEmail,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${profile.ageYears} yrs · ${profile.bloodType} · BMI ${profile.bmi.toStringAsFixed(1)}',
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      isSuperAdmin
                          ? AfterMembershipBadge.admin
                          : membership.badge,
                    ),
                  ),
                  if (profile.conditions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(profile.conditions.join(', ')),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.emergency_outlined),
            title: Text(ref.tr('features.emergency_card')),
            subtitle: Text(ref.tr('features.emergency_card_sub')),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EmergencyCardScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(ref.tr('profile.membership')),
            subtitle: Text(membership.badge),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MembershipScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(ref.tr('profile.settings')),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(ref.tr('profile.sign_out')),
            onTap: () async {
              await session.signOut();
              await ref.read(afterAnalyticsProvider).logEvent('sign_out');
            },
          ),
        ],
      ),
    );
  }
}