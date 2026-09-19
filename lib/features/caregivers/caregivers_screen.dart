import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/records/care_circle_member.dart';

class CaregiversScreen extends ConsumerStatefulWidget {
  const CaregiversScreen({super.key});

  @override
  ConsumerState<CaregiversScreen> createState() => _CaregiversScreenState();
}

class _CaregiversScreenState extends ConsumerState<CaregiversScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentHealthUserIdProvider);
    final repo = ref.watch(healthRecordsRepositoryProvider);
    final members = repo.listCareMembers(userId);

    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.caregivers'))),
      body: AfterScaffoldBody(
        child: ListView(
          children: [
            AfterInlineBanner(
              message: ref.tr('caregivers.default_no_full_access'),
              icon: Icons.family_restroom,
            ),
            const SizedBox(height: 12),
            AfterButton(
              label: ref.tr('caregivers.invite'),
              expand: true,
              onPressed: () async {
                await repo.inviteCareMember(
                  ownerUserId: userId,
                  memberLabel: 'Parent (demo)',
                  role: CareMemberRole.caregiver,
                  visibleFields: const [CareFieldVisibility.appointments],
                );
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            if (members.isEmpty)
              AfterEmptyState(
                title: ref.tr('caregivers.empty_title'),
                subtitle: ref.tr('caregivers.empty_body'),
              )
            else
              for (final m in members)
                AfterCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(m.memberLabel),
                    subtitle: Text(
                      '${m.role.name} · fields: '
                      '${m.visibleFields.isEmpty ? ref.tr('caregivers.none') : m.visibleFields.map((e) => e.name).join(', ')}'
                      '${m.hasFullAccess ? ' · FULL' : ''}',
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        await repo.revokeCareMember(
                          ownerUserId: userId,
                          memberId: m.id,
                        );
                        setState(() {});
                      },
                      child: Text(ref.tr('caregivers.revoke')),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
