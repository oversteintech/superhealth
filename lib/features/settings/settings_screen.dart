import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/app_config.dart';
import '../../app/config/feature_flag_keys.dart';
import '../../app/l10n/app_strings.dart';
import '../../app/security/secure_storage_service.dart';
import '../../app/theme/theme_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  var _reminders = true;
  var _analyticsOptIn = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeCodeProvider);
    final flags = ref.watch(afterFeatureFlagsProvider);
    final offlineSync = flags.isEnabled(
      FeatureFlagKeys.offlineSync,
      defaultValue: true,
    );

    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('settings.title'))),
      body: AfterScaffoldBody(
        child: ListView(
          children: [
            AfterSectionHeader(title: ref.tr('settings.appearance')),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(ref.tr('settings.theme_system')),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(ref.tr('settings.theme_light')),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(ref.tr('settings.theme_dark')),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) {
                ref.read(themeModeProvider.notifier).setMode(value.first);
              },
            ),
            const SizedBox(height: 24),
            AfterSectionHeader(title: ref.tr('settings.language')),
            DropdownButtonFormField<String>(
              value: AfterSupportedLocales.isSupported(locale)
                  ? locale
                  : AfterSupportedLocales.fallbackLanguage,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                for (final code in AfterSupportedLocales.languageCodes)
                  DropdownMenuItem(
                    value: code,
                    child: Text(AfterSupportedLocales.displayNameFor(code)),
                  ),
              ],
              onChanged: (code) async {
                if (code == null) return;
                ref.read(localeCodeProvider.notifier).setLocale(code);
                final prefs = ref.read(afterSharedPreferencesProvider);
                await prefs.setString('superhealth.locale', code);
              },
            ),
            const SizedBox(height: 24),
            AfterSectionHeader(title: ref.tr('settings.notifications')),
            AfterSwitchTile(
              title: ref.tr('settings.medication_reminders'),
              value: _reminders &&
                  flags.isEnabled(
                    FeatureFlagKeys.medicationReminders,
                    defaultValue: true,
                  ),
              onChanged: (value) => setState(() => _reminders = value),
            ),
            AfterSwitchTile(
              title: ref.tr('settings.analytics'),
              subtitle: ref.tr('settings.analytics_subtitle'),
              value: _analyticsOptIn,
              onChanged: (value) async {
                setState(() => _analyticsOptIn = value);
                await ref.read(afterAnalyticsProvider).setUserProperty(
                      'analytics_opt_in',
                      value ? 'true' : 'false',
                    );
              },
            ),
            const SizedBox(height: 24),
            AfterSectionHeader(title: ref.tr('settings.privacy')),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.tr('settings.offline_sync')),
              subtitle: Text(offlineSync ? 'Enabled' : 'Disabled'),
              trailing: const Icon(Icons.cloud_sync_outlined),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.tr('settings.secure_storage_probe')),
              onTap: () async {
                final storage = ref.read(secureStorageServiceProvider);
                await storage.writeHealthSecret('probe', 'ok');
                final value = await storage.readHealthSecret('probe');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Secure storage: $value')),
                );
              },
            ),
            const SizedBox(height: 24),
            AfterSectionHeader(title: ref.tr('settings.about')),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppConfig.appName),
              subtitle: Text(
                'v${AppConfig.versionName}+${AppConfig.versionCode}\n'
                '${AppConfig.privacyUrl}',
              ),
              isThreeLine: true,
            ),
          ],
        ),
      ),
    );
  }
}