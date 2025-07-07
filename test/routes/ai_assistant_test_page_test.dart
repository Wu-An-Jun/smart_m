import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_rec/routes/ai_assistant_test_page.dart';

void main() {
  group('AiAssistantTestPage Tests', () {
    testWidgets('页面正确渲染所有必要组件', (WidgetTester tester) async {
      // 构建页面
      await tester.pumpWidget(
        const MaterialApp(
          home: AiAssistantTestPage(),
        ),
      );

      // 验证关键元素存在
      expect(find.byType(RichText), findsAtLeastNWidgets(1)); // 验证欢迎语RichText存在
      expect(find.text('您可以问我'), findsOneWidget);
      expect(find.text('猜你想问'), findsOneWidget);
      
      // 验证功能入口 - 注意有些文本会在多个地方出现
      expect(find.text('我的设备'), findsAtLeastNWidgets(1));
      expect(find.text('智能生活'), findsAtLeastNWidgets(2)); // 功能入口+底部导航
      expect(find.text('服务'), findsAtLeastNWidgets(1));
      
      // 验证问题卡片
      expect(find.text('怎么省电？有哪些小技巧？'), findsOneWidget);
      expect(find.text('工作日每天9-18点天闭摄像头。'), findsOneWidget);
      expect(find.text('打开客厅的摄像头。'), findsOneWidget);
      
      // 验证底部导航
      expect(find.text('智能管家'), findsOneWidget);
      expect(find.text('设备首页'), findsOneWidget);
      // expect(find.text('智能生活'), findsOneWidget); // 在功能入口已经验证过
      expect(find.text('我的'), findsOneWidget);
    });

    testWidgets('状态栏显示正确的时间和图标', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AiAssistantTestPage(),
        ),
      );

      // 验证状态栏时间
      expect(find.text('12:00'), findsOneWidget);
      
      // 验证状态栏图标存在
      expect(find.byIcon(Icons.signal_cellular_4_bar), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.byIcon(Icons.battery_full), findsOneWidget);
    });

    testWidgets('顶部菜单按钮存在', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AiAssistantTestPage(),
        ),
      );

      // 验证菜单和添加按钮
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('输入框和相关按钮正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AiAssistantTestPage(),
        ),
      );

      // 验证输入框
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('请输入消息...'), findsOneWidget);
      
      // 验证输入框周围的按钮
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.sentiment_satisfied_alt), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });

    testWidgets('功能入口图标正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AiAssistantTestPage(),
        ),
      );

      // 验证功能入口图标
      expect(find.byIcon(Icons.phone_android), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.headset_mic), findsOneWidget);
    });

    testWidgets('问题卡片点击区域存在', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AiAssistantTestPage(),
        ),
      );

      // 验证问题卡片的箭头图标
      expect(find.byIcon(Icons.chevron_right), findsAtLeastNWidgets(3));
      expect(find.byIcon(Icons.lightbulb_outline), findsAtLeastNWidgets(3));
    });

    testWidgets('底部导航图标正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AiAssistantTestPage(),
        ),
      );

      // 验证底部导航图标
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.tablet_android), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('页面可以滚动', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AiAssistantTestPage(),
        ),
      );

      // 验证可滚动widget存在
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('输入框可以接收文本输入', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AiAssistantTestPage(),
        ),
      );

      // 查找文本输入框
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // 点击输入框并输入文本
      await tester.tap(textField);
      await tester.enterText(textField, '测试消息');
      await tester.pump();

      // 验证文本已输入
      expect(find.text('测试消息'), findsOneWidget);
    });
  });
} 