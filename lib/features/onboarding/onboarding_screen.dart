import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/l10n/app_strings.dart';
import '../../domain/records/consent_grant.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({required this.onFinished, super.key});

  final Future<void> Function() onFinished;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  var _index = 0;
  var _localStoreConsent = false;
  var _remindersConsent = false;

  late final _pages = [
    (
      titleKey: 'onboarding.page1_title',
      bodyKey: 'onboarding.page1_body',
      icon: Icons.favorite_outline,
    ),
    (
      titleKey: 'onboarding.page2_title',
      bodyKey: 'onboarding.page2_body',
      icon: Icons.medication_outlined,
    ),
    (
      titleKey: 'onboarding.consent_title',
      bodyKey: 'onboarding.consent_body',
      icon: Icons.privacy_tip_outlined,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _persistConsents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('super_health.consent.local_store', _localStoreConsent);
    await prefs.setBool('super_health.consent.reminders', _remindersConsent);
    await prefs.setString(
      'super_health.consent.version',
      'p0-1',
    );
    // Record purpose enums for audit (values only — no clinical payload).
    final recorded = [
      ConsentPurpose.localHealthStore.name,
      if (_remindersConsent) ConsentPurpose.reminders.name,
    ];
    await prefs.setStringList('super_health.consent.purposes', recorded);
  }

  @override
  Widget build(BuildContext context) {
    final isConsentPage = _index == _pages.length - 1;
    final canFinish = !isConsentPage || _localStoreConsent;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  if (i == _pages.length - 1) {
                    return Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.tr(page.titleKey),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          Text(ref.tr(page.bodyKey)),
                          const SizedBox(height: 24),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _localStoreConsent,
                            onChanged: (v) => setState(
                              () => _localStoreConsent = v ?? false,
                            ),
                            title: Text(ref.tr('onboarding.consent_local')),
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _remindersConsent,
                            onChanged: (v) => setState(
                              () => _remindersConsent = v ?? false,
                            ),
                            title: Text(ref.tr('onboarding.consent_reminders')),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page.icon,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          ref.tr(page.titleKey),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ref.tr(page.bodyKey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: AfterButton(
                label: isConsentPage
                    ? ref.tr('onboarding.get_started')
                    : ref.tr('onboarding.next'),
                expand: true,
                onPressed: !canFinish
                    ? null
                    : () async {
                        if (_index < _pages.length - 1) {
                          await _controller.nextPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                          );
                        } else {
                          await _persistConsents();
                          await widget.onFinished();
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
