import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../../app/family/family_stores.dart';

class EmergencyCrudScreen extends StatelessWidget {
  const EmergencyCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyCrudListPage(
      title: 'Emergency',
      listProvider: emergencyStoreProvider,
      fieldKeys: const ['title', 'name', 'phone'],
      icon: Icons.emergency_outlined,
    );
  }
}
