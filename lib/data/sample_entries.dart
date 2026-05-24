import '../models/entry_type.dart';
import '../models/ledger_entry.dart';

List<LedgerEntry> sampleEntries() {
  return [
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
}
