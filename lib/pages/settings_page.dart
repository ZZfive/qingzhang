import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/section_title.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.onOpenImport,
    required this.onOpenExport,
  });

  final VoidCallback onOpenImport;
  final VoidCallback onOpenExport;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '设置',
      subtitle: '数据属于你，可以随时带走',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('数据与备份'),
                const SizedBox(height: 8),
                Text('默认本地保存；导入、导出、备份永久免费。', style: AppText.muted(context)),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onOpenImport,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('导入 Timi 记账数据'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onOpenExport,
                  icon: const Icon(Icons.download),
                  label: const Text('导出 / 备份'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: const [
                SettingsRow(
                  title: '导出 CSV / Excel / JSON',
                  detail: '完整导出',
                  icon: Icons.table_view_outlined,
                ),
                SettingsRow(
                  title: '本地备份',
                  detail: '生成可恢复备份包',
                  icon: Icons.folder_zip_outlined,
                ),
                SettingsRow(
                  title: '应用锁',
                  detail: 'Face ID / 密码',
                  icon: Icons.lock_outline,
                ),
                SettingsRow(
                  title: '多账本',
                  detail: '个人、旅行、家庭',
                  icon: Icons.library_books_outlined,
                ),
                SettingsRow(
                  title: '搜索与复盘',
                  detail: '金额、备注、分类、日期',
                  icon: Icons.manage_search,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    required this.detail,
    required this.icon,
    this.showDivider = true,
  });

  final String title;
  final String detail;
  final IconData icon;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          trailing: Text(detail, style: AppText.muted(context)),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
