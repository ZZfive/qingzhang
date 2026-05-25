import 'package:accounting_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('non-device MVP checks', () {
    testWidgets('shows prototype-aligned shell and data controls', (
      tester,
    ) async {
      await _pumpApp(tester);

      expect(find.text('¥14732'), findsAtLeastNWidgets(1));
      expect(find.text('当月收入'), findsOneWidget);
      expect(find.text('当月支出'), findsOneWidget);
      expect(find.byTooltip('账本'), findsOneWidget);
      expect(find.text('流水'), findsOneWidget);
      expect(find.text('统计'), findsOneWidget);
      expect(find.text('搜索'), findsAtLeastNWidgets(1));
      expect(find.text('设置'), findsOneWidget);

      await tester.tap(find.byTooltip('账本'));
      await tester.pumpAndSettle();

      expect(find.text('账本'), findsOneWidget);
      expect(find.text('新建账本'), findsOneWidget);
      expect(find.text('旅行账本'), findsOneWidget);

      await tester.tap(find.text('新建账本'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '工作后的账本');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('账本'));
      await tester.pumpAndSettle();
      expect(find.text('工作后的账本'), findsAtLeastNWidgets(1));

      await tester.pageBack();
      await tester.pumpAndSettle();
      await _tapNavLabel(tester, '设置');

      expect(find.text('支出分类'), findsOneWidget);
      await _ensureVisible(tester, '收入分类');
      expect(find.text('收入分类'), findsOneWidget);
      expect(find.text('数据与备份'), findsOneWidget);
      await _ensureVisible(tester, '导入 Timi 记账数据');
      expect(find.text('导入 Timi 记账数据'), findsOneWidget);
      await _ensureVisible(tester, '导出 / 备份');
      expect(find.text('导出 / 备份'), findsOneWidget);
    });

    testWidgets('adds an expense through the quick entry sheet', (
      tester,
    ) async {
      await _pumpApp(tester);

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      expect(find.byTooltip('取消'), findsOneWidget);
      expect(find.text('支出'), findsOneWidget);
      expect(find.text('给父母'), findsAtLeastNWidgets(1));

      await tester.tap(find.text('8').last);
      await tester.tap(find.text('8').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.textContaining('给父母 88'), findsOneWidget);
    });

    testWidgets('opens an existing entry for editing from the timeline', (
      tester,
    ) async {
      await _pumpApp(tester);

      await tester.tap(find.textContaining('餐饮 38').first);
      await tester.pumpAndSettle();

      expect(find.byTooltip('取消'), findsOneWidget);
      expect(find.text('餐饮'), findsAtLeastNWidgets(1));
      expect(find.textContaining('38'), findsAtLeastNWidgets(1));
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
      await _ensureVisibleAndTap(tester, '导入 Timi 记账数据');

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
      await _ensureVisibleAndTap(tester, '导出 / 备份');

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
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const AccountingApp());
  await tester.pumpAndSettle();
}

Future<void> _tapNavLabel(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _ensureVisibleAndTap(WidgetTester tester, String label) async {
  await _ensureVisible(tester, label);
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle();
}

Future<void> _ensureVisible(WidgetTester tester, String label) async {
  final finder = find.text(label);
  final verticalScrollable = find.byWidgetPredicate((widget) {
    return widget is Scrollable &&
        (widget.axisDirection == AxisDirection.down ||
            widget.axisDirection == AxisDirection.up);
  });
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      240,
      scrollable: verticalScrollable.last,
    );
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}
