import '../models/automation_model.dart';
import '../models/condition_model.dart';
import '../models/task_model.dart';

/// 自动化状态
class AutomationState {
  final List<AutomationModel> automations = [];
  final List<ConditionModel> tempConditions = [];
  final List<TaskModel> tempTasks = [];
  bool isLoading = false;
  String? error;

  AutomationState();

  /// 获取空状态
  bool get isEmpty => automations.isEmpty;

  /// 获取是否有错误
  bool get hasError => error != null;

  @override
  String toString() {
    return 'AutomationState(automations: $automations, isLoading: $isLoading, error: $error)';
  }
}

/// 自动化创建状态
class AutomationCreationState {
  final List<ConditionModel> conditions;
  final List<TaskModel> tasks;
  final bool isConditionValid;
  final bool isTaskValid;

  const AutomationCreationState({
    this.conditions = const [],
    this.tasks = const [],
    this.isConditionValid = false,
    this.isTaskValid = false,
  });

  AutomationCreationState copyWith({
    List<ConditionModel>? conditions,
    List<TaskModel>? tasks,
    bool? isConditionValid,
    bool? isTaskValid,
  }) {
    return AutomationCreationState(
      conditions: conditions ?? this.conditions,
      tasks: tasks ?? this.tasks,
      isConditionValid: isConditionValid ?? this.isConditionValid,
      isTaskValid: isTaskValid ?? this.isTaskValid,
    );
  }

  /// 检查是否可以完成创建
  bool get canComplete => conditions.isNotEmpty && tasks.isNotEmpty;
} 