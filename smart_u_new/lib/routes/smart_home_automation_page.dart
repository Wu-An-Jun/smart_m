import 'package:flutter/material.dart';
import '../controllers/automation_controller.dart';
import '../models/automation_model.dart';
import '../widgets/automation_card.dart';
import '../widgets/smart_home_layout.dart';
import 'automation_creation_page.dart';
import '../common/Global.dart';

/// 智能家居自动化页面
class SmartHomeAutomationPage extends StatefulWidget {
  const SmartHomeAutomationPage({super.key});

  @override
  State<SmartHomeAutomationPage> createState() => _SmartHomeAutomationPageState();
}

class _SmartHomeAutomationPageState extends State<SmartHomeAutomationPage> {
  late AutomationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AutomationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        
        return SmartHomeLayout(
          title: '智能管家',
          child: Column(
            children: [
              // 添加按钮
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToCreation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Global.currentTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      '创建自动化',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              // 内容区域
              Expanded(
                child: state.isEmpty 
                    ? _buildEmptyState()
                    : _buildAutomationList(state.automations),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Global.currentTheme.surfaceColor,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.lightbulb_outline,
                size: 60,
                color: Global.currentTheme.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '还没有自动化规则',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '创建您的第一个智能自动化规则\n让生活更加便利和智能',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadSampleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Global.currentTheme.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: const Text(
                '加载示例数据',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建自动化规则列表
  Widget _buildAutomationList(List<AutomationModel> automations) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: automations.length,
      itemBuilder: (context, index) {
        final automation = automations[index];
        return AutomationCard(
          automation: automation,
          onToggle: (enabled) => _toggleAutomation(automation.id),
          onDelete: () => _deleteAutomation(automation.id),
        );
      },
    );
  }

  /// 导航到创建页面
  void _navigateToCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AutomationCreationPage(
          onAutomationCreated: _onAutomationCreated,
        ),
      ),
    );
  }

  /// 当自动化创建完成时的回调
  void _onAutomationCreated(AutomationModel automation) {
    _controller.addAutomation(automation);
  }

  /// 切换自动化状态
  void _toggleAutomation(int id) {
    _controller.toggleAutomation(id);
  }

  /// 删除自动化
  void _deleteAutomation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个自动化规则吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.removeAutomation(id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('自动化规则已删除')),
              );
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// 加载示例数据
  void _loadSampleData() {
    _controller.loadPresetData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('示例数据已加载')),
    );
  }
} 