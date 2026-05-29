import 'package:flutter/material.dart';

import '../theme/app_text.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(subtitle, style: AppText.muted(context)),
          ],
        ),
        toolbarHeight: 72,
        actions: actions,
      ),
      body: SafeArea(child: child),
    );
  }
}
