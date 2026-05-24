import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/app_card.dart';
import '../widgets/flow_page.dart';
import '../widgets/key_value_row.dart';
import '../widgets/section_title.dart';

class ExportBackupPage extends StatelessWidget {
  const ExportBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowPage(
      title: '导出与备份',
      subtitle: '完整导出，不锁数据',
      child: ListView(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SectionTitle('选择导出格式'),
                SizedBox(height: 16),
                ExportFormatRow(
                  title: 'Excel .xlsx',
                  detail: '适合查看和整理',
                  selected: true,
                ),
                ExportFormatRow(title: 'CSV .csv', detail: '适合迁移到其他工具'),
                ExportFormatRow(title: 'JSON 备份包', detail: '适合完整恢复'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle('导出范围'),
                SizedBox(height: 16),
                KeyValueRow(label: '账本', value: '个人账本'),
                Divider(height: 22),
                KeyValueRow(label: '时间', value: '全部时间'),
                Divider(height: 22),
                KeyValueRow(label: '字段', value: '金额、分类、账户、备注、标签、来源'),
                Divider(height: 22),
                KeyValueRow(label: '附件', value: '不包含小票图片'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('本地备份'),
                const SizedBox(height: 8),
                Text('生成带版本号的恢复包，可重新导入到新设备。', style: AppText.muted(context)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text('导出文件'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.folder_zip_outlined),
            label: const Text('生成备份包'),
          ),
        ],
      ),
    );
  }
}

class ExportFormatRow extends StatelessWidget {
  const ExportFormatRow({
    super.key,
    required this.title,
    required this.detail,
    this.selected = false,
  });

  final String title;
  final String detail;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: selected ? AppColors.primary : AppColors.muted,
      ),
      title: Text(title),
      trailing: Text(detail, style: AppText.muted(context)),
    );
  }
}
