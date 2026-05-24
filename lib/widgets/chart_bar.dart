import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ChartBar extends StatelessWidget {
  const ChartBar({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
