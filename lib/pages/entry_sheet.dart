import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../models/ledger_book.dart';
import '../models/ledger_entry.dart';
import '../theme/app_colors.dart';
import 'ledger_timeline_page.dart';

class EntrySheet extends StatefulWidget {
  const EntrySheet({
    super.key,
    required this.books,
    required this.selectedBookId,
    required this.expenseCategories,
    required this.incomeCategories,
    this.entry,
  });

  final List<LedgerBook> books;
  final String selectedBookId;
  final List<String> expenseCategories;
  final List<String> incomeCategories;
  final LedgerEntry? entry;

  @override
  State<EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends State<EntrySheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  EntryType _type = EntryType.expense;
  late String _category;
  late String _account;
  late String _bookId;

  List<String> get _categories => switch (_type) {
    EntryType.expense => widget.expenseCategories,
    EntryType.income => widget.incomeCategories,
    EntryType.transfer => const ['账户转账', '信用卡还款'],
  };

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _type = entry?.type ?? EntryType.expense;
    _category = entry?.category ?? _categories.first;
    _account = entry?.account ?? '现金账户';
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

    final entry = LedgerEntry(
      bookId: _bookId,
      title: _category,
      category: _category,
      amount: amount,
      type: _type,
      date: widget.entry?.date ?? DateTime.now(),
      account: _account,
      note: _noteController.text.trim(),
      source: widget.entry?.source,
    );

    Navigator.of(context).pop(entry);
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
    setState(() {});
  }

  void _deleteAmount() {
    final text = _amountController.text;
    if (text.isEmpty) return;
    _amountController.text = text.substring(0, text.length - 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .92,
      minChildSize: .72,
      maxChildSize: .96,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              18,
              12,
              18,
              MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EntrySheetHeader(
                  editing: widget.entry != null,
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _submit,
                ),
                const SizedBox(height: 14),
                SegmentedButton<EntryType>(
                  segments: const [
                    ButtonSegment(value: EntryType.expense, label: Text('支出')),
                    ButtonSegment(value: EntryType.income, label: Text('收入')),
                  ],
                  selected: {
                    _type == EntryType.transfer ? EntryType.expense : _type,
                  },
                  onSelectionChanged: (value) => _changeType(value.first),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _bookId,
                  decoration: const InputDecoration(
                    labelText: '账本',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final book in widget.books)
                      DropdownMenuItem(value: book.id, child: Text(book.name)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _bookId = value);
                  },
                ),
                const SizedBox(height: 18),
                CategoryGrid(
                  categories: _categories,
                  selectedCategory: _category,
                  onSelected: (category) =>
                      setState(() => _category = category),
                ),
                const SizedBox(height: 18),
                AmountPanel(
                  amountController: _amountController,
                  noteController: _noteController,
                  account: _account,
                  onAccountChanged: (value) => setState(() => _account = value),
                ),
                const SizedBox(height: 12),
                NumberPad(onInput: _appendAmount, onDelete: _deleteAmount),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EntrySheetHeader extends StatelessWidget {
  const EntrySheetHeader({
    super.key,
    required this.editing,
    required this.onCancel,
    required this.onSave,
  });

  final bool editing;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(onPressed: onCancel, child: const Text('取消')),
        Expanded(
          child: Text(
            editing ? '修改账目' : '账目设置',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        SizedBox(
          width: 72,
          child: FilledButton(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('保存'),
          ),
        ),
      ],
    );
  }
}

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 10,
        childAspectRatio: .88,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        final selected = category == selectedCategory;
        return InkWell(
          onTap: () => onSelected(category),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: selected
                    ? categoryColor(category)
                    : AppColors.subtle,
                child: Icon(
                  categoryIconData(category),
                  color: selected ? Colors.white : AppColors.muted,
                  size: 23,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.text : AppColors.muted,
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

class AmountPanel extends StatelessWidget {
  const AmountPanel({
    super.key,
    required this.amountController,
    required this.noteController,
    required this.account,
    required this.onAccountChanged,
  });

  final TextEditingController amountController;
  final TextEditingController noteController;
  final String account;
  final ValueChanged<String> onAccountChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: '金额',
            prefixText: '¥ ',
            border: OutlineInputBorder(),
          ),
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: '备注',
            hintText: '可填写商户、用途或补充说明',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: account,
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
            if (value != null) onAccountChanged(value);
          },
        ),
      ],
    );
  }
}

class NumberPad extends StatelessWidget {
  const NumberPad({super.key, required this.onInput, required this.onDelete});

  final ValueChanged<String> onInput;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0'];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 2.8,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (final key in keys)
          OutlinedButton(
            onPressed: () => onInput(key),
            child: Text(
              key,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
        OutlinedButton(
          onPressed: onDelete,
          child: const Icon(Icons.backspace_outlined),
        ),
      ],
    );
  }
}

String _formatAmount(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}
