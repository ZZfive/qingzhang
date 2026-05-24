import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../models/ledger_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/app_card.dart';
import '../widgets/app_chip.dart';
import '../widgets/flow_page.dart';
import '../widgets/key_value_row.dart';
import '../widgets/section_title.dart';
import 'ledger_timeline_page.dart';

class ImportSourcePage extends StatelessWidget {
  const ImportSourcePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowPage(
      title: '导入数据',
      subtitle: '先选择来源，后续可预览再入库',
      child: Column(
        children: [
          const ImportSourceCard(
            title: 'Timi 记账',
            description: '适配付费导出的 Excel / CSV 文件，支持分类映射与防重复。',
            selected: true,
          ),
          const SizedBox(height: 14),
          const ImportSourceCard(title: '通用 Excel', description: '手动映射字段'),
          const SizedBox(height: 14),
          const ImportSourceCard(title: '通用 CSV', description: '适合其他记账软件迁移'),
          const Spacer(),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ImportPreviewPage()),
            ),
            child: const Text('选择文件'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () {}, child: const Text('查看导入说明')),
        ],
      ),
    );
  }
}

class ImportPreviewPage extends StatelessWidget {
  const ImportPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowPage(
      title: '导入预览',
      subtitle: 'timi_export_2026.xlsx',
      child: ListView(
        children: [
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('共识别', style: AppText.muted(context)),
                      const SizedBox(height: 6),
                      Text(
                        '8,426 条',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '支出 7,980',
                      style: TextStyle(color: AppColors.expense),
                    ),
                    SizedBox(height: 8),
                    Text('收入 421', style: TextStyle(color: AppColors.income)),
                    SizedBox(height: 8),
                    Text('转账 25', style: TextStyle(color: AppColors.muted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('需要处理'),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: const [
                IssueRow(title: '12 个未知分类', detail: '进入分类映射处理', warning: true),
                IssueRow(title: '3 条日期格式异常', detail: '导入前确认', warning: true),
                IssueRow(title: '0 条重复记录', detail: '已按指纹检查'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('样例流水'),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                LedgerEntryTile(
                  entry: LedgerEntry(
                    title: '午餐',
                    category: 'Timi · 餐饮',
                    amount: 38,
                    type: EntryType.expense,
                    date: DateTime(2026, 5, 14),
                  ),
                ),
                LedgerEntryTile(
                  entry: LedgerEntry(
                    title: '工资',
                    category: 'Timi · 工资',
                    amount: 18000,
                    type: EntryType.income,
                    date: DateTime(2026, 5, 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ImportMappingPage()),
            ),
            child: const Text('下一步：分类映射'),
          ),
        ],
      ),
    );
  }
}

class ImportMappingPage extends StatelessWidget {
  const ImportMappingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const mappings = [
      ('餐饮', '餐饮'),
      ('交通', '交通'),
      ('早餐', '餐饮 / 早餐'),
      ('其它', '其他'),
      ('购物消费', '购物'),
      ('红包', '收入 / 红包'),
    ];

    return FlowPage(
      title: '分类映射',
      subtitle: '保存规则，下次自动匹配',
      child: ListView(
        children: [
          const Wrap(
            spacing: 10,
            children: [
              AppChip(label: '全部', selected: true),
              AppChip(label: '未匹配 12'),
              AppChip(label: '已匹配'),
            ],
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              children: [
                for (final mapping in mappings)
                  MappingRow(source: mapping.$1, target: mapping.$2),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('创建新分类'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ImportResultPage()),
                  ),
                  child: const Text('开始导入'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '导入前会创建批次记录，可在导入历史中撤销本次导入。',
            textAlign: TextAlign.center,
            style: AppText.muted(context),
          ),
        ],
      ),
    );
  }
}

class ImportResultPage extends StatelessWidget {
  const ImportResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowPage(
      title: '导入完成',
      subtitle: '批次记录已保存',
      child: ListView(
        children: [
          Center(
            child: Container(
              width: 112,
              height: 112,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 58,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '成功导入 8,411 条',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            '跳过重复 0 条，失败 15 条。失败记录可导出为 CSV 后修正再导入。',
            textAlign: TextAlign.center,
            style: AppText.muted(context),
          ),
          const SizedBox(height: 28),
          const AppCard(
            child: Column(
              children: [
                KeyValueRow(label: '来源', value: 'Timi 记账'),
                Divider(height: 22),
                KeyValueRow(label: '文件', value: 'timi_export_2026.xlsx'),
                Divider(height: 22),
                KeyValueRow(label: '导入时间', value: '2026-05-14 21:30'),
                Divider(height: 22),
                KeyValueRow(label: '批次 ID', value: 'IMP-20260514-001'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('查看流水'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () {}, child: const Text('撤销本次导入')),
        ],
      ),
    );
  }
}

class ImportSourceCard extends StatelessWidget {
  const ImportSourceCard({
    super.key,
    required this.title,
    required this.description,
    this.selected = false,
  });

  final String title;
  final String description;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(description, style: AppText.muted(context)),
              ],
            ),
          ),
          if (selected)
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.check, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }
}

class IssueRow extends StatelessWidget {
  const IssueRow({
    super.key,
    required this.title,
    required this.detail,
    this.warning = false,
  });

  final String title;
  final String detail;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          color: warning ? AppColors.warn : AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: Text(detail, style: AppText.muted(context)),
    );
  }
}

class MappingRow extends StatelessWidget {
  const MappingRow({super.key, required this.source, required this.target});

  final String source;
  final String target;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(source, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: const Text('导入到'),
      trailing: Chip(
        label: Text(target),
        backgroundColor: AppColors.primarySoft,
        side: BorderSide.none,
      ),
    );
  }
}
