import 'entry_type.dart';

class LedgerEntry {
  const LedgerEntry({
    required this.bookId,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.account = '现金账户',
    this.note = '',
    this.source,
    this.categoryIconKey,
  });

  final String bookId;
  final String title;
  final String category;
  final double amount;
  final EntryType type;
  final DateTime date;
  final String account;
  final String note;
  final String? source;
  final String? categoryIconKey;

  LedgerEntry copyWith({
    String? bookId,
    String? title,
    String? category,
    double? amount,
    EntryType? type,
    DateTime? date,
    String? account,
    String? note,
    String? source,
    String? categoryIconKey,
  }) {
    return LedgerEntry(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      account: account ?? this.account,
      note: note ?? this.note,
      source: source ?? this.source,
      categoryIconKey: categoryIconKey ?? this.categoryIconKey,
    );
  }
}
