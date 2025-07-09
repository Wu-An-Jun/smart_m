import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/widgets/delete_confirmation_dialog.dart';
import '../../lib/common/global.dart';

void main() {
  group('DeleteConfirmationDialog Tests', () {
    late Widget testApp;

    setUp(() {
      testApp = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await DeleteConfirmationDialog.show(
                  context,
                  content: '测试内容',
                );
              },
              child: const Text('显示弹窗'),
            ),
          ),
        ),
      );
    });

    testWidgets('弹窗显示基本元素', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      
      // 点击按钮显示弹窗
      await tester.tap(find.text('显示弹窗'));
      await tester.pumpAndSettle();

      // 验证弹窗元素存在
      expect(find.text('确认删除'), findsOneWidget);
      expect(find.text('测试内容'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('点击取消按钮返回false', (WidgetTester tester) async {
      bool? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await DeleteConfirmationDialog.show(
                    context,
                    content: '测试内容',
                  );
                },
                child: const Text('显示弹窗'),
              ),
            ),
          ),
        ),
      );
      
      // 点击按钮显示弹窗
      await tester.tap(find.text('显示弹窗'));
      await tester.pumpAndSettle();

      // 点击取消按钮
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // 验证返回值
      expect(result, false);
    });

    testWidgets('点击确认按钮返回true', (WidgetTester tester) async {
      bool? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await DeleteConfirmationDialog.show(
                    context,
                    content: '测试内容',
                  );
                },
                child: const Text('显示弹窗'),
              ),
            ),
          ),
        ),
      );
      
      // 点击按钮显示弹窗
      await tester.tap(find.text('显示弹窗'));
      await tester.pumpAndSettle();

      // 点击删除按钮
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      // 验证返回值
      expect(result, true);
    });

    testWidgets('自定义标题和内容显示正确', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await DeleteConfirmationDialog.show(
                    context,
                    title: '自定义标题',
                    content: '自定义内容',
                    confirmText: '确定',
                    cancelText: '返回',
                  );
                },
                child: const Text('显示弹窗'),
              ),
            ),
          ),
        ),
      );
      
      // 点击按钮显示弹窗
      await tester.tap(find.text('显示弹窗'));
      await tester.pumpAndSettle();

      // 验证自定义文本
      expect(find.text('自定义标题'), findsOneWidget);
      expect(find.text('自定义内容'), findsOneWidget);
      expect(find.text('确定'), findsOneWidget);
      expect(find.text('返回'), findsOneWidget);
    });

    testWidgets('非危险操作显示帮助图标', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await DeleteConfirmationDialog.show(
                    context,
                    content: '测试内容',
                    isDangerous: false,
                  );
                },
                child: const Text('显示弹窗'),
              ),
            ),
          ),
        ),
      );
      
      // 点击按钮显示弹窗
      await tester.tap(find.text('显示弹窗'));
      await tester.pumpAndSettle();

      // 验证显示帮助图标而不是警告图标
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsNothing);
    });

    testWidgets('扩展方法正常工作', (WidgetTester tester) async {
      bool result = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await context.showDeleteConfirmation(
                    content: '测试内容',
                  );
                },
                child: const Text('显示弹窗'),
              ),
            ),
          ),
        ),
      );
      
      // 点击按钮显示弹窗
      await tester.tap(find.text('显示弹窗'));
      await tester.pumpAndSettle();

      // 点击删除按钮
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      // 验证扩展方法返回值
      expect(result, true);
    });

    testWidgets('弹窗无法通过点击外部关闭', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      
      // 点击按钮显示弹窗
      await tester.tap(find.text('显示弹窗'));
      await tester.pumpAndSettle();

      // 验证弹窗存在
      expect(find.text('确认删除'), findsOneWidget);

      // 尝试点击弹窗外部
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // 验证弹窗仍然存在
      expect(find.text('确认删除'), findsOneWidget);
    });
  });
} 