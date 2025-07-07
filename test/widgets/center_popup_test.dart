import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_rec/widgets/center_popup.dart';

void main() {
  group('CenterPopup 组件测试', () {
    testWidgets('应该显示中间弹窗消息', (WidgetTester tester) async {
      const String testMessage = '测试消息';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    CenterPopup.show(context, testMessage);
                  },
                  child: const Text('显示弹窗'),
                );
              },
            ),
          ),
        ),
      );

      // 点击按钮显示弹窗
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // 验证弹窗消息是否显示
      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('弹窗应该在指定时间后消失', (WidgetTester tester) async {
      const String testMessage = '测试消息';
      const Duration testDuration = Duration(milliseconds: 500);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    CenterPopup.show(context, testMessage, duration: testDuration);
                  },
                  child: const Text('显示弹窗'),
                );
              },
            ),
          ),
        ),
      );

      // 点击按钮显示弹窗
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // 验证弹窗消息显示
      expect(find.text(testMessage), findsOneWidget);

      // 等待指定时间后弹窗应该消失
      await tester.pump(testDuration);
      expect(find.text(testMessage), findsNothing);
    });
  });
} 