import 'entry_type.dart';

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
