import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../family_crud/family_hub_screens.dart';

/// Profile / deep-link entry — same Garage-parity accordion as the Settings tab.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('settings.title'))),
      body: const FamilySettingsTab(),
    );
  }
}
