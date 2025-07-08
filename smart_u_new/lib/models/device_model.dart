import 'package:hive/hive.dart';

part 'device_model.g.dart';

/// 设备类型枚举
@HiveType(typeId: 1)
enum DeviceType {
  @HiveField(0)
  camera('camera', '摄像头'),
  @HiveField(1)
  map('map', '地图设备'),
  @HiveField(2)
  petTracker('pet_tracker', '宠物定位器'),
  @HiveField(3)
  smartSwitch('smart_switch', '智能开关'),
  @HiveField(4)
  router('router', '路由器'),
  @HiveField(5)
  light('light', '灯光');

  const DeviceType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 设备类别枚举
@HiveType(typeId: 2)
enum DeviceCategory {
  @HiveField(0)
  pet('pet', '宠物类家居'),
  @HiveField(1)
  living('living', '生活类家居'),
  @HiveField(2)
  security('security', '安全监控'),
  @HiveField(3)
  navigation('navigation', '导航定位');

  const DeviceCategory(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 设备信息模型
@HiveType(typeId: 3)
class DeviceModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final DeviceType type;
  @HiveField(3)
  final DeviceCategory category;
  @HiveField(4)
  final bool isOnline;
  @HiveField(5)
  final DateTime lastSeen;
  @HiveField(6)
  final String? description;
  @HiveField(7)
  final String? imageUrl;
  @HiveField(8)
  final String? videoUrl;
  @HiveField(9)
  final Map<String, dynamic>? properties;

  DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.isOnline,
    required this.lastSeen,
    this.description,
    this.imageUrl,
    this.videoUrl,
    this.properties,
  });

  DeviceModel copyWith({
    String? id,
    String? name,
    DeviceType? type,
    DeviceCategory? category,
    bool? isOnline,
    DateTime? lastSeen,
    String? description,
    String? imageUrl,
    String? videoUrl,
    Map<String, dynamic>? properties,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'category': category.value,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'properties': properties,
    };
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      name: json['name'],
      type: DeviceType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => DeviceType.camera,
      ),
      category: DeviceCategory.values.firstWhere(
        (e) => e.value == json['category'],
        orElse: () => DeviceCategory.living,
      ),
      isOnline: json['isOnline'],
      lastSeen: DateTime.parse(json['lastSeen']),
      description: json['description'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      properties: json['properties'],
    );
  }
} 