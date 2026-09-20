import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AfterCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AfterSectionHeader(
            title: title,
            subtitle: subtitle,
          ),
          if (trailing != null) ...[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: trailing,
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
