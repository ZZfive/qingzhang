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
import '../utils/category_visuals.dart';

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
    '给父母',
    '一般',
    '用餐',
    '交通',
    '服饰',
    '丽人',
    '日用品',
    '娱乐',
    '食材',
    '零食',
    '酒水',
    '住房',
    '健身',
    '通讯',
    '人情',
    '学习',
    '医疗',
    '旅游',
    '数码',
    '红包',
    '快递物流',
    '水果',
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
  late final Map<String, String> _expenseCategoryIcons = {
    for (final category in _expenseCategories)
      category: inferCategoryIconKey(category, type: EntryType.expense),
  };
  late final Map<String, String> _incomeCategoryIcons = {
    for (final category in _incomeCategories)
      category: inferCategoryIconKey(category, type: EntryType.income),
  };

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
    final entry = await Navigator.of(
      context,
    ).push<LedgerEntry>(_entrySheetRoute(editingEntry));

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

  PageRouteBuilder<LedgerEntry> _entrySheetRoute(LedgerEntry? editingEntry) {
    return PageRouteBuilder<LedgerEntry>(
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => EntrySheet(
        books: _books,
        selectedBookId: _selectedBookId,
        expenseCategories: _expenseCategories,
        incomeCategories: _incomeCategories,
        expenseCategoryIcons: _expenseCategoryIcons,
        incomeCategoryIcons: _incomeCategoryIcons,
        entry: editingEntry,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
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

  Future<void> _openBooksPage() async {
    final result = await Navigator.of(context).push<LedgerBooksResult>(
      MaterialPageRoute(
        builder: (_) =>
            LedgerBooksPage(books: _books, selectedBookId: _selectedBookId),
      ),
    );
    if (result == null) return;
    switch (result) {
      case SelectLedgerBookResult(:final bookId):
        _selectBook(bookId);
      case AddLedgerBookResult(:final name):
        _addBook(name);
      case DeleteLedgerBookResult(:final bookId):
        _deleteBook(bookId);
    }
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

  void _addCategory(EntryType type, String category, String iconKey) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;
    final categories = type == EntryType.income
        ? _incomeCategories
        : _expenseCategories;
    final icons = type == EntryType.income
        ? _incomeCategoryIcons
        : _expenseCategoryIcons;
    if (categories.contains(trimmed)) return;
    setState(() {
      categories.add(trimmed);
      icons[trimmed] = iconKey;
    });
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
        onOpenSearch: _openSearchPage,
      ),
      SettingsPage(
        expenseCategories: _expenseCategories,
        incomeCategories: _incomeCategories,
        expenseCategoryIcons: _expenseCategoryIcons,
        incomeCategoryIcons: _incomeCategoryIcons,
        onAddCategory: _openAddCategoryDialog,
        onManageCategory: _openCategoryActions,
        onOpenImport: _openImportFlow,
        onOpenExport: _openExportPage,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex == 1 ? 2 : 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            _openStatisticsPage();
            return;
          }
          setState(() => _selectedIndex = index == 2 ? 1 : 0);
        },
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
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }

  void _openSearchPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SearchPage(entries: _visibleEntries)),
    );
  }

  void _openStatisticsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StatisticsPage(
          entries: _visibleEntries,
          bookName: _selectedBook.name,
        ),
      ),
    );
  }

  Future<void> _openAddCategoryDialog(EntryType type) async {
    final route = DialogRoute<CategoryEditResult>(
      context: context,
      builder: (_) => AddCategoryDialog(type: type),
    );
    final result = await Navigator.of(context).push(route);
    await route.completed;
    if (!mounted || result == null) return;
    _addCategory(type, result.name, result.iconKey);
  }

  Future<void> _openCategoryActions(EntryType type, String category) async {
    final action = await showModalBottomSheet<CategoryAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => CategoryActionsSheet(category: category),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case CategoryAction.edit:
        await _openEditCategoryDialog(type, category);
      case CategoryAction.delete:
        await _confirmDeleteCategory(type, category);
    }
  }

  Future<void> _openEditCategoryDialog(
    EntryType type,
    String originalCategory,
  ) async {
    final icons = type == EntryType.income
        ? _incomeCategoryIcons
        : _expenseCategoryIcons;
    final route = DialogRoute<CategoryEditResult>(
      context: context,
      builder: (_) => AddCategoryDialog(
        type: type,
        initialName: originalCategory,
        initialIconKey: icons[originalCategory],
      ),
    );
    final result = await Navigator.of(context).push(route);
    await route.completed;
    if (!mounted || result == null) return;
    _renameCategory(type, originalCategory, result.name, result.iconKey);
  }

  Future<void> _confirmDeleteCategory(EntryType type, String category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('删除$category？'),
        content: const Text('只会从可选分类中移除，不会删除已经记录的流水。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    _deleteCategory(type, category);
  }

  void _renameCategory(
    EntryType type,
    String oldCategory,
    String newCategory,
    String iconKey,
  ) {
    final trimmed = newCategory.trim();
    if (trimmed.isEmpty) return;
    final categories = type == EntryType.income
        ? _incomeCategories
        : _expenseCategories;
    final icons = type == EntryType.income
        ? _incomeCategoryIcons
        : _expenseCategoryIcons;
    if (trimmed != oldCategory && categories.contains(trimmed)) return;
    final index = categories.indexOf(oldCategory);
    if (index == -1) return;
    setState(() {
      categories[index] = trimmed;
      if (trimmed != oldCategory) icons.remove(oldCategory);
      icons[trimmed] = iconKey;
      for (var i = 0; i < _entries.length; i++) {
        final entry = _entries[i];
        if (entry.type == type && entry.category == oldCategory) {
          _entries[i] = entry.copyWith(
            title: trimmed,
            category: trimmed,
            categoryIconKey: iconKey,
          );
        }
      }
    });
  }

  void _deleteCategory(EntryType type, String category) {
    final categories = type == EntryType.income
        ? _incomeCategories
        : _expenseCategories;
    final icons = type == EntryType.income
        ? _incomeCategoryIcons
        : _expenseCategoryIcons;
    if (!categories.contains(category)) return;
    setState(() {
      categories.remove(category);
      icons.remove(category);
    });
  }
}
