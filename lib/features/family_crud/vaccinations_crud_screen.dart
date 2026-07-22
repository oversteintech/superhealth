import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../../app/family/family_stores.dart';

class VaccinationsCrudScreen extends StatelessWidget {
  const VaccinationsCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyCrudListPage(
      title: 'Vaccinations',
      listProvider: vaccinationsStoreProvider,
      fieldKeys: const ['title', 'date', 'next'],
      icon: Icons.vaccines,
    );
  }
}
