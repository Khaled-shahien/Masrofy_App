import 'package:flutter/material.dart';

/// A stable serializable key paired with its Material icon.
@immutable
class CategoryIconOption {
  const CategoryIconOption(this.key, this.icon);

  final String key;
  final IconData icon;
}

/// Icons offered for built-in and custom categories.
const categoryIconOptions = <CategoryIconOption>[
  CategoryIconOption('restaurant', Icons.restaurant_outlined),
  CategoryIconOption('local_cafe', Icons.local_cafe_outlined),
  CategoryIconOption('shopping_basket', Icons.shopping_basket_outlined),
  CategoryIconOption('directions_transit', Icons.directions_transit_outlined),
  CategoryIconOption('local_taxi', Icons.local_taxi_outlined),
  CategoryIconOption('checkroom', Icons.checkroom_outlined),
  CategoryIconOption('medical_services', Icons.medical_services_outlined),
  CategoryIconOption('home', Icons.home_outlined),
  CategoryIconOption('receipt_long', Icons.receipt_long_outlined),
  CategoryIconOption('person_transfer', Icons.people_outline),
  CategoryIconOption('content_cut', Icons.content_cut_outlined),
  CategoryIconOption('subscriptions', Icons.subscriptions_outlined),
  CategoryIconOption('celebration', Icons.celebration_outlined),
  CategoryIconOption('payments', Icons.payments_outlined),
  CategoryIconOption('work', Icons.work_outline),
  CategoryIconOption('redeem', Icons.redeem_outlined),
  CategoryIconOption('school', Icons.school_outlined),
  CategoryIconOption('fitness_center', Icons.fitness_center_outlined),
  CategoryIconOption('pets', Icons.pets_outlined),
  CategoryIconOption('category', Icons.category_outlined),
];

/// Accessible swatches used by the custom category editor.
const categoryColorValues = <int>[
  0xFF006D77,
  0xFF2A9D8F,
  0xFFE76F51,
  0xFFF4A261,
  0xFFB08900,
  0xFF3A71C1,
  0xFF5E60CE,
  0xFF7B2CBF,
  0xFFC2255C,
  0xFF657153,
  0xFF795548,
  0xFF455A64,
];

/// Resolves a persisted key without relying on unstable font code points.
IconData categoryIconFor(String key) {
  for (final option in categoryIconOptions) {
    if (option.key == key) {
      return option.icon;
    }
  }
  return switch (key) {
    'localCafe' => Icons.local_cafe_outlined,
    'directionsBus' => Icons.directions_transit_outlined,
    'medicalServices' => Icons.medical_services_outlined,
    'homeRepairService' => Icons.home_outlined,
    'receiptLong' => Icons.receipt_long_outlined,
    'people' => Icons.people_outline,
    'contentCut' => Icons.content_cut_outlined,
    _ => Icons.category_outlined,
  };
}
