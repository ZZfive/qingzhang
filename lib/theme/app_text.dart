import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppText {
  static TextStyle muted(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(color: AppColors.muted, height: 1.35);
  }
}
