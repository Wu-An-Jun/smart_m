import 'dart:async';
import 'package:fl_amap/fl_amap.dart';
import '../models/geofence_model.dart';

/// 高德地图地理围栏服务
/// 使用 fl_amap 插件实现地理围栏功能
class AMapGeofenceService {
  // 单例模式
  static final AMapGeofenceService _instance = AMapGeofenceService._internal();
  factory AMapGeofenceService() => _instance;
  AMapGeofenceService._internal();

  // 围栏事件流控制器
  final StreamController<GeofenceEvent> _eventController =
      StreamController<GeofenceEvent>.broadcast();

  // 本地缓存的围栏列表
  final List<GeofenceModel> _localGeofences = [];

  // 围栏状态映射表
  final Map<String, GeofenceStatus> _previousStates = {};

  /// 围栏事件流
  Stream<GeofenceEvent> get events => _eventController.stream;

  /// 当前围栏列表
  List<GeofenceModel> get geofences => List.unmodifiable(_localGeofences);

  /// 初始化围栏服务
  Future<bool> initialize() async {
    try {
      // 初始化高德地图围栏服务，设置触发动作为停留
      final result = await FlAMapGeoFence().initialize(GeoFenceActivateAction.stayed);
      
      // 添加围栏监听器
      _setupListeners();
      
      print('🏠 高德地图围栏服务初始化${result ? '成功' : '失败'}');
      return result;
    } catch (e) {
      print('🏠 高德地图围栏服务初始化失败: $e');
      return false;
    }
  }

  /// 设置监听器
  void _setupListeners() {
    FlAMapGeoFence().start(onGeoFenceChanged: (result) {
      if (result != null) {
        _handleStatusChanged(result);
      }
    });
  }

  /// 处理围栏状态变化
  void _handleStatusChanged(AMapGeoFenceStatusModel result) {
    // 获取围栏ID和状态
    final customID = result.customID;
    final status = _convertStatus(result.status);
    
    // 查找本地围栏
    final fence = _localGeofences.firstWhere(
      (f) => f.id == customID,
      orElse: () => GeofenceModel.circle(
        id: customID ?? 'unknown',
        name: '未知围栏',
        center: const LocationPoint(latitude: 0, longitude: 0),
        radius: 0,
      ),
    );

    // 获取之前的状态
    final previousStatus = _previousStates[customID] ?? GeofenceStatus.outside;
    
    // 更新状态
    _previousStates[customID ?? 'unknown'] = status;
    
    // 创建事件
    final event = GeofenceEvent(
      geofenceId: customID ?? 'unknown',
      geofenceName: fence.name,
      status: status,
      currentLocation: LocationPoint(
        latitude: result.fence?.center?.latitude ?? 0,
        longitude: result.fence?.center?.longitude ?? 0,
      ),
      timestamp: DateTime.now(),
    );
    
    // 发送事件
    _eventController.add(event);
    print('🔔 地理围栏状态变化: ${fence.name} - ${status.displayName}');
  }

  /// 转换高德围栏状态到应用状态
  GeofenceStatus _convertStatus(GenFenceStatus status) {
    switch (status) {
      case GenFenceStatus.inside:
        return GeofenceStatus.inside;
      case GenFenceStatus.outside:
        return GeofenceStatus.outside;
      case GenFenceStatus.stayed:
        return GeofenceStatus.inside;
      case GenFenceStatus.none:
      case GenFenceStatus.locFailed:
      default:
        return GeofenceStatus.outside;
    }
  }

  /// 添加围栏
  Future<bool> addGeofence(GeofenceModel geofence) async {
    bool result = false;
    
    try {
      switch (geofence.type) {
        case GeofenceType.circle:
          // 添加圆形围栏
          final response = await FlAMapGeoFence().addCircle(
            latLng: LatLng(geofence.center.latitude, geofence.center.longitude),
            radius: geofence.radius,
            customID: geofence.id,
          );
          result = response != null;
          break;
        case GeofenceType.polygon:
          // 添加多边形围栏
          final latLngs = geofence.vertices.map((vertex) {
            return LatLng(vertex.latitude, vertex.longitude);
          }).toList();
          
          final response = await FlAMapGeoFence().addCustom(
            latLng: latLngs,
            customID: geofence.id,
          );
          result = response != null;
          break;
      }
      
      // 如果添加成功，保存到本地列表
      if (result) {
        _localGeofences.add(geofence);
        _previousStates[geofence.id] = GeofenceStatus.outside;
        print('🏠 围栏已添加: ${geofence.name} (总数: ${_localGeofences.length})');
      }
      
      return result;
    } catch (e) {
      print('🏠 添加围栏失败: $e');
      return false;
    }
  }

  /// 移除围栏
  Future<bool> removeGeofence(String geofenceId) async {
    try {
      final result = await FlAMapGeoFence().remove(customID: geofenceId);
      if (result) {
        _localGeofences.removeWhere((fence) => fence.id == geofenceId);
        _previousStates.remove(geofenceId);
      }
      return result;
    } catch (e) {
      print('🏠 移除围栏失败: $e');
      return false;
    }
  }

  /// 清空所有围栏
  Future<bool> clearGeofences() async {
    try {
      final result = await FlAMapGeoFence().remove();
      if (result) {
        _localGeofences.clear();
        _previousStates.clear();
      }
      return result;
    } catch (e) {
      print('🏠 清空围栏失败: $e');
      return false;
    }
  }

  /// 获取围栏信息
  GeofenceModel? getGeofence(String geofenceId) {
    try {
      return _localGeofences.firstWhere((fence) => fence.id == geofenceId);
    } catch (e) {
      return null;
    }
  }

  /// 创建测试围栏
  Future<void> createTestGeofences(double latitude, double longitude) async {
    await clearGeofences();

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

    await addGeofence(circleGeofence1);
    await addGeofence(circleGeofence2);
    await addGeofence(polygonGeofence);
  }

  /// 暂停围栏监听
  Future<bool> pauseGeofence([String? customId]) async {
    try {
      return await FlAMapGeoFence().pause(customID: customId);
    } catch (e) {
      print('🏠 暂停围栏监听失败: $e');
      return false;
    }
  }

  /// 开始围栏监听
  Future<bool> startGeofence() async {
    try {
      return await FlAMapGeoFence().start(onGeoFenceChanged: (result) {
        if (result != null) {
          _handleStatusChanged(result);
        }
      });
    } catch (e) {
      print('🏠 开始围栏监听失败: $e');
      return false;
    }
  }

  /// 获取所有围栏信息
  Future<List<AMapGeoFenceModel>> getAllFences() async {
    try {
      return await FlAMapGeoFence().getAll();
    } catch (e) {
      print('🏠 获取围栏信息失败: $e');
      return [];
    }
  }

  /// 销毁服务
  Future<void> dispose() async {
    await FlAMapGeoFence().dispose();
    _eventController.close();
  }
} 