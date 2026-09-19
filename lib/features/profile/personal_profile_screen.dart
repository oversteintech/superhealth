import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/records/emergency_card_record.dart';
import '../../domain/records/health_profile_record.dart';

class PersonalProfileScreen extends ConsumerStatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  ConsumerState<PersonalProfileScreen> createState() =>
      _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends ConsumerState<PersonalProfileScreen> {
  final _name = TextEditingController();
  final _birthYear = TextEditingController();
  final _height = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _birthYear.dispose();
    _height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentHealthUserIdProvider);
    final repo = ref.watch(healthRecordsRepositoryProvider);
    final existing = repo.profileFor(userId);
    if (existing != null && _name.text.isEmpty) {
      _name.text = existing.displayName;
      _birthYear.text = existing.birthYear?.toString() ?? '';
      _height.text = existing.heightCm?.toString() ?? '';
    }

    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.profile'))),
      body: AfterScaffoldBody(
        child: ListView(
          children: [
            AfterInlineBanner(
              message: ref.tr('profile.no_national_id'),
              icon: Icons.privacy_tip_outlined,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: ref.tr('profile.display_name')),
            ),
            TextField(
              controller: _birthYear,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: ref.tr('profile.birth_year')),
            ),
            TextField(
              controller: _height,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: ref.tr('profile.height_cm')),
            ),
            const SizedBox(height: 16),
            AfterButton(
              label: ref.tr('profile.save'),
              expand: true,
              onPressed: () async {
                await repo.saveProfile(
                  HealthProfile(
                    id: existing?.id ?? 'profile-$userId',
                    ownerUserId: userId,
                    displayName: _name.text.trim().isEmpty
                        ? 'Member'
                        : _name.text.trim(),
                    birthYear: int.tryParse(_birthYear.text.trim()),
                    heightCm: double.tryParse(_height.text.trim()),
                    preferredUnitSystem: UnitSystem.metric,
                    timeZoneId: 'Europe/Istanbul',
                    languageCode: ref.read(localeCodeProvider),
                  ),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ref.tr('profile.saved'))),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyCardManageScreen extends ConsumerStatefulWidget {
  const EmergencyCardManageScreen({super.key});

  @override
  ConsumerState<EmergencyCardManageScreen> createState() =>
      _EmergencyCardManageScreenState();
}

class _EmergencyCardManageScreenState
    extends ConsumerState<EmergencyCardManageScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentHealthUserIdProvider);
    final repo = ref.watch(healthRecordsRepositoryProvider);
    final card = repo.emergencyCardFor(userId) ??
        EmergencyCardRecord(
          id: 'emergency-$userId',
          ownerUserId: userId,
          updatedAt: DateTime.now().toUtc(),
        );

    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.emergency_card'))),
      body: AfterScaffoldBody(
        child: ListView(
          children: [
            AfterInlineBanner(
              message: ref.tr('emergency.default_off'),
              icon: Icons.lock_outline,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.tr('emergency.enable')),
              value: card.enabled,
              onChanged: (v) async {
                final next = card.copyWith(
                  enabled: v,
                  updatedAt: DateTime.now().toUtc(),
                  editHistory: [
                    ...card.editHistory,
                    'enabled=$v@${DateTime.now().toUtc().toIso8601String()}',
                  ],
                );
                await repo.saveEmergencyCard(next);
                setState(() {});
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.tr('emergency.lock_screen_consent')),
              subtitle: Text(ref.tr('emergency.lock_screen_hint')),
              value: card.lockScreenSharingConsent,
              onChanged: card.enabled
                  ? (v) async {
                      final next = card.copyWith(
                        lockScreenSharingConsent: v,
                        updatedAt: DateTime.now().toUtc(),
                        editHistory: [
                          ...card.editHistory,
                          'lock=$v@${DateTime.now().toUtc().toIso8601String()}',
                        ],
                      );
                      await repo.saveEmergencyCard(next);
                      setState(() {});
                    }
                  : null,
            ),
            if (card.enabled) ...[
              const SizedBox(height: 8),
              Text('${ref.tr('emergency.updated')}: ${card.updatedAt.toLocal()}'),
            ] else
              AfterEmptyState(
                title: ref.tr('emergency.disabled_title'),
                subtitle: ref.tr('emergency.disabled_body'),
                kind: AfterEmptyKind.locked,
              ),
          ],
        ),
      ),
    );
  }
}
