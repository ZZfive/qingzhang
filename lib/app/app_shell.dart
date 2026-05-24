import 'package:flutter/material.dart';

import '../data/sample_entries.dart';
import '../models/entry_type.dart';
import '../models/ledger_entry.dart';
import '../pages/entry_sheet.dart';
import '../pages/export_backup_page.dart';
import '../pages/import_pages.dart';
import '../pages/ledger_timeline_page.dart';
import '../pages/search_page.dart';
import '../pages/settings_page.dart';
import '../pages/statistics_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<LedgerEntry> _entries = sampleEntries();

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
