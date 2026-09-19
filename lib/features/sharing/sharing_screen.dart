import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/records/share_grant.dart';

class SharingScreen extends ConsumerStatefulWidget {
  const SharingScreen({super.key});

  @override
  ConsumerState<SharingScreen> createState() => _SharingScreenState();
}

class _SharingScreenState extends ConsumerState<SharingScreen> {
  String? _lastExportPreview;

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentHealthUserIdProvider);
    final repo = ref.watch(healthRecordsRepositoryProvider);
    final grants = repo.listShares(userId);
    final audit = repo.listAudit(userId).take(8).toList();

    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.sharing'))),
      body: AfterScaffoldBody(
        child: ListView(
          children: [
            AfterInlineBanner(
              message: ref.tr('sharing.disclaimer'),
              icon: Icons.ios_share_outlined,
            ),
            const SizedBox(height: 12),
            AfterButton(
              label: ref.tr('sharing.create_csv'),
              expand: true,
              onPressed: () async {
                final grant = await repo.createShare(
                  ownerUserId: userId,
                  recipientLabel: 'Clinician (demo)',
                  categories: const [ShareCategory.observations],
                  format: ShareFormat.csv,
                );
                final export = repo.exportActiveShare(
                  ownerUserId: userId,
                  grantId: grant.id,
                );
                setState(() => _lastExportPreview = export?.body);
              },
            ),
            const SizedBox(height: 8),
            AfterButton(
              label: ref.tr('sharing.create_pdf'),
              variant: AfterButtonVariant.secondary,
              expand: true,
              onPressed: () async {
                final grant = await repo.createShare(
                  ownerUserId: userId,
                  recipientLabel: 'Family (demo)',
                  categories: const [ShareCategory.observations],
                  format: ShareFormat.pdfText,
                );
                final export = repo.exportActiveShare(
                  ownerUserId: userId,
                  grantId: grant.id,
                );
                setState(() => _lastExportPreview = export?.body);
              },
            ),
            const SizedBox(height: 16),
            AfterSectionHeader(title: ref.tr('sharing.active_grants')),
            if (grants.isEmpty)
              Text(ref.tr('sharing.none'))
            else
              for (final g in grants)
                AfterCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(g.recipientLabel),
                    subtitle: Text(
                      '${g.format.name} · '
                      '${g.isActive ? ref.tr('sharing.active') : ref.tr('sharing.revoked')} · '
                      'exp ${g.expiresAt.toLocal()}',
                    ),
                    trailing: g.isActive
                        ? TextButton(
                            onPressed: () async {
                              await repo.revokeShare(
                                ownerUserId: userId,
                                grantId: g.id,
                              );
                              setState(() {});
                            },
                            child: Text(ref.tr('sharing.revoke')),
                          )
                        : null,
                  ),
                ),
            if (_lastExportPreview != null) ...[
              const SizedBox(height: 16),
              AfterSectionHeader(title: ref.tr('sharing.preview')),
              AfterCard(
                child: SelectableText(
                  _lastExportPreview!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 16),
            AfterSectionHeader(title: ref.tr('sharing.audit')),
            for (final e in audit)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(e.action),
                subtitle: Text('${e.entityType} ${e.entityId}'),
                dense: true,
              ),
          ],
        ),
      ),
    );
  }
}
