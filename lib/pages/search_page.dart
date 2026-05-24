import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../models/ledger_entry.dart';
import '../theme/app_text.dart';
import '../utils/ledger_formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page.dart';
import '../widgets/key_value_row.dart';
import '../widgets/section_title.dart';
import 'ledger_timeline_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.entries});

  final List<LedgerEntry> entries;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _queryController = TextEditingController();
  EntryType? _typeFilter;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<LedgerEntry> get _filtered {
    final query = _queryController.text.trim();
    return widget.entries.where((entry) {
      final matchesType = _typeFilter == null || entry.type == _typeFilter;
      final matchesQuery =
          query.isEmpty ||
          entry.title.contains(query) ||
          entry.category.contains(query) ||
          entry.note.contains(query);
      return matchesType && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final expense = filtered
        .where((entry) => entry.type == EntryType.expense)
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    return AppPage(
      title: '搜索',
      subtitle: '按金额、分类、时间和备注查账',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          TextField(
            controller: _queryController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: '搜索备注、商户、标签',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilterChip(
                label: const Text('全部'),
                selected: _typeFilter == null,
                onSelected: (_) => setState(() => _typeFilter = null),
              ),
              FilterChip(
                label: const Text('支出'),
                selected: _typeFilter == EntryType.expense,
                onSelected: (_) =>
                    setState(() => _typeFilter = EntryType.expense),
              ),
              FilterChip(
                label: const Text('收入'),
                selected: _typeFilter == EntryType.income,
                onSelected: (_) =>
                    setState(() => _typeFilter = EntryType.income),
              ),
              FilterChip(
                label: const Text('转账'),
                selected: _typeFilter == EntryType.transfer,
                onSelected: (_) =>
                    setState(() => _typeFilter = EntryType.transfer),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SearchFilterCard(),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: SectionTitle('搜索结果')),
              Text(
                '共 ${filtered.length} 笔 · 支出 ${formatCurrency(expense)}',
                style: AppText.muted(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                for (final entry in filtered) LedgerEntryTile(entry: entry),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchFilterCard extends StatelessWidget {
  const SearchFilterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: const [
          KeyValueRow(label: '日期范围', value: '2026/05/01 - 2026/05/14'),
          Divider(height: 22),
          KeyValueRow(label: '金额范围', value: '¥0 - ¥500'),
          Divider(height: 22),
          KeyValueRow(label: '分类', value: '餐饮、交通、居住'),
          Divider(height: 22),
          KeyValueRow(label: '账户', value: '现金账户、银行卡'),
        ],
      ),
    );
  }
}
