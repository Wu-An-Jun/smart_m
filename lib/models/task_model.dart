/// 任务类型枚举
enum TaskType {
  device, // 设备服务
  app, // 应用服务
}

/// 任务模型类
class TaskModel {
  final String id;
  final TaskType type;
  final String title;
  final String description;
  final Map<String, dynamic> settings;

  const TaskModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.settings,
  });

  TaskModel copyWith({
    String? id,
    TaskType? type,
    String? title,
    String? description,
    Map<String, dynamic>? settings,
  }) {
    return TaskModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      settings: settings ?? this.settings,
    );
  }
}

/// 设备服务设置
class DeviceServiceSettings {
  final String? selectedDevice;
  final String? selectedAction;

  const DeviceServiceSettings({
    this.selectedDevice,
    this.selectedAction,
  });

  Map<String, dynamic> toMap() {
    return {
      'selectedDevice': selectedDevice,
      'selectedAction': selectedAction,
    };
  }

  factory DeviceServiceSettings.fromMap(Map<String, dynamic> map) {
    return DeviceServiceSettings(
      selectedDevice: map['selectedDevice'] as String?,
      selectedAction: map['selectedAction'] as String?,
    );
  }
}

/// 应用服务设置
class AppServiceSettings {
  final String serviceType; // 发送短信通知、发送邮件等

  const AppServiceSettings({
    required this.serviceType,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceType': serviceType,
    };
  }

  factory AppServiceSettings.fromMap(Map<String, dynamic> map) {
    return AppServiceSettings(
      serviceType: map['serviceType'] as String? ?? '发送短信通知',
    );
  }
} 