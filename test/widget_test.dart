import 'package:accounting_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('non-device MVP checks', () {
    testWidgets('shows prototype-aligned shell and data controls', (
      tester,
    ) async {
      await _pumpApp(tester);

      expect(find.text('清账'), findsOneWidget);
      expect(find.text('无广告，本地优先，打开就能记'), findsOneWidget);
      expect(find.text('5月结余'), findsOneWidget);
      expect(find.text('流水'), findsOneWidget);
      expect(find.text('统计'), findsOneWidget);
      expect(find.text('搜索'), findsAtLeastNWidgets(1));
      expect(find.text('设置'), findsOneWidget);

      await _tapNavLabel(tester, '设置');

      expect(find.text('数据与备份'), findsOneWidget);
      expect(find.text('导入 Timi 记账数据'), findsOneWidget);
      expect(find.text('导出 / 备份'), findsOneWidget);
    });

    testWidgets('adds an expense through the quick entry sheet', (
      tester,
    ) async {
      await _pumpApp(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('记一笔'), findsOneWidget);
      expect(find.text('支出'), findsOneWidget);
      expect(find.text('保存并再记一笔'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), '88');
      await tester.enterText(find.byType(TextFormField).at(1), '测试早餐');
      await tester.enterText(find.byType(TextFormField).at(2), '测试备注');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      expect(find.text('测试早餐'), findsOneWidget);
      expect(find.textContaining('测试备注'), findsOneWidget);
      expect(find.text('-¥88'), findsOneWidget);
    });

    testWidgets('filters transactions from the search tab', (tester) async {
      await _pumpApp(tester);

      await _tapNavLabel(tester, '搜索');

      expect(find.text('按金额、分类、时间和备注查账'), findsOneWidget);
      expect(find.text('搜索结果'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '咖啡');
      await tester.pumpAndSettle();

      expect(find.text('咖啡'), findsAtLeastNWidgets(1));
      expect(find.text('午餐'), findsNothing);
      expect(find.textContaining('共 1 笔'), findsOneWidget);

      await tester.tap(find.text('收入'));
      await tester.pumpAndSettle();

      expect(find.textContaining('共 0 笔'), findsOneWidget);
    });

    testWidgets('walks through the Timi import flow without a device', (
      tester,
    ) async {
      await _pumpApp(tester);

      await _tapNavLabel(tester, '设置');
      await tester.tap(find.text('导入 Timi 记账数据'));
      await tester.pumpAndSettle();

      expect(find.text('导入数据'), findsOneWidget);
      expect(find.text('Timi 记账'), findsOneWidget);

      await tester.tap(find.text('选择文件'));
      await tester.pumpAndSettle();

      expect(find.text('导入预览'), findsOneWidget);
      expect(find.text('8,426 条'), findsOneWidget);
      expect(find.text('12 个未知分类'), findsOneWidget);

      await _ensureVisibleAndTap(tester, '下一步：分类映射');

      expect(find.text('分类映射'), findsOneWidget);
      expect(find.text('早餐'), findsOneWidget);
      expect(find.text('餐饮 / 早餐'), findsOneWidget);

      await _ensureVisibleAndTap(tester, '开始导入');

      expect(find.text('导入完成'), findsOneWidget);
      expect(find.text('成功导入 8,411 条'), findsOneWidget);
      await _ensureVisible(tester, '撤销本次导入');
      expect(find.text('撤销本次导入'), findsOneWidget);
    });

    testWidgets('opens export and backup options from settings', (
      tester,
    ) async {
      await _pumpApp(tester);

      await _tapNavLabel(tester, '设置');
      await tester.tap(find.text('导出 / 备份'));
      await tester.pumpAndSettle();

      expect(find.text('导出与备份'), findsOneWidget);
      expect(find.text('完整导出，不锁数据'), findsOneWidget);
      expect(find.text('Excel .xlsx'), findsOneWidget);
      expect(find.text('CSV .csv'), findsOneWidget);
      expect(find.text('JSON 备份包'), findsOneWidget);

      await _ensureVisibleAndTap(tester, '生成备份包');
    });
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const AccountingApp());
  await tester.pumpAndSettle();
}

Future<void> _tapNavLabel(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _ensureVisibleAndTap(WidgetTester tester, String label) async {
  await _ensureVisible(tester, label);
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> _ensureVisible(WidgetTester tester, String label) async {
  final finder = find.text(label);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      240,
      scrollable: find.byType(Scrollable).last,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}
