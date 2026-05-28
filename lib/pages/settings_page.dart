import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/category_visuals.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/section_title.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.expenseCategoryIcons,
    required this.incomeCategoryIcons,
    required this.onAddCategory,
    required this.onManageCategory,
    required this.onOpenImport,
    required this.onOpenExport,
  });

  final List<String> expenseCategories;
  final List<String> incomeCategories;
  final Map<String, String> expenseCategoryIcons;
  final Map<String, String> incomeCategoryIcons;
  final ValueChanged<EntryType> onAddCategory;
  final void Function(EntryType type, String category) onManageCategory;
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
            type: EntryType.expense,
            categories: expenseCategories,
            categoryIcons: expenseCategoryIcons,
            onAdd: () => onAddCategory(EntryType.expense),
            onManage: onManageCategory,
          ),
          const SizedBox(height: 16),
          CategorySettingsCard(
            title: '收入分类',
            type: EntryType.income,
            categories: incomeCategories,
            categoryIcons: incomeCategoryIcons,
            onAdd: () => onAddCategory(EntryType.income),
            onManage: onManageCategory,
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
}

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({
    super.key,
    required this.type,
    this.initialName,
    this.initialIconKey,
  });

  final EntryType type;
  final String? initialName;
  final String? initialIconKey;

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  late final TextEditingController _controller;
  late String _iconKey;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _iconKey =
        widget.initialIconKey ??
        inferCategoryIconKey(widget.initialName ?? '', type: widget.type);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.initialName == null ? '新增' : '编辑';
    final typeName = widget.type == EntryType.income ? '收入' : '支出';
    return AlertDialog(
      title: Text('$action$typeName分类'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: '输入分类名称'),
              textInputAction: TextInputAction.done,
              onChanged: _syncIconFromName,
              onSubmitted: _submit,
            ),
            const SizedBox(height: 14),
            IconPresetPicker(
              selectedIconKey: _iconKey,
              onSelected: (value) => setState(() => _iconKey = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('保存')),
      ],
    );
  }

  void _submit([String? value]) {
    Navigator.of(context).pop(
      CategoryEditResult(name: value ?? _controller.text, iconKey: _iconKey),
    );
  }

  void _syncIconFromName(String value) {
    if (widget.initialName != null) return;
    final inferred = inferCategoryIconKey(value, type: widget.type);
    if (inferred != _iconKey) setState(() => _iconKey = inferred);
  }
}

class CategoryEditResult {
  const CategoryEditResult({required this.name, required this.iconKey});

  final String name;
  final String iconKey;
}

class IconPresetPicker extends StatelessWidget {
  const IconPresetPicker({
    super.key,
    required this.selectedIconKey,
    required this.onSelected,
  });

  final String selectedIconKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: GridView.builder(
        itemCount: categoryVisualPresets.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final visual = categoryVisualPresets[index];
          final selected = visual.key == selectedIconKey;
          return InkWell(
            onTap: () => onSelected(visual.key),
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: selected
                  ? visual.color
                  : visual.color.withValues(alpha: .22),
              child: Icon(
                visual.icon,
                color: selected ? Colors.white : visual.color,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}

enum CategoryAction { edit, delete }

class CategoryActionsSheet extends StatelessWidget {
  const CategoryActionsSheet({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(category),
              subtitle: const Text('分类操作'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('编辑分类'),
              onTap: () => Navigator.of(context).pop(CategoryAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('删除分类'),
              textColor: AppColors.expense,
              iconColor: AppColors.expense,
              onTap: () => Navigator.of(context).pop(CategoryAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class CategorySettingsCard extends StatelessWidget {
  const CategorySettingsCard({
    super.key,
    required this.title,
    required this.type,
    required this.categories,
    required this.categoryIcons,
    required this.onAdd,
    required this.onManage,
  });

  final String title;
  final EntryType type;
  final List<String> categories;
  final Map<String, String> categoryIcons;
  final VoidCallback onAdd;
  final void Function(EntryType type, String category) onManage;

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
                CategoryIconItem(
                  category: category,
                  type: type,
                  iconKey: categoryIcons[category],
                  onLongPress: () => onManage(type, category),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryIconItem extends StatelessWidget {
  const CategoryIconItem({
    super.key,
    required this.category,
    required this.type,
    required this.iconKey,
    required this.onLongPress,
  });

  final String category;
  final EntryType type;
  final String? iconKey;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final visual = categoryVisual(category, type: type, iconKey: iconKey);
    return GestureDetector(
      onLongPress: onLongPress,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: visual.color,
              child: Icon(visual.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 5),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppText.muted(context).copyWith(fontSize: 12),
            ),
          ],
        ),
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
