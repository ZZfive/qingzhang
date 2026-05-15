import 'package:accounting_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows prototype-aligned shell and data controls', (
    tester,
  ) async {
    await tester.pumpWidget(const AccountingApp());

    expect(find.text('清账'), findsOneWidget);
    expect(find.text('无广告，本地优先，打开就能记'), findsOneWidget);
    expect(find.text('5月结余'), findsOneWidget);
    expect(find.text('流水'), findsOneWidget);
    expect(find.text('统计'), findsOneWidget);
    expect(find.text('搜索'), findsAtLeastNWidgets(1));
    expect(find.text('设置'), findsOneWidget);

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    expect(find.text('数据与备份'), findsOneWidget);
    expect(find.text('导入 Timi 记账数据'), findsOneWidget);
  });
}
