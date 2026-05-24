String categoryIcon(String category) {
  if (category.contains('餐') || category.contains('咖')) return '餐';
  if (category.contains('交通')) return '行';
  if (category.contains('工资')) return '薪';
  if (category.contains('居住')) return '住';
  if (category.contains('购物')) return '购';
  if (category.contains('红包')) return '红';
  return '…';
}

String formatCurrency(double value) {
  final abs = value.abs();
  final isWhole = abs == abs.roundToDouble();
  final amount = isWhole ? abs.toStringAsFixed(0) : abs.toStringAsFixed(2);
  return '¥$amount';
}

String formatDate(DateTime date) {
  return '${date.month}月${date.day}日';
}
