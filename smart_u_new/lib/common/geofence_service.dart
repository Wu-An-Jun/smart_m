import 'dart:async';
import 'dart:math';

import '../models/geofence_model.dart';

/// 地理围栏服务
/// 负责管理地理围栏的创建、检测和事件通知
class GeofenceService {
  // 单例模式
  static final GeofenceService _instance = GeofenceService._internal();
  factory GeofenceService() => _instance;
  GeofenceService._internal();

  final List<GeofenceModel> _geofences = [];
  final StreamController<GeofenceEvent> _eventController =
      StreamController<GeofenceEvent>.broadcast();

  // 重新添加状态跟踪以防止重复事件
  final Map<String, GeofenceStatus> _previousStates = {};

  /// 围栏事件流
  Stream<GeofenceEvent> get events => _eventController.stream;

  /// 当前围栏列表
  List<GeofenceModel> get geofences => List.unmodifiable(_geofences);

  /// 添加围栏
  void addGeofence(GeofenceModel geofence) {
    _geofences.add(geofence);
    // 初始化状态为外部
    _previousStates[geofence.id] = GeofenceStatus.outside;
    print('🏠 围栏已添加: ${geofence.name} (总数: ${_geofences.length})');
  }

  /// 移除围栏
  void removeGeofence(String geofenceId) {
    _geofences.removeWhere((fence) => fence.id == geofenceId);
    _previousStates.remove(geofenceId);
  }

  /// 清空所有围栏
  void clearGeofences() {
    _geofences.clear();
    _previousStates.clear();
  }

  /// 获取围栏信息
  GeofenceModel? getGeofence(String geofenceId) {
    try {
      return _geofences.firstWhere((fence) => fence.id == geofenceId);
    } catch (e) {
      return null;
    }
  }

  /// 创建测试围栏
  void createTestGeofences(double latitude, double longitude) {
    clearGeofences();

    // 创建圆形测试围栏
    final circleGeofence1 = GeofenceModel.circle(
      id: 'test_circle_1',
      name: '家庭围栏',
      center: LocationPoint(
        latitude: latitude + 0.001,
        longitude: longitude + 0.001,
      ),
      radius: 150.0,
    );

    final circleGeofence2 = GeofenceModel.circle(
      id: 'test_circle_2',
      name: '公司围栏',
      center: LocationPoint(
        latitude: latitude - 0.002,
        longitude: longitude - 0.002,
      ),
      radius: 200.0,
    );

    // 创建多边形测试围栏
    final polygonVertices = [
      LocationPoint(latitude: latitude + 0.003, longitude: longitude - 0.001),
      LocationPoint(latitude: latitude + 0.004, longitude: longitude + 0.001),
      LocationPoint(latitude: latitude + 0.002, longitude: longitude + 0.003),
      LocationPoint(latitude: latitude + 0.001, longitude: longitude + 0.002),
    ];

    final polygonGeofence = GeofenceModel.polygon(
      id: 'test_polygon_1',
      name: '学校围栏',
      vertices: polygonVertices,
    );

    addGeofence(circleGeofence1);
    addGeofence(circleGeofence2);
    addGeofence(polygonGeofence);
  }

  /// 检查当前位置是否触发围栏事件
  void checkLocation(double latitude, double longitude) {
    print(
      "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++",
    );
    final currentLocation = LocationPoint(
      latitude: latitude,
      longitude: longitude,
    );

    for (final geofence in _geofences) {
      if (!geofence.isActive) continue;

      final isInside = _isLocationInsideGeofence(currentLocation, geofence);
      final currentStatus =
          isInside ? GeofenceStatus.inside : GeofenceStatus.outside;
      final previousStatus =
          _previousStates[geofence.id] ?? GeofenceStatus.outside;

      // 调试日志：位置检查信息
      print('🔍 地理围栏检查: ${geofence.name}');
      print(
        '   位置: (${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)})',
      );
      print('   当前状态: ${currentStatus.displayName}');
      print('   之前状态: ${previousStatus.displayName}');
      print('   状态变化: ${previousStatus != currentStatus ? "是" : "否"}');

      // 只在状态发生变化时才发送事件
      if (previousStatus != currentStatus) {
        GeofenceStatus eventStatus;

        if (previousStatus == GeofenceStatus.outside &&
            currentStatus == GeofenceStatus.inside) {
          // 从外部进入围栏
          eventStatus = GeofenceStatus.enter;
        } else if (previousStatus == GeofenceStatus.inside &&
            currentStatus == GeofenceStatus.outside) {
          // 从内部离开围栏
          eventStatus = GeofenceStatus.exit;
        } else {
          // 其他状态变化（正常情况下不应该发生）
          eventStatus = currentStatus;
        }

        // 更新状态
        _previousStates[geofence.id] = currentStatus;

        // 发送事件
        final event = GeofenceEvent(
          geofenceId: geofence.id,
          geofenceName: geofence.name,
          status: eventStatus,
          currentLocation: currentLocation,
          timestamp: DateTime.now(),
        );

        _eventController.add(event);
        print('🔔 地理围栏状态变化: ${geofence.name} - ${eventStatus.displayName}');
      }
    }
  }

  /// 检查位置是否在围栏内
  bool _isLocationInsideGeofence(
    LocationPoint location,
    GeofenceModel geofence,
  ) {
    switch (geofence.type) {
      case GeofenceType.circle:
        return _isLocationInsideCircle(
          location,
          geofence.center,
          geofence.radius,
        );
      case GeofenceType.polygon:
        return _isLocationInsidePolygon(location, geofence.vertices);
    }
  }

  /// 检查位置是否在圆形围栏内
  bool _isLocationInsideCircle(
    LocationPoint location,
    LocationPoint center,
    double radius,
  ) {
    final distance = _calculateDistance(location, center);
    return distance <= radius;
  }

  /// 检查位置是否在多边形围栏内（射线投射算法）
  bool _isLocationInsidePolygon(
    LocationPoint location,
    List<LocationPoint> vertices,
  ) {
    if (vertices.length < 3) return false;

    int intersectionCount = 0;
    final x = location.longitude;
    final y = location.latitude;

    for (int i = 0; i < vertices.length; i++) {
      final j = (i + 1) % vertices.length;
      final xi = vertices[i].longitude;
      final yi = vertices[i].latitude;
      final xj = vertices[j].longitude;
      final yj = vertices[j].latitude;

      if (((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi)) {
        intersectionCount++;
      }
    }

    return intersectionCount % 2 == 1;
  }

  /// 计算两点间距离（米）
  double _calculateDistance(LocationPoint point1, LocationPoint point2) {
    const double earthRadius = 6371000; // 地球半径（米）

    final double lat1Rad = point1.latitude * pi / 180;
    final double lat2Rad = point2.latitude * pi / 180;
    final double deltaLatRad = (point2.latitude - point1.latitude) * pi / 180;
    final double deltaLngRad = (point2.longitude - point1.longitude) * pi / 180;

    final double a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLngRad / 2) *
            sin(deltaLngRad / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// 销毁服务
  void dispose() {
    _eventController.close();
  }
}
