/// 条件类型枚举
enum ConditionType {
  environment, // 生活环境变化
  time, // 特定时间
}

/// 条件模型类
class ConditionModel {
  final String id;
  final ConditionType type;
  final String title;
  final String description;
  final Map<String, dynamic> settings;

  const ConditionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.settings,
  });

  ConditionModel copyWith({
    String? id,
    ConditionType? type,
    String? title,
    String? description,
    Map<String, dynamic>? settings,
  }) {
    return ConditionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      settings: settings ?? this.settings,
    );
  }
}

/// 环境条件设置
class EnvironmentSettings {
  final double? targetTemperature;
  final String? temperatureComparison; // "达到" 或 "低于"
  final double? targetHumidity;
  final String? humidityComparison;
  final String? weather; // 天气条件
  final String? city;

  const EnvironmentSettings({
    this.targetTemperature,
    this.temperatureComparison,
    this.targetHumidity,
    this.humidityComparison,
    this.weather,
    this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'targetTemperature': targetTemperature,
      'temperatureComparison': temperatureComparison,
      'targetHumidity': targetHumidity,
      'humidityComparison': humidityComparison,
      'weather': weather,
      'city': city,
    };
  }

  factory EnvironmentSettings.fromMap(Map<String, dynamic> map) {
    return EnvironmentSettings(
      targetTemperature: map['targetTemperature']?.toDouble(),
      temperatureComparison: map['temperatureComparison'] as String?,
      targetHumidity: map['targetHumidity']?.toDouble(),
      humidityComparison: map['humidityComparison'] as String?,
      weather: map['weather'] as String?,
      city: map['city'] as String?,
    );
  }
}

/// 时间条件设置
class TimeSettings {
  final String period; // "每天", "工作日", "周末"
  final String startTime;
  final String endTime;

  const TimeSettings({
    required this.period,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'period': period,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory TimeSettings.fromMap(Map<String, dynamic> map) {
    return TimeSettings(
      period: map['period'] as String? ?? '每天',
      startTime: map['startTime'] as String? ?? '10:00',
      endTime: map['endTime'] as String? ?? '11:00',
    );
  }
} 