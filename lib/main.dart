import 'package:flutter/material.dart';

void main() {
  runApp(const AccountingApp());
}

enum EntryType { expense, income, transfer }

class LedgerEntry {
  const LedgerEntry({
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.account = '现金账户',
    this.note = '',
    this.source,
  });

  final String title;
  final String category;
  final double amount;
  final EntryType type;
  final DateTime date;
  final String account;
  final String note;
  final String? source;
}

class AccountingApp extends StatelessWidget {
  const AccountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '清账',
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<LedgerEntry> _entries = [
    LedgerEntry(
      title: '午餐',
      category: '餐饮',
      amount: 38,
      type: EntryType.expense,
      date: DateTime(2026, 5, 14, 12, 30),
      note: '公司楼下',
    ),
    LedgerEntry(
      title: '地铁',
      category: '交通',
      amount: 6,
      type: EntryType.expense,
      date: DateTime(2026, 5, 14, 9, 12),
      note: '通勤',
    ),
    LedgerEntry(
      title: '咖啡',
      category: '餐饮',
      amount: 24,
      type: EntryType.expense,
      date: DateTime(2026, 5, 14, 15, 20),
      note: '备注联想',
    ),
    LedgerEntry(
      title: '工资',
      category: '工资',
      amount: 18000,
      type: EntryType.income,
      date: DateTime(2026, 5, 13, 10),
      account: '银行卡',
    ),
    LedgerEntry(
      title: '房租',
      category: '居住',
      amount: 3200,
      type: EntryType.expense,
      date: DateTime(2026, 5, 13, 18),
      note: '周期账单',
    ),
  ];

  double get _income => _entries
      .where((entry) => entry.type == EntryType.income)
      .fold(0, (total, entry) => total + entry.amount);

  double get _expense => _entries
      .where((entry) => entry.type == EntryType.expense)
      .fold(0, (total, entry) => total + entry.amount);

  double get _balance => _income - _expense;

  void _addEntry(LedgerEntry entry) {
    setState(() => _entries.insert(0, entry));
  }

  Future<void> _openEntrySheet() async {
    final entry = await showModalBottomSheet<LedgerEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const EntrySheet(),
    );

    if (entry != null) {
      _addEntry(entry);
    }
  }

  void _openImportFlow() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ImportSourcePage()));
  }

  void _openExportPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ExportBackupPage()));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      LedgerTimelinePage(
        entries: _entries,
        income: _income,
        expense: _expense,
        balance: _balance,
        onAdd: _openEntrySheet,
        onOpenSearch: () => setState(() => _selectedIndex = 2),
      ),
      StatisticsPage(entries: _entries),
      SearchPage(entries: _entries),
      SettingsPage(
        onOpenImport: _openImportFlow,
        onOpenExport: _openExportPage,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: '流水',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.manage_search),
            label: '搜索',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _openEntrySheet,
              tooltip: '记一笔',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

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
          for (final group in _groupEntriesByDay(entries)) ...[
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
                      _formatCurrency(balance),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Text(
                '本月可用 ${_formatCurrency(balance)}',
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
                  '支出 ${_formatCurrency(expense)}',
                  style: const TextStyle(
                    color: AppColors.expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '收入 ${_formatCurrency(income)}',
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
          '${total >= 0 ? '+' : ''}${_formatCurrency(total)}',
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
          CategoryAvatar(label: _categoryIcon(entry.category)),
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
            '$sign${_formatCurrency(entry.amount)}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class EntrySheet extends StatefulWidget {
  const EntrySheet({super.key});

  @override
  State<EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends State<EntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: '午餐');
  final _amountController = TextEditingController(text: '38.00');
  final _noteController = TextEditingController(text: '公司楼下午餐');
  EntryType _type = EntryType.expense;
  String _category = '餐饮';
  String _account = '现金账户';

  List<String> get _categories => switch (_type) {
    EntryType.expense => const ['餐饮', '交通', '购物', '居住', '娱乐', '其他'],
    EntryType.income => const ['工资', '奖金', '红包', '理财', '其他'],
    EntryType.transfer => const ['账户转账', '信用卡还款'],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit({bool keepOpen = false}) {
    if (!_formKey.currentState!.validate()) return;

    final entry = LedgerEntry(
      title: _titleController.text.trim(),
      category: _category,
      amount: double.parse(_amountController.text.trim()),
      type: _type,
      date: DateTime.now(),
      account: _account,
      note: _noteController.text.trim(),
    );

    if (keepOpen) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已保存，可继续记下一笔')));
      _titleController.clear();
      _amountController.clear();
      _noteController.clear();
      return;
    }

    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '记一笔',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              SegmentedButton<EntryType>(
                segments: const [
                  ButtonSegment(value: EntryType.expense, label: Text('支出')),
                  ButtonSegment(value: EntryType.income, label: Text('收入')),
                  ButtonSegment(value: EntryType.transfer, label: Text('转账')),
                ],
                selected: {_type},
                onSelectionChanged: (value) {
                  setState(() {
                    _type = value.first;
                    _category = _categories.first;
                  });
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: '金额',
                  prefixText: '¥ ',
                  border: UnderlineInputBorder(),
                ),
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount <= 0) return '请输入有效金额';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              Text(
                '分类',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final category in _categories)
                    ChoiceChip(
                      label: Text(category),
                      selected: category == _category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return '请输入名称';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _account,
                decoration: const InputDecoration(
                  labelText: '账户',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '现金账户', child: Text('现金账户')),
                  DropdownMenuItem(value: '银行卡', child: Text('银行卡')),
                  DropdownMenuItem(value: '支付宝', child: Text('支付宝')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _account = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _submit, child: const Text('保存')),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _submit(keepOpen: true),
                child: const Text('保存并再记一笔'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key, required this.entries});

  final List<LedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _categoryTotals(entries);
    final maxTotal = categoryTotals.isEmpty
        ? 1.0
        : categoryTotals
              .map((item) => item.value)
              .reduce((a, b) => a > b ? a : b);

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
                for (final item in categoryTotals.take(4)) ...[
                  Row(
                    children: [
                      Expanded(child: Text(item.key)),
                      Text(_formatCurrency(item.value)),
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
                for (final item in categoryTotals.take(3))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CategoryAvatar(label: _categoryIcon(item.key)),
                    title: Text(item.key),
                    subtitle: Text(
                      '${_countExpenseEntries(entries, item.key)} 笔',
                    ),
                    trailing: Text(
                      '-${_formatCurrency(item.value)}',
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
                '共 ${filtered.length} 笔 · 支出 ${_formatCurrency(expense)}',
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

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.onOpenImport,
    required this.onOpenExport,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const Spacer(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 112,
            height: 112,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 58, color: AppColors.primary),
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
          const Spacer(),
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

class FlowPage extends StatelessWidget {
  const FlowPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: AppText.muted(context)),
              const SizedBox(height: 22),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(subtitle, style: AppText.muted(context)),
          ],
        ),
        toolbarHeight: 82,
        actions: actions,
      ),
      body: SafeArea(child: child),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap ?? () {},
      label: Text(label),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.muted,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: selected ? AppColors.primarySoft : Colors.white,
      side: BorderSide.none,
      shape: const StadiumBorder(),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class ChartBar extends StatelessWidget {
  const ChartBar({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 19,
      backgroundColor: AppColors.subtle,
      foregroundColor: AppColors.text,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppText.muted(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
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

class AppText {
  static TextStyle muted(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(color: AppColors.muted, height: 1.35);
  }
}

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bg,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.bg,
        surfaceTintColor: AppColors.bg,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class AppColors {
  static const bg = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF17202A);
  static const muted = Color(0xFF6B7280);
  static const subtle = Color(0xFFE8EDF2);
  static const line = Color(0xFFDDE3EA);
  static const primary = Color(0xFF0F766E);
  static const primarySoft = Color(0xFFD9F5F1);
  static const income = Color(0xFF16803C);
  static const expense = Color(0xFFC2410C);
  static const warn = Color(0xFFB45309);
}

class DayGroup {
  const DayGroup({required this.label, required this.entries});

  final String label;
  final List<LedgerEntry> entries;
}

List<DayGroup> _groupEntriesByDay(List<LedgerEntry> entries) {
  final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));
  final groups = <String, List<LedgerEntry>>{};

  for (final entry in sorted) {
    final label = entry.date.day == 14 ? '今天 5月14日' : _formatDate(entry.date);
    groups.putIfAbsent(label, () => []).add(entry);
  }

  return groups.entries
      .map((entry) => DayGroup(label: entry.key, entries: entry.value))
      .toList();
}

List<MapEntry<String, double>> _categoryTotals(List<LedgerEntry> entries) {
  final totals = <String, double>{};

  for (final entry in entries.where(
    (entry) => entry.type == EntryType.expense,
  )) {
    totals.update(
      entry.category,
      (amount) => amount + entry.amount,
      ifAbsent: () => entry.amount,
    );
  }

  return totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
}

int _countExpenseEntries(List<LedgerEntry> entries, String category) {
  return entries
      .where(
        (entry) =>
            entry.type == EntryType.expense && entry.category == category,
      )
      .length;
}

String _categoryIcon(String category) {
  if (category.contains('餐') || category.contains('咖')) return '餐';
  if (category.contains('交通')) return '行';
  if (category.contains('工资')) return '薪';
  if (category.contains('居住')) return '住';
  if (category.contains('购物')) return '购';
  if (category.contains('红包')) return '红';
  return '…';
}

String _formatCurrency(double value) {
  final abs = value.abs();
  final isWhole = abs == abs.roundToDouble();
  final amount = isWhole ? abs.toStringAsFixed(0) : abs.toStringAsFixed(2);
  return '¥$amount';
}

String _formatDate(DateTime date) {
  return '${date.month}月${date.day}日';
}
