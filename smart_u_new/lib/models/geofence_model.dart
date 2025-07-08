/// 地理围栏状态枚举
enum GeofenceStatus {
  enter('进入围栏'),
  exit('离开围栏'),
  inside('在围栏内'),
  outside('在围栏外');

  const GeofenceStatus(this.displayName);
  final String displayName;
}

/// 地理围栏报警设置枚举
enum GeofenceAlertType {
  enter('进入围栏'),
  exit('离开围栏'),
  both('进出围栏');

  const GeofenceAlertType(this.displayName);
  final String displayName;
}

/// 地理围栏类型枚举
enum GeofenceType {
  circle('圆形围栏'),
  polygon('多边形围栏');

  const GeofenceType(this.displayName);
  final String displayName;
}

/// 地理位置点
class LocationPoint {
  final double latitude;
  final double longitude;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }
}

/// 地理围栏模型
class GeofenceModel {
  final String id;
  final String name;
  final GeofenceType type;
  final LocationPoint center;
  final double radius; // 圆形围栏半径
  final List<LocationPoint> vertices; // 多边形围栏顶点
  final bool isActive;
  final GeofenceAlertType alertType; // 报警设置
  final DateTime createdAt;

  const GeofenceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.center,
    this.radius = 100.0,
    this.vertices = const [],
    this.isActive = true,
    this.alertType = GeofenceAlertType.both, // 默认进出都报警
    required this.createdAt,
  });

  /// 创建圆形围栏
  factory GeofenceModel.circle({
    required String id,
    required String name,
    required LocationPoint center,
    required double radius,
    bool isActive = true,
    GeofenceAlertType alertType = GeofenceAlertType.both,
  }) {
    return GeofenceModel(
      id: id,
      name: name,
      type: GeofenceType.circle,
      center: center,
      radius: radius,
      isActive: isActive,
      alertType: alertType,
      createdAt: DateTime.now(),
    );
  }

  /// 创建多边形围栏
  factory GeofenceModel.polygon({
    required String id,
    required String name,
    required List<LocationPoint> vertices,
    bool isActive = true,
    GeofenceAlertType alertType = GeofenceAlertType.both,
  }) {
    // 计算中心点
    final centerLat = vertices.map((p) => p.latitude).reduce((a, b) => a + b) / vertices.length;
    final centerLng = vertices.map((p) => p.longitude).reduce((a, b) => a + b) / vertices.length;
    
    return GeofenceModel(
      id: id,
      name: name,
      type: GeofenceType.polygon,
      center: LocationPoint(latitude: centerLat, longitude: centerLng),
      vertices: vertices,
      isActive: isActive,
      alertType: alertType,
      createdAt: DateTime.now(),
    );
  }

  GeofenceModel copyWith({
    String? id,
    String? name,
    GeofenceType? type,
    LocationPoint? center,
    double? radius,
    List<LocationPoint>? vertices,
    bool? isActive,
    GeofenceAlertType? alertType,
    DateTime? createdAt,
  }) {
    return GeofenceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      vertices: vertices ?? this.vertices,
      isActive: isActive ?? this.isActive,
      alertType: alertType ?? this.alertType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'center': center.toMap(),
      'radius': radius,
      'vertices': vertices.map((v) => v.toMap()).toList(),
      'isActive': isActive,
      'alertType': alertType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GeofenceModel.fromMap(Map<String, dynamic> map) {
    return GeofenceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: GeofenceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => GeofenceType.circle,
      ),
      center: LocationPoint.fromMap(map['center'] ?? {}),
      radius: map['radius']?.toDouble() ?? 100.0,
      vertices: (map['vertices'] as List<dynamic>?)
          ?.map((v) => LocationPoint.fromMap(v))
          .toList() ?? [],
      isActive: map['isActive'] ?? true,
      alertType: GeofenceAlertType.values.firstWhere(
        (e) => e.name == map['alertType'],
        orElse: () => GeofenceAlertType.both,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// 地理围栏事件
class GeofenceEvent {
  final String geofenceId;
  final String geofenceName;
  final GeofenceStatus status;
  final LocationPoint currentLocation;
  final DateTime timestamp;

  const GeofenceEvent({
    required this.geofenceId,
    required this.geofenceName,
    required this.status,
    required this.currentLocation,
    required this.timestamp,
  });

  String get statusText => status.displayName;

  Map<String, dynamic> toMap() {
    return {
      'geofenceId': geofenceId,
      'geofenceName': geofenceName,
      'status': status.name,
      'currentLocation': currentLocation.toMap(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GeofenceEvent.fromMap(Map<String, dynamic> map) {
    return GeofenceEvent(
      geofenceId: map['geofenceId'] ?? '',
      geofenceName: map['geofenceName'] ?? '',
      status: GeofenceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GeofenceStatus.outside,
      ),
      currentLocation: LocationPoint.fromMap(map['currentLocation'] ?? {}),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
} 