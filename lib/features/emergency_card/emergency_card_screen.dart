import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../app/security/secure_storage_service.dart';
import '../../data/providers/infrastructure_providers.dart';

final emergencyCardProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getEmergencyCard();
});

class EmergencyCardScreen extends ConsumerWidget {
  const EmergencyCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(emergencyCardProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.emergency_card'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (card) => AfterScaffoldBody(
          child: ListView(
            children: [
              AfterCard(
                variant: AfterCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.fullName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${ref.tr('emergency.blood_type')}: ${card.bloodType}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (card.organDonor) ...[
                      const SizedBox(height: 8),
                      Chip(label: Text(ref.tr('emergency.organ_donor'))),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AfterSectionHeader(title: ref.tr('emergency.contact')),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.contact_phone_outlined),
                title: Text(card.emergencyContactName),
                subtitle: Text(card.emergencyContactPhone),
              ),
              AfterSectionHeader(title: ref.tr('emergency.allergies')),
              Wrap(
                spacing: 8,
                children: [
                  for (final item in card.allergies) Chip(label: Text(item)),
                ],
              ),
              const SizedBox(height: 12),
              AfterSectionHeader(title: ref.tr('emergency.conditions')),
              Wrap(
                spacing: 8,
                children: [
                  for (final item in card.conditions) Chip(label: Text(item)),
                ],
              ),
              const SizedBox(height: 12),
              AfterSectionHeader(title: ref.tr('emergency.medications')),
              Wrap(
                spacing: 8,
                children: [
                  for (final item in card.medications) Chip(label: Text(item)),
                ],
              ),
              if (card.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(card.notes),
              ],
              const SizedBox(height: 24),
              AfterButton(
                label: ref.tr('emergency.pin_secure'),
                expand: true,
                icon: Icons.lock_outline,
                onPressed: () async {
                  final storage = ref.read(secureStorageServiceProvider);
                  await storage.writeHealthSecret(
                    'emergency_card_snapshot',
                    '${card.fullName}|${card.bloodType}|${card.emergencyContactPhone}',
                  );
                  await ref.read(afterAnalyticsProvider).logEvent(
                        'emergency_card_secured',
                      );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ref.tr('emergency.secured'))),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}