import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../models/ledger_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/ledger_stats.dart';
import 'ledger_timeline_page.dart';

enum StatsView { summary, income, expense }

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({
    super.key,
    required this.entries,
    required this.bookName,
  });

  final List<LedgerEntry> entries;
  final String bookName;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  StatsView _view = StatsView.summary;
  DateTime _startDate = DateTime(2026, 5, 1);
  DateTime _endDate = DateTime(2026, 5, 26);

  List<LedgerEntry> get _filteredEntries {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      23,
      59,
      59,
    );
    return widget.entries
        .where(
          (entry) => !entry.date.isBefore(start) && !entry.date.isAfter(end),
        )
        .toList();
  }

  double get _income => _filteredEntries
      .where((entry) => entry.type == EntryType.income)
      .fold(0, (sum, entry) => sum + entry.amount);

  double get _expense => _filteredEntries
      .where((entry) => entry.type == EntryType.expense)
      .fold(0, (sum, entry) => sum + entry.amount);

  double get _balance => _income - _expense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StatsHeader(title: _title),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 18),
                children: [
                  DateRangePickerRow(
                    startDate: _startDate,
                    endDate: _endDate,
                    onPickStart: () => _pickDate(isStart: true),
                    onPickEnd: () => _pickDate(isStart: false),
                  ),
                  MonthSelector(
                    selectedMonth: _startDate.month,
                    onSelectMonth: _selectMonth,
                    onSelectYear: _selectThisYear,
                    onSelectAll: _selectAll,
                  ),
                  switch (_view) {
                    StatsView.summary => SummaryStatsView(
                      entries: _filteredEntries,
                      income: _income,
                      expense: _expense,
                      balance: _balance,
                      startDate: _startDate,
                      endDate: _endDate,
                    ),
                    StatsView.income => CategoryStatsView(
                      title: '我的收入及财务状况',
                      type: EntryType.income,
                      entries: _filteredEntries,
                      total: _income,
                      peerDelta: -243.34,
                    ),
                    StatsView.expense => CategoryStatsView(
                      title: '历史支出状况',
                      type: EntryType.expense,
                      entries: _filteredEntries,
                      total: _expense,
                      peerDelta: 7213.94,
                    ),
                  },
                ],
              ),
            ),
            StatsBottomTabs(
              selected: _view,
              onChanged: (view) => setState(() => _view = view),
            ),
          ],
        ),
      ),
    );
  }

  String get _title {
    return switch (_view) {
      StatsView.summary => '全部收支汇总',
      StatsView.income => '我的收入及财务状况',
      StatsView.expense => '历史支出状况',
    };
  }

  Future<void> _pickDate({required bool isStart}) async {
    final current = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked.isAfter(_endDate) ? _endDate : picked;
      } else {
        _endDate = picked.isBefore(_startDate) ? _startDate : picked;
      }
    });
  }

  void _selectMonth(int month) {
    setState(() {
      _startDate = DateTime(2026, month, 1);
      _endDate = DateTime(2026, month + 1, 0);
    });
  }

  void _selectThisYear() {
    setState(() {
      _startDate = DateTime(2026);
      _endDate = DateTime(2026, 12, 31);
    });
  }

  void _selectAll() {
    setState(() {
      _startDate = DateTime(2021, 7, 14);
      _endDate = DateTime(2026, 5, 26);
    });
  }
}

class StatsHeader extends StatelessWidget {
  const StatsHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.subtle)),
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 0,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 24),
              color: AppColors.muted,
              tooltip: '关闭',
            ),
          ),
        ],
      ),
    );
  }
}

class DateRangePickerRow extends StatelessWidget {
  const DateRangePickerRow({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.subtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DateCard(
              label: '开始日期',
              date: startDate,
              color: const Color(0xFFD95765),
              onTap: onPickStart,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('.....', style: AppText.muted(context)),
          ),
          Expanded(
            child: DateCard(
              label: '结束日期',
              date: endDate,
              color: const Color(0xFF2EA8D5),
              onTap: onPickEnd,
            ),
          ),
        ],
      ),
    );
  }
}

class DateCard extends StatelessWidget {
  const DateCard({
    super.key,
    required this.label,
    required this.date,
    required this.color,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.subtle),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 3),
                  Text(
                    '${date.year}年${_two(date.month)}月${_two(date.day)}日',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontSize: 17),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onSelectMonth,
    required this.onSelectYear,
    required this.onSelectAll,
  });

  final int selectedMonth;
  final ValueChanged<int> onSelectMonth;
  final VoidCallback onSelectYear;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    final items = [
      (3, 'MAR', '3月'),
      (4, 'APR', '4月'),
      (5, 'MAY', '5月'),
      (-1, 'YEAR', '今年'),
      (-2, 'ALL', '全部'),
    ];
    return Container(
      height: 66,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.subtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final item in items)
            InkWell(
              onTap: () {
                if (item.$1 > 0) onSelectMonth(item.$1);
                if (item.$1 == -1) onSelectYear();
                if (item.$1 == -2) onSelectAll();
              },
              child: SizedBox(
                width: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: item.$1 == selectedMonth
                            ? const Color(0xFFD4A22A)
                            : AppColors.line,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$3,
                      style: TextStyle(
                        color: item.$1 == selectedMonth
                            ? const Color(0xFFD4A22A)
                            : AppColors.muted,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SummaryStatsView extends StatelessWidget {
  const SummaryStatsView({
    super.key,
    required this.entries,
    required this.income,
    required this.expense,
    required this.balance,
    required this.startDate,
    required this.endDate,
  });

  final List<LedgerEntry> entries;
  final double income;
  final double expense;
  final double balance;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    final days = math.max(1, endDate.difference(startDate).inDays + 1);
    final saveRate = income <= 0 ? 0.0 : (balance / income).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatsTotalsRow(
          items: [
            StatsTotal(label: '月支出', amount: expense),
            StatsTotal(label: '月收入', amount: income),
            StatsTotal(label: '结余', amount: balance),
          ],
        ),
        SizedBox(
          height: 238,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TrendChart(
              entries: entries,
              startDate: startDate,
              days: days,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Row(
            children: [
              Text(
                '${endDate.year}\n${_two(endDate.month)}月${_two(endDate.day)}日',
              ),
              const Spacer(),
              Text(
                '当前日账单',
                style: AppText.muted(context).copyWith(fontSize: 18),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('理财建议', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 22),
              Center(
                child: Text(
                  '你的结余率为${(saveRate * 100).round()}%',
                  style: AppText.muted(context).copyWith(fontSize: 18),
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: saveRate,
                  minHeight: 22,
                  color: const Color(0xFFF2AB1D),
                  backgroundColor: AppColors.subtle,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '建议保持结余率在49%以上',
                  style: AppText.muted(context).copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                '健康',
                style: TextStyle(
                  color: Color(0xFFF2AB1D),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                saveRate >= .49
                    ? '结余率健康，当前财务状况良好，继续保持。'
                    : '结余率偏低，建议关注大额支出和高频分类。',
                style: AppText.muted(context).copyWith(fontSize: 17),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoryStatsView extends StatelessWidget {
  const CategoryStatsView({
    super.key,
    required this.title,
    required this.type,
    required this.entries,
    required this.total,
    required this.peerDelta,
  });

  final String title;
  final EntryType type;
  final List<LedgerEntry> entries;
  final double total;
  final double peerDelta;

  @override
  Widget build(BuildContext context) {
    final totals = categoryTotalsByType(entries, type);
    final average = total / 24;
    final maxTotal = totals.isEmpty ? 1.0 : totals.first.value;
    return Column(
      children: [
        StatsTotalsRow(
          items: [
            StatsTotal(
              label: type == EntryType.income ? '月收入' : '月支出',
              amount: total,
            ),
            StatsTotal(
              label: type == EntryType.income ? '日均收入' : '日均支出',
              amount: average,
            ),
            StatsTotal(
              label: '对比上月',
              amount: peerDelta.abs(),
              prefix: peerDelta >= 0 ? '↑ ' : '↓ ',
            ),
          ],
        ),
        if (type == EntryType.expense)
          ExpenseDonutSection(totals: totals, total: total)
        else
          IncomeStackSection(totals: totals, total: total),
        const Divider(height: 1),
        for (final item in totals.take(8))
          CategoryStatRow(
            category: item.key,
            amount: item.value,
            maxAmount: maxTotal,
          ),
      ],
    );
  }
}

class StatsTotalsRow extends StatelessWidget {
  const StatsTotalsRow({super.key, required this.items});

  final List<StatsTotal> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.subtle)),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.label,
                    style: AppText.muted(context).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.prefix}${_amount(item.amount)}元',
                    style: const TextStyle(fontSize: 17, color: AppColors.text),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class StatsTotal {
  const StatsTotal({
    required this.label,
    required this.amount,
    this.prefix = '',
  });

  final String label;
  final double amount;
  final String prefix;
}

class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.entries,
    required this.startDate,
    required this.days,
  });

  final List<LedgerEntry> entries;
  final DateTime startDate;
  final int days;

  @override
  Widget build(BuildContext context) {
    final income = List<double>.filled(days, 0);
    final expense = List<double>.filled(days, 0);
    for (final entry in entries) {
      final index = entry.date.difference(startDate).inDays;
      if (index < 0 || index >= days) continue;
      if (entry.type == EntryType.income) income[index] += entry.amount;
      if (entry.type == EntryType.expense) expense[index] += entry.amount;
    }
    return CustomPaint(
      painter: TrendChartPainter(income: income, expense: expense),
      child: const SizedBox.expand(),
    );
  }
}

class TrendChartPainter extends CustomPainter {
  const TrendChartPainter({required this.income, required this.expense});

  final List<double> income;
  final List<double> expense;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.subtle
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    _drawLine(canvas, size, expense, const Color(0xFFE36A52));
    _drawLine(canvas, size, income, const Color(0xFF66B6AE));
  }

  void _drawLine(Canvas canvas, Size size, List<double> values, Color color) {
    if (values.isEmpty) return;
    final maxValue = math.max(1.0, [...income, ...expense].reduce(math.max));
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : size.width * i / (values.length - 1);
      final y = size.height - size.height * values[i] / maxValue;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant TrendChartPainter oldDelegate) {
    return income != oldDelegate.income || expense != oldDelegate.expense;
  }
}

class ExpenseDonutSection extends StatelessWidget {
  const ExpenseDonutSection({
    super.key,
    required this.totals,
    required this.total,
  });

  final List<MapEntry<String, double>> totals;
  final double total;

  @override
  Widget build(BuildContext context) {
    final top = totals.isEmpty ? null : totals.first;
    final percent = total <= 0 || top == null ? 0 : top.value / total;
    return SizedBox(
      height: 330,
      child: Column(
        children: [
          const SizedBox(height: 18),
          if (top != null)
            Text(
              '${top.key}\n${_amount(top.value)}',
              textAlign: TextAlign.center,
              style: AppText.muted(context).copyWith(fontSize: 18),
            ),
          Expanded(
            child: CustomPaint(
              painter: DonutChartPainter(totals: totals, total: total),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      top == null
                          ? Icons.pie_chart_outline
                          : categoryIconData(top.key),
                      color: const Color(0xFFB5A64B),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(percent * 100).round()}%',
                      style: AppText.muted(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  const DonutChartPainter({required this.totals, required this.total});

  final List<MapEntry<String, double>> totals;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .34;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.butt;
    if (total <= 0 || totals.isEmpty) {
      canvas.drawCircle(center, radius, paint..color = AppColors.subtle);
      return;
    }
    var start = -math.pi / 2;
    for (var i = 0; i < totals.length; i++) {
      final sweep = math.pi * 2 * totals[i].value / total;
      paint.color = categoryColor(totals[i].key);
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return totals != oldDelegate.totals || total != oldDelegate.total;
  }
}

class IncomeStackSection extends StatelessWidget {
  const IncomeStackSection({
    super.key,
    required this.totals,
    required this.total,
  });

  final List<MapEntry<String, double>> totals;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 42, 14, 48),
      child: SizedBox(
        height: 62,
        child: Row(
          children: [
            for (final item in totals)
              Expanded(
                flex: math.max(
                  1,
                  (item.value / math.max(1, total) * 1000).round(),
                ),
                child: Container(color: categoryColor(item.key)),
              ),
            if (totals.isEmpty)
              Expanded(child: Container(color: AppColors.subtle)),
          ],
        ),
      ),
    );
  }
}

class CategoryStatRow extends StatelessWidget {
  const CategoryStatRow({
    super.key,
    required this.category,
    required this.amount,
    required this.maxAmount,
  });

  final String category;
  final double amount;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category);
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.subtle)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Icon(
              categoryIconData(category),
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(
              category,
              style: AppText.muted(context).copyWith(fontSize: 15),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: amount / maxAmount,
                minHeight: 5,
                color: color,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 82,
            child: Text(
              _amount(amount),
              textAlign: TextAlign.right,
              style: AppText.muted(context).copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class StatsBottomTabs extends StatelessWidget {
  const StatsBottomTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final StatsView selected;
  final ValueChanged<StatsView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.subtle)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          BottomStatsItem(
            icon: Icons.show_chart,
            label: '汇总',
            selected: selected == StatsView.summary,
            onTap: () => onChanged(StatsView.summary),
          ),
          BottomStatsItem(
            icon: Icons.bar_chart,
            label: '收入',
            selected: selected == StatsView.income,
            onTap: () => onChanged(StatsView.income),
          ),
          BottomStatsItem(
            icon: Icons.donut_large,
            label: '支出',
            selected: selected == StatsView.expense,
            onTap: () => onChanged(StatsView.expense),
          ),
        ],
      ),
    );
  }
}

class BottomStatsItem extends StatelessWidget {
  const BottomStatsItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFD4A22A) : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

String _two(int value) => value.toString().padLeft(2, '0');

String _amount(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}
