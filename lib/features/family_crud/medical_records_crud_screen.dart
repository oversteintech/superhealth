import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../../app/family/family_stores.dart';

class MedicalRecordsCrudScreen extends StatelessWidget {
  const MedicalRecordsCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyCrudListPage(
      title: 'Medical Records',
      listProvider: medicalRecordsStoreProvider,
      fieldKeys: const ['title', 'category', 'notes'],
      icon: Icons.folder_outlined,
    );
  }
}
