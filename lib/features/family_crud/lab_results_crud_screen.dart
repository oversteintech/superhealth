import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../../app/family/family_stores.dart';

class LabResultsCrudScreen extends StatelessWidget {
  const LabResultsCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyCrudListPage(
      title: 'Lab Results',
      listProvider: labResultsStoreProvider,
      fieldKeys: const ['title', 'status', 'date'],
      icon: Icons.science_outlined,
    );
  }
}
