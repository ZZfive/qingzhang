import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../models/ledger_book.dart';
import '../models/ledger_entry.dart';
import '../theme/app_colors.dart';
import '../utils/category_visuals.dart';

class EntrySheet extends StatefulWidget {
  const EntrySheet({
    super.key,
    required this.books,
    required this.selectedBookId,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.expenseCategoryIcons,
    required this.incomeCategoryIcons,
    this.entry,
  });

  final List<LedgerBook> books;
  final String selectedBookId;
  final List<String> expenseCategories;
  final List<String> incomeCategories;
  final Map<String, String> expenseCategoryIcons;
  final Map<String, String> incomeCategoryIcons;
  final LedgerEntry? entry;

  @override
  State<EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends State<EntrySheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  EntryType _type = EntryType.expense;
  late String _category;
  late String _bookId;

  List<String> get _categories => switch (_type) {
    EntryType.expense => widget.expenseCategories,
    EntryType.income => widget.incomeCategories,
    EntryType.transfer => const ['账户转账', '信用卡还款'],
  };

  Map<String, String> get _categoryIcons => switch (_type) {
    EntryType.expense => widget.expenseCategoryIcons,
    EntryType.income => widget.incomeCategoryIcons,
    EntryType.transfer => const {},
  };

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _type = entry?.type ?? EntryType.expense;
    _category = entry?.category ?? _categories.first;
    _bookId = entry?.bookId ?? widget.selectedBookId;
    _amountController.text = entry == null ? '' : _formatAmount(entry.amount);
    _noteController.text = entry?.note ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效金额')));
      return;
    }

    Navigator.of(context).pop(
      LedgerEntry(
        bookId: _bookId,
        title: _category,
        category: _category,
        categoryIconKey: _categoryIcons[_category],
        amount: amount,
        type: _type,
        date: widget.entry?.date ?? DateTime.now(),
        account: widget.entry?.account ?? '默认账户',
        note: _noteController.text.trim(),
        source: widget.entry?.source,
      ),
    );
  }

  void _changeType(EntryType type) {
    setState(() {
      _type = type;
      if (!_categories.contains(_category)) _category = _categories.first;
    });
  }

  void _appendAmount(String value) {
    final text = _amountController.text;
    if (value == '.' && text.contains('.')) return;
    if (text == '0' && value != '.') {
      _amountController.text = value;
    } else {
      _amountController.text = '$text$value';
    }
  }

  void _deleteAmount() {
    final text = _amountController.text;
    if (text.isEmpty) return;
    _amountController.text = text.substring(0, text.length - 1);
  }

  void _clearAmount() {
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            EntryTopBar(
              type: _type,
              onCancel: () => Navigator.of(context).pop(),
              onTypeChanged: _changeType,
            ),
            SelectedCategoryBar(
              category: _category,
              iconKey: _categoryIcons[_category],
              type: _type,
              amountController: _amountController,
            ),
            Expanded(
              child: CategoryPager(
                categories: _categories,
                categoryIcons: _categoryIcons,
                type: _type,
                selectedCategory: _category,
                onSelected: (category) => setState(() => _category = category),
              ),
            ),
            EntryMetaBar(
              noteController: _noteController,
              books: widget.books,
              bookId: _bookId,
              onBookChanged: (value) => setState(() => _bookId = value),
            ),
            NumberPad(
              onInput: _appendAmount,
              onDelete: _deleteAmount,
              onClear: _clearAmount,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class EntryTopBar extends StatelessWidget {
  const EntryTopBar({
    super.key,
    required this.type,
    required this.onCancel,
    required this.onTypeChanged,
  });

  final EntryType type;
  final VoidCallback onCancel;
  final ValueChanged<EntryType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close, size: 24),
            tooltip: '取消',
            color: AppColors.muted,
          ),
          const Spacer(),
          TypeTab(
            label: '收入',
            selected: type == EntryType.income,
            onTap: () => onTypeChanged(EntryType.income),
          ),
          const SizedBox(width: 26),
          TypeTab(
            label: '支出',
            selected: type == EntryType.expense,
            onTap: () => onTypeChanged(EntryType.expense),
          ),
          const Spacer(),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class TypeTab extends StatelessWidget {
  const TypeTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFFD4A22A) : AppColors.muted,
          fontSize: 20,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

class SelectedCategoryBar extends StatelessWidget {
  const SelectedCategoryBar({
    super.key,
    required this.category,
    required this.iconKey,
    required this.type,
    required this.amountController,
  });

  final String category;
  final String? iconKey;
  final EntryType type;
  final TextEditingController amountController;

  @override
  Widget build(BuildContext context) {
    final visual = categoryVisual(category, type: type, iconKey: iconKey);
    return Container(
      height: 54,
      color: visual.color,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: Colors.white.withValues(alpha: .2),
            child: Icon(visual.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: amountController,
            builder: (context, value, child) {
              final amount = value.text.isEmpty ? '0.00' : value.text;
              return Text(
                '¥ $amount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CategoryPager extends StatefulWidget {
  const CategoryPager({
    super.key,
    required this.categories,
    required this.categoryIcons,
    required this.type,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final Map<String, String> categoryIcons;
  final EntryType type;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  State<CategoryPager> createState() => _CategoryPagerState();
}

class _CategoryPagerState extends State<CategoryPager> {
  static const _pageSize = 15;
  final _controller = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <List<String>>[];
    for (var index = 0; index < widget.categories.length; index += _pageSize) {
      final end = (index + _pageSize).clamp(0, widget.categories.length);
      pages.add(widget.categories.sublist(index, end));
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) => setState(() => _pageIndex = index),
            itemBuilder: (context, pageIndex) {
              return CategoryGridPage(
                categories: pages[pageIndex],
                categoryIcons: widget.categoryIcons,
                type: widget.type,
                selectedCategory: widget.selectedCategory,
                onSelected: widget.onSelected,
              );
            },
          ),
        ),
        SizedBox(
          height: 18,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < pages.length; index++)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: index == _pageIndex
                        ? const Color(0xFFE1AE28)
                        : AppColors.line,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoryGridPage extends StatelessWidget {
  const CategoryGridPage({
    super.key,
    required this.categories,
    required this.categoryIcons,
    required this.type,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final Map<String, String> categoryIcons;
  final EntryType type;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 2,
        crossAxisSpacing: 6,
        childAspectRatio: 1.02,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        final selected = category == selectedCategory;
        final visual = categoryVisual(
          category,
          type: type,
          iconKey: categoryIcons[category],
        );
        return InkWell(
          onTap: () => onSelected(category),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: selected
                    ? visual.color
                    : visual.color.withValues(alpha: .88),
                child: Icon(visual.icon, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 3),
              Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.text : AppColors.muted,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EntryMetaBar extends StatelessWidget {
  const EntryMetaBar({
    super.key,
    required this.noteController,
    required this.books,
    required this.bookId,
    required this.onBookChanged,
  });

  final TextEditingController noteController;
  final List<LedgerBook> books;
  final String bookId;
  final ValueChanged<String> onBookChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: const Color(0xFFF2F3F5),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: bookId,
                isExpanded: true,
                items: [
                  for (final book in books)
                    DropdownMenuItem(value: book.id, child: Text(book.name)),
                ],
                onChanged: (value) {
                  if (value != null) onBookChanged(value);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: '备注',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.onInput,
    required this.onDelete,
    required this.onClear,
    required this.onSubmit,
  });

  final ValueChanged<String> onInput;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.66,
              children: [
                for (final key in const [
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8',
                  '9',
                ])
                  NumberKey(label: key, onTap: () => onInput(key)),
                NumberKey(label: '清零', onTap: onClear),
                NumberKey(label: '0', onTap: () => onInput('0')),
                NumberKey(label: '.', onTap: () => onInput('.')),
              ],
            ),
          ),
          SizedBox(
            width: 86,
            child: Column(
              children: [
                Expanded(
                  child: NumberKey(label: '+', onTap: () {}),
                ),
                Expanded(
                  child: NumberKey(label: '-', onTap: () {}),
                ),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: onSubmit,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAED),
                        border: Border.all(color: AppColors.line, width: .5),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 28,
                          color: AppColors.text,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
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

class NumberKey extends StatelessWidget {
  const NumberKey({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F4),
          border: Border.all(color: AppColors.line, width: .5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: label.length > 1 ? 21 : 26,
            color: AppColors.text,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}

String _formatAmount(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}
