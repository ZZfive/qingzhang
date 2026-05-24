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

class LedgerTimelinePage extends StatelessWidget {
  const LedgerTimelinePage({
    super.key,
    required this.entries,
    required this.income,
    required this.expense,
    required this.balance,
    required this.onAdd,
    required this.onOpenSearch,
  });

  final List<LedgerEntry> entries;
  final double income;
  final double expense;
  final double balance;
  final VoidCallback onAdd;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '清账',
      subtitle: '无广告，本地优先，打开就能记',
      actions: [
        IconButton(
          onPressed: onOpenSearch,
          icon: const Icon(Icons.search),
          tooltip: '搜索',
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          MonthSummaryCard(balance: balance, income: income, expense: expense),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: [
              const AppChip(label: '本月', selected: true),
              AppChip(label: '搜索', onTap: onOpenSearch),
              const AppChip(label: '日历'),
            ],
          ),
          const SizedBox(height: 24),
          for (final group in groupEntriesByDay(entries)) ...[
            TimelineDayHeader(entries: group.entries, label: group.label),
            const SizedBox(height: 10),
            for (final entry in group.entries) LedgerEntryTile(entry: entry),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  final double balance;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('5月结余', style: AppText.muted(context)),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(balance),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Text(
                '本月可用 ${formatCurrency(balance)}',
                style: AppText.muted(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  '支出 ${formatCurrency(expense)}',
                  style: const TextStyle(
                    color: AppColors.expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '收入 ${formatCurrency(income)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.income,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const LinearProgressIndicator(
            value: .61,
            minHeight: 6,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
        ],
      ),
    );
  }
}

class TimelineDayHeader extends StatelessWidget {
  const TimelineDayHeader({
    super.key,
    required this.entries,
    required this.label,
  });

  final List<LedgerEntry> entries;
  final String label;

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<double>(0, (sum, entry) {
      return sum +
          (entry.type == EntryType.income ? entry.amount : -entry.amount);
    });

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '${total >= 0 ? '+' : ''}${formatCurrency(total)}',
          style: TextStyle(
            color: total >= 0 ? AppColors.income : AppColors.expense,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class LedgerEntryTile extends StatelessWidget {
  const LedgerEntryTile({super.key, required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == EntryType.income;
    final isTransfer = entry.type == EntryType.transfer;
    final amountColor = isIncome
        ? AppColors.income
        : isTransfer
        ? AppColors.muted
        : AppColors.expense;
    final sign = isIncome
        ? '+'
        : isTransfer
        ? ''
        : '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CategoryAvatar(label: categoryIcon(entry.category)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  '${entry.category} · ${entry.note.isEmpty ? entry.account : entry.note}',
                  style: AppText.muted(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '$sign${formatCurrency(entry.amount)}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
