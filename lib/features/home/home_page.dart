import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final manifest = PlatformConfig.current;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AfterSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                manifest.appName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AfterSpacing.sm),
              Text(
                'Personal health Super App on After Framework.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AfterSpacing.xl),
              AfterCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AfterSpacing.sm),
                    Text('appId: ${manifest.appId}'),
                    Text('package: ${manifest.packageName}'),
                    const SizedBox(height: AfterSpacing.md),
                    Text(
                      'Vertical features ship under lib/features/. '
                      'Auth, AI, premium, and design language come from After Framework.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Powered by After Framework · Built by Overstein Labs',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
