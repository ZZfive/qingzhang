import 'package:flutter/material.dart';

import '../models/entry_type.dart';
import '../models/ledger_entry.dart';

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
