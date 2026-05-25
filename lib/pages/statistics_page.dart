import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../models/ledger_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/ledger_formatters.dart';
import '../utils/ledger_stats.dart';
import '../widgets/app_card.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_page.dart';
import '../widgets/category_avatar.dart';
import '../widgets/chart_bar.dart';
import '../widgets/section_title.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({
    super.key,
    required this.entries,
    required this.bookName,
  });

  final List<LedgerEntry> entries;
  final String bookName;

  @override
  Widget build(BuildContext context) {
    final expenseTotals = categoryTotalsByType(entries, EntryType.expense);
    final incomeTotals = categoryTotalsByType(entries, EntryType.income);
    final maxExpense = expenseTotals.isEmpty
        ? 1.0
        : expenseTotals
              .map((item) => item.value)
              .reduce((a, b) => a > b ? a : b);
    final maxIncome = incomeTotals.isEmpty
        ? 1.0
        : incomeTotals
              .map((item) => item.value)
              .reduce((a, b) => a > b ? a : b);

    return AppPage(
      title: '统计',
      subtitle: '$bookName · 收入和支出分开复盘',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          const Row(
            children: [
              AppChip(label: '月', selected: true),
              SizedBox(width: 10),
              AppChip(label: '年'),
              SizedBox(width: 10),
              AppChip(label: '自定义'),
            ],
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('每日支出趋势'),
                const SizedBox(height: 18),
                SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      ChartBar(height: 42),
                      ChartBar(height: 88),
                      ChartBar(height: 54),
                      ChartBar(height: 120),
                      ChartBar(height: 76),
                      ChartBar(height: 138),
                      ChartBar(height: 66),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('支出分类'),
                const SizedBox(height: 16),
                for (final item in expenseTotals.take(6)) ...[
                  Row(
                    children: [
                      Expanded(child: Text(item.key)),
                      Text(formatCurrency(item.value)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: item.value / maxExpense,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('收入分类'),
                const SizedBox(height: 16),
                for (final item in incomeTotals.take(6)) ...[
                  Row(
                    children: [
                      Expanded(child: Text(item.key)),
                      Text(formatCurrency(item.value)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: item.value / maxIncome,
                    minHeight: 7,
                    color: AppColors.income,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                ],
                if (incomeTotals.isEmpty)
                  Text('当前账本暂无收入记录', style: AppText.muted(context)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('支出排行'),
                const SizedBox(height: 12),
                for (final item in expenseTotals.take(3))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CategoryAvatar(label: categoryIcon(item.key)),
                    title: Text(item.key),
                    subtitle: Text(
                      '${countEntriesByType(entries, item.key, EntryType.expense)} 笔',
                    ),
                    trailing: Text(
                      '-${formatCurrency(item.value)}',
                      style: const TextStyle(
                        color: AppColors.expense,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
