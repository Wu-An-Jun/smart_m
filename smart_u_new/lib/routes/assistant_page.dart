import 'package:flutter/material.dart';
import 'smart_home_automation_page.dart';

/// 智能助手页面 - 使用智能家居自动化界面
class AssistantPage extends StatelessWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 直接返回智能管家界面
    return const SmartHomeAutomationPage();
  }
} 