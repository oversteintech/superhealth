import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';

class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AfterEmptyState(
      title: title,
      subtitle: message,
      icon: Icons.health_and_safety_outlined,
    );
  }
}