import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap ?? () {},
      label: Text(label),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.muted,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: selected ? AppColors.primarySoft : Colors.white,
      side: BorderSide.none,
      shape: const StadiumBorder(),
    );
  }
}
