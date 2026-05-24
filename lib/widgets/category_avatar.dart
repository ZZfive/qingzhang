import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 19,
      backgroundColor: AppColors.subtle,
      foregroundColor: AppColors.text,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
