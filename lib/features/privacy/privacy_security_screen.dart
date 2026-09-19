import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family/family_stores.dart';
import '../../app/l10n/app_strings.dart';
import '../../app/security/secure_storage_service.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/membership/health_entitlement_matrix.dart';
import '../../domain/privacy/consent_registry.dart';
import '../../domain/privacy/data_lifecycle_service.dart';
import '../../domain/privacy/privacy_preferences.dart';
import '../../domain/records/consent_grant.dart';

final privacyPreferencesProvider = Provider<PrivacyPreferences>((ref) {
  return PrivacyPreferences(ref.watch(sharedPreferencesProvider));
});

final consentRegistryProvider = Provider<ConsentRegistry>((ref) {
  return ConsentRegistry(ref.watch(sharedPreferencesProvider));
});

final dataLifecycleProvider = Provider<DataLifecycleService>((ref) {
  return DataLifecycleService(
    prefs: ref.watch(sharedPreferencesProvider),
    records: ref.watch(healthRecordsRepositoryProvider),
  );
});

class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  ConsumerState<PrivacySecurityScreen> createState() =>
      _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  String? _exportPreview;
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(privacyPreferencesProvider);
    final userId = ref.watch(currentHealthUserIdProvider);
    final registry = ref.watch(consentRegistryProvider);
    final lifecycle = ref.watch(dataLifecycleProvider);
    final membership = ref.watch(healthMembershipProvider);
    final audit = ref
        .watch(healthRecordsRepositoryProvider)
        .listAudit(userId)
        .take(12)
        .toList();

    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('privacy.title'))),
      body: AfterScaffoldBody(
        child: ListView(
          children: [
            AfterInlineBanner(
              message: ref.tr('privacy.cloud_clarity'),
              icon: Icons.cloud_outlined,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.tr('privacy.ack_cloud')),
              value: prefs.cloudClarityAcknowledged,
              onChanged: (v) async {
                await prefs.setCloudClarityAcknowledged(v);
                setState(() {});
              },
            ),
            const Divider(),
            Text(
              '${ref.tr('privacy.plan')}: ${HealthEntitlementMatrix.tierLabel(membership.plan)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(ref.tr('privacy.records_free')),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.tr('privacy.lock')),
              subtitle: Text(ref.tr('privacy.lock_hint')),
              value: prefs.lockEnabled,
              onChanged: (v) async {
                await prefs.setLockEnabled(v);
                setState(() {});
              },
            ),
            if (prefs.lockEnabled) ...[
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: ref.tr('privacy.pin'),
                ),
              ),
              AfterButton(
                label: ref.tr('privacy.save_pin'),
                onPressed: () async {
                  final pin = _pinController.text.trim();
                  if (pin.length < 4) return;
                  await ref.read(secureStorageServiceProvider).writeHealthSecret(
                        'app_lock_pin',
                        pin,
                      );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ref.tr('privacy.pin_saved'))),
                  );
                },
              ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.tr('privacy.hide_notif')),
              value: prefs.hideNotificationBody,
              onChanged: (v) async {
                await prefs.setHideNotificationBody(v);
                setState(() {});
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.tr('privacy.block_screenshots')),
              value: prefs.blockScreenshots,
              onChanged: (v) async {
                await prefs.setBlockScreenshots(v);
                setState(() {});
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.tr('privacy.clear_signout')),
              value: prefs.clearOnSignOut,
              onChanged: (v) async {
                await prefs.setClearOnSignOut(v);
                setState(() {});
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.tr('privacy.reminders')),
              value: prefs.remindersEnabled,
              onChanged: (v) async {
                await prefs.setRemindersEnabled(v);
                await registry.record(
                  ownerUserId: userId,
                  purpose: ConsentPurpose.reminders,
                  granted: v,
                );
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            AfterSectionHeader(title: ref.tr('privacy.consent')),
            Text(
              '${ref.tr('privacy.consent_version')}: ${ConsentVersions.current}',
            ),
            AfterButton(
              label: ref.tr('privacy.renew_local_consent'),
              variant: AfterButtonVariant.secondary,
              onPressed: () async {
                await registry.record(
                  ownerUserId: userId,
                  purpose: ConsentPurpose.localHealthStore,
                  granted: true,
                );
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            AfterSectionHeader(title: ref.tr('privacy.data')),
            AfterButton(
              label: ref.tr('privacy.export'),
              expand: true,
              onPressed: () {
                setState(() => _exportPreview = lifecycle.exportJson(userId));
              },
            ),
            const SizedBox(height: 8),
            AfterButton(
              label: ref.tr('privacy.delete_all'),
              variant: AfterButtonVariant.danger,
              expand: true,
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(ref.tr('privacy.delete_confirm_title')),
                    content: Text(ref.tr('privacy.delete_confirm_body')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(ref.tr('privacy.cancel')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(ref.tr('privacy.delete_all')),
                      ),
                    ],
                  ),
                );
                if (ok != true) return;
                await lifecycle.deleteAllLocalData(userId);
                if (!mounted) return;
                setState(() => _exportPreview = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ref.tr('privacy.deleted'))),
                );
              },
            ),
            if (_exportPreview != null) ...[
              const SizedBox(height: 12),
              AfterCard(
                child: SelectableText(
                  _exportPreview!.length > 2000
                      ? '${_exportPreview!.substring(0, 2000)}…'
                      : _exportPreview!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 16),
            AfterSectionHeader(title: ref.tr('privacy.access_log')),
            if (audit.isEmpty)
              Text(ref.tr('privacy.access_empty'))
            else
              for (final e in audit)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(e.action),
                  subtitle: Text('${e.entityType} ${e.entityId}'),
                ),
          ],
        ),
      ),
    );
  }
}
