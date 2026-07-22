import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({required this.onFinished, super.key});

  final Future<void> Function() onFinished;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  var _index = 0;

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
      titleKey: 'onboarding.page3_title',
      bodyKey: 'onboarding.page3_body',
      icon: Icons.auto_awesome_outlined,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                label: _index == _pages.length - 1
                    ? ref.tr('onboarding.get_started')
                    : ref.tr('onboarding.next'),
                expand: true,
                onPressed: () async {
                  if (_index < _pages.length - 1) {
                    await _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  } else {
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