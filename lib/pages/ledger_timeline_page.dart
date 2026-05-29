import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../models/ledger_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/category_visuals.dart';
import '../utils/ledger_formatters.dart';
import '../utils/ledger_stats.dart';
import '../widgets/category_avatar.dart';

class LedgerTimelinePage extends StatefulWidget {
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
  State<LedgerTimelinePage> createState() => _LedgerTimelinePageState();
}

class _LedgerTimelinePageState extends State<LedgerTimelinePage> {
  bool _showBalanceInTitle = false;
  RefreshIndicatorStatus? _pullStatus;
  bool _isPullingDown = false;

  @override
  void didUpdateWidget(covariant LedgerTimelinePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedBookName != widget.selectedBookName) {
      _showBalanceInTitle = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = groupEntriesByDay(widget.entries);

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TimelineHeader(
              bookName: widget.selectedBookName,
              income: widget.income,
              expense: widget.expense,
              balance: widget.balance,
              entries: widget.entries,
              pullStatus: _pullStatus,
              isPullingDown: _isPullingDown,
              showBalanceTitle: _showBalanceInTitle,
              onToggleTitle: () =>
                  setState(() => _showBalanceInTitle = !_showBalanceInTitle),
              onAdd: widget.onAdd,
              onOpenBooks: widget.onOpenBooks,
              onOpenSearch: widget.onOpenSearch,
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleTimelineScroll,
                child: RefreshIndicator.noSpinner(
                  onRefresh: _openAddFromPull,
                  onStatusChange: (status) {
                    setState(() {
                      _pullStatus = status;
                      if (status == null ||
                          status == RefreshIndicatorStatus.done ||
                          status == RefreshIndicatorStatus.canceled) {
                        _isPullingDown = false;
                      }
                    });
                  },
                  child: groups.isEmpty
                      ? EmptyTimeline(onAdd: widget.onAdd)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 96),
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            return TimelineDaySection(
                              label: group.label,
                              entries: group.entries,
                              onEditEntry: widget.onEditEntry,
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _handleTimelineScroll(ScrollNotification notification) {
    final atTop =
        notification.metrics.pixels <=
        notification.metrics.minScrollExtent + 0.5;
    var pullingDown = _isPullingDown;

    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null &&
        atTop) {
      pullingDown = notification.dragDetails!.delta.dy > 0;
    } else if (notification is OverscrollNotification && atTop) {
      pullingDown = notification.overscroll < 0;
    } else if (notification is ScrollEndNotification) {
      pullingDown = false;
    }

    if (pullingDown != _isPullingDown) {
      setState(() => _isPullingDown = pullingDown);
    }
    return false;
  }

  Future<void> _openAddFromPull() async {
    widget.onAdd();
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}

class TimelineHeader extends StatelessWidget {
  const TimelineHeader({
    super.key,
    required this.bookName,
    required this.income,
    required this.expense,
    required this.balance,
    required this.entries,
    required this.pullStatus,
    required this.isPullingDown,
    required this.showBalanceTitle,
    required this.onToggleTitle,
    required this.onAdd,
    required this.onOpenBooks,
    required this.onOpenSearch,
  });

  final String bookName;
  final double income;
  final double expense;
  final double balance;
  final List<LedgerEntry> entries;
  final RefreshIndicatorStatus? pullStatus;
  final bool isPullingDown;
  final bool showBalanceTitle;
  final VoidCallback onToggleTitle;
  final VoidCallback onAdd;
  final VoidCallback onOpenBooks;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final titleText = showBalanceTitle ? formatCurrency(balance) : bookName;
    return SizedBox(
      height: 258,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 156,
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
            bottom: 104,
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
                    onTap: onToggleTitle,
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
                        titleText,
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
            child: Container(height: 114, color: Colors.white),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 198,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 46),
                    child: SummaryAmount(label: '当月收入', amount: income),
                  ),
                ),
                const SizedBox(width: 126),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 46),
                    child: SummaryAmount(
                      label: '当月支出',
                      amount: expense,
                      alignRight: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 106,
            child: Center(
              child: AddCircleButton(
                onTap: onAdd,
                entries: entries,
                pullStatus: pullStatus,
                isPullingDown: isPullingDown,
              ),
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
        fixedSize: const Size.square(48),
      ),
    );
  }
}

class AddCircleButton extends StatefulWidget {
  const AddCircleButton({
    super.key,
    required this.onTap,
    required this.entries,
    required this.pullStatus,
    required this.isPullingDown,
  });

  final VoidCallback onTap;
  final List<LedgerEntry> entries;
  final RefreshIndicatorStatus? pullStatus;
  final bool isPullingDown;

  @override
  State<AddCircleButton> createState() => _AddCircleButtonState();
}

class _AddCircleButtonState extends State<AddCircleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _shouldRotate {
    return widget.isPullingDown &&
        widget.pullStatus != null &&
        widget.pullStatus != RefreshIndicatorStatus.done &&
        widget.pullStatus != RefreshIndicatorStatus.canceled;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    if (_shouldRotate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant AddCircleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRotate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!_shouldRotate && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 8,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: widget.onTap,
        child: CustomPaint(
          painter: CategoryRingPainter(data: _categoryRingData()),
          child: SizedBox(
            width: 112,
            height: 112,
            child: Center(
              child: RotationTransition(
                turns: _controller,
                child: const Icon(
                  Icons.add,
                  size: 44,
                  color: Color(0xFFE1AE28),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  CategoryRingData _categoryRingData() {
    final totals = <String, _CategoryRingTotal>{};
    for (final entry in widget.entries) {
      if (entry.type == EntryType.transfer || entry.amount <= 0) continue;
      final visual = categoryVisual(
        entry.category,
        type: entry.type,
        iconKey: entry.categoryIconKey,
      );
      final key =
          '${entry.type.index}:${entry.category}:${entry.categoryIconKey ?? ''}';
      totals.update(
        key,
        (total) => total.copyWith(amount: total.amount + entry.amount),
        ifAbsent: () => _CategoryRingTotal(
          amount: entry.amount,
          color: visual.color,
          type: entry.type,
        ),
      );
    }
    if (totals.isEmpty) {
      return const CategoryRingData(
        income: [],
        expense: [CategoryRingSegment(amount: 1, color: Color(0xFFE1AE28))],
      );
    }
    final income = <CategoryRingSegment>[];
    final expense = <CategoryRingSegment>[];
    for (final total in totals.values) {
      final segment = CategoryRingSegment(
        amount: total.amount,
        color: total.color,
      );
      if (total.type == EntryType.income) {
        income.add(segment);
      } else {
        expense.add(segment);
      }
    }
    income.sort((a, b) => b.amount.compareTo(a.amount));
    expense.sort((a, b) => b.amount.compareTo(a.amount));
    return CategoryRingData(income: income, expense: expense);
  }
}

class _CategoryRingTotal {
  const _CategoryRingTotal({
    required this.amount,
    required this.color,
    required this.type,
  });

  final double amount;
  final Color color;
  final EntryType type;

  _CategoryRingTotal copyWith({double? amount, Color? color}) {
    return _CategoryRingTotal(
      amount: amount ?? this.amount,
      color: color ?? this.color,
      type: type,
    );
  }
}

class CategoryRingData {
  const CategoryRingData({required this.income, required this.expense});

  final List<CategoryRingSegment> income;
  final List<CategoryRingSegment> expense;

  double get incomeTotal =>
      income.fold<double>(0, (sum, segment) => sum + segment.amount);

  double get expenseTotal =>
      expense.fold<double>(0, (sum, segment) => sum + segment.amount);
}

class CategoryRingSegment {
  const CategoryRingSegment({required this.amount, required this.color});

  final double amount;
  final Color color;
}

class CategoryRingPainter extends CustomPainter {
  const CategoryRingPainter({required this.data});

  final CategoryRingData data;

  @override
  void paint(Canvas canvas, Size size) {
    final incomeTotal = data.incomeTotal;
    final expenseTotal = data.expenseTotal;
    final total = incomeTotal + expenseTotal;
    if (total <= 0) return;

    final strokeWidth = 7.0;
    final rect =
        Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final incomeSweep = math.pi * 2 * incomeTotal / total;
    final expenseSweep = math.pi * 2 - incomeSweep;

    _drawSide(
      canvas: canvas,
      rect: rect,
      paint: paint,
      segments: data.income,
      start: math.pi - incomeSweep / 2,
      sweep: incomeSweep,
    );
    _drawSide(
      canvas: canvas,
      rect: rect,
      paint: paint,
      segments: data.expense,
      start: -expenseSweep / 2,
      sweep: expenseSweep,
    );
  }

  void _drawSide({
    required Canvas canvas,
    required Rect rect,
    required Paint paint,
    required List<CategoryRingSegment> segments,
    required double start,
    required double sweep,
  }) {
    if (sweep <= 0) return;
    final total = segments.fold<double>(0, (sum, item) => sum + item.amount);
    if (total <= 0) return;

    var sideStart = start;
    for (final segment in segments) {
      final segmentSweep = sweep * segment.amount / total;
      paint.color = segment.color;
      canvas.drawArc(rect, sideStart, segmentSweep, false, paint);
      sideStart += segmentSweep;
    }
  }

  @override
  bool shouldRepaint(covariant CategoryRingPainter oldDelegate) {
    return _segmentsChanged(data.income, oldDelegate.data.income) ||
        _segmentsChanged(data.expense, oldDelegate.data.expense);
  }

  bool _segmentsChanged(
    List<CategoryRingSegment> segments,
    List<CategoryRingSegment> oldSegments,
  ) {
    if (segments.length != oldSegments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final oldSegment = oldSegments[i];
      if (segment.amount != oldSegment.amount ||
          segment.color != oldSegment.color) {
        return true;
      }
    }
    return false;
  }
}

class SummaryAmount extends StatelessWidget {
  const SummaryAmount({
    super.key,
    required this.label,
    required this.amount,
    this.alignRight = false,
  });

  final String label;
  final double amount;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.muted(context).copyWith(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          formatCurrency(amount).replaceFirst('¥', ''),
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SizedBox(
        height: 38,
        child: Row(
          children: [
            Expanded(
              child: income > 0
                  ? Text(
                      '+${formatCurrency(income)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.income,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : const SizedBox(),
            ),
            SizedBox(
              width: 108,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.replaceFirst('今天 ', ''),
                      style: AppText.muted(context).copyWith(fontSize: 14),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
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
                expense > 0
                    ? formatCurrency(expense).replaceFirst('¥', '')
                    : '',
                style: AppText.muted(context).copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
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
    final visual = categoryVisual(
      entry.category,
      type: entry.type,
      iconKey: entry.categoryIconKey,
    );
    final color = isIncome ? AppColors.income : visual.color;
    final icon = isIncome ? Icons.payments_outlined : visual.icon;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 74),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 22),
                child: isIncome
                    ? _EntryTitle(entry: entry, alignRight: true)
                    : const SizedBox(),
              ),
            ),
            SizedBox(
              width: 86,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Container(width: 1, color: AppColors.subtle),
                    ),
                  ),
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: color,
                    child: Icon(icon, color: Colors.white, size: 21),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 22),
                child: isIncome ? const SizedBox() : _EntryTitle(entry: entry),
              ),
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
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (entry.note.isNotEmpty)
          Text(
            entry.note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.muted(context).copyWith(fontSize: 11),
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 240,
          child: Center(
            child: TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('记第一笔'),
            ),
          ),
        ),
      ],
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
  return categoryVisual(category).color;
}

IconData categoryIconData(String category) {
  return categoryVisual(category).icon;
}
