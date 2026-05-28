import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../theme/app_colors.dart';

class CategoryVisual {
  const CategoryVisual({
    required this.key,
    required this.icon,
    required this.color,
  });

  final String key;
  final IconData icon;
  final Color color;
}

const categoryVisualPresets = [
  CategoryVisual(
    key: 'general',
    icon: Icons.sell_outlined,
    color: AppColors.primary,
  ),
  CategoryVisual(key: 'food', icon: Icons.restaurant, color: Color(0xFF7DB7AE)),
  CategoryVisual(
    key: 'traffic',
    icon: Icons.directions_subway,
    color: Color(0xFF4E79A7),
  ),
  CategoryVisual(
    key: 'shopping',
    icon: Icons.shopping_bag_outlined,
    color: Color(0xFFE15759),
  ),
  CategoryVisual(
    key: 'home',
    icon: Icons.home_outlined,
    color: Color(0xFF8B6F47),
  ),
  CategoryVisual(
    key: 'beauty',
    icon: Icons.spa_outlined,
    color: Color(0xFFD86BA6),
  ),
  CategoryVisual(
    key: 'daily',
    icon: Icons.local_laundry_service_outlined,
    color: Color(0xFF6C8EBF),
  ),
  CategoryVisual(
    key: 'entertainment',
    icon: Icons.mic_external_on,
    color: Color(0xFFF39A38),
  ),
  CategoryVisual(key: 'snack', icon: Icons.icecream, color: Color(0xFFA77B65)),
  CategoryVisual(
    key: 'medical',
    icon: Icons.medical_services_outlined,
    color: Color(0xFF4D9B6F),
  ),
  CategoryVisual(
    key: 'study',
    icon: Icons.menu_book_outlined,
    color: Color(0xFF6D6BCB),
  ),
  CategoryVisual(
    key: 'travel',
    icon: Icons.flight_takeoff_outlined,
    color: Color(0xFF3F88C5),
  ),
  CategoryVisual(
    key: 'digital',
    icon: Icons.devices_outlined,
    color: Color(0xFF5B6C7D),
  ),
  CategoryVisual(
    key: 'gift',
    icon: Icons.card_giftcard_outlined,
    color: Color(0xFFE76F51),
  ),
  CategoryVisual(
    key: 'shipping',
    icon: Icons.local_shipping_outlined,
    color: Color(0xFF8A6D3B),
  ),
  CategoryVisual(
    key: 'fitness',
    icon: Icons.fitness_center,
    color: Color(0xFF2A9D8F),
  ),
  CategoryVisual(
    key: 'phone',
    icon: Icons.phone_iphone_outlined,
    color: Color(0xFF577590),
  ),
  CategoryVisual(
    key: 'income',
    icon: Icons.payments_outlined,
    color: AppColors.income,
  ),
  CategoryVisual(
    key: 'bonus',
    icon: Icons.emoji_events_outlined,
    color: Color(0xFFD4A22A),
  ),
  CategoryVisual(
    key: 'finance',
    icon: Icons.trending_up,
    color: Color(0xFF16803C),
  ),
  CategoryVisual(
    key: 'work',
    icon: Icons.work_outline,
    color: Color(0xFF476A6F),
  ),
  CategoryVisual(
    key: 'reimburse',
    icon: Icons.receipt_long_outlined,
    color: Color(0xFF467599),
  ),
];

CategoryVisual categoryVisual(
  String category, {
  EntryType? type,
  String? iconKey,
}) {
  final key = iconKey ?? inferCategoryIconKey(category, type: type);
  return categoryVisualPresets.firstWhere(
    (preset) => preset.key == key,
    orElse: () => categoryVisualPresets.first,
  );
}

String inferCategoryIconKey(String category, {EntryType? type}) {
  if (category.contains('餐') ||
      category.contains('用餐') ||
      category.contains('食材')) {
    return 'food';
  }
  if (category.contains('交通') || category.contains('地铁')) return 'traffic';
  if (category.contains('服饰') || category.contains('购物')) return 'shopping';
  if (category.contains('住房') ||
      category.contains('居住') ||
      category.contains('住宿')) {
    return 'home';
  }
  if (category.contains('丽人')) return 'beauty';
  if (category.contains('日用品')) return 'daily';
  if (category.contains('娱乐')) return 'entertainment';
  if (category.contains('零食') || category.contains('水果')) return 'snack';
  if (category.contains('医疗')) return 'medical';
  if (category.contains('学习')) return 'study';
  if (category.contains('旅游')) return 'travel';
  if (category.contains('数码')) return 'digital';
  if (category.contains('红包') || category.contains('人情')) return 'gift';
  if (category.contains('快递') || category.contains('物流')) return 'shipping';
  if (category.contains('健身')) return 'fitness';
  if (category.contains('通讯')) return 'phone';
  if (category.contains('工资')) return 'income';
  if (category.contains('奖金')) return 'bonus';
  if (category.contains('理财')) return 'finance';
  if (category.contains('兼职')) return 'work';
  if (category.contains('报销')) return 'reimburse';
  if (type == EntryType.income) return 'income';
  return 'general';
}
