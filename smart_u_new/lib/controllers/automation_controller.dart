import 'package:flutter/foundation.dart';
import '../states/automation_state.dart';
import '../models/automation_model.dart';
import '../models/condition_model.dart';
import '../models/task_model.dart';

/// 自动化控制器
class AutomationController extends ChangeNotifier {
  final AutomationState _state = AutomationState();
  
  AutomationState get state => _state;

  AutomationController() {
    _initializeData();
  }

  /// 初始化数据
  void _initializeData() {
    // 初始状态为空，显示空状态界面
    _state.automations.clear();
    notifyListeners();
  }

  /// 添加自动化规则
  void addAutomation(AutomationModel automation) {
    _state.automations.add(automation);
    notifyListeners();
  }

  /// 删除自动化规则
  void removeAutomation(int id) {
    _state.automations.removeWhere((automation) => automation.id == id);
    notifyListeners();
  }

  /// 切换自动化规则状态
  void toggleAutomation(int id) {
    final index = _state.automations.indexWhere((automation) => automation.id == id);
    if (index != -1) {
      _state.automations[index] = _state.automations[index].copyWith(
        isEnabled: !_state.automations[index].isEnabled,
      );
      notifyListeners();
    }
  }

  /// 更新自动化规则
  void updateAutomation(int id, AutomationModel updatedAutomation) {
    final updatedList = _state.automations.map((automation) {
      return automation.id == id ? updatedAutomation : automation;
    }).toList();
    
    _state.automations.clear();
    _state.automations.addAll(updatedList);
    notifyListeners();
  }

  /// 加载预设数据
  void loadPresetData() {
    _state.automations.clear();
    _state.automations.addAll([
      AutomationModel(
        id: 1,
        title: '离家提醒',
        description: '自动关闭设备和通知离家信息',
        icon: 'home',
        iconBg: 'red',
        iconColor: 'white',
        subText: '离家时自动执行',
        defaultChecked: true,
        isEnabled: true,
      ),
      AutomationModel(
        id: 2,
        title: '回家提醒',
        description: '自动开启设备和发送欢迎信息',
        icon: 'welcome',
        iconBg: 'green',
        iconColor: 'white',
        subText: '回家时自动执行',
        defaultChecked: false,
        isEnabled: false,
      ),
      AutomationModel(
        id: 3,
        title: '帮助睡眠设备',
        description: '晚上自动调节设备状态帮助睡眠',
        icon: 'sleep',
        iconBg: 'blue',
        iconColor: 'white',
        subText: '睡眠时自动执行',
        defaultChecked: true,
        isEnabled: true,
      ),
    ]);
    notifyListeners();
  }

  /// 设置加载状态
  void setLoading(bool isLoading) {
    _state.isLoading = isLoading;
    notifyListeners();
  }

  /// 设置错误信息
  void setError(String? error) {
    _state.error = error;
    notifyListeners();
  }
}

/// 自动化创建流程状态
class AutomationCreationState {
  final List<ConditionModel> conditions = [];
  final List<TaskModel> tasks = [];

  /// 检查是否可以完成创建
  bool get canComplete => conditions.isNotEmpty && tasks.isNotEmpty;

  /// 清空所有数据
  void clear() {
    conditions.clear();
    tasks.clear();
  }
}

/// 自动化创建控制器
class AutomationCreationController extends ChangeNotifier {
  final AutomationCreationState _state = AutomationCreationState();

  AutomationCreationState get state => _state;

  /// 添加条件
  void addCondition(ConditionModel condition) {
    _state.conditions.add(condition);
    notifyListeners();
  }

  /// 移除条件
  void removeCondition(String id) {
    _state.conditions.removeWhere((condition) => condition.id == id);
    notifyListeners();
  }

  /// 添加任务
  void addTask(TaskModel task) {
    _state.tasks.add(task);
    notifyListeners();
  }

  /// 移除任务
  void removeTask(String id) {
    _state.tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  /// 添加示例数据
  void addSampleData() {
    // 添加示例条件
    _state.conditions.add(
      ConditionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: ConditionType.time,
        title: '工作日早晨',
        description: '周一至周五 08:00-09:00',
        settings: const TimeSettings(
          period: '工作日',
          startTime: '08:00',
          endTime: '09:00',
        ).toMap(),
      ),
    );

    // 添加示例任务
    _state.tasks.add(
      TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TaskType.app,
        title: '发送提醒',
        description: '发送早晨提醒通知',
        settings: const AppServiceSettings(
          serviceType: '发送早晨提醒',
        ).toMap(),
      ),
    );

    notifyListeners();
  }

  /// 清空数据
  void clear() {
    _state.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
} 