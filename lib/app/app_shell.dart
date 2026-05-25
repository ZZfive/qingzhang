import 'package:flutter/material.dart';

import '../data/sample_entries.dart';
import '../models/entry_type.dart';
import '../models/ledger_book.dart';
import '../models/ledger_entry.dart';
import '../pages/entry_sheet.dart';
import '../pages/export_backup_page.dart';
import '../pages/import_pages.dart';
import '../pages/ledger_books_page.dart';
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
  String _selectedBookId = 'personal';

  final List<LedgerEntry> _entries = sampleEntries();
  final List<LedgerBook> _books = const [
    LedgerBook(id: 'personal', name: '个人账本', description: '日常消费和收入'),
    LedgerBook(id: 'travel', name: '旅行账本', description: '出行预算和结算'),
  ].toList();
  final List<String> _expenseCategories = [
    '餐饮',
    '交通',
    '购物',
    '居住',
    '娱乐',
    '水果',
    '零食',
    '医疗',
    '学习',
    '住宿',
    '其他',
  ];
  final List<String> _incomeCategories = [
    '工资',
    '奖金',
    '红包',
    '理财',
    '兼职',
    '报销',
    '其他',
  ];

  List<LedgerEntry> get _visibleEntries =>
      _entries.where((entry) => entry.bookId == _selectedBookId).toList();

  LedgerBook get _selectedBook =>
      _books.firstWhere((book) => book.id == _selectedBookId);

  double get _income => _entries
      .where(
        (entry) =>
            entry.bookId == _selectedBookId && entry.type == EntryType.income,
      )
      .fold(0, (total, entry) => total + entry.amount);

  double get _expense => _entries
      .where(
        (entry) =>
            entry.bookId == _selectedBookId && entry.type == EntryType.expense,
      )
      .fold(0, (total, entry) => total + entry.amount);

  double get _balance => _income - _expense;

  Future<void> _openEntrySheet([LedgerEntry? editingEntry]) async {
    final entry = await showModalBottomSheet<LedgerEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => EntrySheet(
        books: _books,
        selectedBookId: _selectedBookId,
        expenseCategories: _expenseCategories,
        incomeCategories: _incomeCategories,
        entry: editingEntry,
      ),
    );

    if (entry != null) {
      setState(() {
        if (editingEntry == null) {
          _entries.insert(0, entry);
        } else {
          final index = _entries.indexOf(editingEntry);
          if (index == -1) {
            _entries.insert(0, entry);
          } else {
            _entries[index] = entry;
          }
        }
      });
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

  void _openBooksPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LedgerBooksPage(
          books: _books,
          selectedBookId: _selectedBookId,
          onSelectBook: _selectBook,
          onAddBook: _addBook,
          onDeleteBook: _deleteBook,
        ),
      ),
    );
  }

  void _selectBook(String bookId) {
    setState(() => _selectedBookId = bookId);
  }

  void _addBook(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final id = 'book_${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _books.add(LedgerBook(id: id, name: trimmed, description: '自定义账本'));
      _selectedBookId = id;
    });
  }

  void _deleteBook(String bookId) {
    if (_books.length <= 1) return;
    setState(() {
      _books.removeWhere((book) => book.id == bookId);
      _entries.removeWhere((entry) => entry.bookId == bookId);
      if (_selectedBookId == bookId) {
        _selectedBookId = _books.first.id;
      }
    });
  }

  void _addCategory(EntryType type, String category) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;
    final categories = type == EntryType.income
        ? _incomeCategories
        : _expenseCategories;
    if (categories.contains(trimmed)) return;
    setState(() => categories.add(trimmed));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      LedgerTimelinePage(
        entries: _visibleEntries,
        selectedBookName: _selectedBook.name,
        income: _income,
        expense: _expense,
        balance: _balance,
        onAdd: _openEntrySheet,
        onEditEntry: _openEntrySheet,
        onOpenBooks: _openBooksPage,
        onOpenSearch: () => setState(() => _selectedIndex = 2),
      ),
      StatisticsPage(entries: _visibleEntries, bookName: _selectedBook.name),
      SearchPage(entries: _visibleEntries),
      SettingsPage(
        expenseCategories: _expenseCategories,
        incomeCategories: _incomeCategories,
        onAddCategory: _addCategory,
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
    );
  }
}
