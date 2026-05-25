import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../models/ledger_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/ledger_formatters.dart';
import '../utils/ledger_stats.dart';
import '../widgets/category_avatar.dart';

class LedgerTimelinePage extends StatelessWidget {
  const LedgerTimelinePage({
    super.key,
    required this.entries,
    required this.selectedBookName,
    required this.income,
    required this.expense,
    required this.balance,
    required this.onAdd,
    required this.onEditEntry,
    required this.onOpenBooks,
    required this.onOpenSearch,
  });

  final List<LedgerEntry> entries;
  final String selectedBookName;
  final double income;
  final double expense;
  final double balance;
  final VoidCallback onAdd;
  final ValueChanged<LedgerEntry> onEditEntry;
  final VoidCallback onOpenBooks;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final groups = groupEntriesByDay(entries);

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TimelineHeader(
              bookName: selectedBookName,
              income: income,
              expense: expense,
              balance: balance,
              onAdd: onAdd,
              onOpenBooks: onOpenBooks,
              onOpenSearch: onOpenSearch,
            ),
            Expanded(
              child: groups.isEmpty
                  ? EmptyTimeline(onAdd: onAdd)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return TimelineDaySection(
                          label: group.label,
                          entries: group.entries,
                          onEditEntry: onEditEntry,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineHeader extends StatelessWidget {
  const TimelineHeader({
    super.key,
    required this.bookName,
    required this.income,
    required this.expense,
    required this.balance,
    required this.onAdd,
    required this.onOpenBooks,
    required this.onOpenSearch,
  });

  final String bookName;
  final double income;
  final double expense;
  final double balance;
  final VoidCallback onAdd;
  final VoidCallback onOpenBooks;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 278,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 174,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2F8EA3), Color(0xFF173F50)],
              ),
            ),
          ),
          Positioned.fill(
            top: 12,
            bottom: 118,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderIconButton(
                    icon: Icons.grid_view_rounded,
                    tooltip: '账本',
                    onTap: onOpenBooks,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onOpenBooks,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .38),
                        ),
                      ),
                      child: Text(
                        bookName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  HeaderIconButton(
                    icon: Icons.search_rounded,
                    tooltip: '搜索',
                    onTap: onOpenSearch,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 144,
            child: Container(height: 134, color: Colors.white),
          ),
          Positioned(
            left: 24,
            top: 190,
            child: SummaryAmount(label: '当月收入', amount: income),
          ),
          Positioned(
            right: 24,
            top: 190,
            child: SummaryAmount(label: '当月支出', amount: expense),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 116,
            child: Center(
              child: AddCircleButton(balance: balance, onTap: onAdd),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(icon),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: .16),
        fixedSize: const Size.square(54),
      ),
    );
  }
}

class AddCircleButton extends StatelessWidget {
  const AddCircleButton({
    super.key,
    required this.balance,
    required this.onTap,
  });

  final double balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 8,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 132,
          height: 132,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE1AE28), width: 9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 46, color: Color(0xFFE1AE28)),
              const SizedBox(height: 4),
              Text(
                formatCurrency(balance),
                style: AppText.muted(context).copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryAmount extends StatelessWidget {
  const SummaryAmount({super.key, required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.muted(context).copyWith(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            formatCurrency(amount).replaceFirst('¥', ''),
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineDaySection extends StatelessWidget {
  const TimelineDaySection({
    super.key,
    required this.label,
    required this.entries,
    required this.onEditEntry,
  });

  final String label;
  final List<LedgerEntry> entries;
  final ValueChanged<LedgerEntry> onEditEntry;

  @override
  Widget build(BuildContext context) {
    final expense = entries
        .where((entry) => entry.type == EntryType.expense)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final income = entries
        .where((entry) => entry.type == EntryType.income)
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    return Column(
      children: [
        TimelineDayHeader(label: label, expense: expense, income: income),
        for (final entry in entries)
          TimelineEntryRow(entry: entry, onTap: () => onEditEntry(entry)),
      ],
    );
  }
}

class TimelineDayHeader extends StatelessWidget {
  const TimelineDayHeader({
    super.key,
    required this.label,
    required this.expense,
    required this.income,
  });

  final String label;
  final double expense;
  final double income;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          const Expanded(child: SizedBox()),
          SizedBox(
            width: 96,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.replaceFirst('今天 ', ''),
                    style: AppText.muted(context),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.line,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(
              expense > 0 ? formatCurrency(expense).replaceFirst('¥', '') : '',
              style: AppText.muted(context),
            ),
          ),
          if (income > 0)
            Text(
              '+${formatCurrency(income)}',
              style: const TextStyle(
                color: AppColors.income,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class TimelineEntryRow extends StatelessWidget {
  const TimelineEntryRow({super.key, required this.entry, required this.onTap});

  final LedgerEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == EntryType.income;
    final color = isIncome ? AppColors.income : categoryColor(entry.category);
    final icon = isIncome
        ? Icons.payments_outlined
        : categoryIconData(entry.category);

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 86),
        child: Row(
          children: [
            Expanded(
              child: isIncome
                  ? _EntryTitle(entry: entry, alignRight: true)
                  : const SizedBox(),
            ),
            SizedBox(
              width: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Container(width: 1, color: AppColors.subtle),
                    ),
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color,
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isIncome ? const SizedBox() : _EntryTitle(entry: entry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTitle extends StatelessWidget {
  const _EntryTitle({required this.entry, this.alignRight = false});

  final LedgerEntry entry;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final text =
        '${entry.category} ${formatCurrency(entry.amount).replaceFirst('¥', '')}';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (entry.note.isNotEmpty)
          Text(
            entry.note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.muted(context).copyWith(fontSize: 12),
          ),
      ],
    );
  }
}

class EmptyTimeline extends StatelessWidget {
  const EmptyTimeline({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: const Text('记第一笔'),
      ),
    );
  }
}

class LedgerEntryTile extends StatelessWidget {
  const LedgerEntryTile({super.key, required this.entry, this.onTap});

  final LedgerEntry entry;
  final VoidCallback? onTap;

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

    return InkWell(
      onTap: onTap,
      child: Padding(
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
      ),
    );
  }
}

Color categoryColor(String category) {
  if (category.contains('餐') || category.contains('用餐')) {
    return const Color(0xFF7DB7AE);
  }
  if (category.contains('水果')) return const Color(0xFF287E78);
  if (category.contains('娱乐')) return const Color(0xFFF39A38);
  if (category.contains('零食')) return const Color(0xFFA77B65);
  if (category.contains('宝宝')) return const Color(0xFFE04F43);
  if (category.contains('交通')) return const Color(0xFF4E79A7);
  if (category.contains('购物')) return const Color(0xFFE15759);
  if (category.contains('居住') || category.contains('住宿')) {
    return const Color(0xFF8B6F47);
  }
  return AppColors.primary;
}

IconData categoryIconData(String category) {
  if (category.contains('餐') || category.contains('用餐')) {
    return Icons.restaurant;
  }
  if (category.contains('水果')) return Icons.apple;
  if (category.contains('娱乐')) return Icons.mic_external_on;
  if (category.contains('零食')) return Icons.icecream;
  if (category.contains('交通')) return Icons.directions_subway;
  if (category.contains('购物')) return Icons.shopping_bag_outlined;
  if (category.contains('居住') || category.contains('住宿')) {
    return Icons.home_outlined;
  }
  if (category.contains('医疗')) return Icons.medical_services_outlined;
  if (category.contains('学习')) return Icons.menu_book_outlined;
  return Icons.sell_outlined;
}
