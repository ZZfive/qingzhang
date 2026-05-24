import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_shell.dart';

class AccountingApp extends StatelessWidget {
  const AccountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '清账',
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}
