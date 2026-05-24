import 'package:flutter/material.dart';

import '../models/ledger_entry.dart';
import '../theme/app_colors.dart';
import '../utils/ledger_formatters.dart';
import '../utils/ledger_stats.dart';
import '../widgets/app_card.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_page.dart';
import '../widgets/category_avatar.dart';
import '../widgets/chart_bar.dart';
import '../widgets/section_title.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key, required this.entries});

  final List<LedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    final totals = categoryTotals(entries);
    final maxTotal = totals.isEmpty
        ? 1.0
        : totals.map((item) => item.value).reduce((a, b) => a > b ? a : b);

    return AppPage(
      title: '统计',
      subtitle: '分类占比、趋势和排行',
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
                const SectionTitle('分类占比'),
                const SizedBox(height: 16),
                for (final item in totals.take(4)) ...[
                  Row(
                    children: [
                      Expanded(child: Text(item.key)),
                      Text(formatCurrency(item.value)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: item.value / maxTotal,
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
                const SectionTitle('支出排行'),
                const SizedBox(height: 12),
                for (final item in totals.take(3))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CategoryAvatar(label: categoryIcon(item.key)),
                    title: Text(item.key),
                    subtitle: Text(
                      '${countExpenseEntries(entries, item.key)} 笔',
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
