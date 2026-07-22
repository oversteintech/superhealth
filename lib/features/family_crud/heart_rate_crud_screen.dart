import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../../app/family/family_stores.dart';

class HeartRateCrudScreen extends StatelessWidget {
  const HeartRateCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyCrudListPage(
      title: 'Heart Rate',
      listProvider: heartRateStoreProvider,
      fieldKeys: const ['title', 'value', 'unit'],
      icon: Icons.favorite_outlined,
    );
  }
}
