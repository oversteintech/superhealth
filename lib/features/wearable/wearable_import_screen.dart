import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/import/demo_wearable_import_adapter.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/import/wearable_import_port.dart';
import '../../domain/records/audit_event.dart';

final wearableImportPortProvider = Provider<WearableImportPort>((ref) {
  return DemoWearableImportAdapter();
});

class WearableImportScreen extends ConsumerStatefulWidget {
  const WearableImportScreen({super.key});

  @override
  ConsumerState<WearableImportScreen> createState() =>
      _WearableImportScreenState();
}

class _WearableImportScreenState extends ConsumerState<WearableImportScreen> {
  var _lastCount = 0;
  var _message = '';

  @override
  Widget build(BuildContext context) {
    final port = ref.watch(wearableImportPortProvider);
    final userId = ref.watch(currentHealthUserIdProvider);
    final repo = ref.watch(healthRecordsRepositoryProvider);

    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.wearable_import'))),
      body: AfterScaffoldBody(
        child: ListView(
          children: [
            AfterInlineBanner(
              message: port.isDemo
                  ? ref.tr('wearable.demo_banner')
                  : ref.tr('wearable.live_banner'),
              icon: Icons.watch_outlined,
            ),
            const SizedBox(height: 12),
            Text('${ref.tr('wearable.platform')}: ${port.platformId}'),
            if (port.isDemo) Chip(label: Text(ref.tr('wearable.demo_chip'))),
            const SizedBox(height: 16),
            AfterButton(
              label: ref.tr('wearable.request_permission'),
              expand: true,
              onPressed: () async {
                await port.requestPermission();
                setState(() => _message = ref.tr('wearable.permission_ok'));
              },
            ),
            const SizedBox(height: 8),
            AfterButton(
              label: ref.tr('wearable.import'),
              variant: AfterButtonVariant.secondary,
              expand: true,
              onPressed: () async {
                final since =
                    DateTime.now().toUtc().subtract(const Duration(days: 7));
                final raw = await port.importSince(
                  ownerUserId: userId,
                  sinceUtc: since,
                );
                final existing = {
                  for (final o in repo.listObservations(userId))
                    WearableDeduper.fingerprint(o),
                };
                var imported = 0;
                for (final o in raw) {
                  final fp = WearableDeduper.fingerprint(o);
                  if (existing.contains(fp)) continue;
                  await repo.upsertObservation(o);
                  existing.add(fp);
                  imported++;
                }
                await repo.appendAudit(
                  AuditEvent(
                    id: const Uuid().v4(),
                    ownerUserId: userId,
                    action: 'wearable.import',
                    occurredAt: DateTime.now().toUtc(),
                    entityType: 'observations',
                    metadata: {
                      'platform': port.platformId,
                      'demo': '${port.isDemo}',
                      'count': '$imported',
                    },
                  ),
                );
                setState(() {
                  _lastCount = imported;
                  _message = ref.tr(
                    'wearable.imported',
                    args: {'count': '$imported'},
                  );
                });
              },
            ),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(_message),
              Text('${ref.tr('wearable.last_count')}: $_lastCount'),
            ],
          ],
        ),
      ),
    );
  }
}
