import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';

/// Overflow-safe record row: title + lines + optional action below text.
class HealthRecordCard extends StatelessWidget {
  const HealthRecordCard({
    required this.title,
    this.lines = const [],
    this.leading,
    this.trailing,
    this.actions,
    this.onTap,
    this.titleMaxLines = 2,
    this.lineMaxLines = 3,
    this.boxed = true,
    super.key,
  });

  final String title;
  final List<String> lines;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final int titleMaxLines;
  final int lineMaxLines;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  for (final line in lines.where((l) => l.trim().isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        line,
                        maxLines: lineMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Flexible(child: trailing!),
            ],
          ],
        ),
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions!,
          ),
        ],
      ],
    );
    if (!boxed) return body;
    return AfterCard(onTap: onTap, child: body);
  }
}
