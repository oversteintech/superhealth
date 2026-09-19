import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/records/health_document.dart';

class DocumentsVaultScreen extends ConsumerStatefulWidget {
  const DocumentsVaultScreen({super.key});

  @override
  ConsumerState<DocumentsVaultScreen> createState() =>
      _DocumentsVaultScreenState();
}

class _DocumentsVaultScreenState extends ConsumerState<DocumentsVaultScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentHealthUserIdProvider);
    final repo = ref.watch(healthRecordsRepositoryProvider);
    final items = repo.listDocuments(userId);

    return Scaffold(
      appBar: AfterAppBar(
        title: Text(ref.tr('features.documents')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await repo.upsertDocument(
                HealthDocument(
                  id: const Uuid().v4(),
                  ownerUserId: userId,
                  title: 'Lab panel (sample)',
                  kind: HealthDocumentKind.labResult,
                  documentDate: DateTime.now().toUtc(),
                  localUri: 'local://demo/lab.pdf',
                  tags: const ['demo'],
                  mimeType: 'application/pdf',
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? AfterEmptyState(
              title: ref.tr('documents.empty_title'),
              subtitle: ref.tr('documents.empty_body'),
            )
          : AfterScaffoldBody(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final d = items[i];
                  return AfterCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(d.title),
                      subtitle: Text(
                        '${d.kind.name} · ${d.documentDate.toLocal()}',
                      ),
                      trailing: IconButton(
                        tooltip: ref.tr('documents.delete'),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await repo.deleteDocument(
                            ownerUserId: userId,
                            id: d.id,
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
