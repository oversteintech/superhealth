import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../../app/family/family_stores.dart';

class SleepCrudScreen extends StatelessWidget {
  const SleepCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyCrudListPage(
      title: 'Sleep',
      listProvider: sleepStoreProvider,
      fieldKeys: const ['title', 'hours', 'quality'],
      icon: Icons.bedtime_outlined,
    );
  }
}
