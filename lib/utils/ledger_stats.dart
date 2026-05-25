import '../models/entry_type.dart';
import '../models/ledger_entry.dart';
import 'ledger_formatters.dart';

class DayGroup {
  const DayGroup({required this.label, required this.entries});

  final String label;
  final List<LedgerEntry> entries;
}

List<DayGroup> groupEntriesByDay(List<LedgerEntry> entries) {
  final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));
  final groups = <String, List<LedgerEntry>>{};

  for (final entry in sorted) {
    final label = entry.date.day == 14 ? '今天 5月14日' : formatDate(entry.date);
    groups.putIfAbsent(label, () => []).add(entry);
  }

  return groups.entries
      .map((entry) => DayGroup(label: entry.key, entries: entry.value))
      .toList();
}

List<MapEntry<String, double>> categoryTotals(List<LedgerEntry> entries) {
  return categoryTotalsByType(entries, EntryType.expense);
}

List<MapEntry<String, double>> categoryTotalsByType(
  List<LedgerEntry> entries,
  EntryType type,
) {
  final totals = <String, double>{};

  for (final entry in entries.where((entry) => entry.type == type)) {
    totals.update(
      entry.category,
      (amount) => amount + entry.amount,
      ifAbsent: () => entry.amount,
    );
  }

  return totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
}

int countExpenseEntries(List<LedgerEntry> entries, String category) {
  return countEntriesByType(entries, category, EntryType.expense);
}

int countEntriesByType(
  List<LedgerEntry> entries,
  String category,
  EntryType type,
) {
  return entries
      .where((entry) => entry.type == type && entry.category == category)
      .length;
}
