import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../../app/family/family_stores.dart';

class NutritionCrudScreen extends StatelessWidget {
  const NutritionCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyCrudListPage(
      title: 'Nutrition',
      listProvider: nutritionStoreProvider,
      fieldKeys: const ['title', 'calories', 'notes'],
      icon: Icons.restaurant_outlined,
    );
  }
}
