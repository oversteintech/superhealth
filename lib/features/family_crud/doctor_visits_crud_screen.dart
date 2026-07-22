import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../../app/family/family_stores.dart';

class DoctorVisitsCrudScreen extends StatelessWidget {
  const DoctorVisitsCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyCrudListPage(
      title: 'Doctor Visits',
      listProvider: doctorVisitsStoreProvider,
      fieldKeys: const ['title', 'clinician', 'when'],
      icon: Icons.event_outlined,
    );
  }
}
