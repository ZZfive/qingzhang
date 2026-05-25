import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/section_title.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.onAddCategory,
    required this.onOpenImport,
    required this.onOpenExport,
  });

  final List<String> expenseCategories;
  final List<String> incomeCategories;
  final void Function(EntryType type, String category) onAddCategory;
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
          CategorySettingsCard(
            title: '支出分类',
            categories: expenseCategories,
            onAdd: () => _showAddCategoryDialog(context, EntryType.expense),
          ),
          const SizedBox(height: 16),
          CategorySettingsCard(
            title: '收入分类',
            categories: incomeCategories,
            onAdd: () => _showAddCategoryDialog(context, EntryType.income),
          ),
          const SizedBox(height: 16),
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

  Future<void> _showAddCategoryDialog(
    BuildContext context,
    EntryType type,
  ) async {
    final controller = TextEditingController();
    final title = type == EntryType.income ? '新增收入分类' : '新增支出分类';
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入分类名称'),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null) onAddCategory(type, name);
  }
}

class CategorySettingsCard extends StatelessWidget {
  const CategorySettingsCard({
    super.key,
    required this.title,
    required this.categories,
    required this.onAdd,
  });

  final String title;
  final List<String> categories;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SectionTitle(title)),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: '新增分类',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in categories)
                Chip(
                  label: Text(category),
                  backgroundColor: AppColors.primarySoft,
                  side: BorderSide.none,
                ),
            ],
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
