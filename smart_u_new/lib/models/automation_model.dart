/// 自动化模型类
class AutomationModel {
  final int id;
  final String title;
  final String description;
  final String icon;
  final String iconBg;
  final String iconColor;
  final String subText;
  final bool defaultChecked;
  final bool isEnabled;

  const AutomationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.subText,
    required this.defaultChecked,
    this.isEnabled = true,
  });

  AutomationModel copyWith({
    int? id,
    String? title,
    String? description,
    String? icon,
    String? iconBg,
    String? iconColor,
    String? subText,
    bool? defaultChecked,
    bool? isEnabled,
  }) {
    return AutomationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      iconBg: iconBg ?? this.iconBg,
      iconColor: iconColor ?? this.iconColor,
      subText: subText ?? this.subText,
      defaultChecked: defaultChecked ?? this.defaultChecked,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'iconBg': iconBg,
      'iconColor': iconColor,
      'subText': subText,
      'defaultChecked': defaultChecked,
      'isEnabled': isEnabled,
    };
  }

  factory AutomationModel.fromJson(Map<String, dynamic> json) {
    return AutomationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      iconBg: json['iconBg'] as String,
      iconColor: json['iconColor'] as String,
      subText: json['subText'] as String,
      defaultChecked: json['defaultChecked'] as bool,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.icon == icon &&
        other.iconBg == iconBg &&
        other.iconColor == iconColor &&
        other.subText == subText &&
        other.defaultChecked == defaultChecked &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      icon,
      iconBg,
      iconColor,
      subText,
      defaultChecked,
      isEnabled,
    );
  }

  @override
  String toString() {
    return 'AutomationModel(id: $id, title: $title, description: $description, icon: $icon, iconBg: $iconBg, iconColor: $iconColor, subText: $subText, defaultChecked: $defaultChecked, isEnabled: $isEnabled)';
  }
} 