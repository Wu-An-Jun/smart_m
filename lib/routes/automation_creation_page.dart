import 'package:flutter/material.dart';
import '../controllers/automation_controller.dart';
import '../models/automation_model.dart';
import '../models/condition_model.dart';
import '../models/task_model.dart';
import '../widgets/smart_home_layout.dart';
import '../widgets/condition_type_dialog.dart';
import 'time_condition_page.dart';
import 'environment_condition_page.dart';
import 'task_setting_page.dart';

/// 自动化规则创建页面
class AutomationCreationPage extends StatefulWidget {
  final Function(AutomationModel) onAutomationCreated;

  const AutomationCreationPage({
    super.key,
    required this.onAutomationCreated,
  });

  @override
  State<AutomationCreationPage> createState() => _AutomationCreationPageState();
}

class _AutomationCreationPageState extends State<AutomationCreationPage> {
  late AutomationCreationController _creationController;

  @override
  void initState() {
    super.initState();
    _creationController = AutomationCreationController();
  }

  @override
  void dispose() {
    _creationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _creationController,
      builder: (context, _) {
        final state = _creationController.state;
        
        return SmartHomeLayout(
          title: '自动化设置',
          showBackButton: true,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildConditionsSection(state),
                      const SizedBox(height: 20),
                      _buildTaskSection(state),
                      const SizedBox(height: 20),
                      _buildQuickAddSection(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(context, state),
            ],
          ),
        );
      },
    );
  }

  /// 构建条件设置区域
  Widget _buildConditionsSection(state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '设置触发条件',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        
        // 显示已设置的条件
        if (state.conditions.isNotEmpty) ...[
          ...state.conditions.map((condition) => _buildConditionCard(condition)),
          const SizedBox(height: 8),
        ],
        
        // 添加条件按钮
        GestureDetector(
          onTap: _showConditionTypeDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  size: 24,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Text(
                  state.conditions.isEmpty ? '触发条件' : '继续添加条件',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.flash_on,
                  size: 16,
                  color: Color(0xFF3B82F6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建任务设置区域
  Widget _buildTaskSection(state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '设置任务',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        
        // 显示已设置的任务
        if (state.tasks.isNotEmpty) ...[
          ...state.tasks.map((task) => _buildTaskCard(task)),
          const SizedBox(height: 8),
        ],
        
        // 添加任务按钮
        GestureDetector(
          onTap: _navigateToTaskSetting,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  size: 24,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Text(
                  state.tasks.isEmpty ? '执行任务' : '继续添加任务',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.flash_on,
                  size: 16,
                  color: Color(0xFF3B82F6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建条件卡片
  Widget _buildConditionCard(ConditionModel condition) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF7C3AED),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9D5FF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              condition.type == ConditionType.environment 
                  ? Icons.water_drop_outlined 
                  : Icons.access_time,
              size: 14,
              color: const Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  condition.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  condition.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Text(
            '已设置',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF10B981),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.flash_on,
            size: 12,
            color: Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  /// 构建任务卡片
  Widget _buildTaskCard(TaskModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF059669),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              task.type == TaskType.device 
                  ? Icons.devices_outlined 
                  : Icons.notifications_outlined,
              size: 14,
              color: const Color(0xFF059669),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  task.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Text(
            '已设置',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF10B981),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.check_circle,
            size: 12,
            color: Color(0xFF059669),
          ),
        ],
      ),
    );
  }

  /// 构建快速添加区域
  Widget _buildQuickAddSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速添加示例',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _creationController.addSampleData(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              border: Border.all(
                color: const Color(0xFF0EA5E9),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: Color(0xFF0EA5E9),
                ),
                SizedBox(width: 8),
                Text(
                  '添加示例数据',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0EA5E9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建底部操作按钮
  Widget _buildBottomActions(BuildContext context, state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: const Text(
                '取消',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: (!state.canComplete) 
                  ? null 
                  : () => _handleConfirm(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: (!state.canComplete) 
                    ? const Color(0xFF9CA3AF) 
                    : const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (!state.canComplete) 
                        ? '请完善设置' 
                        : '完成',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (state.canComplete) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.flash_on, size: 16, color: Colors.yellow),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示条件类型对话框
  void _showConditionTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => ConditionTypeDialog(
        onTypeSelected: _navigateToConditionSetup,
      ),
    );
  }

  /// 导航到条件设置页面
  void _navigateToConditionSetup(ConditionType type) {
    switch (type) {
      case ConditionType.environment:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnvironmentConditionPage(
              onConditionSet: _addCondition,
            ),
          ),
        );
        break;
      case ConditionType.time:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimeConditionPage(
              onConditionSet: _addCondition,
            ),
          ),
        );
        break;
    }
  }

  /// 导航到任务设置页面
  void _navigateToTaskSetting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskSettingPage(
          onTaskSet: _addTask,
        ),
      ),
    );
  }

  /// 添加条件
  void _addCondition(ConditionModel condition) {
    _creationController.addCondition(condition);
  }

  /// 添加任务
  void _addTask(TaskModel task) {
    _creationController.addTask(task);
  }

  /// 处理确认操作
  void _handleConfirm(BuildContext context, state) {
    if (state.conditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先设置触发条件')),
      );
      return;
    }

    if (state.tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先设置执行任务')),
      );
      return;
    }

    // 根据条件和任务生成自动化任务描述
    final conditionsDesc = state.conditions.map((c) => c.description).join(', ');
    final tasksDesc = state.tasks.map((t) => t.description).join(', ');
    
    final newAutomation = AutomationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '自定义自动化',
      description: '条件: $conditionsDesc | 任务: $tasksDesc',
      icon: 'bell',
      iconBg: 'purple',
      iconColor: 'purple',
      subText: '${state.conditions.length}个条件, ${state.tasks.length}个任务',
      defaultChecked: true,
    );

    // 回调给父页面
    widget.onAutomationCreated(newAutomation);

    // 返回上一页
    Navigator.pop(context);
    
    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('自动化任务创建成功！')),
    );
  }
} 