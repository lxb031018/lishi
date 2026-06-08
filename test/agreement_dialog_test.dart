import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lishi/widgets/agreement_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // 每个测试前清掉 SharedPreferences, 避免污染
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => AgreementDialog.show(ctx),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('弹窗显示标题、两份协议卡片、勾选框、两个按钮', (tester) async {
    await pumpDialog(tester);

    expect(find.text('欢迎使用粒时'), findsOneWidget);
    expect(find.text('《粒时用户协议》'), findsOneWidget);
    expect(find.text('《粒时隐私政策》'), findsOneWidget);
    expect(find.text('我已阅读并同意上述协议'), findsOneWidget);
    expect(find.text('同意并继续'), findsOneWidget);
    expect(find.text('不同意并退出'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
  });

  testWidgets('未勾选时"同意并继续"按钮是禁用的', (tester) async {
    await pumpDialog(tester);

    final agreeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '同意并继续'),
    );
    expect(agreeButton.onPressed, isNull);
  });

  testWidgets('勾选后"同意并继续"按钮可用, 点击后写 SharedPreferences 并返回 true',
      (tester) async {
    await pumpDialog(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    final agreeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '同意并继续'),
    );
    expect(agreeButton.onPressed, isNotNull);

    // 点击 "同意并继续", 异步写 prefs + 关闭弹窗
    await tester.tap(find.text('同意并继续'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(AgreementDialog.prefsKey), isTrue);
  });

  testWidgets('点击"不同意并退出"返回 false, 不写 SharedPreferences', (tester) async {
    bool? dialogResult;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  dialogResult = await AgreementDialog.show(ctx);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('不同意并退出'));
    await tester.pumpAndSettle();

    expect(dialogResult, false);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(AgreementDialog.prefsKey), isNull);
  });
}
