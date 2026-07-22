import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../../app/family/family_stores.dart';

class MedicationsCrudScreen extends StatelessWidget {
  const MedicationsCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyCrudListPage(
      title: 'Medications',
      listProvider: medicationsStoreProvider,
      fieldKeys: const ['name', 'dosage', 'schedule'],
      icon: Icons.medication_outlined,
    );
  }
}
