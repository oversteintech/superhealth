import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../../app/family/family_stores.dart';

class WeightCrudScreen extends StatelessWidget {
  const WeightCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyCrudListPage(
      title: 'Weight',
      listProvider: weightStoreProvider,
      fieldKeys: const ['title', 'value', 'unit'],
      icon: Icons.monitor_weight,
    );
  }
}
